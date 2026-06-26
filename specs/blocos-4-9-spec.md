# Especificação — Blocos 4 a 9 + Playbook

> **Para quem executa (Sonnet):** este documento é o roteiro de produção dos slides
> restantes da apresentação "IA com Eficiência". Os blocos 1–3 já estão prontos em
> `slides.md`. Sua tarefa é transformar cada bloco abaixo em slides Slidev seguindo as
> **convenções visuais já estabelecidas** (seção logo abaixo). O conteúdo técnico e a
> narração já estão definidos aqui — produza os slides quase mecanicamente, sem reinventar
> a substância.
>
> **Para o João (ajuste fino no banco):** todos os pontos marcados com `<<EXEMPLO REAL: ...>>`
> são lacunas para você preencher com material dos projetos reais do banco. Os exemplos
> genéricos que deixei funcionam como fallback caso você não troque algum.

---

## Convenções visuais já estabelecidas (leia antes de produzir)

Extraídas dos blocos 1–3 de `slides.md`. **Replique exatamente estes padrões** para manter
coesão visual:

- **Tema:** `seriph`. Transições: `slide-left` (global), `fade-out` em alguns dividers.
- **Divisor de seção:** frontmatter `layout: section`, com `# N. Título` e uma linha de
  subtítulo em texto normal logo abaixo.
- **Slide de punchline / frase de impacto:** `layout: center` + `class: text-center`, frase
  grande com `text-3xl font-bold` e fechamento opcional em `text-xl opacity-80`.
- **Revelação progressiva:** use `<v-clicks>` para listas e `<v-click>` para blocos isolados
  (callouts, segunda coluna de comparação). Padrão consagrado: o lado "❌ antes" aparece de
  imediato, o lado "✅ depois" entra com `v-click`.
- **Cards de comparação (antes/depois):** grid de 2 colunas
  `<div class="grid grid-cols-2 gap-6 pt-2">`, card ruim com
  `border border-red-400 rounded-lg p-4` e título `### ❌ Antes`, card bom com
  `border border-green-500 rounded-lg p-4` e título `### ✅ Depois`. Blocos de código dentro
  dos cards; comentário explicativo em `text-sm opacity-80`.
- **Comparação genérica de 2 colunas (não-código):** `grid grid-cols-2 gap-8` com `###`
  como cabeçalho de cada coluna (ver "imposto da redescoberta" no bloco 2).
- **Mermaid:** sempre horizontal (`flowchart LR`) quando couber, escala pequena
  (`{scale: 0.6}` a `{scale: 0.8}` — caixas com muito texto exigem escala menor para não
  cortar na direita). Vermelho = desperdício (`fill:#fee,stroke:#c33`), verde = bom
  (`fill:#efe,stroke:#3a3`). **Teste sempre se o último nó não corta** rodando o dev server
  e tirando screenshot.
- **Callout de destaque:** `<div class="pt-6 text-center text-xl">` ou bloco `>` (blockquote).
- **Idioma:** português do Brasil, tom humilde e prático (não professoral).

**Fluxo de produção sugerido:** preencher um bloco → `npm run dev` → screenshot via Playwright
(ver histórico do projeto: usa `/usr/bin/google-chrome`, `node_modules/playwright`, porta 3030)
→ conferir que Mermaid e cards não cortam → ajustar escala se necessário.

---

## Orçamento de tempo (1h, ~10 min de Q&A)

Bloco 3 termina por volta dos **26 min**. Daí em diante:

| Bloco | Tema | Janela | Duração |
|---|---|---|---|
| 4 | CLAUDE.md hierárquico | 26–35 | 9 min |
| 5 | Skills | 35–40 | 5 min |
| 6 | Higiene de sessão | 40–43 | 3 min |
| 7 | MCPs — poder e tradeoffs | 43–49 | 6 min |
| 8 | Sub-agents | 49–53 | 4 min |
| 9 | Roteamento de modelo | 53–60 | 7 min |
| — | Playbook (slide-resumo, transição rápida) | encavalado no fim | 1 min |
| — | Q&A | sobra / estouro controlado | ~7–10 min |

> A ordem das **seções** segue o sumário já fixado em `slides.md`
> (6 = MCPs, 7 = Sub-agents, 8 = Roteamento). Mantenha essa numeração nos `# N.` dos
> divisores — não renumere.

---

# BLOCO 4 — CLAUDE.md hierárquico (seção "3. Pilar 2")

**Objetivo (a única coisa que devem lembrar):** o CLAUDE.md mata o "imposto da redescoberta"
do bloco 2 — mas só funciona se for **enxuto e em camadas**, porque ele é recarregado a cada
sessão (logo, é contexto que você paga sempre).

**Conexão com o bloco 2:** este bloco é o pagamento da promessa feita lá. Reabra com "lembram
do imposto da redescoberta? Aqui está como a gente não paga mais."

### Slides

**4.1 — Divisor de seção**
- `layout: section`
- `# 3. Pilar 2 — CLAUDE.md hierárquico`
- Subtítulo: "O agente já chega sabendo onde as coisas estão"

**4.2 — O que é o CLAUDE.md (e por que ele resolve o pedágio)**
- Título: `# O mapa que o agente lê antes de começar`
- Texto curto: "Um arquivo Markdown que o Claude carrega **automaticamente** no início da
  sessão. É a memória persistente do projeto — escrita uma vez, lida sempre."
- `<v-clicks>` com 3 itens:
  - O que o projeto **é** (domínio, arquitetura em uma frase)
  - **Onde** as coisas estão (estrutura, pastas que importam)
  - **Como** se faz aqui (convenções, comandos de build/test, regras de "não faça")
- `<v-click>` callout: "Sem isso, cada tarefa começa do zero (o pedágio do bloco 2). Com isso,
  começa do mapa."

**4.3 — A hierarquia (o coração do bloco)**
- Título: `# Camadas: do geral ao específico`
- Mermaid vertical curto OU diagrama de caixas aninhadas mostrando os níveis. Sugestão de
  Mermaid (`flowchart TD`, escala ~0.7):
  ```
  ~/.claude/CLAUDE.md   → suas preferências, vale pra TODO projeto
        ↓
  <raiz>/CLAUDE.md      → o que a solução é, visão geral da API
        ↓
  api/CLAUDE.md · application/CLAUDE.md · infrastructure/CLAUDE.md
                        → detalhes de cada camada
  ```
- Callout com a **regra de ouro**: "O arquivo **mais próximo** do que você está editando
  vence / complementa. Trabalhando em `infrastructure/`? O Claude puxa o CLAUDE.md de lá
  junto com o da raiz."
- `<<EXEMPLO REAL: substituir os nomes api/application/infrastructure pela estrutura real da
  solução do banco, e mostrar 2–3 linhas verdadeiras do CLAUDE.md da raiz — só o cabeçalho
  que descreve o que a API faz.>>`

**4.4 — O que vai em cada nível (tabela mental)**
- Título: `# O que escrever onde`
- Grid de 2 colunas OU tabela:
  - **Raiz da solução:** "Esta API faz X. Stack: Y. Build: `cmd`. Test: `cmd`. Padrão de
    branch/commit. Onde NÃO mexer."
  - **Subprojeto (api/application/infra):** convenções locais, padrões de camada, gotchas
    específicos ("repositório usa Dapper, não EF", etc.)
- `<<EXEMPLO REAL: trocar pelos comandos e convenções reais — o comando de build do banco, o
  padrão de nomenclatura que o time usa.>>`

**4.5 — O equilíbrio que quase todo mundo erra (slide-chave de eficiência)**
- Título: `# Rico o bastante, enxuto o bastante`
- Aqui está a tensão de eficiência — **não pule este slide**, é o que conecta CLAUDE.md ao
  tema de tokens:
- Grid 2 colunas (❌ vermelho / ✅ verde, reaproveitando o padrão de cards):
  - ❌ "CLAUDE.md gigante": despeja o README inteiro, histórico, tudo → **imposto invertido**:
    agora você paga esse contexto **todo turno, toda sessão, todo dev**.
  - ✅ "CLAUDE.md de alto sinal": bullets curtos, comandos, ponteiros ("detalhes de auth em
    `docs/auth.md`") → o agente sabe onde buscar quando precisar, sem carregar tudo sempre.
- Callout: "O CLAUDE.md é imposto fixo: cobrado em toda sessão. Mantenha-o como um índice, não
  como uma enciclopédia."

**4.6 — Como começar (prático, baixa fricção)**
- Título: `# Começar é barato`
- `<v-clicks>`:
  - Rode `/init` — o Claude gera um rascunho lendo o projeto
  - Edite: corte o ruído, adicione os comandos e as 3–4 regras de "não faça"
  - Commite junto com o código — é contexto **compartilhado pelo time** (todo dev se beneficia)
  - Refine quando notar o agente "redescobrindo" algo: aquilo virou linha no CLAUDE.md
- Callout de fechamento: "Cada redescoberta que você vê é um candidato a virar uma linha aqui."

### Narração rica (fala do apresentador)

> No bloco 2 a gente viu o imposto da redescoberta: sem contexto, o agente faz `grep`, abre
> cinco arquivos e deduz as convenções **toda vez**. O CLAUDE.md é como a gente para de pagar
> esse pedágio. É um Markdown que o Claude lê sozinho no começo da sessão — você não cola, não
> lembra de mandar, ele simplesmente já vem lido.
>
> A graça está na **hierarquia**. Um arquivo na raiz da solução descreve o que a API é no
> geral. Aí, dentro de cada subprojeto — no nosso caso api, application, infrastructure — um
> CLAUDE.md menor descreve as particularidades daquela camada. A regra é: o arquivo mais
> próximo do arquivo que você está editando é o que vale. Se eu estou mexendo na camada de
> infraestrutura, o Claude puxa o CLAUDE.md de infra **junto** com o da raiz. Ele compõe.
>
> Agora, o erro clássico — e isso é importante porque é sobre tokens: a tentação é despejar
> tudo no CLAUDE.md. README inteiro, histórico, decisões antigas. O problema é que esse arquivo
> é recarregado **toda sessão**. Então um CLAUDE.md inchado é imposto fixo: você paga aquele
> contexto multiplicado por cada dev, cada tarefa, cada dia. O CLAUDE.md bom é um índice de
> alto sinal — bullets curtos, os comandos, as regras de "não faça", e ponteiros para onde os
> detalhes moram. Rico o bastante pro agente não se perder, enxuto o bastante pra não pesar.
>
> Como começar? `/init` gera um rascunho. Você poda o ruído, adiciona os comandos reais, e
> commita junto com o código — porque aí vira contexto do time inteiro. E todo dia que você vir
> o agente redescobrindo alguma coisa, aquela coisa vira uma linha aqui.

---

# BLOCO 5 — Skills (seção "4. Pilar 3")

**Objetivo:** Skills são procedimentos reutilizáveis que **só custam tokens quando usados**
(divulgação progressiva). É como você tira peso do CLAUDE.md sem perder a capacidade.

**Conexão com o bloco 4:** "Se o CLAUDE.md é o que está **sempre** carregado, a Skill é o que
carrega **só quando precisa**." É o contraponto natural.

### Slides

**5.1 — Divisor de seção**
- `layout: section`
- `# 4. Pilar 3 — Skills`
- Subtítulo: "Procedimentos que só pesam quando você usa"

**5.2 — O que é uma Skill**
- Título: `# Um procedimento que o agente carrega sob demanda`
- Texto: "Uma pasta com um `SKILL.md` (nome + descrição + instruções) e, opcionalmente,
  scripts. O Claude lê a descrição, decide se é relevante, e só então carrega o conteúdo
  completo."
- `<v-clicks>`:
  - Exemplos: "fazer deploy", "gerar uma migration", "rodar o checklist de PR"
  - O agente **escolhe sozinho** quando usar, pela descrição
  - Pode embutir scripts → trabalho determinístico sai dos tokens e vira código executado

**5.3 — O truque de eficiência: divulgação progressiva (slide-chave)**
- Título: `# Por que Skills são baratas`
- Diagrama simples (2 estados) ou grid 2 colunas:
  - **Em repouso:** só o **nome + descrição** da skill estão no contexto (poucos tokens)
  - **Quando acionada:** aí sim o SKILL.md inteiro entra
- Callout: "Você pode ter 20 skills e pagar quase nada por elas até precisar de uma. Compare
  com colar o procedimento inteiro no CLAUDE.md — que pesaria sempre."

**5.4 — Skill vs CLAUDE.md (a decisão prática)**
- Título: `# Quando vira Skill, quando fica no CLAUDE.md`
- Grid 2 colunas (sem vermelho/verde aqui — é escolha, não erro):
  - **CLAUDE.md:** fato sempre-relevante do projeto (o que é, onde está, convenção geral)
  - **Skill:** procedimento ocasional, com passo a passo (deploy, scaffold, checklist)
- Regra de bolso (callout): "Se você consultaria **toda tarefa** → CLAUDE.md. Se é um
  **roteiro que você segue de vez em quando** → Skill."
- `<<EXEMPLO REAL: citar 1 procedimento real do time que seria uma boa skill — ex.: o passo a
  passo de criar um novo endpoint seguindo o padrão da casa, ou o checklist de deploy.>>`

### Narração rica

> Skill é um procedimento empacotado. Uma pastinha com um arquivo SKILL.md que tem um nome,
> uma descrição e as instruções — e, se fizer sentido, scripts junto. A diferença pro CLAUDE.md
> é **quando** isso entra no contexto.
>
> O CLAUDE.md está sempre carregado. A Skill usa uma coisa chamada divulgação progressiva: em
> repouso, só o nome e a descrição dela ocupam contexto — quase nada. O Claude lê essa
> descrição, decide se a tarefa atual precisa daquilo, e **só então** carrega o procedimento
> inteiro. Na prática isso significa que você pode ter vinte skills e pagar quase nada por elas
> até precisar de uma. Se você colasse esses mesmos vinte procedimentos no CLAUDE.md, pagaria
> tudo, toda sessão.
>
> A decisão é simples: se é um fato que você consultaria em toda tarefa — o que o projeto é,
> onde as coisas estão — isso é CLAUDE.md. Se é um roteiro que você segue de vez em quando —
> fazer deploy, criar uma migration, rodar o checklist de PR — isso é uma Skill. E quando a
> skill embute um script, melhor ainda: o trabalho determinístico sai dos tokens e vira código
> de verdade rodando.

---

# BLOCO 6 — Higiene de sessão (seção "5")

**Objetivo:** vitórias de graça. `/clear` entre tarefas e plan mode antes de tarefas grandes
zeram desperdício sem você mudar mais nada.

**Conexão com o bloco 2:** callback direto ao gráfico "contexto reenviado a cada turno". Se o
custo por turno cresce com o histórico, então **começar limpo** entre tarefas reseta a curva.

### Slides

**6.1 — Divisor de seção**
- `layout: section`
- `# 5. Higiene de sessão`
- Subtítulo: "Vitórias de eficiência que não custam nada"

**6.2 — `/clear` entre tarefas (a vitória mais barata)**
- Título: `# Uma tarefa, uma sessão`
- Reabrir o gráfico mental do bloco 2: cada turno reenvia todo o histórico. Arrastar a tarefa
  B dentro da sessão cheia da tarefa A faz a B pagar pelo contexto da A.
- `<v-clicks>`:
  - Terminou a tarefa? `/clear` antes de começar outra **não relacionada**
  - Contexto limpo = turnos baratos de novo (a curva reseta)
  - Regra: trocou de assunto, `/clear`
- Callout: "É o hábito de maior ROI por ser literalmente um comando."

**6.3 — Plan mode antes de tarefa grande**
- Título: `# Planeje antes de deixar editar`
- Texto: "No plan mode o agente **explora e propõe** um plano sem tocar no código. Você aprova,
  aí ele executa."
- Por que economiza (grid ou v-clicks):
  - Sem plano: ele tenta, erra a abordagem, refaz → tokens gastos em caminho errado
  - Com plano: você corrige a **direção** antes de qualquer edição — barato
- `<<EXEMPLO REAL (opcional): se o time tem um caso onde o agente saiu codando a coisa errada,
  esse é o slide pra mencionar de leve.>>`

**6.4 — Compactação (o seguro)**
- Título: `# Quando a sessão precisa continuar longa`
- Texto curto: "`/compact` resume a conversa e segue em frente, em vez de só inflar. O Claude
  Code também compacta sozinho perto do limite."
- Callout de fechamento do bloco: "`/clear` é o hábito; plan mode é o freio; compactação é o
  seguro. Três comandos, zero custo."

### Narração rica

> Esse bloco é o mais curto e o mais lucrativo, porque são vitórias de graça. Lembram do
> gráfico do bloco 2, o contexto sendo reenviado a cada turno? A consequência disso é que, se
> você termina uma tarefa e começa outra **na mesma sessão**, a tarefa nova paga por todo o
> histórico da anterior — que não tem nada a ver. O `/clear` resolve isso num comando: terminou,
> trocou de assunto, limpa. A curva de custo reseta. É o hábito de maior retorno justamente
> porque é só apertar um botão.
>
> A segunda é o plan mode. Para tarefas não triviais, em vez de deixar o agente sair editando,
> você pede um plano primeiro: ele explora, propõe os passos, e não toca no código até você
> aprovar. Isso economiza porque você corrige a **direção** antes de qualquer linha ser escrita.
> Sem isso, ele às vezes vai fundo numa abordagem errada e você paga tokens por código que vai
> jogar fora.
>
> E a compactação é o seguro pras conversas que precisam mesmo ser longas: o `/compact` resume
> o histórico e segue, em vez de carregar tudo cru. O Claude Code faz isso sozinho perto do
> limite, mas saber que existe ajuda. Resumindo: `/clear` é o hábito, plan mode é o freio,
> compactação é o seguro.

---

# BLOCO 7 — MCPs: poder e tradeoffs (seção "6")

**Objetivo:** MCPs dão poder real (ações e dados ao vivo), mas têm um **custo invisível**: o
schema de cada servidor ocupa contexto em todo turno, usado ou não. Habilite com parcimônia.

**Conexão:** é o primeiro bloco que mostra que "mais capacidade" pode significar "mais imposto
fixo" — amarra com a lição do CLAUDE.md inchado.

### Slides

**7.1 — Divisor de seção**
- `layout: section`
- `# 6. MCPs — poder e tradeoffs`
- Subtítulo: "Conectar o agente ao mundo — com consciência do custo"

**7.2 — O que é um MCP**
- Título: `# O agente conectado a ferramentas de verdade`
- Texto: "MCP (Model Context Protocol) liga o Claude a sistemas externos — GitHub, Jira, banco
  de dados, Sentry — de forma padronizada. Ele deixa de só conversar e passa a **agir** e a
  **ler dados ao vivo**."
- `<v-clicks>` ganhos:
  - Sem copia-e-cola: o agente lê o ticket, abre o PR, consulta o log
  - Padronizado: o mesmo protocolo serve pra vários serviços

**7.3 — O custo invisível (slide-chave do bloco)**
- Título: `# O imposto que você não vê`
- O ponto central: cada servidor MCP injeta as **definições das suas ferramentas (schemas)**
  no contexto — em **todo turno**, mesmo que você não use nenhuma delas naquela conversa.
- Visual sugerido: grid 2 colunas ou diagrama mostrando "3 MCPs habilitados = N ferramentas =
  X tokens de schema **antes** de você escrever qualquer coisa."
- Callout: "Ligar dez MCPs 'por garantia' é o mesmo erro do CLAUDE.md gigante: capacidade que
  você paga sempre e usa quase nunca."

**7.4 — Caso real: Playwright (exemplo concreto)**
- Título: `# Exemplo: navegação web`
- Contraste prático (grid):
  - Pra **ler** uma página → `WebFetch` é leve, traz o conteúdo e pronto
  - Pra **interagir** de verdade (clicar, preencher, screenshot) → o MCP do Playwright, que
    expõe muitas ferramentas com schemas grandes
- Lição: "Use a ferramenta pesada só quando precisa da interação. Pra ler, o leve resolve."
- (Este exemplo está alinhado com a prática que você já adota — `WebFetch` sobre Playwright pra
  economizar tokens.)

**7.5 — Regra de uso**
- `layout: center` / punchline
- Frase: "Habilite o MCP que a **tarefa** pede. Desligue o resto."
- Subtexto: "Poder sob demanda, não poder por garantia."
- `<<EXEMPLO REAL: se o time já usa algum MCP (Azure DevOps? Jira? um interno?), citar qual e o
  ganho concreto que ele trouxe — fica muito mais palpável que o exemplo genérico.>>`

### Narração rica

> MCP é o que conecta o Claude ao mundo de verdade. Model Context Protocol — um jeito
> padronizado de ligar o agente a sistemas externos: GitHub, Jira, um banco, o Sentry. Com isso
> ele para de só conversar e passa a agir: lê o ticket, abre o PR, consulta o log, sem você
> ficar copiando e colando. O ganho é real e eu não quero diminuir isso.
>
> Mas tem um custo que não aparece na tela, e é o ponto deste bloco. Cada servidor MCP que você
> habilita injeta no contexto a definição de todas as ferramentas dele — os schemas. E isso
> entra **todo turno**, mesmo que naquela conversa você não use nenhuma. Então se você liga dez
> MCPs "por garantia", você está pagando o schema dos dez em cada mensagem, o tempo todo. É
> exatamente o mesmo erro do CLAUDE.md gigante: capacidade que pesa sempre e que você usa quase
> nunca.
>
> Um exemplo concreto que eu gosto: navegação web. Se eu só preciso **ler** uma página, o
> WebFetch é leve — pega o conteúdo e acabou. Agora, se eu preciso **interagir** — clicar,
> preencher um formulário, tirar screenshot — aí sim vale o MCP do Playwright, que expõe um
> monte de ferramenta com schema grande. A regra é essa: habilite o MCP que a tarefa pede e
> desligue o resto. Poder sob demanda, não poder por garantia.

---

# BLOCO 8 — Sub-agents: quando valem (seção "7")

**Objetivo:** sub-agent tem um tradeoff claro — **cold start** (ele começa do zero, sem o seu
contexto) vs **contexto isolado** (mantém o ruído fora da sua sessão). Vale pra fan-out e
tarefa longa isolada; não vale pra coisinha rápida.

**Conexão:** fecha a tríade "ferramentas" (Skills, MCPs, Sub-agents) — todas sobre escalar
capacidade sem inflar o contexto principal.

### Slides

**8.1 — Divisor de seção**
- `layout: section`
- `# 7. Sub-agents — quando valem`
- Subtítulo: "Delegar sem poluir a sessão principal"

**8.2 — O que é um sub-agent**
- Título: `# Um agente com a própria janela de contexto`
- Texto: "Você dispara um sub-agente pra uma tarefa; ele trabalha numa janela de contexto
  **separada** e devolve só o **resultado final** pra sessão principal."
- Ponto-chave a plantar: "O trabalho sujo dele — buscas, arquivos lidos, tentativas — **não**
  entope a sua conversa."

**8.3 — O tradeoff (slide-chave)**
- Título: `# Cold start vs contexto isolado`
- Grid 2 colunas (sem vermelho/verde — é balanço, não certo/errado):
  - **Custo — cold start:** o sub-agente começa do zero. Ele **não** tem o seu histórico, então
    re-descobre o que precisa. Disparar tem overhead.
  - **Ganho — contexto isolado:** todo o ruído intermediário fica na janela dele. A sua sessão
    principal recebe só a conclusão, limpa.
- Callout: "A pergunta é sempre: o overhead de começar do zero compensa manter o ruído fora?"

**8.4 — Quando sim, quando não (decisão prática)**
- Título: `# A régua`
- Grid 2 colunas (✅ verde / ❌ vermelho, reaproveitando cards):
  - ✅ **Vale:**
    - Fan-out: várias buscas/tarefas independentes em paralelo
    - Tarefa longa e isolada cujo trabalho intermediário você não precisa ver
  - ❌ **Não vale:**
    - Coisinha rápida (um `grep`, ler um arquivo) — o cold start custa mais que o trabalho
    - Tarefa que **depende** do contexto da sua conversa (ele não tem)
- Callout de fechamento: "Sub-agent é para isolar trabalho pesado e paralelizável — não para
  terceirizar o que você faria em dois cliques."

### Narração rica

> Sub-agent é você disparar um outro agente pra uma tarefa, e ele roda numa janela de contexto
> separada da sua. Quando termina, devolve só o resultado final. O detalhe importante é esse: o
> trabalho sujo dele — as buscas, os arquivos que ele abriu, as tentativas — fica todo na janela
> dele e **não** entope a sua conversa principal.
>
> O tradeoff tem dois lados. O custo é o cold start: o sub-agente começa do zero, ele não tem o
> seu histórico, então ele re-descobre o que precisa saber. Disparar tem overhead. O ganho é o
> contexto isolado: justamente porque o ruído fica na janela dele, a sua sessão recebe só a
> conclusão, limpa. A pergunta que decide é sempre: o overhead de começar do zero compensa
> manter o ruído fora?
>
> Na prática: vale muito a pena pra duas coisas. Fan-out — quando você tem várias tarefas
> independentes e quer rodar em paralelo. E tarefa longa e isolada, onde você só quer o
> resultado e não liga pro caminho. Não vale pra coisinha rápida, tipo um grep ou ler um
> arquivo, porque aí o cold start custa mais que o próprio trabalho. E não vale quando a tarefa
> depende do que já foi conversado, porque o sub-agente não tem esse contexto. Resumindo: é pra
> isolar trabalho pesado e paralelizável, não pra terceirizar o que você faria em dois cliques.

---

# BLOCO 9 — Roteamento de modelo (seção "8")

**Objetivo:** **a maior alavanca de custo do time.** Modelo barato (Haiku/Sonnet) pro trivial e
bem-especificado; Opus pro difícil. Mostrar os números.

**Conexão:** é o fecho que amarra tudo — e dialoga com a prática de "modelo forte pra
especificar, Sonnet pra executar". Toda a disciplina dos blocos anteriores (spec, CLAUDE.md,
sessão limpa) é o que **permite** rodar o modelo barato com segurança.

> ⚠️ **Números conferidos na API (não inventar):** preços por milhão de tokens (input/output).

| Modelo | ID | Input | Output |
|---|---|---|---|
| Opus 4.8 | `claude-opus-4-8` | $5 | $25 |
| Sonnet 4.6 | `claude-sonnet-4-6` | $3 | $15 |
| Haiku 4.5 | `claude-haiku-4-5` | $1 | $5 |

Relações úteis: Opus ≈ **1,67×** Sonnet (mesma razão no input e no output). Sonnet ≈ **3×**
Haiku. Opus ≈ **5×** Haiku.

### Slides

**9.1 — Divisor de seção**
- `layout: section`
- `# 8. Roteamento de modelo`
- Subtítulo: "A maior alavanca de custo do time"

**9.2 — A ideia central**
- Título: `# Nem toda tarefa precisa do modelo mais caro`
- Texto: "Combine o modelo à dificuldade da tarefa. Trivial e bem-especificado → modelo barato.
  Raciocínio difícil, plano, arquitetura → modelo forte."
- `<v-clicks>`:
  - Haiku/Sonnet: refactor mecânico, boilerplate, tarefa bem-descrita
  - Opus: planejar, decidir arquitetura, depurar o problema cabeludo

**9.3 — Os números (slide-chave — é o que convence)**
- Título: `# O que cada modelo custa`
- Tabela (input / output por milhão de tokens) com os três modelos. Destaque visual nas razões:
  Opus 1,67× Sonnet, Sonnet 3× Haiku.
- Callout: "Multiplique isso por cada dev, cada dia. Trocar o modelo na tarefa certa é a
  economia mais direta que existe."

**9.4 — O padrão que junta tudo (spec forte, executa barato)**
- Título: `# Especifique no forte, execute no barato`
- O insight que conecta com o bloco 3 (Spec-Driven):
  - Use o modelo forte (Opus) pra **pensar**: o plano, a spec, a arquitetura
  - Use o modelo barato (Sonnet/Haiku) pra **executar** o que já está bem-especificado
- Callout: "Aqui é onde os pilares se pagam: foi a sua spec clara (bloco 3) e o seu CLAUDE.md
  (bloco 4) que tornaram seguro deixar o modelo barato executar."
- `<<EXEMPLO REAL: se você tem um caso onde planejou no Opus e executou no Sonnet — inclusive
  esta própria apresentação foi feita assim — vale mencionar como prova viva.>>`

**9.5 — Régua rápida de escolha**
- `layout: center` / punchline OU lista curta
- Frase-régua: "Se você consegue descrever o resultado, um modelo barato consegue entregar."
  (eco direto da regra de ouro do bloco 3)
- Subtexto: "Quando você **não** consegue descrever — é tarefa de Opus."

### Narração rica

> Esse é o fecho, e é a maior alavanca de custo do time inteiro. A ideia é simples: nem toda
> tarefa precisa do modelo mais caro. Você combina o modelo à dificuldade. Coisa trivial e
> bem-especificada — um refactor mecânico, boilerplate, uma tarefa que você descreveu bem — roda
> lindamente no Haiku ou no Sonnet. Já planejar uma arquitetura, decidir um trade-off difícil,
> depurar aquele bug cabeludo — aí vale o Opus.
>
> E os números importam, porque é o que convence. Por milhão de tokens: Haiku custa um dólar de
> entrada, cinco de saída. Sonnet, três e quinze. Opus, cinco e vinte e cinco. Ou seja, Opus é
> cerca de uma vez e dois terços o Sonnet, e o Sonnet é três vezes o Haiku. Isso parece pouco
> numa tarefa, mas multiplica por cada dev, cada dia — e aí vira a economia mais direta que
> existe no time.
>
> E olha como isso junta tudo o que a gente viu. O padrão mais poderoso é: especifique no forte,
> execute no barato. Use o Opus pra pensar — o plano, a spec, a arquitetura. E use o Sonnet ou o
> Haiku pra executar o que já está bem-especificado. Repara que isso só é seguro por causa dos
> pilares anteriores: foi a sua spec clara, do bloco 3, e o seu CLAUDE.md, do bloco 4, que
> tornaram possível confiar a execução ao modelo barato. Aliás — esta apresentação foi feita
> exatamente assim. E a régua final é a mesma regra de ouro do começo: se você consegue
> descrever o resultado, um modelo barato consegue entregar. Quando você não consegue descrever,
> é tarefa de Opus.

---

# PLAYBOOK — checklist de 1 página (seção "9")

**Objetivo:** síntese acionável que cabe num slide e que o time leva pra casa. Não é bloco
novo de conteúdo — é o resumo de tudo num cartão.

### Slide

**P.1 — O playbook**
- Título: `# 9. Playbook do time` (manter o divisor que já existe, ou transformar este no
  conteúdo). Sugiro um único slide denso, legível, em formato de checklist.
- Conteúdo (uma linha por pilar, na ordem da apresentação):
  - ✅ **Especifique antes** — contexto, tarefa, resultado esperado, restrições. Se não dá pra
    descrever, o agente não adivinha.
  - ✅ **CLAUDE.md enxuto e em camadas** — o agente já chega sabendo; índice, não enciclopédia.
  - ✅ **Skills pro que é procedimento** — carrega só quando usa.
  - ✅ **`/clear` entre tarefas, plan mode antes das grandes** — vitórias de graça.
  - ✅ **MCP que a tarefa pede, desliga o resto** — cuidado com o schema invisível.
  - ✅ **Sub-agent pra fan-out e trabalho isolado** — não pra coisinha rápida.
  - ✅ **Especifique no forte, execute no barato** — a maior alavanca de custo.
- Callout final / ponte pro slide de "Obrigado" que já existe: "Usar IA como engenharia é isso:
  contexto certo, modelo certo, sessão limpa. O resto é hábito."

**Observação:** o `slides.md` já tem o slide final "Obrigado 🙌". O playbook entra **antes**
dele. Não duplicar o encerramento.

### Narração rica (curta — é transição pro fecho)

> Pra levar pra casa, é isto numa página. Especifique antes — se você não descreve o resultado,
> o agente não adivinha. CLAUDE.md enxuto e em camadas, pra ele já chegar sabendo. Skills pro
> que é procedimento. `/clear` entre tarefas e plan mode antes das grandes. MCP só o que a
> tarefa pede. Sub-agent pra fan-out e trabalho pesado isolado. E a maior de todas: especifique
> no modelo forte, execute no barato. No fundo é uma frase só — usar IA como engenharia é
> contexto certo, modelo certo, sessão limpa. O resto é hábito.

---

## Checklist de produção para o Sonnet

- [ ] Bloco 4 — substituir os placeholders dos divisores `# 3.` existentes em `slides.md`
- [ ] Bloco 5 — `# 4.`
- [ ] Bloco 6 — `# 5.`
- [ ] Bloco 7 — `# 6.`
- [ ] Bloco 8 — `# 7.`
- [ ] Bloco 9 — `# 8.`
- [ ] Playbook — `# 9.` (antes do "Obrigado")
- [ ] Rodar `npm run dev` e conferir cada slide via screenshot (Mermaid/cards não cortam)
- [ ] `npm run build` limpo no fim
- [ ] **Não** preencher os `<<EXEMPLO REAL>>` — deixar como estão para o João trocar no banco
      (ou converter em comentário `<!-- EXEMPLO REAL: ... -->` para não vazar no slide)
