# Fluxo de Desenvolvimento

> **⚠️ ATENÇÃO: Nunca executar etapas automaticamente. Sempre aguardar ordem explícita do usuário.**

---

## Etapas

### 1. Extração do Figma

- Identificar theme necessário (cores, fontes, estilos)
- Mapear todas as telas do projeto
- Entender fluxos de navegação

---

### 2. Estruturar Pastas

Criar estrutura de pastas **sem arquivos ainda**:

```
lib/
├── assets/
│   ├── fonts/
│   └── images/
├── features/
│   ├── core/
│   │   └── [feature_name]/
│   │       ├── views/
│   │       ├── controllers/
│   │       └── widgets/
│   ├── inners/
│   │   └── [feature_name]/
│   │       ├── views/
│   │       ├── controllers/
│   │       └── widgets/
│   └── borders/
└── shared/
    ├── routes/
    ├── theme/
    ├── utils/
    └── widgets/
```

**Regras:**
- Pasta `widgets/` é criada junto com a feature
- Pasta `bindings/` **NÃO** é criada ainda (depende das rotas)

---

### 3. Criar Rotas Principais

Definir apenas rotas essenciais (checkpoints de navegação):

```dart
// Exemplo de rotas principais
'/splash'
'/onboarding'
'/auth'
'/setup'
'/home'
```

**Regra:** Nada de rotas demais. Apenas o necessário para linkar navegações.

---

### 4. Definir Wrapper

Criar padrão do Wrapper (splash) seguindo [architecture.md](architecture.md), mas **sem utilizar ainda**.

---

### 5. Adicionar Bindings

Atualizar estrutura de pastas:
- Criar pasta `bindings/` apenas nas features que têm rota própria

```
feature_name/
├── views/
├── controllers/
├── widgets/
└── bindings/      ← adicionar agora
```

---

### 6. Navegação com Placeholders

Implementar navegação funcional com telas placeholder:
- Seguir padrões e regras da empresa
- **Sem controllers ainda** nesta etapa
- Apenas estrutura visual básica

---

## Implementação

### 7. Feature por Feature

Para cada feature, implementar:

1. **UI** — Views e widgets
2. **Controller** — Lógica e estados
3. **Testes** — Cobertura da feature

#### Estrutura de Testes

Espelhar estrutura do projeto:

```
test/
├── features/
│   ├── core/
│   │   └── [feature_name]/
│   │       └── controllers/
│   └── inners/
│       └── [feature_name]/
│           └── controllers/
└── shared/
    ├── utils/
    └── widgets/
```

**Nota:** Views não precisam de testes (não contêm lógica).

---

### 8. Revisão

- Verificar se segue padrões e regras
- Aplicar ajustes necessários

---

## Ciclo

```
┌─────────────────────────────────────┐
│  7. Implementar feature             │
│  8. Revisar padrões                 │
│  ↓                                  │
│  Repetir até finalizar todas        │
└─────────────────────────────────────┘
```

---

## Regra Crítica

> **🚨 NUNCA executar etapas automaticamente.**
> 
> Sempre informar qual etapa será executada e aguardar confirmação.
> Manter em mente a ordem, mas nunca prosseguir sem ordem explícita.
