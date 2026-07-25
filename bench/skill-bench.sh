#!/usr/bin/env bash
# skill-bench.sh — chama o agente, você VÊ ele fazer a tarefa COM a skill, depois
# SEM a skill, e no fim recebe o benchmark real (custo/tokens/turnos) lado a lado.
#
# Uso:
#   ./bench/skill-bench.sh <skill> <arquivo-prompt> [runs] [modelo] [baseline]
#
# Ex. (criar um endpoint E2E, verificando se compila):
#   VERIFY_CMD="dotnet build -clp:ErrorsOnly" \
#     ./bench/skill-bench.sh criar-endpoint bench/spec-endpoint.txt 1 opus main
#
#   <skill>   pasta em .claude/skills/<skill> — a skill que você quer medir
#   <prompt>  arquivo com a tarefa; a MESMA vai pros dois lados (é o controle)
#   runs      rodadas por lado (default 1, pra assistir; use 2-3 pra média confiável)
#   modelo    mesmo nos dois lados (default opus)
#   baseline  commit/branch limpo de onde cada rodada parte (default HEAD)
#   VERIFY_CMD (env) comando que diz se o resultado presta: "dotnet build"/"dotnet test".
#              Sem isso, "sem skill custou menos" pode ser mentira (não compilou).
#
# Isolamento: cria UM worktree git descartável. Antes de cada rodada volta ao baseline
# (reset --hard + clean), então a rodada 2 nunca vê o que a 1 criou. Seu repo não é tocado.
# No lado "sem", renomeia a pasta da skill (o reset da rodada seguinte desfaz sozinho).
#
# Requisitos: a skill precisa estar COMITADA em .claude/skills/. Se for skill de
# usuário (~/.claude/skills), troque o `mv` por --disable-slash-commands no lado "sem".
# ⚠️ Roda com bypassPermissions (por isso o worktree) e pode custar $1-5/rodada no Opus.
set -euo pipefail

command -v jq  >/dev/null || { echo "precisa de jq";  exit 1; }
command -v claude >/dev/null || { echo "precisa do claude na PATH"; exit 1; }

SKILL="${1:?pasta da skill em .claude/skills/}"
PROMPT_FILE="${2:?arquivo com a tarefa}"
RUNS="${3:-1}"
MODEL="${4:-opus}"
BASELINE="${5:-HEAD}"
VERIFY_CMD="${VERIFY_CMD:-}"

BASE_SHA="$(git rev-parse "$BASELINE")"
PROMPT="$(cat "$PROMPT_FILE")"
SKILL_DIR=".claude/skills/$SKILL"
WORK="$(mktemp -d)"; WT="$WORK/wt"
RESULTS="$(mktemp)"

git worktree add --force --detach "$WT" "$BASE_SHA" >/dev/null
cleanup(){ git worktree remove --force "$WT" 2>/dev/null || true; rm -rf "$WORK" "$RESULTS"; }
trap cleanup EXIT

B=$'\e[1m'; DIM=$'\e[2m'; CY=$'\e[36m'; Z=$'\e[0m'

pristine(){ git -C "$WT" reset --hard "$BASE_SHA" >/dev/null; git -C "$WT" clean -fd >/dev/null; }

# formatter: NDJSON do stream -> linhas legíveis, ao vivo
LIVE='
if .type=="assistant" then (.message.content[]? |
    if .type=="text" and (.text|length>0) then "  "+.text
    elif .type=="tool_use" then "  [36m→ "+.name+"[0m "+((.input|tostring)[0:88])
    else empty end)
elif .type=="user" then (.message.content[]? |
    if .type=="tool_result" then "  [2m  ↳ ok[0m" else empty end)
else empty end'

run_arm(){
  local arm="$1" i="$2" raw="$WORK/${arm}-${i}.ndjson"
  pristine
  [ "$arm" = "sem" ] && mv "$WT/$SKILL_DIR" "$WT/${SKILL_DIR}.off"

  echo; echo "${B}━━━ [${arm} skill] rodada ${i}/${RUNS} ━━━${Z}"
  ( cd "$WT" && claude -p "$PROMPT" \
        --output-format stream-json --verbose --model "$MODEL" \
        --permission-mode bypassPermissions --no-session-persistence ) \
    | tee "$raw" \
    | jq -r --unbuffered "$LIVE" 2>/dev/null || true

  local verify="skip"
  if [ -n "$VERIFY_CMD" ]; then
    ( cd "$WT" && eval "$VERIFY_CMD" ) >/dev/null 2>&1 && verify="pass" || verify="FAIL"
  fi

  grep '"type":"result"' "$raw" | tail -1 \
    | jq -c --arg arm "$arm" --arg v "$verify" '{arm:$arm,verify:$v,
        cost:.total_cost_usd,turns:.num_turns,ms:.duration_ms,
        out:.usage.output_tokens,cread:.usage.cache_read_input_tokens}' >> "$RESULTS"

  local last; last="$(tail -1 "$RESULTS")"
  echo "${DIM}  ✔ \$$(echo "$last"|jq .cost) · $(echo "$last"|jq .turns) turns · verify=${verify}${Z}"
}

for i in $(seq 1 "$RUNS"); do run_arm com "$i"; done
for i in $(seq 1 "$RUNS"); do run_arm sem "$i"; done

echo; echo "${B}═══ benchmark (média de ${RUNS}) ═══${Z}"
jq -rs '
  group_by(.arm)[] | {arm:.[0].arm,n:length,
    cost:(map(.cost)|add/length),turns:(map(.turns)|add/length),
    out:(map(.out)|add/length),cread:(map(.cread)|add/length),
    pass:(map(select(.verify=="pass"))|length),sec:(map(.ms)|add/length/1000)}
  | "\(.arm)\t$\((.cost*100|round)/100)\tturns \((.turns*10|round)/10)\tout \(.out|round)\tcread \(.cread|round)\tok \(.pass)/\(.n)\t\((.sec*10|round)/10)s"
' "$RESULTS" | column -t -s $'\t'

jq -rs '
  (map(select(.arm=="com"))) as $C | (map(select(.arm=="sem"))) as $S |
  (($C|map(.cost)|add/length)) as $cc | (($S|map(.cost)|add/length)) as $sc |
  (($C|map(.turns)|add/length)) as $ct | (($S|map(.turns)|add/length)) as $st |
  "\nveredito: sem a skill custou \((($sc-$cc)/$cc*100)|round)% a mais e \(($st-$ct)|round) turns a mais."
' "$RESULTS"
