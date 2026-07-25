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

---

# Limpar também custa — escolha a ferramenta certa

Os comandos são baratos como hábito, mas nem todos são de graça. `/compact` dispara uma requisição extra que **relê o histórico inteiro e gera o resumo** — tokens de output + tempo. `/rewind` não gera nada: trunca de volta a um turno anterior cujo prefixo **já está em cache**.

<div class="pt-2">

| Comando | O que faz | Custo | Quando |
| --- | --- | --- | --- |
| `/clear` | Zera tudo | Barato | Troquei de assunto, não preciso do anterior |
| `/rewind` | Volta a um turno anterior | Barato (prefixo já cacheado) | Fui por um caminho que quero abandonar |
| `/compact` | Troca o histórico por um resumo | Paga a **geração** do resumo | Mesmo assunto, muito acumulado que não vou mais reler |

</div>

<v-click>

<div class="pt-4 text-center text-xl">

A melhor otimização é **não carregar** o que não vai usar.<br/>Analogia .NET: não alocar o objeto grande é melhor que rodar o GC pra recolher depois — o GC (compact) não é de graça.

</div>

</v-click>

---

# O que invalida o cache (e zera a economia)

O cache read barato depende do **prefixo** ficar estável. Mexeu no começo da requisição, o resto recomputa — o próximo turno vem caro.

<div class="grid grid-cols-2 gap-8 pt-2">

<div>

### 💥 Derruba o cache

- Trocar de **modelo** (inclui `opusplan` a cada plan mode)
- Mudar **effort level**
- Ligar **fast mode**
- **MCP** conecta/desconecta (se as tools estão no prefixo)
- Plugin **com MCP** ligado/desligado
- **Negar uma tool** inteira (`Bash`, `WebFetch`…)
- `/compact` (reconstrói o histórico)
- **Upgrade** do Claude Code

</div>

<div v-click>

### ✅ Não mexe no cache

- Editar arquivos do repo
- Editar CLAUDE.md no meio (nem aplica)
- Trocar output style / permission mode
- Invocar skill ou command
- `/recap`, `/rewind`
- Abrir um sub-agent

</div>

</div>

<v-click>

<div class="pt-4 text-center text-lg">

⚠️ Alguns acontecem **sem você pedir**: um MCP reconectando sozinho ou um upgrade derrubam o cache. É a conta subindo "do nada" — quase sempre é isso.

</div>

</v-click>
