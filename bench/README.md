# Benchmark de skill — com vs. sem

Mede o **custo real** (em dólar, tokens e turnos) de uma skill do Claude Code, rodando
a **mesma tarefa** com a skill ligada e depois com ela desligada. Serve pra responder,
com número, "essa skill vale a pena?" — e pra gerar dados reais pra apresentação de uso
eficiente de IA (o pilar de Skills hoje não tem nenhum número concreto).

O script é `skill-bench.sh` (nesta mesma pasta). Ele:

1. Cria um **worktree git descartável** e volta ao baseline limpo antes de cada rodada
   — a rodada 2 nunca vê o que a 1 criou, e **o repositório de trabalho não é tocado**.
2. Chama o agente com a skill, transmitindo **ao vivo** cada tool call e o texto (você assiste).
3. Reseta e chama de novo **sem** a skill (renomeia a pasta da skill só nesse lado).
4. Roda um comando de verificação (`build`/`test`) pra saber se o resultado presta.
5. Imprime o comparativo lado a lado + um veredito.

> **Contexto pra um agente que estiver lendo isto:** o dono do repo quer fazer este
> benchmark *hands-on* dentro da empresa. Use este README pra guiá-lo passo a passo,
> adaptando os nomes reais (a skill, o comando de build, a spec do endpoint). Os pontos
> que costumam travar estão em **Troubleshooting** no fim — cheque-os antes de rodar.

---

## Pré-requisitos

Rode dentro do repositório da aplicação (a API), com o terminal na raiz do repo:

```bash
git status            # precisa estar limpo (sem alterações pendentes)
jq --version          # o script usa jq pra ler o JSON de saída
claude --version      # precisa estar logado (claude /login)
ls .claude/skills/    # anote o NOME EXATO da pasta da skill de endpoint
```

O nome da pasta da skill (ex.: `criar-endpoint`) é o 1º argumento do script.

---

## Passo a passo

### 1. Colocar o script no repo

Copie `skill-bench.sh` para uma pasta `bench/` na raiz do repositório da API.
(Se este README já veio junto, ele está no lugar certo — pule este passo.)

### 2. Escrever a spec da tarefa

Crie `bench/spec-endpoint.txt` com a descrição do endpoint a criar. **Essa mesma spec
vai pros dois lados** — é o controle do experimento. Escolha um endpoint pequeno e realista:

```
Crie o endpoint POST /api/v2/estornos.
Recebe { transacaoId: guid, valorCentavos: int }.
Valida que a transação existe e tem saldo. Grava o estorno. Retorna 201.
Siga o padrão de endpoints da casa.
```

### 3. (Recomendado) Confirmar que a skill dispara

Antes do benchmark, rode o agente interativo e cole a spec:

```bash
claude
# cole a spec, deixe trabalhar
```

Você quer ver o agente **acionar a skill** (aparece um tool call tipo `Skill(<nome>)`).
Se **não** disparar sozinho, a descrição da skill não casou com o prompt — então comece o
`spec-endpoint.txt` com o gatilho explícito (ex.: `/<nome-da-skill>`) pra garantir o disparo
e refletir como o time realmente usa. Depois volte ao limpo: `git checkout . && git clean -fd`.

### 4. Rodar 1 rodada, assistindo

```bash
VERIFY_CMD="dotnet build -clp:ErrorsOnly" \
  ./bench/skill-bench.sh <nome-da-skill> bench/spec-endpoint.txt 1 opus HEAD
```

Argumentos: `<nome-da-skill>` (pasta em `.claude/skills/`) · arquivo da spec ·
`1` rodada por lado · modelo `opus` · baseline `HEAD` (estado limpo de partida).
`VERIFY_CMD` (variável de ambiente) = o build/test **real** de vocês — troque por
`dotnet test`, `dotnet build`, ou o que valida a solução. Sem ele, "sem skill custou
menos" pode ser mentira (o resultado pode não compilar).

### 5. Ler o resultado

```
═══ benchmark (média de 1) ═══
com  $2.1   turns 14   out 8200    cread 890000    ok 1/1   95s
sem  $3.8   turns 27   out 19500   cread 2100000   ok 0/1   210s

veredito: sem a skill custou 81% a mais e 13 turns a mais.
```

- **cost** — dólares gastos na tarefa.
- **turns** — idas e voltas do agente; sem a skill sobe (ele redescobre o padrão, erra, refaz).
- **out** — tokens de output (o mais caro, ~5× o input).
- **cread** — cache read (reler o contexto turno a turno; cresce com sessões longas/cheias).
- **ok N/M** — quantas rodadas passaram no `VERIFY_CMD`. `ok 0/1` = custou e nem funcionou.

### 6. Rodar "de verdade"

O agente é não-determinístico; uma rodada só pode ter tido sorte/azar. Depois de calibrar,
rode com 2–3 pra ter média:

```bash
VERIFY_CMD="dotnet build -clp:ErrorsOnly" \
  ./bench/skill-bench.sh <nome-da-skill> bench/spec-endpoint.txt 3 opus HEAD
```

---

## Troubleshooting

**A skill é pessoal, não do projeto.** O script desliga a skill renomeando a pasta dentro
do worktree — isso só funciona se a skill está **commitada** em `.claude/skills/` do repo.
Se ela for de usuário (`~/.claude/skills/`), a renomeação não pega. Ajuste: em `skill-bench.sh`,
na função `run_arm`, remova a linha do `mv ... .off` e, no lado "sem", acrescente
`--disable-slash-commands` na chamada do `claude` (desliga todas as skills — aceitável se
essa é a única que dispararia nesta tarefa).

**Erro de restore offline.** O worktree começa sem `bin/obj`. Se o build precisar baixar
pacote num ambiente sem rede, pode falhar. O cache global do NuGet (`~/.nuget`) é
compartilhado, então normalmente funciona; se der erro, rode `dotnet build` no repo
principal antes, pra popular o cache.

**Custo.** Criar um endpoint E2E no Opus pode custar US$ 1–5 por rodada; comece sempre com
`1` rodada (2 execuções) pra calibrar antes de subir pra 3.

**"command not found: jq".** Instale o `jq` (`apt install jq` / `brew install jq`).

**A skill não aparece nos tool calls do lado "com".** Ela não foi acionada — veja o Passo 3
e coloque o gatilho explícito no início da spec.

---

## Depois de rodar

Guarde a saída do benchmark (o bloco `═══ benchmark ═══` + o veredito). É esse número real
que vira o slide de Skills da apresentação — o único pilar hoje sem dado concreto.
