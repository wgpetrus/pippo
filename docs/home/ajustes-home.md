# Ajustes Home - Projeto Pippo

> Análise de conformidade da feature Home

---

## Status: ✅ Conforme

A feature Home está em conformidade com os padrões da empresa.

---

## Checklist de Conformidade

### Estrutura de Pastas
- [x] Feature em `features/inners/` (correto para feature interna)
- [x] Subpastas: `views/`, `widgets/`, `controllers/`, `bindings/`
- [x] Páginas internas em features separadas (shop, leaderboard, etc.)
- [x] Widgets específicos na pasta `widgets/` da feature

### Nomenclatura
- [x] View principal: `home_view.dart` (sufixo `_view`)
- [x] Páginas internas: `*_page.dart` (sufixo `_page`)
- [x] Controller: `home_controller.dart`
- [x] Binding: `home_binding.dart`
- [x] Widgets sem prefixo (específicos da feature)

### Controller
- [x] Estados obrigatórios: `isLoading`, `errorMessage`
- [x] Sem `TextEditingController` (não há forms)
- [x] Sem streams ou managers complexos
- [x] Código enxuto

### View
- [x] `StatelessWidget` (não há forms)
- [x] Sem lógica de negócio
- [x] `Obx()` apenas onde necessário
- [x] Navegação por estado (`IndexedStack`)

### Widgets Globais
- [x] `AppBottombar` em `shared/widgets/` (usado em 5 features)
- [x] `AppButton` usado nos modais
- [x] `AppFloatAnim` e `AppLessonButton` em shared

### Estilização
- [x] Cores do `AppTheme`
- [x] Fontes do `AppTheme`
- [x] Assets via `AppAssets`
- [x] FontAwesome para ícones

### Packages
- [x] `popover` para menu de lições
- [x] Modais com `showDialog` padrão

---

## Observações

### Decisões Aceitas

| Item | Justificativa |
|------|---------------|
| `_LessonButtonData` na view | Classe privada de dados para configuração visual, não é lógica de negócio |
| Modais como widgets | Cada modal é um widget separado com método estático `show()` |

### Pontos de Atenção (não são erros)

1. **OnboardingController no HomeBinding**
   - Necessário para fluxo "Add Course"
   - Aceitável pois é dependência real

2. **Dados hardcoded nos modais**
   - Normal para fase de UI
   - Será substituído por dados reais na implementação de lógica

---

## Próximos Passos (Lógica)

Quando implementar lógica, atentar para:

1. **HomeController**
   - Carregar dados do usuário (streak, gems, energy)
   - Carregar cursos do usuário
   - Carregar progresso das lições

2. **Modais**
   - Conectar com dados reais
   - Implementar ações (compra de gems, refill energy, etc.)

3. **Navegação**
   - Implementar navegação para lição
   - Implementar troca de curso ativo

---

## Checklist Final

- [x] Estrutura de pastas correta
- [x] Nomenclatura correta
- [x] Controller com estados obrigatórios
- [x] View sem lógica de negócio
- [x] Widgets globais em shared/
- [x] Estilização centralizada
- [x] Packages aprovados
- [x] Comentários em português
- [x] Código enxuto
