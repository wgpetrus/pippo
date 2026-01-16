# Steering - Padrões da Empresa

> **Regras obrigatórias para todos os projetos Flutter.**

---

## Arquivos

### Padrões Fixos (todos os projetos)

| Arquivo | Conteúdo |
|---------|----------|
| [code-rules.md](./code-rules.md) | Regras gerais e resumo de todas as regras |
| [architecture.md](./architecture.md) | Estrutura de pastas, navegação, nomenclatura |
| [dev-flow.md](./dev-flow.md) | Fluxo de desenvolvimento etapa por etapa |
| [getx-patterns.md](./getx-patterns.md) | Controllers, Views, Obx, navegação |
| [forms-validation.md](./forms-validation.md) | Padrão de formulários e validação |
| [firebase.md](./firebase.md) | Error handlers padronizados, conversão de datas |
| [project-structure.md](./project-structure.md) | Organização de arquivos e imports |
| [styling-guide.md](./styling-guide.md) | Theme, fontes, ícones e packages de UI |
| [responsive.md](./responsive.md) | Responsividade, breakpoints, SafeArea |
| [security-storage.md](./security-storage.md) | SharedPreferences, SecureStorage, segurança |
| [conventions.md](./conventions.md) | Comentários, mensagens e formatação |

### Por Projeto

| Arquivo | Conteúdo |
|---------|----------|
| [project.md](./project.md) | Definição do projeto (preencher por projeto) |

---

## Regras Gerais

### Stack
- **GetX** para state management, navegação e injeção de dependência

### Idioma
- Comentários em **português**
- Mensagens de erro em **português** e amigáveis (nunca técnico)

### Commits
- Kiro **nunca faz commits automaticamente**
- Apenas avisa quando é hora de commitar e sugere a mensagem

**Tipos de commit:**
- `feat:` nova funcionalidade
- `fix:` correção de bug
- `refactor:` refatoração sem mudar comportamento
- `chore:` manutenção (deps, configs)

---

## Princípios

1. **Código enxuto** — sem complexidade desnecessária
2. **Cada coisa no seu lugar** — estrutura organizada
3. **Padrões consistentes** — mesma forma em todo projeto
