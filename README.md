# IA com Eficiência 🧠⚡

Apresentação Slidev de 1h para o time de dev sobre uso eficiente do Claude Code — como evitar ficar sem tokens e usar IA como engenharia, não como sorte.

## Pré-requisitos

- Node.js 18+
- npm

## Instalação

```bash
npm install
```

## Executando localmente

```bash
npm run dev
```

Abre automaticamente em `http://localhost:3030`.

## Scripts disponíveis

| Comando | Descrição |
|---|---|
| `npm run dev` | Inicia o servidor de desenvolvimento com hot reload |
| `npm run build` | Gera build estático na pasta `dist/` |
| `npm run export` | Exporta os slides para PDF (requer Playwright) |

## Estrutura

```
palestra-ia-eficiente/
├── slides.md        # Conteúdo dos slides (único arquivo de edição)
├── specs/           # Especificações e rascunhos
└── dist/            # Build estático (gerado, não versionar)
```

## Conteúdo da apresentação

1. Como os tokens são gastos de verdade
2. Spec-Driven — especificar antes de executar
3. CLAUDE.md hierárquico
4. Skills
5. Higiene de sessão
6. MCPs — poder e tradeoffs
7. Sub-agents
8. Roteamento de modelo
9. Playbook do time

## Nota sobre arquivos de exemplo

Os exemplos usados na apresentação podem conter arquivos confidenciais do projeto. Por isso, esta apresentação **não deve ser publicada** — execute sempre localmente.

Arquivos sensíveis adicionados aos exemplos devem ser listados no `.gitignore` antes de qualquer commit.
