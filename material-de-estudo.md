# Material de estudo — IA com Eficiência

Material de apoio para a palestra. A ideia aqui não é o que vai no slide, é o que você precisa **saber por trás** de cada slide pra falar com segurança, responder pergunta difícil e complementar a fala sem depender do que está projetado.

Está organizado na mesma ordem dos blocos. Em cada bloco: o conceito a fundo, o "por que funciona assim" (mecânica), o que costuma ser dúvida da plateia, e os artigos da própria Anthropic pra ler.

> Uma ressalva honesta sobre números: preços e detalhes de tokenizer mudam. Os valores citados são os de jun/2026, conferidos na página de pricing. Antes de apresentar, revise a página de pricing e o `/usage` de um projeto seu — número real seu vale mais que qualquer tabela.

---

## Antes de tudo: o modelo mental que sustenta a palestra inteira

Uma frase resume o restante: **um LLM não tem memória entre turnos — ele é uma função sem estado que recebe todo o contexto de novo a cada chamada e devolve o próximo token.** Tudo o que parece "memória" (a conversa continuar, o agente lembrar do arquivo) é o cliente reenviando o histórico junto do seu novo prompt.

Se isso está firme na cabeça da plateia, cada técnica da palestra deixa de ser "dica" e vira consequência lógica:

- Contexto reenviado a cada turno → sessão longa fica cara → `/clear`, `/compact`.
- O modelo redescobre o projeto a cada tarefa → escreva o mapa uma vez → CLAUDE.md.
- O modelo não adivinha o que você quer → descreva → Spec-Driven.
- Todo token que ocupa a janela é pago e "dilui" a atenção → só carregue o que a tarefa pede → Skills sob demanda, MCP sob demanda, sub-agentes pra isolar ruído.

A Anthropic deu nome a essa disciplina: **context engineering** — "o conjunto de estratégias para manter o conjunto ótimo de tokens durante a inferência". É a evolução do prompt engineering: menos "achar as palavras mágicas", mais "qual configuração de contexto gera o comportamento que eu quero". Vale ler antes de tudo, é a espinha dorsal:

- **Effective context engineering for AI agents** — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Versão prática, com código (memory / compaction / tool clearing): **Context engineering cookbook** — https://platform.claude.com/cookbook/tool-use-context-engineering-context-engineering-tools

Um conceito que aparece nesses textos e vale citar: **"context rot"** — conforme a janela enche, a qualidade das respostas cai. Não é só custo; é performance. Contexto é recurso **finito**, e não só financeiramente: mais tokens irrelevantes = mais chance de o modelo se perder. Esse é o argumento que transforma "economizar token" em "trabalhar melhor", que é o enquadramento que você quer com um time de engenharia.

---

## Bloco 1 — Como os tokens são gastos de verdade

### 1.1 O contexto é reenviado a cada turno

O ponto técnico: cada chamada à API manda o array de mensagens **inteiro** — system prompt + todo o histórico + seu novo prompt. O modelo não guarda nada entre chamadas. Então numa conversa de N turnos, o turno N reprocessa tudo dos turnos 1..N-1.

Consequência que você quer que grude: **o custo por turno cresce ao longo da sessão.** Uma conversa de 2h não custa 2× uma de 1h — custa mais, porque os turnos do fim carregam todo o acúmulo dos turnos do começo. É uma curva, não uma reta.

Onde isso salva a conta: **prompt caching.** Reenviar tudo seria proibitivo se cada token fosse cobrado a preço cheio toda vez. O cache guarda o prefixo já processado e cobra a releitura a **0,1×** do preço de input. É isso que torna o reenvio viável — e é por isso que o item que mais aparece numa sessão longa é *cache read*, não output.

### 1.2 Nem todo token custa igual

Quatro naturezas de token, e o `/usage` separa elas:

| Tipo | O que é | Multiplicador | Por que existe |
|---|---|---|---|
| **Cache read** | reler um prefixo já cacheado | **0,1×** | releitura é barata: o trabalho pesado já foi feito |
| **Input** | token novo, processado pela 1ª vez | 1× (base) | preço de referência |
| **Cache write** | gravar um prefixo novo no cache | 1,25× | pequeno ágio pra guardar; se paga na 2ª leitura |
| **Output** | token que o modelo **gera** | 5× | geração autoregressiva é o passo caro |

Números pra ter na ponta (multiplicadores sobre o input de cada modelo):

- **Cache write de 5 min = 1,25×** do input; **cache read = 0,1×**; **output = 5×**.
- Existe também **cache write de 1h = 2×** — TTL maior, ágio maior. Só entra na conversa se perguntarem sobre sessões muito espaçadas.

O TTL padrão do cache é **5 minutos**, renovado a cada uso. Ou seja: numa sessão ativa o cache "se mantém quente"; se você some por 6 minutos e volta, o prefixo pode ter expirado e a próxima leitura vira cache write de novo. Esse detalhe conecta com um ponto do Claude Code mais à frente (por que sleeps longos custam).

**Erro comum da plateia:** achar que output é o que pesa porque "é o que a IA produz". Na prática, em trabalho agentico com sessão longa, quem domina a conta é o cache read — reler o contexto, turno após turno. Seu "Caso real" prova isso com número.

### 1.3 O caso real ($2,23)

O valor da história não é o total, é a **proporção**: cache read foi ~62% do custo ($1,38 de $2,23), output foi ~16%. O contexto sendo relido a cada ajuste de slide gastou 4× mais que tudo que a IA escreveu. Isso é o argumento do `/clear` e do contexto enxuto em números que vieram do seu próprio `/usage` — muito mais forte que teoria.

Dica de fala: puxe o `/usage` de um projeto real seu antes da palestra e leia a linha de cache read em voz alta. É o "aha" do bloco.

### 1.4 O imposto da redescoberta

Sem contexto persistente, toda tarefa começa com o modelo se localizando: `grep` na estrutura, abre vários arquivos "pra entender", deduz convenção do zero. Isso é trabalho **repetido a cada tarefa, por cada dev**. É o mesmo projeto sendo redescoberto centenas de vezes. Os blocos 2, 3 e 4 são, cada um à sua maneira, formas de pagar esse pedágio **uma vez**.

### Leitura Anthropic — Bloco 1
- **Prompt caching (docs, com a tabela de multiplicadores)** — https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- **Prompt caching with Claude (anúncio, o "porquê")** — https://www.anthropic.com/news/prompt-caching
- **How Claude Code uses prompt caching** — https://code.claude.com/docs/en/prompt-caching
- **Pricing (fonte dos multiplicadores e preços por MTok)** — https://platform.claude.com/docs/en/about-claude/pricing

---

## Bloco 2 — Pilar 1: Especificar antes (Spec-Driven)

### 2.1 O custo de um prompt vago é um loop de descoberta

"O endpoint tá quebrando" força o modelo a **descobrir o que você quer** antes de fazer qualquer coisa: explora arquivos, pergunta o erro, você responde (mais tokens), ele lê arquivos irrelevantes que **ficam no contexto e encarecem todo turno seguinte**, tenta uma abordagem, erra, refaz. Cada rodada dessas é token que não precisava existir — e o pior nem é o token gasto na rodada, é o lixo que ficou na janela inflando o resto da sessão.

Repare que isso conecta direto com o bloco 1: prompt vago não custa só a rodada extra, custa o **contexto inflado** que você relê (cache read) até o fim da sessão.

### 2.2 Anatomia de um bom prompt

Quatro ingredientes que matam o loop de descoberta:

1. **Contexto** — qual arquivo/endpoint/serviço está em jogo. Tira o modelo do "onde é isso?".
2. **Tarefa** — verbo de ação sem ambiguidade: corrija, adicione, revise, explique.
3. **Comportamento esperado** — o que o resultado deve ser, ou como validar. É o critério de "pronto".
4. **Restrições** — o que **não** tocar. Reduz o espaço de busca e evita estrago colateral.

O exemplo do slide 2 (o "depois" do bug) tem os quatro: endpoint + status + condição (contexto), "esperado 422" (comportamento), "não altere repositório" (restrição). Uma ida, um fix.

Um jeito bom de vender isso pro time: **a spec é o mesmo rigor de um bom ticket / um bom PR description.** Ninguém no time acha estranho exigir passos de reprodução num bug report. Prompt bom é a mesma coisa — você não está "sendo educado com a IA", está eliminando trabalho de adivinhação que você paga.

### 2.3 A regra de ouro

*Se você não consegue descrever o resultado esperado, o agente também não vai conseguir.* Isso não é sobre a IA ser burra — é que o pedido é genuinamente subespecificado, e alguém vai ter que preencher a lacuna adivinhando. Se for a IA adivinhando, você paga as tentativas.

E o gancho pro bloco 5: spec clara → o agente propõe um **plano** → você valida o plano (texto, barato de corrigir) → o agente executa. Corrigir um parágrafo de plano custa quase nada; desfazer uma refatoração que foi na direção errada custa caro.

### 2.4 Ligação com a doutrina da Anthropic

O que você chama de Spec-Driven é o lado do usuário do que a Anthropic chama de **context engineering** e de bons **system prompts / tools**: dar ao modelo informação "informativa, porém enxuta", no "altitude certa" — nem regras rígidas demais, nem vago demais. O texto de context engineering e o de building effective agents batem exatamente nisso.

### Leitura Anthropic — Bloco 2
- **Effective context engineering for AI agents** (seções de system prompt e "right altitude") — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- **Building effective agents** (quando um fluxo simples e bem-especificado vence um agente elaborado) — https://www.anthropic.com/research/building-effective-agents
- **Claude Code best practices** (a parte de dar instruções específicas) — https://code.claude.com/docs/en/best-practices

---

## Bloco 3 — Pilar 2: CLAUDE.md hierárquico

### 3.1 O que é, mecanicamente

`CLAUDE.md` é um Markdown que o Claude Code carrega **automaticamente** no começo da sessão e injeta no contexto. É memória persistente do projeto: escrita uma vez, lida sempre. Responde três perguntas que o modelo senão descobriria do zero toda vez:

- O que o projeto **é** (domínio + arquitetura em uma frase).
- **Onde** as coisas estão (estrutura, pastas que importam).
- **Como** se faz aqui (build/test, convenções, o que **não** fazer).

### 3.2 Hierarquia: do geral ao específico

O Claude Code lê CLAUDE.md em camadas e combina:

- `~/.claude/CLAUDE.md` — suas preferências pessoais, valem pra todo projeto (não vai pro repo).
- `raiz/CLAUDE.md` — descreve a solução, comitado, o time inteiro herda.
- `modulo/CLAUDE.md` — convenções locais de cada camada (api/, application/, infrastructure/).

O arquivo **mais próximo** do que você está editando entra junto com o da raiz. Trabalhando em `infrastructure/`, o Claude puxa o CLAUDE.md de lá **e** o da raiz. É o mesmo princípio de escopo de configuração em cascata que todo dev já conhece (.editorconfig, tsconfig aninhado, appsettings por ambiente) — nada exótico.

### 3.3 O tradeoff central: rico o bastante, enxuto o bastante

Aqui mora a lição mais importante do bloco, e é contraintuitiva: **CLAUDE.md é imposto fixo.** Ele é lido em **toda** sessão, de **todo** dev. Então cada linha inútil ali é multiplicada por todo o time, todo dia, pra sempre. Despejar o README inteiro é o "imposto invertido": você paga contexto que quase nunca é relevante, sempre.

A regra: **CLAUDE.md é índice, não enciclopédia.** Bullets curtos, comandos, e **ponteiros** ("detalhes de auth em `docs/auth.md`") em vez do conteúdo. O modelo sabe onde buscar quando precisar, sem carregar tudo sempre. Isso é exatamente o **progressive disclosure** que a Anthropic prega pra Skills — só que aplicado a manual do projeto.

A Anthropic é explícita sobre isso: quase todas as best practices do Claude Code derivam de uma restrição — **a janela enche rápido e a performance cai conforme enche.** CLAUDE.md gordo trabalha contra você em dois eixos: custo e qualidade.

### 3.4 Começar é barato

- `/init` gera um rascunho lendo o projeto. Ponto de partida, não produto final.
- Edite: corte ruído, adicione comandos de build/test, regras de "não faça", limitações do ambiente (ex.: sem `sudo` no devcontainer — isso evita o agente entrar em loop tentando instalar coisa que não pode).
- `.claudeignore` tira `bin/`, `obj/`, gerados, migrations dos greps — o agente para de varrer o que não faz sentido ler.
- Comite CLAUDE.md e .claudeignore junto do código: é contexto **compartilhado**, todo dev herda.
- Refino contínuo: **toda vez que você vê o agente redescobrindo algo, aquilo é candidato a virar uma linha.** Esse é o loop de manutenção do arquivo.

### 3.5 A conexão com "how Anthropic teams use Claude Code"

Vale citar: internamente, os times da Anthropic tratam a qualidade da navegação do Claude como **função de quão bem o codebase está preparado** — camadas de CLAUDE.md e Skills. Não é mágica do modelo, é setup. Isso reforça o enquadramento "IA como engenharia" da sua abertura.

### Leitura Anthropic — Bloco 3
- **Claude Code best practices** (seção de CLAUDE.md) — https://code.claude.com/docs/en/best-practices
- **How Claude Code works in large codebases** — https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start
- **How Anthropic teams use Claude Code (PDF)** — https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf
- **Effective context engineering** (por que "enxuto" é performance, não só custo) — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents

---

## Bloco 4 — Pilar 3: Skills

### 4.1 O que é uma Skill

Uma pasta com um `SKILL.md` — frontmatter YAML obrigatório (`name` + `description`), instruções em Markdown, e **opcionalmente scripts e outros arquivos**. É um procedimento empacotado que o agente carrega **sob demanda**: deploy, gerar migration, rodar o checklist de PR, seguir o padrão da casa pra criar um endpoint.

### 4.2 Por que são baratas — progressive disclosure

Este é o conceito técnico do bloco, e é elegante. No startup, o agente pré-carrega **só o `name` + `description`** de cada Skill instalada no system prompt — poucos tokens, o suficiente pra ele saber **quando** cada uma serve. O corpo do `SKILL.md` só entra no contexto **quando a Skill é acionada**.

A Anthropic descreve isso como um manual bem organizado: primeiro o índice (nomes + descrições), depois o capítulo específico (o SKILL.md), e só então o apêndice detalhado (arquivos/scripts que a Skill referencia). O modelo desce os níveis só na medida da necessidade.

Consequência prática pra vender pro time: **você pode ter 20 Skills e pagar quase nada por elas até usar uma.** Compare com colar o procedimento inteiro no CLAUDE.md — que pesaria em **toda** sessão, mesmo nas 19 em que aquele procedimento não tem nada a ver.

Camada extra de eficiência: Skills podem **embutir scripts**. Trabalho determinístico (rodar um comando, transformar um arquivo) sai do domínio "modelo gera tokens" e vira **código executado**. Mais barato, mais confiável, sem alucinação. É a diferença entre pedir pro modelo "calcular" e dar a ele uma calculadora.

### 4.3 Skill vs CLAUDE.md — a régua de decisão

- **Consulta em TODA tarefa?** (o que o projeto é, onde as coisas estão, convenção geral) → **CLAUDE.md**.
- **Roteiro que você segue de vez em quando?** (deploy, scaffold, checklist) → **Skill**.

O critério é frequência × tamanho. Fato pequeno e sempre-relevante: CLAUDE.md. Procedimento grande e ocasional: Skill, pra não pesar quando não é usado.

### 4.4 Contexto de mercado (pra responder "isso é padrão ou coisa da Anthropic?")

Skills viraram **spec aberta** — a Anthropic abriu como padrão, no mesmo espírito do MCP. Então não é lock-in: é um formato de pastas + SKILL.md que outros agentes podem adotar. Se perguntarem, o repositório público de Skills da Anthropic é um bom lugar pra mostrar exemplos reais.

### Leitura Anthropic — Bloco 4
- **Equipping agents for the real world with Agent Skills** (o texto de engenharia, explica progressive disclosure) — https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- **Agent Skills (docs, estrutura do SKILL.md)** — https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- **anthropics/skills (repositório público de exemplos)** — https://github.com/anthropics/skills

---

## Bloco 5 — Higiene de sessão

Três comandos, custo zero, retorno alto. Todos derivam do bloco 1.

### 5.1 `/clear` — uma tarefa, uma sessão

Como o contexto é reenviado a cada turno, arrastar a tarefa B pra dentro da sessão cheia da tarefa A faz **B pagar (em cache read, todo turno) pelo contexto de A** — que é irrelevante pra B. `/clear` zera a janela; a curva de custo por turno **reseta**. Regra simples de comunicar: **trocou de assunto, `/clear`.** É o hábito de maior retorno da palestra porque custa um comando e barateia todos os turnos seguintes.

### 5.2 Plan mode — planejar antes de deixar editar

No plan mode o agente **explora e propõe** um plano sem tocar no código. Você aprova, aí ele executa. O ganho: você corrige a **direção** enquanto ela ainda é texto (barato), não depois de virar uma refatoração errada (caro de desfazer). Funciona **porque a spec já estava clara** (bloco 2) — o agente sabe o suficiente pra propor algo concreto. Plan mode e Spec-Driven são o mesmo princípio em dois momentos: descrever o resultado, validar o caminho, então executar.

### 5.3 `/compact` — quando a sessão precisa continuar longa

Tarefa longa, mesmo assunto, não dá pra `/clear`. Aí entra `/compact`: ele **resume** a conversa e substitui o histórico longo por esse resumo, liberando janela. O Claude Code compacta sozinho perto do limite — mas aí **ele** decide o que sobra. Melhor você rodar antes, dirigindo:

- `/compact` puro → resumo genérico, escolha automática do que é relevante.
- `/compact <instrução>` → você direciona. Ex.: *"mantenha as decisões de arquitetura e os erros já descartados, descarte trechos de código já aplicados"*.
- **Rode ao virar de fase** (terminou o plano, vai implementar): resume o que foi decidido e abre espaço pro que vem.

Detalhe técnico importante pra não vender ilusão: compactar é **lossy** — é um resumo, informação se perde. Por isso a instrução dirigida importa: você escolhe o que **não** pode se perder. A Anthropic trata compaction como uma técnica central de context engineering pra tarefas longas — o cookbook tem a implementação.

**Resumo do bloco:** `/clear` zera; plan mode trava edição até aprovação; `/compact` dirigido preserva o que importa. Três alavancas sobre a mesma física do bloco 1.

### Leitura Anthropic — Bloco 5
- **Effective context engineering** (seção de compaction e de sessões longas) — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- **Context engineering cookbook** (compaction / tool result clearing, com código) — https://platform.claude.com/cookbook/tool-use-context-engineering-context-engineering-tools
- **Claude Code best practices** (fluxo de trabalho, plan mode) — https://code.claude.com/docs/en/best-practices

---

## Bloco 6 — MCPs: poder e tradeoffs

### 6.1 O que é MCP

**Model Context Protocol** é um padrão aberto pra conectar o modelo a sistemas externos — GitHub, Jira, banco, Sentry — de forma padronizada. Em vez de cada integração ser um adaptador custom, todo mundo fala o mesmo protocolo: **servidores MCP** expõem dados/ações, **clientes MCP** (como o Claude Code) consomem. O modelo deixa de só conversar e passa a **agir** (abrir PR) e **ler ao vivo** (consultar log, query no banco).

Contexto que vale citar: a Anthropic lançou MCP em nov/2024, e ele virou padrão de mercado — adotado por OpenAI, Google e outros; em dez/2025 foi doado pra Agentic AI Foundation (Linux Foundation). Ou seja, apostar em MCP não é apostar num formato proprietário.

### 6.2 O imposto que você não vê — e a correção importante

Aqui está o ponto que o deck **corrige** em relação a uma crença comum (e que você acertou ao revisar): a ideia de que "ligar um MCP injeta o schema inteiro de todas as ferramentas no contexto o tempo todo" **está desatualizada**. O comportamento real são **dois portões separados**:

1. **Ligar o servidor** — decisão manual, feita antes da tarefa (comando ou config no projeto). Servidor desligado = custo zero. A tarefa não liga nada sozinha.
2. **Carregar o schema** — de um servidor **ligado**, entra no contexto de início só o **nome da ferramenta + uma instrução curta** por turno. O **schema completo** de cada tool (a parte pesada) só é puxado **quando o agente, durante a tarefa, decide que precisa dela.**

A frase que fecha: **"ligado" cobra todo turno (o nome + instrução); "usado" cobra por tarefa (o schema).** Você só controla o primeiro portão — e é ele que compensa cortar.

Por que isso importa e não é só nitpick: muda a recomendação. Não é "nunca ligue MCP porque explode o contexto". É "o custo fixo por MCP ligado é pequeno **por turno**, mas se multiplica: 10 MCPs 'por garantia' = 10× nome+instrução em **todo** turno, antes de você escrever qualquer coisa". É o mesmo erro do CLAUDE.md gigante — capacidade que você paga sempre, mesmo leve, e usa quase nunca.

### 6.3 O exemplo web (WebFetch vs MCP de browser)

O tradeoff concreto: **ler uma página** → `WebFetch`, leve, pega o conteúdo e pronto, sem schema extra. **Interagir de verdade** (clicar, preencher, screenshot) → MCP de browser automation (Playwright), muitas ferramentas, schemas grandes. Regra: use a ferramenta pesada só quando a tarefa pede interação real; pra ler, o leve resolve.

E o detalhe que enriquece: isso **não é idiossincrasia do Claude** — é padrão que o mercado de agentes convergiu. Quase todo assistente de código com web tem os dois modos (fetch leve + browser automation), pela mesma razão: não pague o custo de um navegador inteiro (schemas, sessão, DOM) só pra ler um artigo. E o CLAUDE.md pode reforçar isso com uma linha ("prefira WebFetch a MCP de browser; só use automação se precisar interagir").

### 6.4 Onde a decisão fica (settings.json)

`/mcp` liga/desliga na hora, dentro da sessão. Pra fixar no projeto, a lista vai no `settings.json`:

```json
{
  "enabledMcpjsonServers": ["github", "postgres"],
  "disabledMcpjsonServers": ["figma", "shopify", "blender"]
}
```

Comitado no repo, **o time inteiro herda a mesma escolha** — ninguém precisa lembrar de desligar nada a cada sessão. É a mesma filosofia do CLAUDE.md comitado: a decisão de configuração é feita uma vez, no setup do projeto, não a cada prompt.

### 6.5 A régua (o exemplo dos 6 MCPs)

Projeto .NET em Git: dá pra ligar MCP de qualquer coisa "porque um dia pode ser útil", mas só três fazem o quê nesse projeto (Git/GitHub, Azure DevOps, SQL Server). Figma sem handoff de design, Shopify sem loja, Blender sem asset 3D — cada um desses é 1× nome+instrução em todo turno sem nunca ser chamado. **Habilite os MCPs que o projeto realmente usa, desligue o resto.**

### Leitura Anthropic — Bloco 6
- **Introducing the Model Context Protocol** — https://www.anthropic.com/news/model-context-protocol
- **Especificação e docs do protocolo** — https://modelcontextprotocol.io
- **Effective context engineering** (seção de *tools* — por que curar ferramentas importa) — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Se quiser o detalhe de como o Claude Code lida com MCP: **Claude Code docs / best practices** — https://code.claude.com/docs/en/best-practices

---

## Bloco 7 — Sub-agents: quando valem

### 7.1 O que é

Você dispara um sub-agente pra uma tarefa; ele trabalha numa **janela de contexto separada**, com system prompt próprio, ferramentas próprias e permissões próprias, e devolve **só o resultado final** pra sessão principal. Todo o trabalho sujo — buscas, arquivos lidos, tentativas, logs — fica na janela **dele** e nunca entope a sua conversa.

O Claude Code já vem com alguns embutidos (Explore, Plan, general-purpose) e você pode criar os seus.

### 7.2 O tradeoff: cold start vs contexto isolado

- **Custo (cold start):** o sub-agente começa do zero. Não tem o seu histórico — precisa redescobrir o que já era óbvio pra você. Isso é um custo fixo toda vez que você dispara.
- **Ganho (contexto isolado):** todo o ruído intermediário fica na janela dele; sua sessão principal recebe só a conclusão, limpa.

A pergunta que decide sempre: **o overhead de começar do zero compensa manter o ruído fora da sua janela?** É a mesma conta do bloco 1, olhada de outro ângulo — você troca um custo pontual (cold start) por não pagar o custo recorrente (reler o ruído em cache read até o fim da sessão).

### 7.3 A régua

**Vale:**
- **Fan-out:** várias buscas/tarefas **independentes** em paralelo. Cada sub-agente cuida de uma, todas ao mesmo tempo, cada uma devolve um resumo curto.
- **Tarefa longa e isolada** cujo trabalho intermediário você não vai reusar (rodar a suíte de testes, varrer logs, ler documentação extensa) — o output verboso fica na janela do sub-agente, só o resumo volta.

**Não vale:**
- **Coisinha rápida** (um `grep`, ler um arquivo): o cold start custa mais que o trabalho.
- **Tarefa que depende do contexto da sua conversa:** o sub-agente não tem esse contexto, e você acabaria reenviando tudo pra ele — matando o ganho.

A frase-régua: **sub-agent é pra isolar trabalho pesado e paralelizável — não pra terceirizar o que você faria em dois cliques.**

### 7.4 Como você dispara (a ponte pro bloco 8)

Na maioria dos casos não precisa de nada especial: você descreve a tarefa e o Claude **decide delegar sozinho**, roda o sub-agente e traz só o resultado. Pra padronizar, dá pra definir sub-agentes próprios com `/agents` — cada um com **seu prompt, suas ferramentas e seu próprio modelo**.

E é aqui que sub-agent encosta em roteamento de modelo: **um agente de busca pode rodar em Haiku enquanto a sua sessão está em Opus** — barato pra vasculhar, forte pra decidir. Quem faz o trabalho braçal não precisa ser o modelo caro. Segura essa ideia, ela abre o bloco 8.

### 7.5 Nuance honesta pra não superusar

O texto **Building effective agents** da Anthropic é deliberadamente cético: a maioria das tarefas não precisa de multi-agente; comece com o mais simples que resolve e só adicione complexidade (sub-agentes, orquestração) quando ela **paga** em resultado. Sub-agente mal usado vira overhead de cold start sem ganho. Essa honestidade cai bem num time de engenharia — mostra que não é hype.

### Leitura Anthropic — Bloco 7
- **Create custom subagents (Claude Code docs)** — https://code.claude.com/docs/en/sub-agents
- **How and when to use subagents in Claude Code** — https://claude.com/blog/subagents-in-claude-code
- **Building effective agents** (quando NÃO usar multi-agente) — https://www.anthropic.com/research/building-effective-agents

---

## Bloco 8 — Roteamento de modelo

### 8.1 A ideia central

Combine o modelo à dificuldade da tarefa. Trivial e bem-especificado → modelo barato (Haiku/Sonnet). Raciocínio difícil, plano, arquitetura, bug cabeludo → modelo forte (Opus). É a decisão que mais pesa no custo do time porque multiplica por cada dev, cada dia.

### 8.2 O que cada modelo custa (jun/2026 — CONFERIR antes de apresentar)

| Modelo | Input ($/MTok) | Output ($/MTok) |
|---|---|---|
| Haiku 4.5 | $1 | $5 |
| Sonnet 5 | $2 | $10 |
| Opus 4.8 | $5 | $25 |

Razões: **Sonnet ≈ 2× Haiku**, **Opus ≈ 2,5× Sonnet**, **Opus ≈ 5× Haiku**. (Sonnet 5 a $2/$10 é preço introdutório até 31/08/2026; depois vai a $3/$15 — confira na página de pricing na semana da palestra.)

### 8.3 O preço por token não conta tudo — o tokenizer

Este é o ponto mais não-óbvio da palestra inteira, e o que mais impressiona um público técnico, porque quase ninguém sabe: **modelos diferentes usam tokenizers diferentes.** Os mais novos (Sonnet 5, Opus 4.7+) usam um tokenizer que, **pro mesmo texto**, produz cerca de **30% mais tokens** que o do Haiku 4.5.

Consequências:

- O mesmo arquivo, o mesmo prompt, vira **mais tokens** no Sonnet 5 / Opus do que no Haiku.
- Ou seja, a coluna de preço por MTok **subestima** o custo real dos modelos novos quando você compara com o Haiku — o preço unitário é só metade da conta; a outra metade é **quantos tokens aquele modelo gera pro mesmo trabalho.**
- Na tarefa simples, o Haiku 4.5 leva **vantagem dupla**: mais barato por token **e** contando menos tokens pro mesmo texto.

A regra que fecha: **não compare modelos só pela coluna de preço. O que fecha a conta é preço por token × quantos tokens aquele modelo gera.** Se alguém perguntar como medir isso: o endpoint de **token counting** conta os tokens de um texto pra um modelo específico — dá pra comparar o mesmo payload entre modelos.

> Cheque de honestidade antes de apresentar: o "~30%" é a ordem de grandeza que estava valendo; o número exato varia por texto (código vs prosa vs outro idioma). Apresente como "cerca de 30%, varia com o conteúdo", não como constante. Se quiser blindar, meça um arquivo real seu com o token counting nos dois modelos e mostre o número.

### 8.4 Especifique no forte, execute no barato

O padrão de trabalho:

- **Opus pra pensar:** o plano, a spec, a arquitetura, depurar o problema difícil.
- **Sonnet/Haiku pra executar:** o que já está bem-especificado, tarefas claras e delimitadas.

E o fecho que amarra a palestra toda: **foi a sua spec clara (bloco 2) e o seu CLAUDE.md (bloco 3) que tornaram seguro deixar o modelo barato executar.** Sem isso, o modelo barato erra mais e você perde a economia refazendo. Roteamento de modelo não é um truque isolado — é o **pagamento** dos investimentos dos blocos 2 e 3.

### 8.5 Onde você troca o modelo

- `/model` troca o modelo da sessão na hora e salva como padrão pras próximas.
- Plan mode e sub-agentes podem rodar num modelo diferente do de execução.
- Hábito prático: **planeja no Opus, dá `/model` pra Sonnet, deixa ele executar a spec.**

Trocar é barato; o que custa é **esquecer no modelo errado** — ficar no Opus fazendo boilerplate, ou no Haiku tentando resolver arquitetura. O ganho não vem de usar sempre o barato; vem de estar no **modelo certo em cada etapa**.

### 8.6 A regra

*Se você consegue descrever o resultado, um modelo barato consegue entregar. Quando você **não** consegue descrever — é tarefa de Opus.* Repare que a régua do roteamento é a **mesma** da spec-driven. Descritibilidade é o critério unificador da palestra: se dá pra descrever, dá pra especificar, dá pra planejar, dá pra rodar barato. Se não dá, é trabalho de raciocínio caro.

### Leitura Anthropic — Bloco 8
- **Pricing (preços e nota sobre preço introdutório)** — https://platform.claude.com/docs/en/about-claude/pricing
- **Token counting (medir tokens por modelo — a prova do ponto do tokenizer)** — https://platform.claude.com/docs/en/build-with-claude/token-counting
- **Building effective agents** (combinar capacidade do modelo à tarefa) — https://www.anthropic.com/research/building-effective-agents
- **Claude Code best practices** (uso de `/model` no fluxo) — https://code.claude.com/docs/en/best-practices

---

## Bloco 9 — Playbook do time

O cartão de bolso, e a razão de cada item (útil pra fechar respondendo "por quê" de cada linha):

- **Especifique antes** — contexto, tarefa, resultado, restrições. *Por quê:* mata o loop de descoberta e o contexto inflado (blocos 1, 2).
- **CLAUDE.md enxuto e em camadas** — índice, não enciclopédia. *Por quê:* é imposto fixo cobrado em toda sessão de todo dev (bloco 3).
- **Skills pro que é procedimento** — carrega só quando usa. *Por quê:* progressive disclosure, 20 skills custam quase nada em repouso (bloco 4).
- **`/clear` entre tarefas, plan mode antes das grandes** — de graça. *Por quê:* reseta a curva de custo por turno; corrige direção enquanto é texto (blocos 1, 5).
- **MCP que a tarefa pede, desligue o resto** — cuidado com o schema invisível. *Por quê:* cada ligado é nome+instrução em todo turno (bloco 6).
- **Sub-agent pra fan-out e trabalho isolado** — não pra coisinha rápida. *Por quê:* isola ruído, mas tem cold start (bloco 7).
- **Especifique no forte, execute no barato** — onde o time mais economiza. *Por quê:* roteamento é o retorno dos investimentos de spec + CLAUDE.md (bloco 8).

**Fecho:** usar IA como engenharia é isso — contexto certo, modelo certo, sessão limpa. O resto é hábito.

---

## Perguntas difíceis que podem vir (e a resposta curta)

- **"Isso tudo não é só pra economizar uns dólares?"** — Não. É contexto finito: quando a janela enche, a **qualidade** cai (context rot). Economia de token e qualidade de resposta são o mesmo eixo. Fonte: effective context engineering.
- **"O cache não guarda dados sensíveis?"** — O cache é por organização/conta e tem TTL curto (5 min padrão); é um prefixo de tokens reprocessável, não um armazenamento de longo prazo. Detalhes na doc de prompt caching.
- **"Skills e MCP não são a mesma coisa?"** — Não. MCP conecta a **sistemas externos** (ações/dados ao vivo). Skill empacota um **procedimento** (instruções + scripts) que o modelo carrega sob demanda. Um dá braços; o outro dá manual.
- **"Sub-agente é sempre melhor pra tarefa grande?"** — Não. Se a tarefa depende do seu contexto, ou é rápida, o cold start não compensa. Building effective agents é explícito em começar simples.
- **"Qual modelo eu uso por padrão?"** — O que você consegue descrever a tarefa pra ele resolver. Se dá pra escrever a spec, comece no barato; suba pro Opus quando precisar de raciocínio que você não consegue descrever.
- **"O tokenizer muda 30% mesmo?"** — É a ordem de grandeza; varia com o conteúdo. Meça com token counting no seu material real antes de cravar número.

---

## Apêndice — RAG a fundo (retrieval-augmented generation)

Isto aqui é o mergulho completo pra você ter domínio do assunto, não só a fala de passagem do slide. É longo de propósito.

### A.1 A definição, e por que ela existe

**RAG = Retrieval-Augmented Generation.** Em uma frase: **antes de perguntar ao modelo, você busca informação relevante numa fonte externa e cola essa informação no prompt, pra que o modelo responda baseado nela em vez de só no que "sabe" do treino.**

Ele nasce de dois limites duros de um LLM:

1. **Conhecimento paramétrico é congelado e genérico.** O que o modelo "sabe" está nos pesos, fixado no fim do treino. Ele não conhece seus dados privados (o wiki interno do banco, os tickets, o código proprietário) nem o que aconteceu depois do corte de treino. E quando não sabe, ele tende a **alucinar** com confiança.
2. **A janela de contexto é finita.** Você poderia colar tudo no prompt — mas "tudo" pode ser 10 mil páginas, o que não cabe, custa caro (blocos 1 e 8) e ainda degrada a qualidade (o *context rot* / *lost in the middle*, mais abaixo).

RAG resolve os dois de uma vez: em vez de colar tudo (não cabe) ou torcer pra o modelo saber (alucina), você **recupera só os poucos trechos que importam pra esta pergunta** e entrega mastigado. O modelo vira um raciocinador sobre um material que você forneceu, não um oráculo de memória.

O termo é de um paper de 2020 (Lewis et al., Facebook AI + UCL) — vale saber a origem pra não achar que é buzzword nova; a técnica antecede o boom atual em anos.

### A.2 O pipeline, parte por parte

RAG clássico tem duas metades: uma **offline** (indexação, feita uma vez / periodicamente) e uma **online** (por consulta, em tempo real).

**Offline — construir o índice:**

1. **Load** — junte as fontes: PDFs, páginas de wiki, tickets, docstrings, o que for.
2. **Chunk (fatiar)** — quebre cada documento em pedaços (chunks) de algumas centenas de tokens. Por que fatiar? Porque você quer recuperar *o parágrafo certo*, não o documento de 80 páginas inteiro. O tamanho do chunk é um tradeoff central (ver A.4).
3. **Embed (vetorizar)** — passe cada chunk por um **modelo de embedding**, que transforma o texto num **vetor** de centenas/milhares de números. A propriedade mágica: textos com *significado parecido* viram vetores *próximos* no espaço. "Como resetar minha senha" e "procedimento de recuperação de acesso" ficam perto, mesmo sem compartilhar palavras.
4. **Store** — guarde os vetores num **vector database** (Pinecone, Weaviate, Qdrant, pgvector no Postgres, Azure AI Search, Elasticsearch) indexado pra busca por proximidade rápida.

**Online — responder uma pergunta:**

5. **Embed a query** — vetorize a pergunta do usuário com o *mesmo* modelo de embedding.
6. **Retrieve (busca por similaridade)** — ache os *k* chunks cujos vetores estão mais próximos do vetor da pergunta. "Próximo" geralmente é **similaridade de cosseno** (o ângulo entre os vetores). Isso é o "top-k retrieval".
7. **(Opcional) Rerank** — reordene esses k candidatos com um modelo mais caro e preciso (um *cross-encoder*), pra empurrar os realmente relevantes pro topo. Melhora muito a qualidade (ver A.5).
8. **Augment** — monte o prompt: instrução + os chunks recuperados + a pergunta. (O famoso "stuff the context".)
9. **Generate** — o modelo responde usando os chunks como fonte. Boa prática: pedir **citação da fonte** e instruir "se não estiver nos trechos, diga que não sabe" — reduz alucinação.

### A.3 Embeddings e busca vetorial, sem hand-waving

O **embedding** é o coração. Um modelo de embedding (ex.: `text-embedding-3` da OpenAI, `voyage` da Voyage AI — que a Anthropic recomenda por não ter modelo de embedding próprio, ou `e5`/`bge` open-source) mapeia texto → vetor num espaço de, digamos, 1.024 dimensões. Nesse espaço, **distância = dissimilaridade semântica**.

- **Similaridade de cosseno** é a métrica usual: mede o ângulo entre dois vetores, ignorando magnitude. Cosseno 1 = mesma direção (muito parecido), 0 = ortogonal (nada a ver).
- **Busca aproximada (ANN)** — comparar a query com milhões de vetores um a um é lento. Vector DBs usam índices aproximados (HNSW é o mais comum) que trocam um tiquinho de precisão por buscas em milissegundos. É por isso que "vector database" é uma categoria de produto, não só um `SELECT`.

Ponto que confunde muita gente: **embedding ≠ o LLM.** É um modelo separado, menor, treinado só pra produzir vetores. Você usa ele na indexação e na busca; o LLM só entra no passo 9.

### A.4 O problema do chunking (onde RAG mais quebra na prática)

Fatiar é onde mora o diabo. Chunk **grande demais**: você recupera muito ruído junto do trecho útil, gasta contexto e dilui a atenção. Chunk **pequeno demais**: o pedaço perde o contexto que o tornava compreensível.

O exemplo canônico: um chunk diz *"A receita cresceu 3% em relação ao trimestre anterior."* Sozinho, esse chunk é quase inútil pra busca — **qual** empresa? **qual** trimestre? A informação que dava sentido estava no cabeçalho do documento, três páginas acima, e sumiu na fatia. Quando a query é "crescimento da receita da ACME no Q2 2025", esse chunk pode nem ser recuperado, porque as palavras/vetores que ligam ele à ACME e ao Q2 não estão nele.

Estratégias pra mitigar: *overlap* entre chunks (sobreposição pra não cortar no meio de uma ideia), chunking por estrutura (por seção/heading em vez de por N tokens fixos), e — a jogada da Anthropic — **Contextual Retrieval** (A.6).

### A.5 Busca por palavra vs por significado, e o híbrido

Dois paradigmas de retrieval, e eles se complementam:

- **Léxica / esparsa (BM25, TF-IDF)** — casa **palavras exatas**. Imbatível pra código de erro, nome de função, SKU, sigla, ID. Falha quando a pergunta usa sinônimos ("carro" vs "automóvel").
- **Semântica / densa (embeddings)** — casa **significado**. Ótima pra linguagem natural e paráfrase. Falha justamente onde a léxica brilha: pode "achar parecido" um `UserServiceV2` quando você queria o `UserService` exato.

**Hybrid search** roda as duas e funde os rankings (ex.: *reciprocal rank fusion*). É o padrão de produção sério hoje, porque cobre os pontos cegos um do outro. Guarde isso: quando alguém diz "meu RAG não acha o que devia", 8 em 10 vezes a resposta é *chunking melhor + híbrido + reranking*, não "trocar de LLM".

**Reranking** é a etapa que mais dá retorno por esforço: você recupera generosamente (ex.: top-50 barato) e passa por um *cross-encoder* que lê query+chunk juntos e dá uma nota de relevância bem melhor que o cosseno, ficando com os top-5. Cohere Rerank e cross-encoders open-source são os usuais.

### A.6 Contextual Retrieval — a contribuição da Anthropic

É a resposta direta ao problema de chunking do A.4, e é o artigo que está no slide. A ideia: **antes de embutir cada chunk, use um LLM barato pra prepender um resumo curto do contexto daquele chunk dentro do documento** — ex.: transformar *"A receita cresceu 3%..."* em *"[Relatório da ACME, Q2 2025, seção Finanças] A receita cresceu 3%..."*. Aí você embute e indexa (BM25 também) o chunk **já contextualizado**.

Resultado que a Anthropic reporta: **até 49% menos falhas de recuperação** com Contextual Embeddings + Contextual BM25, e **até 67% menos** combinando com reranking. O custo de rodar o LLM em cada chunk fica viável graças a **prompt caching** (olha o bloco 1 de novo aparecendo). Tem cookbook com implementação.

### A.7 Como o RAG falha (pra você não vender como bala de prata)

- **Retrieval miss** — o chunk certo existe mas não foi recuperado (chunking ruim, query mal formulada, só busca densa sem léxica). Se não recuperou, o modelo não tem como responder — e pior, pode alucinar em cima do que recuperou errado.
- **Ruído recuperado** — você trouxe 10 chunks, 2 relevantes e 8 distratores. LLM se distrai com contexto irrelevante; qualidade cai. Menos-e-melhor > mais.
- **Contexto perdido no chunk** (A.4).
- **Índice velho** — a fonte mudou, o índice não foi reconstruído; o modelo responde com dado desatualizado, parecendo confiante.
- **Alucinação apesar do retrieval** — o modelo ignora as fontes e "completa" com o paramétrico. Mitiga com prompt ("responda só com base nos trechos; cite; se faltar, diga que não sabe") e com verificação de citação.
- **Segurança** — se o retrieval traz conteúdo de fonte não confiável, isso é um vetor de *prompt injection indireto* (um doc malicioso no índice manda instruções pro modelo). Retrieval amplia a superfície de ataque.

### A.8 Avaliação (como saber se o seu RAG presta)

Separe as duas metades, porque elas falham por motivos diferentes:

- **Qualidade do retrieval:** *recall@k* (a fração de perguntas em que o chunk certo apareceu no top-k) e *precision@k*. Se o recall é baixo, o gerador nem tem chance — conserte o retrieval primeiro.
- **Qualidade da geração:** *faithfulness/groundedness* (a resposta se sustenta nos trechos recuperados?) e *answer relevance* (responde a pergunta?). Frameworks como **RAGAS** e **TruLens** automatizam essas métricas usando um LLM como juiz.

Regra de ouro de depuração: **retrieval primeiro, geração depois.** A maioria dos "RAGs ruins" são problemas de recuperação disfarçados de problema de modelo.

### A.9 RAG vs janela longa vs fine-tuning (a decisão que importa)

Três formas de "dar conhecimento" ao modelo — não são a mesma coisa:

- **RAG** — conhecimento **dinâmico, grande, que muda** (docs, base de conhecimento, dados por usuário). Fácil de atualizar (reindexa), dá rastreabilidade (cita a fonte), não retreina nada. É o default pra "responder sobre nossos dados".
- **Contexto longo (colar tudo no prompt)** — quando o material **cabe** e a tarefa é pontual. Modelos de janela enorme (centenas de milhares de tokens) reduziram a necessidade de RAG *para volumes médios* — mas atenção ao **"Lost in the Middle"**: modelos usam melhor o que está no **começo e no fim** do contexto e "perdem" o que está no meio. Ou seja: janela grande não é o mesmo que atenção uniforme; jogar 200 páginas no prompt raramente é ótimo, e ainda custa caro por token a cada turno (bloco 1). RAG + reranking coloca o relevante no topo *de propósito*.
- **Fine-tuning** — ensina **comportamento, formato, tom, uma habilidade** — não fatos voláteis. Se você precisa que o modelo *saiba um fato novo*, fine-tuning é a ferramenta errada (caro, difícil de atualizar, e ele ainda alucina nas bordas). Se você precisa que ele *responda sempre num formato específico* ou domine um estilo, aí sim.

O erro comum é usar fine-tuning pra injetar conhecimento (deveria ser RAG) ou usar RAG pra corrigir formato (deveria ser prompt/fine-tuning). Frequentemente a resposta certa é **RAG + um bom prompt**, e fine-tuning só quando sobra necessidade.

### A.10 Agentic search / just-in-time retrieval — e por que isso conecta com a sua palestra

Aqui está o gancho que faz o RAG pertencer à *sua* tese, não ser um apêndice solto.

RAG clássico é **retrieval na frente**: você decide *antes* quais chunks entram, com um pipeline fixo de embeddings pré-computados. A Anthropic (e o Claude Code) defende uma alternativa pra agentes: **agentic search / just-in-time retrieval** — em vez de pré-indexar tudo, dê **ferramentas de busca** ao modelo e deixe **ele** decidir o que buscar, quando, e iterar (buscar, ler, refinar a busca, ler mais). O `grep`/leitura de arquivos do Claude Code é exatamente isso: retrieval sob demanda, decidido pelo agente, em vez de um vector store pré-montado.

Por que isso importa pra um time de código: para **codebases**, agentic search costuma **ganhar** do RAG por embeddings, porque:
- o código tem estrutura navegável de graça (imports, referências, tipos) que a busca agêntica segue;
- não há um pipeline de indexação pra manter atualizado a cada commit;
- o agente vê o estado **atual** do arquivo, não um embedding de duas semanas atrás.

E é literalmente a **mesma tese da palestra inteira**: *buscar sob demanda > carregar tudo.* Repare como três coisas suas são a mesma ideia:
- **CLAUDE.md com ponteiros** ("detalhes de auth em `docs/auth.md`") = RAG manual: você diz *onde buscar* em vez de colar o doc.
- **Skills / progressive disclosure** = carrega o procedimento só quando a descrição casa.
- **MCP schema sob demanda** = puxa o schema pesado só quando a tool é usada.

Todas são recuperação *just-in-time* do trecho certo, em vez de despejar a base no contexto. RAG é o nome que o mercado deu pra versão "com vector DB" dessa mesma intuição. Por isso, no palco, a menção de passagem fecha: você não muda de assunto — você dá o nome da indústria pra algo que a plateia acabou de ver funcionando três vezes.

### A.11 Quando um time .NET realmente *constrói* RAG (concreto)

RAG não é só "o que o Claude Code faz por baixo" — às vezes você constrói um. Casos típicos num banco:

- **Bot de Q&A sobre a base interna** (Confluence/SharePoint, políticas, normativos) — o caso de uso número um.
- **Suporte / atendimento** ancorado na documentação de produto.
- **Busca semântica** sobre tickets, contratos, jurisprudência regulatória.

Stack no ecossistema .NET (pra você reconhecer os nomes):
- **Microsoft.Extensions.AI** e **Semantic Kernel** — orquestração de LLM/embeddings em C#.
- **Kernel Memory** — serviço de RAG pronto (ingestão, chunking, índice, query) da Microsoft.
- **pgvector** (Postgres), **Azure AI Search** (tem vetorial + híbrido + reranking gerenciado), **Qdrant**, **Elasticsearch** — o lado do vector store.
- Embeddings via Azure OpenAI ou Voyage.

Mensagem honesta pro time: **só construa RAG quando você tem uma base grande, que muda, e que o agente precisa consultar de forma repetível.** Pra "trabalhar no nosso código", agentic search + CLAUDE.md já é a forma certa de retrieval — não precisa montar vector DB do seu repositório.

### A.12 Variantes que você vai ouvir citarem (pra não ser pego de surpresa)

- **GraphRAG** — em vez de (ou além de) chunks soltos, constrói um grafo de entidades/relações e recupera por ele. Bom pra perguntas que exigem conectar fatos espalhados ("quais fornecedores foram afetados por X e também atendem Y?").
- **Reranking / cross-encoders** — já cobri (A.5), mas é o termo que mais aparece.
- **HyDE** (Hypothetical Document Embeddings) — o modelo escreve uma resposta *hipotética* pra query e você usa o embedding *dela* pra buscar (às vezes casa melhor que o da pergunta crua).
- **Multi-query / query expansion** — reescrever a pergunta em várias variações e unir os resultados.
- **Contextual Retrieval** — a da Anthropic (A.6).

---

## Índice de leituras da Anthropic (tudo num lugar)

**Fundamentos / context engineering**
- Effective context engineering for AI agents — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Context engineering cookbook (memory, compaction, tool clearing) — https://platform.claude.com/cookbook/tool-use-context-engineering-context-engineering-tools
- Building effective agents — https://www.anthropic.com/research/building-effective-agents

**Custo / tokens / cache**
- Pricing — https://platform.claude.com/docs/en/about-claude/pricing
- Prompt caching (docs) — https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- Prompt caching (anúncio) — https://www.anthropic.com/news/prompt-caching
- Claude Code prompt caching — https://code.claude.com/docs/en/prompt-caching
- Token counting — https://platform.claude.com/docs/en/build-with-claude/token-counting

**Claude Code / prática**
- Best practices — https://code.claude.com/docs/en/best-practices
- How Claude Code works in large codebases — https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start
- How Anthropic teams use Claude Code (PDF) — https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf
- Create custom subagents — https://code.claude.com/docs/en/sub-agents
- Subagents (blog) — https://claude.com/blog/subagents-in-claude-code

**Skills**
- Equipping agents for the real world with Agent Skills — https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- Agent Skills (docs) — https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- anthropics/skills — https://github.com/anthropics/skills

**MCP**
- Introducing the Model Context Protocol — https://www.anthropic.com/news/model-context-protocol
- Especificação — https://modelcontextprotocol.io

**RAG (Anthropic)**
- Contextual Retrieval in AI Systems (o artigo do slide) — https://www.anthropic.com/news/contextual-retrieval
- Effective context engineering (a seção de *just-in-time retrieval* / agentic search vs RAG clássico) — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Embeddings com Voyage AI (a Anthropic não tem modelo de embedding próprio) — https://docs.claude.com/en/docs/build-with-claude/embeddings

> Nota: URLs da Anthropic às vezes migram entre `anthropic.com`, `claude.com`, `platform.claude.com` e `code.claude.com`. Se algum link cair, procure pelo **título** do artigo — o conteúdo continua existindo, só muda de endereço.

---

## Leituras fora da Anthropic (também valem)

Fontes de terceiros que são referência real no assunto — não marketing. (URLs de terceiros mudam mais ainda; se cair, o **título** entre aspas acha.)

**Papers fundamentais**
- Lewis et al. (2020), *"Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks"* — o paper que cunhou RAG — https://arxiv.org/abs/2005.11401
- Liu et al. (2023), *"Lost in the Middle: How Language Models Use Long Contexts"* — a base empírica do "atenção não é uniforme na janela" — https://arxiv.org/abs/2307.03172
- Karpukhin et al. (2020), *"Dense Passage Retrieval for Open-Domain QA"* (DPR) — a origem do retrieval denso com embeddings — https://arxiv.org/abs/2004.04906
- Gao et al. (2022), *"Precise Zero-Shot Dense Retrieval without Relevance Labels"* (o paper do HyDE) — https://arxiv.org/abs/2212.10496

**Guias práticos de referência (hubs de aprendizado)**
- Pinecone Learning Center — RAG, chunking, hybrid search, reranking, explicados a fundo — https://www.pinecone.io/learn/
- Weaviate Blog / docs — bom material sobre busca híbrida e vetorial — https://weaviate.io/blog
- OpenAI Cookbook — receitas de embeddings e RAG (agnósticas o suficiente pra aproveitar) — https://cookbook.openai.com
- Microsoft GraphRAG — projeto e paper de RAG com grafo — https://github.com/microsoft/graphrag

**Avaliação de RAG**
- RAGAS (framework de métricas: faithfulness, answer/context relevance) — https://docs.ragas.io
- TruLens (avaliação e tracing de apps RAG/LLM) — https://www.trulens.org

**Ecossistema .NET (se o time for construir)**
- Semantic Kernel (Microsoft) — https://learn.microsoft.com/en-us/semantic-kernel/
- Kernel Memory (Microsoft) — serviço de RAG pronto — https://github.com/microsoft/kernel-memory
- pgvector (busca vetorial no Postgres) — https://github.com/pgvector/pgvector
- Azure AI Search (vetorial + híbrido + reranking gerenciado) — https://learn.microsoft.com/en-us/azure/search/

**Leitura avulsa que vale**
- Simon Willison sobre o Contextual Retrieval da Anthropic (resumo crítico e didático) — https://simonwillison.net/2024/Sep/20/introducing-contextual-retrieval/
