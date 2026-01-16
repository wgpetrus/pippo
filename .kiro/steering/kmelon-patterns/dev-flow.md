# Fluxo de Desenvolvimento

> **⚠️ ATENÇÃO: Nunca executar etapas automaticamente. Sempre aguardar ordem explícita do usuário.**

---

## Etapas

### 1. Extração do Figma

- Identificar theme necessário (cores, fontes, estilos)
- Mapear todas as telas do projeto
- Identificar o que é `_view` e o que é `_page`
- Entender fluxos de navegação

📄 **Documentar em:** `docs/1.preparacao/1-fluxo.md`

---

### 2. Estruturar Pastas

Criar estrutura de pastas com features extraídas da análise do Figma **sem arquivos ainda**:

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

⏳ **Documentação da estrutura:** Aguardar etapa 5 (após bindings)

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

📄 **Documentar em:** `docs/1.preparacao/3-rotas.md`

---

### 4. Definir Wrapper

Criar padrão do Wrapper (splash) seguindo [architecture.md](architecture.md), mas **sem utilizar ainda**.

📄 **Documentar em:** `docs/1.preparacao/4-wrapper.md`

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

📄 **Documentar estrutura COMPLETA em:** `docs/1.preparacao/2-estrutura.md`

---

### 6. Navegação com Placeholders

Implementar navegação funcional com telas placeholder:
- Criar arquivos das telas com nome em placeholder no centro da tela
- Seguir padrões e regras da empresa
- **Sem controllers ainda** nesta etapa
- Apenas estrutura visual básica

📄 **Documentar em:** `docs/1.preparacao/6-navegacao.md`

---

## Implementação de UI

### 7. UI por Tela (ciclo)

Para cada tela, implementar:

1. **UI** — View e widgets (sem lógica, sem controllers)
2. **Dados mockados** — Se precisar de dados temporários, mockar dentro da própria view
3. **Comentários TODO** — Marcar onde a lógica será implementada futuramente
4. **Ajustes finais** — Revisar e ajustar a tela antes de prosseguir

**Regras:**
- ❌ Nenhum controller nesta etapa
- ❌ Nenhum `Get.find()` ou `Obx()` nesta etapa
- ❌ Nenhum teste nesta etapa
- ✅ Dados temporários ficam mockados na própria view
- ✅ Usar `// TODO: [etapa 8]` para marcar onde entrará lógica

**Padrão de comentários TODO:**

```dart
// Para botões de ação
ElevatedButton(
  onPressed: () {
    // TODO: [etapa 8] conectar com controller.login()
  },
  child: Text('Entrar'),
)

// Para validadores em forms
TextFormField(
  controller: _emailController,
  validator: (value) {
    // TODO: [etapa 8] mover para controller.validateEmail()
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    return null;
  },
)

// Para dados mockados
// TODO: [etapa 8] substituir por dados do controller
final mockItems = ['Item 1', 'Item 2', 'Item 3'];
```

📄 **Documentar em:** `docs/2.imp-ui/[feature].md` (criar arquivo por feature conforme desenvolvimento)

```
┌─────────────────────────────────────┐
│  Construir UI da tela               │
│  Marcar TODOs para etapa 8          │
│  Ajustes finais da tela             │
│  ↓                                  │
│  Repetir para próxima tela          │
└─────────────────────────────────────┘
```

---

## Implementação de Lógica

### 8. Controllers e Testes (após todas UIs prontas)

Após todas as UIs estarem construídas:

1. **Controller** — Criar controller com lógica e estados
2. **Binding** — Criar binding para injeção de dependência
3. **Conectar View** — Substituir TODOs por código real (`Get.find()`, `Obx()`, chamadas ao controller)
4. **Testes** — Cobertura da feature
5. **Revisão geral** — Verificar padrões em toda feature (views, controllers, widgets)

**Ao conectar a View, substituir:**

```dart
// ANTES (etapa 7)
ElevatedButton(
  onPressed: () {
    // TODO: [etapa 8] conectar com controller.login()
  },
  child: Text('Entrar'),
)

// DEPOIS (etapa 8)
final controller = Get.find<AuthController>();

Obx(() => ElevatedButton(
  onPressed: controller.isLoading.value ? null : () {
    controller.login(_emailController.text, _passwordController.text);
  },
  child: controller.isLoading.value
      ? CircularProgressIndicator()
      : Text('Entrar'),
))
```

**Regras:**
- Implementar via specs principalmente (não obrigatório)
- Revisão geral ao final de cada feature completa
- Remover todos os `// TODO: [etapa 8]` ao conectar

📄 **Documentar em:** `docs/3.imp-logica/[feature].md` (criar arquivo por feature conforme desenvolvimento)

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

```
┌─────────────────────────────────────┐
│  Controller + Testes da feature     │
│  Revisão geral da feature           │
│  ↓                                  │
│  Repetir para próxima feature       │
└─────────────────────────────────────┘
```

---

## Regra Crítica

> **🚨 NUNCA executar etapas automaticamente.**
> 
> Sempre informar qual etapa será executada e aguardar confirmação.
> Manter em mente a ordem, mas nunca prosseguir sem ordem explícita.
