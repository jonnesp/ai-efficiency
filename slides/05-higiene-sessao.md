---
layout: section
---

# 5. Higiene de sessão

Ganhos de eficiência que não custam nada

---

# Uma tarefa, uma sessão

Cada turno reenvia todo o histórico. Arrastar a tarefa B dentro da sessão cheia da tarefa A faz a B pagar pelo contexto da A.

<v-clicks>

- Terminou a tarefa? `/clear` antes de começar outra **não relacionada**
- Contexto limpo = turnos baratos de novo (a curva reseta)
- Regra: trocou de assunto, `/clear`

</v-clicks>

<v-click>

<div class="pt-6 text-center text-xl">

É o hábito de maior retorno: custa um comando e barateia todos os turnos seguintes.

</div>

</v-click>

---

# Planeje antes de deixar editar

No plan mode o agente **explora e propõe** um plano sem tocar no código. Você aprova, aí ele executa.

<div class="grid grid-cols-2 gap-8 pt-4">

<div>

### ❌ Sem plano

Ele tenta, erra a abordagem, refaz → tokens gastos em caminho errado

</div>

<div v-click>

### ✅ Com plano

Você corrige a **direção** antes de qualquer edição — barato

</div>

</div>

<v-click>

<div class="pt-6 text-center text-xl">

Isso funciona porque a spec já estava clara — o agente sabe o suficiente para propor algo concreto.

</div>

</v-click>

---

# Plan mode — o que aparece na prática

<div class="grid grid-cols-2 gap-6 pt-2">

<div class="border border-gray-400 rounded-lg p-4 text-sm">

**Você escreve:**

```
Adiciona validação: ValorCentavos deve ser > 0
em POST /api/v2/transferencias.
Retorna 422 com "Valor deve ser positivo".
Arquivo: Application/UseCases/TransferenciaUseCase.cs
Não altere testes existentes.
```

</div>

<div v-click class="border border-blue-400 rounded-lg p-4 text-sm">

**O agente propõe (sem tocar no código):**

```
Plano de execução:

1. Localizar método Handle em
   TransferenciaUseCase.cs
2. Adicionar guard clause antes
   da chamada ao repositório
3. Retornar 422 com a mensagem
   especificada
4. Verificar padrão de erro do
   projeto para validações

Aguardando aprovação.
```

</div>

</div>

<v-click>

<div class="pt-4 text-center text-xl">

Você lê, ajusta a direção se precisar — e só então o agente escreve código.

</div>

</v-click>

---

# Quando a sessão precisa continuar longa

Tarefa longa, mas ainda é o mesmo assunto? Não dá pra usar `/clear`. Use `/compact` **você mesmo**, sem esperar o limite — o Claude Code também compacta sozinho perto do limite, mas aí você não escolhe o que sobra.

<v-clicks>

- `/compact` sozinho: resumo genérico, decide por conta própria o que é relevante
- `/compact <instrução>`: você direciona — ex. `/compact mantenha as decisões de arquitetura e os erros já descartados, descarte trechos de código já aplicados`
- Rode antes de virar de fase (ex. terminou o plano, vai começar a implementar) — resume o que já foi decidido e libera espaço pro que vem

</v-clicks>

<v-click>

<div class="pt-6 text-center text-xl">

`/clear` zera o contexto; plan mode trava edição até aprovação; compactação dirigida preserva o que importa.<br/>**Três comandos, zero custo.**

</div>

</v-click>
