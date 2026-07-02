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

O sub-agente começa do zero. Ele **não** tem o seu histórico — precisa redescobrir o que já era óbvio pra você. Isso tem um custo fixo toda vez que você dispara.

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

# Na prática: como você dispara

Não precisa de nada especial na maioria dos casos — você descreve a tarefa e o Claude decide delegar sozinho, rodando o sub-agente e trazendo só o resultado de volta.

<v-clicks>

- Pra padronizar, dá pra definir sub-agentes próprios com `/agents`: cada um com seu prompt, suas ferramentas e **seu próprio modelo**
- Um agente de busca pode rodar em Haiku enquanto a sua sessão está em Opus — barato pra vasculhar, forte pra decidir

</v-clicks>

<v-click>

<div class="pt-6 text-center text-xl">

É aqui que sub-agent encosta em roteamento de modelo (bloco 8):<br/>quem faz o trabalho braçal não precisa ser o modelo caro.

</div>

</v-click>

---

# Exemplo: fan-out num monorepo

<!-- RASCUNHO — trocar pelo caso real do time. Ideia: uma tarefa que se divide em N investigações independentes,
     cada uma num sub-agente, rodando em paralelo, devolvendo só o resumo. Ajustar os números e os nomes de serviço. -->

Precisa saber quais dos **[N]** serviços do monorepo ainda chamam a `[API/lib legada]`. Sozinho, é abrir um por um, em série, entupindo a sessão de código lido.

<div class="grid grid-cols-2 gap-6 pt-2">

<div class="border border-red-400 rounded-lg p-4">

### ❌ Sessão única

Lê os [N] serviços em sequência. Cada arquivo aberto fica no seu contexto até o fim — e você paga por ele em todo turno seguinte.

</div>

<div class="border border-green-500 rounded-lg p-4">

### ✅ Fan-out

[N] sub-agentes, um por serviço, em paralelo. Cada um devolve só *"usa / não usa, aqui está a linha"*. Sua sessão recebe [N] respostas curtas.

</div>

</div>

<v-click>

<div class="pt-4 text-center text-lg">

<!-- TODO: se tiver número real (tempo ou tokens desta apresentação/de um projeto), colocar aqui — fica muito mais palpável. -->
O trabalho de ler [N] repositórios inteiros nunca chega na sua janela — só a conclusão de cada um.

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
