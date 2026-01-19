 # Packages de Dados vs Packages de UI

> Esclarecimento sobre quais packages devem ser mencionados nas specs

---

## 📦 Packages de Dados (Mencionar nas Specs)

Estes packages lidam com **lógica de dados** e devem ser mencionados nas specs quando relevante:

### uuid

**⚠️ REGRA CRÍTICA: UUID v5 APENAS para informações pessoais**

**Quando usar UUID v5** (determinístico - sempre gera o mesmo ID para o mesmo input):
- ✅ Dados pessoais sensíveis que precisam ser consistentes
- ✅ Exemplo: IDs baseados em email, CPF, telefone

```dart
import 'package:uuid/uuid.dart';

const uuid = Uuid();

// Para dados pessoais (determinístico)
final userId = uuid.v5(Uuid.NAMESPACE_URL, userEmail);
```

**Quando NÃO usar UUID** (usar Firestore auto-generated ID):
- ❌ Cursos (não são dados pessoais)
- ❌ Lições, exercícios, desafios
- ❌ Qualquer documento que não seja informação pessoal

```dart
// ✅ CORRETO - Firestore auto-generated ID para cursos
final courseRef = FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('courses')
    .doc(); // Auto-generated ID

final courseId = courseRef.id;

await courseRef.set({
  'id': courseId,
  // ... outros campos
});
```

**Regra crítica**: 
- UUID v5 → **APENAS** informações pessoais (determinístico)
- Firestore auto-generated ID → **TUDO** que não for informação pessoal

**Onde mencionar**:
- ✅ Apenas quando for necessário UUID v5 para dados pessoais
- ❌ NÃO mencionar para cursos, lições, etc (usar Firestore auto-generated ID)

---

### mask_text_input_formatter

**Quando usar**: Formatação de inputs com máscaras (telefone, CPF, data)

```dart
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

var phoneFormatter = MaskTextInputFormatter(
  mask: '+## (##) #####-####',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

TextField(
  inputFormatters: [phoneFormatter],
);
```

**Onde mencionar**:
- ✅ Perfil (vincular telefone)
- ✅ Qualquer input que precise de máscara de formatação

---

## 🎨 Packages de UI (NÃO Mencionar nas Specs)

Estes packages lidam com **interface visual** e já estão documentados nas steering rules. **NÃO devem ser mencionados nas specs**:

### Modals e Bottomsheets
- ❌ `wolt_modal_sheet` - Já documentado em styling-guide.md
- ❌ `pinput` - Já documentado em styling-guide.md

### Menus e Popovers
- ❌ `pie_menu` - Já documentado em styling-guide.md
- ❌ `popover` - Já documentado em styling-guide.md

### Switches e Toggles
- ❌ `toggle_switch` - Já documentado em styling-guide.md

### Gráficos
- ❌ `syncfusion_flutter_charts` - Já documentado em styling-guide.md

### Onboarding
- ❌ `showcaseview` - Já documentado em styling-guide.md

---

## 🎯 Regra Geral

**Specs devem mencionar packages quando:**
- ✅ Afetam lógica de dados
- ✅ Afetam estrutura de armazenamento
- ✅ Afetam formatação de dados
- ✅ São necessários para cálculos ou validações

**Specs NÃO devem mencionar packages quando:**
- ❌ São apenas visuais/UI
- ❌ Já estão documentados nas steering rules
- ❌ São widgets ou componentes de interface

---

## 📚 Referências

- **Packages de UI**: `.kiro/steering/kmelon-patterns/styling-guide.md`
- **Widgets padrão**: `.kiro/steering/kmelon-patterns/components.md`
- **Regras de código**: `.kiro/steering/kmelon-patterns/code-rules.md`

---

**Resumo**: Specs focam em **lógica de negócio e dados**. Interface visual já está documentada nas steering rules.
