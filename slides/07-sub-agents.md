---
layout: section
---

# 7. Sub-agents — quando valem

Delegar sem poluir a sessão principal

---

# Um agente com a própria janela de contexto

Você dispara um sub-agente pra uma tarefa; ele trabalha numa janela de contexto **separada** e devolve só o **resultado final** pra sessão principal.

<v-click>

<div class="pt-6 text-center text-xl">

O trabalho sujo dele — buscas, arquivos lidos, tentativas — **não** entope a sua conversa.

</div>

</v-click>

---

# Cold start vs contexto isolado

<div class="grid grid-cols-2 gap-8 pt-4">

<div>

### Custo — cold start

O sub-agente começa do zero. Ele **não** tem o seu histórico — re-descobre o que precisa. Disparar tem overhead.

</div>

<div>

### Ganho — contexto isolado

Todo o ruído intermediário fica na janela dele. A sua sessão principal recebe só a conclusão, limpa.

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

A pergunta é sempre: o overhead de começar do zero compensa manter o ruído fora?

</div>

</v-click>

---

# A régua

<div class="grid grid-cols-2 gap-6 pt-2">

<div class="border border-green-500 rounded-lg p-4">

### ✅ Vale

- Fan-out: várias buscas/tarefas independentes em paralelo
- Tarefa longa e isolada cujo trabalho intermediário você não precisa ver

</div>

<div class="border border-red-400 rounded-lg p-4">

### ❌ Não vale

- Coisinha rápida (um `grep`, ler um arquivo) — o cold start custa mais que o trabalho
- Tarefa que **depende** do contexto da sua conversa (ele não tem)

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

Sub-agent é para isolar trabalho pesado e paralelizável —<br/>não para terceirizar o que você faria em dois cliques.

</div>

</v-click>
