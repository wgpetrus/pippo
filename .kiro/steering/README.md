# Steering - Padrões da Empresa

> **Regras obrigatórias para todos os projetos Flutter.**

---

## Arquivos

| Arquivo | Conteúdo |
|---------|----------|
| [architecture.md](./architecture.md) | Estrutura de pastas, navegação, nomenclatura |
| [code-rules.md](./code-rules.md) | Regras de código, controllers, views |
| [firebase.md](./firebase.md) | Error handlers, conversão de datas |
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
