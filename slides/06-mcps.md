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

Cada servidor MCP injeta as **definições das suas ferramentas (schemas)** no contexto — em **todo turno**, mesmo que você não use nenhuma delas naquela conversa.

<div class="grid grid-cols-2 gap-8 pt-4">

<div>

### 1 MCP habilitado

Schema das ferramentas → X tokens em todo turno

</div>

<div v-click>

### 10 MCPs habilitados

10× schemas → N tokens **antes de você escrever qualquer coisa**

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

Ligar dez MCPs "por garantia" é o mesmo erro do CLAUDE.md gigante:<br/>capacidade que você paga sempre e usa quase nunca.

</div>

</v-click>

---

# Exemplo: navegação web

<div class="grid grid-cols-2 gap-6 pt-2">

<div class="border border-green-500 rounded-lg p-4">

### ✅ Só ler uma página

`WebFetch` — leve, traz o conteúdo e pronto.

Quase zero overhead de schema.

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
layout: center
class: text-center
---

# MCPs — a regra

<div class="text-3xl font-bold pt-8 pb-6 leading-snug">

Habilite o MCP que a <strong>tarefa</strong> pede.<br/>Desligue o resto.

</div>

<v-click>

<div class="text-xl opacity-80 pt-4">

Poder sob demanda, não poder por garantia.

</div>

</v-click>

<!-- EXEMPLO REAL: se o time já usa algum MCP (Azure DevOps? Jira? um interno?), citar qual e o ganho concreto que ele trouxe — fica muito mais palpável que o exemplo genérico. -->
