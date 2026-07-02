---
layout: section
---

# 6. MCPs — poder e tradeoffs

Conectar o agente ao mundo — com consciência do custo

---

# O agente conectado a ferramentas de verdade

MCP (Model Context Protocol) liga o Claude a sistemas externos — GitHub, Jira, banco de dados, Sentry — de forma padronizada. Ele deixa de só conversar e passa a **agir** e a **ler dados ao vivo**.

<v-clicks>

- Sem copia-e-cola: o agente lê o ticket, abre o PR, consulta o log
- Padronizado: o mesmo protocolo serve pra vários serviços

</v-clicks>

---

# O imposto que você não vê

Cada servidor MCP **habilitado** injeta o nome de cada ferramenta e uma instrução curta do servidor no contexto — em **todo turno**, mesmo que você não use nenhuma delas naquela conversa. (O schema completo de cada tool é a parte mais pesada — essa vem depois, sob demanda.)

<div class="grid grid-cols-2 gap-8 pt-4">

<div>

### 1 MCP habilitado

Nomes + instrução → X tokens em todo turno

</div>

<div v-click>

### 10 MCPs habilitados

10× nomes + instruções → N tokens **antes de você escrever qualquer coisa**

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

Ligar dez MCPs "por garantia" é o mesmo erro do CLAUDE.md gigante:<br/>capacidade que você paga sempre, mesmo que leve, e usa quase nunca.

</div>

</v-click>

---

# Exemplo: navegação web

<div class="grid grid-cols-2 gap-6 pt-2">

<div class="border border-green-500 rounded-lg p-4">

### ✅ Só ler uma página

`WebFetch` — leve, traz o conteúdo e pronto.

Sem MCP, sem schema extra pra carregar.

</div>

<div class="border border-red-400 rounded-lg p-4">

### ⚠️ Interagir de verdade

MCP do Playwright — clicar, preencher, screenshot.

Muitas ferramentas, schemas grandes.

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

Use a ferramenta pesada só quando a tarefa pede interação real.<br/>Para ler, o leve resolve.

</div>

</v-click>

---

# Curiosidade: ler leve não é ideia da Anthropic

O tradeoff "buscar conteúdo direto vs. abrir um navegador completo" não é exclusividade do Claude — é um padrão que o mercado inteiro de agentes convergiu.

<v-clicks>

- Praticamente todo assistente de código com acesso à web tem os dois modos: um fetch leve (pega a página, extrai o texto) e um MCP/plugin de browser automation (Playwright, Puppeteer) pra quando precisa de interação real
- A ideia por trás é sempre a mesma: não pague o custo de um navegador inteiro — schemas, sessão, DOM — só pra ler um artigo ou uma doc

</v-clicks>

<v-click>

<div class="pt-6 text-center text-xl">

E o CLAUDE.md pode reforçar isso: uma instrução como<br/>
<code>"prefira WebFetch a MCPs de browser; só use automação se precisar interagir"</code><br/>
já orienta o agente a escolher a via mais barata por padrão.

</div>

</v-click>

---

# O gatilho, na prática

"Habilitado" não quer dizer "schema sempre no contexto". São **dois portões** diferentes.

<div class="grid grid-cols-2 gap-6 pt-4">

<div class="border border-blue-400 rounded-lg p-4">

### 1. Ligar o servidor

Decisão manual, feita antes da tarefa — por comando ou por configuração salva no projeto.

Servidor desligado = custo zero. A tarefa não liga nada sozinha.

</div>

<div class="border border-orange-400 rounded-lg p-4">

### 2. Carregar o schema

De servidor **ligado**, só o nome da ferramenta e uma instrução curta entram no contexto no início da sessão.

O schema completo de cada tool só é puxado quando o agente, durante a tarefa, decide que precisa dela.

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

"Ligado" cobra todo turno. "Usado" cobra por tarefa.<br/>
Você só decide o primeiro — e é ele que compensa cortar.

</div>

</v-click>

---

# Onde essa decisão fica

`/mcp` liga e desliga na hora, dentro da sessão. Pra deixar fixo no projeto, a lista vai no `settings.json`:

```json
{
  "enabledMcpjsonServers": ["github", "postgres"],
  "disabledMcpjsonServers": ["figma", "shopify", "blender"]
}
```

<v-click>

<div class="pt-4 text-lg">

Comitado no repo, o time inteiro herda a mesma escolha — ninguém precisa lembrar de desligar nada a cada sessão.

</div>

</v-click>

---

# Exemplo: seis MCPs disponíveis, três fazem sentido

Projeto .NET, versionado em Git. Dá pra ligar MCP de qualquer coisa "porque um dia pode ser útil" — mas nesse projeto, só três têm o que fazer.

<div class="grid grid-cols-2 gap-6 pt-2 text-sm">

<div class="border border-red-400 rounded-lg p-3">

### ❌ Ligado tudo

- ✅ Git/GitHub
- ✅ Azure DevOps
- ✅ Banco de dados (SQL Server)
- ⚠️ Figma — sem handoff de design
- ⚠️ Shopify — não é loja virtual
- ⚠️ Blender — sem asset 3D aqui

<div class="pt-2 text-xs opacity-70">6 servidores → 6× nome+instrução em todo turno</div>

</div>

<div class="border border-green-500 rounded-lg p-3">

### ✅ Só o que serve

- Git/GitHub
- Azure DevOps
- Banco de dados (SQL Server)

<div class="pt-2 text-xs opacity-70">Nada de útil ficou de fora — só cortou o que nunca ia ser chamado.</div>

</div>

</div>

<v-click>

<div class="pt-4 text-center text-lg">

Essa escolha é feita uma vez, ao configurar o projeto — não a cada prompt.

</div>

</v-click>

---
layout: center
class: text-center
---

# MCPs — a regra

<div class="text-3xl font-bold pt-8 pb-6 leading-snug">

Habilite os MCPs que o <strong>projeto</strong> realmente usa.<br/>Desligue o resto.

</div>

<v-click>

<div class="text-xl opacity-80 pt-4">

Decisão de configuração, do contrário o contexto pode ser maior a cada prompt desnecessariamente.

</div>

</v-click>

<!-- EXEMPLO REAL: se o time já usa algum MCP (Azure DevOps? Jira? um interno?), citar qual e o ganho concreto que ele trouxe — fica muito mais palpável que o exemplo genérico. -->
