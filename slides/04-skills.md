---
layout: section
---

# 4. Pilar 3 — Skills

Procedimentos que só pesam quando você usa

---

# Um procedimento que o agente carrega sob demanda

Uma pasta com um `SKILL.md` (nome + descrição + instruções) e, opcionalmente, scripts. O Claude lê a descrição, decide se é relevante, e só então carrega o conteúdo completo.

<v-clicks>

- Exemplos: "fazer deploy", "gerar uma migration", "rodar o checklist de PR"
- O agente **escolhe sozinho** quando usar, pela descrição
- Pode embutir scripts → trabalho determinístico sai dos tokens e vira código executado

</v-clicks>

---

# Por que Skills são baratas

<div class="grid grid-cols-2 gap-8 pt-4">

<div>

### Em repouso

Só o **nome + descrição** da skill estão no contexto — poucos tokens

</div>

<div>

### Quando acionada

Aí sim o SKILL.md inteiro entra no contexto

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

Você pode ter 20 skills e pagar quase nada por elas até precisar de uma.<br/>Compare com colar o procedimento inteiro no CLAUDE.md — que pesaria sempre.

</div>

</v-click>

---

# Quando vira Skill, quando fica no CLAUDE.md

<div class="grid grid-cols-2 gap-8 pt-4">

<div>

### CLAUDE.md

Fato sempre-relevante do projeto: o que é, onde está, convenção geral

</div>

<div>

### Skill

Procedimento ocasional, com passo a passo: deploy, scaffold, checklist

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

Se você consultaria **toda tarefa** → CLAUDE.md.<br/>Se é um **roteiro que você segue de vez em quando** → Skill.

</div>

</v-click>

<!-- EXEMPLO REAL: citar 1 procedimento real do time que seria uma boa skill — ex.: o passo a passo de criar um novo endpoint seguindo o padrão da casa, ou o checklist de deploy. -->
