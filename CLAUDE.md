# Projeto

Palestra em **Slidev** (Vue + Markdown) sobre uso eficiente de tokens com IA. Deck em pt-BR, público: o time de dev.

# Estrutura

- `slides.md` — **índice**: frontmatter global + capa/problema/sumário + imports `src:` das seções. Edite aqui só a intro ou a ordem das seções.
- `slides/NN-nome.md` — uma seção por arquivo. Para ajustar uma seção, edite só o arquivo dela (evita reler o deck inteiro).
- `specs/` — rascunhos de conteúdo.
- `dist/`, `node_modules/` — gerados, ignorados. Não leia nem edite.

# Comandos

- Dev: `npm run dev` (abre no browser)
- Build: `npm run build`
- Export PDF: `npm run export`

# Convenções dos slides

- Separador de slide: `---` em linha própria; frontmatter por slide entre `---`.
- Animações: `<v-click>` / `<v-clicks>`. Layout via frontmatter (`layout: section`, `layout: center`).
- Tom: direto, técnico-acessível, sem hype. Exemplos em .NET/C# quando ilustrarem código.
- Preços/números de tokens: conferir antes de alterar — o deck cita valores reais.

# Ao editar

- Peça/edite pela seção (ex.: "seção de MCPs" → `slides/06-mcps.md`), não pelo deck todo.
- Rode `npm run build` para validar que os `src:` continuam resolvendo.
