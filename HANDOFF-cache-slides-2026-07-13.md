# Handoff — slides de prompt caching (sessão 2026-07-13)

Documento para aplicar em um **fork** do projeto `palestra-ia-eficiente` que tem outras mudanças.
Não é preciso varrer o diff: abaixo estão os **anchors exatos** e o **conteúdo completo** de cada slide novo.

Tema das adições: mecânica de prompt caching do Claude Code (read/write/input, invalidação de cache,
custo de `/clear` `/compact` `/rewind`). Referência: https://code.claude.com/docs/en/prompt-caching

Estrutura do projeto: deck modular. `slides.md` é só o índice; cada bloco é `slides/NN-nome.md`.
Editar sempre pela seção. Validar com `npm run build` (deve terminar em `✓ built`).

---

## Resumo (3 slides novos, 2 arquivos)

| # | Arquivo | Slide novo | Posição |
|---|---------|-----------|---------|
| 1 | `slides/01-tokens.md` | **A esteira: o que é read, write e input num turno** | entre "Nem todo token custa igual" e "Caso real" |
| 2 | `slides/05-higiene-sessao.md` | **Limpar também custa — escolha a ferramenta certa** | no fim, após "Três comandos, zero custo" |
| 3 | `slides/05-higiene-sessao.md` | **O que invalida o cache (e zera a economia)** | no fim, logo após o slide #2 |

Nenhuma linha existente foi removida ou alterada — só inserções. Nenhuma mudança em `slides.md`.

---

## Mudança 1 — `slides/01-tokens.md`

**Anchor:** inserir um novo slide ENTRE o slide "Nem todo token custa igual" e o slide "Caso real — esta própria apresentação".

O slide "Nem todo token custa igual" termina com este bloco:

```md
O cache é o que torna o reenvio do contexto viável: reler custa **1/10**.<br/>
Mas atenção ao volume — numa sessão longa, o cache read relê **tudo, a cada turno**.

</div>

</v-click>
```

Logo depois vem o separador `---` e o `# Caso real — esta própria apresentação`.
**Inserir o slide abaixo entre esses dois** (ou seja: após o `</v-click>` acima e antes do `# Caso real`):

````md
---

# A esteira: o que é read, write e input num turno

A cada turno a requisição tem sempre a mesma forma. Só a **ponta** é nova:

```
Turno N:
[========== cache read (0,1×) ==========][ write (1,25×) ][ input (1×) ]
 system + tools + CLAUDE.md + histórico    delta novo        sua msg
 (tudo que já estava selado)               sendo selado      de agora
```

<div class="grid grid-cols-3 gap-4 pt-4 text-sm">

<div class="border border-green-500 rounded-lg p-3">

**🟢 cache read** — o prefixo que já existia. A **maior** fatia e a mais barata. Relido inteiro todo turno.

</div>

<div class="border border-blue-400 rounded-lg p-3">

**🔵 cache write** — só o **delta** desde a última selagem. Cada pedaço passa aqui **uma vez** na vida.

</div>

<div class="border border-gray-400 rounded-lg p-3">

**⚪ input 1×** — só a sua **mensagem nova**. A ponta ainda não selada. Sempre pequena.

</div>

</div>

<v-click>

<div class="pt-4 text-center text-lg">

A ponta escorrega pra esquerda a cada turno: sua msg de hoje é **input** → amanhã vira **write** → depois **read pra sempre**.<br/>
<span class="opacity-80">É por isso que, no `/usage`, o **read domina** e o input fica minúsculo.</span>

</div>

</v-click>
````

---

## Mudança 2 e 3 — `slides/05-higiene-sessao.md`

**Anchor:** anexar no FIM do arquivo. O último slide existente termina assim:

```md
`/clear` zera o contexto; plan mode trava edição até aprovação; compactação dirigida preserva o que importa.<br/>**Três comandos, zero custo.**

</div>

</v-click>
```

**Adicionar os dois slides abaixo logo após esse `</v-click>` final:**

````md
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
````

---

## Depois de aplicar

1. Rodar `npm run build` — deve terminar em `✓ built`. Os avisos de `PLUGIN_TIMINGS`/rolldown são pré-existentes, ignorar.
2. (Opcional) `npm run dev` para conferir os 3 slides no browser.

## Notas de estilo (convenções do deck — respeitar no fork)

- Tom: dev explicando pra dev, sem hype. Evitar "curadoria", "alavancar", "sinergia", "otimizar", "potencializar".
- Code blocks de diagrama ASCII: usar ``` sem language hint (com `mdc: true`, `bash`/`gitignore` + `**` quebra o slide).
- Preços citados: cache write 1,25× (TTL 5min) / 2× (TTL 1h); cache read 0,1×; output 5×. Conferir antes de alterar.
