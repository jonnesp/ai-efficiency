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
| Sonnet 5 | $2 | $10 |
| Opus 4.8 | $5 | $25 |

<v-clicks>

- Sonnet ≈ **2× Haiku**
- Opus ≈ **2,5× Sonnet**
- Opus ≈ **5× Haiku**

</v-clicks>

<div class="pt-2 text-xs opacity-60">Sonnet 5 a $2/$10 é preço introdutório até 31/08/2026 — depois vai pra $3/$15.</div>

<v-click>

<div class="pt-4 text-center text-xl">

Multiplique isso por cada dev, cada dia.<br/>Trocar o modelo na tarefa certa é a economia mais direta que existe.

</div>

</v-click>

---

# O preço por token não conta tudo

Os modelos mais novos (Sonnet 5, Opus 4.7+) usam um tokenizer diferente do Haiku 4.5: pro **mesmo texto**, eles contam cerca de **30% mais tokens**.

<v-clicks>

- O mesmo arquivo, o mesmo prompt, vira mais tokens no Sonnet 5 e no Opus do que no Haiku
- Ou seja: o preço por MTok da tabela **subestima** o custo real dos modelos novos quando você compara com o Haiku
- Na prática o Haiku leva vantagem dupla na tarefa simples — mais barato por token **e** contando menos tokens pro mesmo trabalho

</v-clicks>

<v-click>

<div class="pt-6 text-center text-xl">

Não compare modelos só pela coluna de preço.<br/>O que fecha a conta é preço por token <strong>×</strong> quantos tokens aquele modelo gera.

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

---

# Exemplo: a mesma tarefa, dois modelos

<!-- RASCUNHO — preencher com número real. Melhor caso: esta própria apresentação (planejada no Opus, executada no Sonnet),
     ou uma feature de um projeto seu. Pegar do /usage: tokens de input/output por etapa e o custo de cada uma. -->

Uma feature bem-especificada: **[breve descrição da tarefa]**. Plano fechado no Opus, execução delegada.

<div class="grid grid-cols-2 gap-6 pt-2">

<div class="border border-red-400 rounded-lg p-4">

### Tudo no Opus

- [X] tokens in / [Y] tokens out
- Custo: **$[valor]**

</div>

<div class="border border-green-500 rounded-lg p-4">

### Plano no Opus, execução no Sonnet

- Plano: [x] tokens no Opus
- Execução: [z] tokens no Sonnet
- Custo: **$[valor menor]**

</div>

</div>

<v-click>

<div class="pt-4 text-center text-lg">

<!-- TODO: fechar com o % de economia real desta comparação. -->
Mesma entrega. A diferença foi só **em qual modelo cada etapa rodou**.

</div>

</v-click>

---

# Onde você troca o modelo

Trocar é barato — o que custa é esquecer no modelo errado.

<v-clicks>

- `/model` troca o modelo da sessão na hora (e salva como padrão pras próximas)
- Plan mode e sub-agentes podem rodar num modelo diferente do de execução
- Hábito prático: planeja no Opus, dá `/model` pra Sonnet e deixa ele executar a spec

</v-clicks>

<v-click>

<div class="pt-6 text-center text-xl">

O ganho não vem de usar sempre o barato —<br/>vem de estar no modelo certo em cada etapa.

</div>

</v-click>

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
