# Sistema de Adicionar e Trocar Cursos

## ✅ Comportamento Implementado

### Adicionar Novo Curso
1. ✅ Usuário clica em "Adicionar Curso" no modal
2. ✅ Completa onboarding do novo curso (idioma, nível, motivo, tempo)
3. ✅ **Novo curso é ativado automaticamente**
4. ✅ Curso anterior é desativado (mas mantém progresso salvo)
5. ✅ UI atualiza com novo curso:
   - ✅ Bandeira muda para novo idioma
   - ⚠️ **Dados de gamificação permanecem** (XP, streak, gems, energy)
   - ⚠️ Progresso do curso anterior é mantido

### Problema Atual
- ✅ Bandeira atualiza corretamente
- ✅ **Dados de gamificação são GLOBAIS** (XP, streak, gems, energy compartilhados entre cursos)
- ✅ Progresso de lições é POR CURSO (independente)

### Comportamento Implementado: Gamificação Global

**Decisão: Gamificação Global (Compartilhada)**
- ✅ XP, streak, gems, energy são **globais** (mesmos para todos os cursos)
- ✅ Apenas progresso de lições é por curso
- ✅ Vantagem: Usuário não perde conquistas ao trocar curso
- ✅ Vantagem: Incentiva aprender múltiplos idiomas
- ⚠️ Desvantagem: Pode confundir (XP alto em curso novo)

**Estrutura no Firestore:**
```
users/{userId}/
├── stats/
│   └── gamification/  ← GLOBAL (compartilhado entre cursos)
│       ├── streak: {...}
│       ├── energy: {...}
│       ├── xp: {...}
│       ├── gems: {...}
│       └── currentLeague: "bronze"
│
└── courses/
    ├── {courseId1}/
    │   ├── language: "zh"
    │   ├── isActive: true
    │   └── progress/  ← POR CURSO (independente)
    │       ├── 1/ {...}
    │       └── 2/ {...}
    │
    └── {courseId2}/
        ├── language: "de"
        ├── isActive: false
        └── progress/  ← POR CURSO (independente)
            └── (vazio)
```

**Justificativa:**
1. **Simplicidade:** Não precisa migrar stats ao trocar curso
2. **Motivação:** Usuário mantém conquistas ao explorar novos idiomas
3. **Consistência:** Leaderboard e ranking são globais (não por curso)
4. **Realismo:** Na vida real, habilidades de aprendizado são transferíveis

## 📊 Estrutura de Dados

### Firestore: `users/{userId}/courses/{courseId}`
```
gKRtGWh5B2c5Ca65HYIf (Chinês)
├── id: "gKRtGWh5B2c5Ca65HYIf"
├── language: "zh"
├── languageName: "Chinês"
├── level: "Sou novo em {lang}"
├── reason: "Quero me conectar com pessoas."
├── studyTime: 10
├── isActive: true  ← Apenas 1 curso pode ser true
├── isPrimary: true ← Apenas 1 curso pode ser true
└── createdAt: Timestamp

abc123xyz (Alemão - novo)
├── id: "abc123xyz"
├── language: "de"
├── languageName: "Alemão"
├── level: "beginner"
├── reason: "travel"
├── studyTime: 10
├── isActive: false ← Novo curso não é ativo por padrão
└── createdAt: Timestamp
```

### Firestore: `users/{userId}/courses/{courseId}/progress/{lessonId}`
**IMPORTANTE:** Progresso é **POR CURSO**!

```
users/TL0u8nDFpGhcOdaozkZGaH7FiCB2/courses/gKRtGWh5B2c5Ca65HYIf/progress/
├── 1/
│   ├── lessonId: "1"
│   ├── status: "completed"
│   └── completedAt: Timestamp
└── 2/
    ├── lessonId: "2"
    ├── status: "in_progress"
    └── startedAt: Timestamp

users/TL0u8nDFpGhcOdaozkZGaH7FiCB2/courses/abc123xyz/progress/
└── (vazio - curso novo sem progresso)
```

## 🎯 Fluxo Esperado

### 1. Trocar Curso Ativo
**Arquivo:** `lib/features/inners/home/controllers/home_controller.dart`
**Método:** `switchActiveCourse(String newCourseId)`

```dart
Future<void> switchActiveCourse(String newCourseId) async {
  debugPrint('🔄 switchActiveCourse() INICIADO: $newCourseId');
  
  // 1. Desativar curso atual no Firestore
  // 2. Ativar novo curso no Firestore
  // 3. Recarregar curso ativo (_loadActiveCourse)
  // 4. Recarregar progresso do novo curso (_loadLessonProgress)
  // 5. UI atualiza automaticamente (Obx)
}
```

### 2. UI Reativa
**Arquivo:** `lib/features/inners/home/views/home_view.dart`

A UI deve reagir automaticamente às mudanças:
- `activeCourseFlag` → Bandeira no AppBar
- `activeCourseName` → Nome do curso no AppBar
- `completedLessons` → Progresso dos botões de lição
- `currentUnitIndex` → Header da unidade

## 🐛 Problemas a Investigar

### 1. `switchActiveCourse()` não recarrega UI
**Possível causa:** Método não está chamando `_loadActiveCourse()` e `_loadLessonProgress()` corretamente.

**Verificar:**
```dart
// Após batch.commit()
await _loadActiveCourse();  // ← Está sendo chamado?
await _loadLessonProgress(); // ← Está sendo chamado?
```

### 2. Progresso não reseta ao trocar curso
**Possível causa:** `_loadLessonProgress()` está buscando progresso do curso errado.

**Verificar:**
```dart
// Deve buscar progresso do NOVO curso ativo
final courseId = coursesSnapshot.docs.first.id; // ← Curso correto?

await _firestore
  .collection('users')
  .doc(userId)
  .collection('courses')
  .doc(courseId)  // ← Deve ser o novo curso
  .collection('progress')
  .get();
```

### 3. Modal não fecha após trocar curso
**Possível causa:** Modal não está sendo fechado após `switchActiveCourse()`.

**Verificar:**
```dart
// Em courses_modal.dart ou home_view.dart
onCourseSelected: (course) {
  controller.switchActiveCourse(courseId);
  Get.back(); // ← Fecha modal?
}
```

### 4. Dados do curso anterior persistem
**Possível causa:** Variáveis observáveis não estão sendo atualizadas.

**Verificar:**
```dart
// Em _loadActiveCourse()
activeCourseId.value = newCourseId;      // ← Atualiza?
activeCourseLanguage.value = languageCode; // ← Atualiza?
activeCourseName.value = languageName;     // ← Atualiza?
activeCourseFlag.value = flagAsset;        // ← Atualiza?

// Em _loadLessonProgress()
completedLessons.value = [...];  // ← Limpa lista antiga?
inProgressLessons.value = [...]; // ← Limpa lista antiga?
```

## 🧪 Testes Necessários

### Teste 1: Trocar Curso Ativo
1. [ ] Ter 2 cursos (Chinês ativo, Alemão inativo)
2. [ ] Abrir modal de cursos
3. [ ] Clicar em Alemão
4. [ ] Verificar logs:
   - `🔄 switchActiveCourse() INICIADO: abc123xyz`
   - `📝 Desativando curso atual: gKRtGWh5B2c5Ca65HYIf`
   - `📝 Ativando novo curso: abc123xyz`
   - `✅ Batch commit realizado`
   - `🔄 _loadActiveCourse() INICIADO`
   - `✅ Curso ativo carregado: Alemão (de)`
   - `🔄 _loadLessonProgress() INICIADO`
   - `✅ Lições completadas: 0`
5. [ ] Verificar UI:
   - Bandeira = Alemanha
   - Nome = Alemão
   - Progresso = 0 lições completadas
   - Botão 1 = "Começar" (não "Continuar")

### Teste 2: Voltar para Curso Anterior
1. [ ] Abrir modal de cursos
2. [ ] Clicar em Chinês
3. [ ] Verificar UI:
   - Bandeira = China
   - Nome = Chinês
   - Progresso = 1 lição completada (mantido)
   - Botão 1 = "Continuar"

### Teste 3: Progresso Independente
1. [ ] Estar em Alemão (0 lições)
2. [ ] Completar 1 lição
3. [ ] Trocar para Chinês
4. [ ] Verificar: Chinês tem 1 lição (progresso mantido)
5. [ ] Trocar para Alemão
6. [ ] Verificar: Alemão tem 1 lição (progresso mantido)

## 📝 Logs Esperados

### Ao trocar curso:
```
🔄 switchActiveCourse() INICIADO: abc123xyz
  📝 Desativando curso atual: gKRtGWh5B2c5Ca65HYIf
  📝 Ativando novo curso: abc123xyz
  ✅ Batch commit realizado
🔄 _loadActiveCourse() INICIADO
  👤 UserId: TL0u8nDFpGhcOdaozkZGaH7FiCB2
  ✅ Curso ativo carregado:
    ID: abc123xyz
    Idioma: Alemão (de)
    Bandeira: lib/assets/images/flags/germany-flag.png
    Nível: 1
✅ _loadActiveCourse() CONCLUÍDO
🔄 _loadLessonProgress() INICIADO
  👤 UserId: TL0u8nDFpGhcOdaozkZGaH7FiCB2
  📚 Curso ativo: abc123xyz
  ✅ Lições completadas: 0
  ✅ Lições em progresso: 0
  📊 _updateCurrentUnit:
    ✅ Lições completadas: 0
    🎯 Header da unidade: 1 (index 0)
✅ _loadLessonProgress() CONCLUÍDO
✅ switchActiveCourse() CONCLUÍDO
```

## 🔧 Arquivos a Modificar

1. **`lib/features/inners/home/controllers/home_controller.dart`**
   - Método `switchActiveCourse()` - adicionar logs e garantir reload
   - Método `_loadActiveCourse()` - verificar se atualiza variáveis
   - Método `_loadLessonProgress()` - verificar se busca curso correto

2. **`lib/features/inners/home/views/home_view.dart`**
   - Método `_showCoursesModal()` - garantir que fecha modal após trocar
   - Verificar se `Obx()` está envolvendo widgets corretos

3. **`lib/features/inners/home/widgets/courses_modal.dart`**
   - Callback `onCourseSelected` - garantir que chama `switchActiveCourse()`
   - Fechar modal após seleção

## 💡 Solução Esperada

### Fluxo Completo
```
1. Usuário clica em curso no modal
   ↓
2. Modal chama controller.switchActiveCourse(newCourseId)
   ↓
3. Controller atualiza Firestore (batch):
   - Desativa curso atual (isActive = false)
   - Ativa novo curso (isActive = true)
   ↓
4. Controller recarrega dados:
   - _loadActiveCourse() → atualiza bandeira, nome, nível
   - _loadLessonProgress() → carrega progresso do NOVO curso
   ↓
5. Variáveis observáveis (.obs) são atualizadas
   ↓
6. UI reage automaticamente (Obx):
   - AppBar atualiza bandeira e nome
   - Botões de lição atualizam status
   - Header da unidade atualiza
   ↓
7. Modal fecha
   ↓
8. Usuário vê novo curso ativo com progresso correto
```

## 📚 Conceitos Importantes

### 1. Curso Ativo vs Curso Primário
- **isActive:** Curso que está sendo usado AGORA (apenas 1 pode ser true)
- **isPrimary:** Curso principal do usuário (pode ser diferente do ativo)
- **Regra:** Ao trocar curso ativo, NÃO alterar isPrimary automaticamente

### 2. Progresso por Curso
- Cada curso tem sua própria subcoleção `progress/`
- Progresso é INDEPENDENTE entre cursos
- Ao trocar curso, carregar progresso da subcoleção correta

### 3. UI Reativa
- Usar `.obs` para variáveis que afetam UI
- Envolver widgets com `Obx()` para reagir a mudanças
- Não precisa chamar `setState()` - GetX faz automaticamente

## ✅ Status Final

### Implementado e Funcionando
1. ✅ Adicionar novo curso via onboarding
2. ✅ Novo curso é ativado automaticamente
3. ✅ Curso anterior é desativado (mas mantém progresso)
4. ✅ UI atualiza com bandeira do novo curso
5. ✅ Progresso de lições é independente por curso
6. ✅ Gamificação é global (compartilhada entre cursos)
7. ✅ Usuário pode voltar para curso anterior e continuar de onde parou

### Comportamento Confirmado
- **Gamificação:** Global (XP, streak, gems, energy compartilhados)
- **Progresso:** Por curso (lições completadas são independentes)
- **Navegação:** Automática para novo curso após adicionar
- **Persistência:** Curso anterior mantém todo o progresso salvo

## 📌 Observações

- **NÃO** perder progresso do curso anterior
- **NÃO** alterar isPrimary automaticamente
- **SIM** atualizar UI imediatamente
- **SIM** carregar progresso correto de cada curso
- **SIM** permitir voltar para curso anterior
