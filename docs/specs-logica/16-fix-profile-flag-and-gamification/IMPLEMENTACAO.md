# Implementação: Correção de Bandeira e Gamificação

## ✅ Correções Implementadas

### 1. ProfileController - `_loadProfileStats()`

**Problema:** Carregava stats da estrutura antiga (`users/{userId}/stats/gamification`)

**Solução:** Agora carrega do curso ativo (`users/{userId}/courses/{courseId}/stats/gamification`)

**Mudanças:**
- ✅ Busca curso ativo antes de carregar stats
- ✅ Carrega stats do curso ativo (estrutura nova)
- ✅ Conta lições completadas do curso ativo (não de todos os cursos)
- ✅ Retorna valores padrão se não houver curso ativo

**Código:**
```dart
// 1. Buscar curso ativo
final coursesSnapshot = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .where('isActive', isEqualTo: true)
    .limit(1)
    .get();

// 2. Buscar stats do curso ativo
final statsDoc = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .doc(courseId)
    .collection('stats')
    .doc('gamification')
    .get();

// 3. Contar lições do curso ativo
final progressSnapshot = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .doc(courseId)
    .collection('progress')
    .where('status', isEqualTo: 'completed')
    .count()
    .get();
```

### 2. ProfileController - `loadUserCourses()`

**Problema:** Lógica complexa com `isPrimary` que não era usada consistentemente

**Solução:** Simplificado para usar apenas `isActive`

**Mudanças:**
- ✅ Removida lógica de `isPrimary`
- ✅ Removida chamada a `setPrimaryCourse()`
- ✅ Código mais simples e direto
- ✅ Menos bugs potenciais

**Código:**
```dart
// Buscar TODOS os cursos
final coursesSnapshot = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .get();

// Mapear para lista simples
coursesList.add({
  'id': doc.id,
  'language': languageCode,
  'languageName': _getLanguageName(languageCode),
  'flagAsset': _getLanguageFlag(languageCode),
  'level': courseData['level'],
  'studyTime': courseData['studyTime'],
  'isActive': courseData['isActive'] ?? false,
});
```

### 3. ProfilePage - `_getPrimaryCourseFlag()` → `_getActiveCourseFlag()`

**Problema:** Buscava curso com `isPrimary: true` ao invés de `isActive: true`

**Solução:** Renomeado e alterado para buscar curso ativo

**Mudanças:**
- ✅ Método renomeado de `_getPrimaryCourseFlag()` para `_getActiveCourseFlag()`
- ✅ Busca curso com `isActive: true`
- ✅ Atualizado em 2 locais (ProfileHeader e OverviewSection)

**Código:**
```dart
String _getActiveCourseFlag() {
  // Buscar curso ATIVO (não primário)
  final activeCourse = _controller.userCourses.firstWhere(
    (course) => course['isActive'] == true,
    orElse: () => <String, dynamic>{},
  );

  if (activeCourse.isNotEmpty && activeCourse['flagAsset'] != null) {
    return activeCourse['flagAsset'] as String;
  }

  // Fallback: bandeira do país
  return _getCountryFlag(_controller.country.value);
}
```

---

## 📊 Arquivos Modificados

| Arquivo | Linhas Alteradas | Descrição |
|---------|------------------|-----------|
| `profile_controller.dart` | ~100 linhas | Corrigido `_loadProfileStats()` e simplificado `loadUserCourses()` |
| `profile_page.dart` | ~30 linhas | Renomeado método e atualizado chamadas |

---

## 🧪 Como Testar

### Teste 1: Bandeira Atualiza
```
1. Abrir app com curso Chinês ativo
2. Ir para tab Profile
3. Verificar: bandeira da China aparece
4. Voltar para Home
5. Trocar para curso Alemão
6. Ir para tab Profile
7. Verificar: bandeira da Alemanha aparece ✅
```

### Teste 2: Stats Resetam
```
1. Ter curso Chinês com XP=20, streak=1
2. Ir para tab Profile
3. Verificar: XP=20, streak=1
4. Voltar para Home
5. Trocar para curso Alemão (novo, XP=0)
6. Ir para tab Profile
7. Verificar: XP=0, streak=0 ✅
8. Voltar para Home
9. Trocar para curso Chinês
10. Ir para tab Profile
11. Verificar: XP=20, streak=1 (mantido) ✅
```

### Teste 3: Lições Completadas
```
1. Ter curso Chinês com 5 lições completadas
2. Ir para tab Profile
3. Verificar: "5 lições completadas"
4. Trocar para curso Alemão (0 lições)
5. Ir para tab Profile
6. Verificar: "0 lições completadas" ✅
```

---

## ✅ Resultado Final

**Antes:**
- ❌ Bandeira não atualizava ao trocar curso
- ❌ Stats eram compartilhados entre cursos
- ❌ Lições completadas somavam todos os cursos
- ❌ Código complexo com `isPrimary`

**Depois:**
- ✅ Bandeira atualiza automaticamente
- ✅ Stats são por curso (isolados)
- ✅ Lições completadas são do curso ativo
- ✅ Código simplificado (apenas `isActive`)

---

## 🎯 Benefícios

1. **Consistência:** Profile agora usa a mesma estrutura que GamificationController
2. **Simplicidade:** Removida lógica desnecessária de `isPrimary`
3. **Correção:** Stats agora são realmente por curso
4. **Manutenibilidade:** Menos código = menos bugs

---

## 📝 Notas Técnicas

### Estrutura de Dados

**ANTES (incorreto):**
```
users/{userId}/
├── stats/gamification/  ← Global (errado!)
└── courses/{courseId}/
```

**DEPOIS (correto):**
```
users/{userId}/
└── courses/{courseId}/
    ├── stats/gamification/  ← Por curso (correto!)
    └── progress/
```

### Fluxo de Carregamento

1. `ProfilePage.initState()` → chama `loadOwnProfile()`
2. `loadOwnProfile()` → chama `_loadProfileStats(userId)`
3. `_loadProfileStats()` → busca curso ativo → carrega stats do curso
4. `loadOwnProfile()` → chama `loadUserCourses()`
5. `loadUserCourses()` → carrega lista de cursos com `isActive`
6. `_getActiveCourseFlag()` → busca curso com `isActive: true` → retorna bandeira

### Sincronização com HomeController

Quando o usuário troca de curso:
1. `HomeController.switchActiveCourse()` → atualiza Firestore
2. `HomeController.reloadAfterAddCourse()` → recarrega dados
3. `ProfileController.loadOwnProfile()` → recarrega profile
4. Profile mostra dados do novo curso ✅

---

## 🎉 Status

**STATUS:** ✅ IMPLEMENTADO E PRONTO PARA TESTES

Todas as correções foram implementadas com sucesso!
