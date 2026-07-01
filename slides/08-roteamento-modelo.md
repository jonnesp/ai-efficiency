---
layout: section
---

# 8. Roteamento de modelo

A decisão que mais pesa no custo do time

---

# Nem toda tarefa precisa do modelo mais caro

Combine o modelo à dificuldade da tarefa. Trivial e bem-especificado → modelo barato. Raciocínio difícil, plano, arquitetura → modelo forte.

<v-clicks>

- **Haiku / Sonnet:** refactor mecânico, boilerplate, tarefa bem-descrita
- **Opus:** planejar, decidir arquitetura, depurar o problema cabeludo

</v-clicks>

---

# O que cada modelo custa

| Modelo | Input (por MTok) | Output (por MTok) |
|---|---|---|
| Haiku 4.5 | $1 | $5 |
| Sonnet 4.6 | $3 | $15 |
| Opus 4.8 | $5 | $25 |

<v-clicks>

- Sonnet ≈ **3× Haiku**
- Opus ≈ **1,67× Sonnet**
- Opus ≈ **5× Haiku**

</v-clicks>

<v-click>

<div class="pt-4 text-center text-xl">

Multiplique isso por cada dev, cada dia.<br/>Trocar o modelo na tarefa certa é a economia mais direta que existe.

</div>

</v-click>

---

# Especifique no forte, execute no barato

<div class="grid grid-cols-2 gap-8 pt-4">

<div>

### Opus — para **pensar**

- O plano
- A spec / arquitetura
- Depurar o problema difícil

</div>

<div>

### Sonnet / Haiku — para **executar**

- O que já está bem-especificado
- Tarefas claras e delimitadas

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

Foi a sua spec clara (bloco 2) e o seu CLAUDE.md (bloco 3) que tornaram seguro<br/>deixar o modelo barato executar.

</div>

</v-click>

<!-- EXEMPLO REAL: se você tem um caso onde planejou no Opus e executou no Sonnet — inclusive esta própria apresentação foi feita assim — vale mencionar como prova viva. -->

---
layout: center
class: text-center
---

# Roteamento — a regra

<div class="text-3xl font-bold pt-8 pb-6 leading-snug">

Se você consegue descrever o resultado,<br/>um modelo barato consegue entregar.

</div>

<v-click>

<div class="text-xl opacity-80 pt-4">

Quando você <strong>não</strong> consegue descrever — é tarefa de Opus.

</div>

</v-click>
