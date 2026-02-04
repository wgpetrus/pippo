# Correção: Bandeira do Profile e Gamificação Compartilhada

## 🎯 Problemas Identificados

### Problema 1: Bandeira do Profile Não Atualiza
**Sintoma:** Ao trocar de curso, a bandeira na tela de profile não atualiza para o novo idioma.

**Causa:** O ProfileController está buscando curso com `isPrimary: true`, mas o sistema usa `isActive: true` para determinar o curso atual.

**Localização:** 
- `lib/features/inners/profile/controllers/profile_controller.dart` (método `loadUserCourses()`)
- `lib/features/inners/profile/views/profile_page.dart` (método `_getPrimaryCourseFlag()`)

### Problema 2: Gamificação Compartilhada Entre Cursos
**Sintoma:** Ao trocar de curso, os dados de gamificação (XP, streak, gems, energy) não resetam.

**Causa:** O ProfileController está carregando stats da estrutura ANTIGA (`users/{userId}/stats/gamification`) ao invés da estrutura NOVA (`users/{userId}/courses/{courseId}/stats/gamification`).

**Localização:**
- `lib/features/inners/profile/controllers/profile_controller.dart` (método `_loadProfileStats()`)

---

## ✅ Solução

### Correção 1: Usar `isActive` ao Invés de `isPrimary`

O sistema já usa `isActive` para determinar qual curso está ativo. O campo `isPrimary` é usado apenas para exibição no profile (qual curso mostrar na bandeira).

**Mudança necessária:**
1. Remover lógica de `isPrimary` do `loadUserCourses()`
2. Usar `isActive` para determinar qual bandeira mostrar no profile
3. Simplificar o código removendo a complexidade desnecessária

### Correção 2: Carregar Stats do Curso Ativo

O ProfileController deve carregar stats da mesma estrutura que o GamificationController usa.

**Estrutura CORRETA:**
```
users/{userId}/courses/{courseId}/stats/gamification/
users/{userId}/courses/{courseId}/stats/dailyHistory/days/
```

**Estrutura INCORRETA (antiga):**
```
users/{userId}/stats/gamification/  ← NÃO USAR MAIS
users/{userId}/stats/dailyHistory/days/  ← NÃO USAR MAIS
```

**Métodos afetados:**
- `_loadProfileStats()` - carrega XP, level, streak
- `_loadUserWeeklyProgress()` - carrega dados do gráfico semanal

---

## 📝 Implementação

### Arquivo 1: `profile_controller.dart`

#### Método `loadUserCourses()` - SIMPLIFICAR

**ANTES (linha ~1000):**
```dart
Future<void> loadUserCourses() async {
  // ... código complexo com isPrimary ...
  
  // Se não há curso primário mas há cursos, definir o primeiro curso ativo como primário
  if (primaryId == null && coursesList.isNotEmpty) {
    // ... lógica complexa ...
    await setPrimaryCourse(firstActiveCourse['id'] as String, showSnackbar: false);
  }
}
```

**DEPOIS:**
```dart
Future<void> loadUserCourses() async {
  isLoadingCourses.value = true;
  errorMessage.value = '';

  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      errorMessage.value = 'Usuário não autenticado.';
      return;
    }

    // Buscar TODOS os cursos
    final coursesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .get();

    final coursesList = <Map<String, dynamic>>[];

    for (final doc in coursesSnapshot.docs) {
      final courseData = doc.data();
      final languageCode = courseData['language'] as String;
      
      coursesList.add({
        'id': doc.id,
        'language': languageCode,
        'languageName': _getLanguageName(languageCode),
        'flagAsset': _getLanguageFlag(languageCode),
        'level': courseData['level'],
        'studyTime': courseData['studyTime'],
        'isActive': courseData['isActive'] ?? false,
      });
    }

    userCourses.value = coursesList;
    
    if (kDebugMode) {
      debugPrint('✅ loadUserCourses: ${coursesList.length} cursos carregados');
      for (final course in coursesList) {
        debugPrint('   - ${course['languageName']}: isActive=${course['isActive']}');
      }
    }
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    errorMessage.value = 'Erro ao carregar cursos. Tente novamente.';
  } finally {
    isLoadingCourses.value = false;
  }
}
```

#### Método `_loadProfileStats()` - CORRIGIR ESTRUTURA

**ANTES (linha ~1700):**
```dart
Future<void> _loadProfileStats(String userId) async {
  try {
    // ❌ ERRADO - estrutura antiga
    final statsDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification')
        .get();
    
    // ... resto do código ...
  }
}
```

**DEPOIS:**
```dart
Future<void> _loadProfileStats(String userId) async {
  try {
    if (kDebugMode) {
      debugPrint('🔍 _loadProfileStats: Carregando stats para $userId');
    }
    
    // 1. Buscar curso ativo
    final coursesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (coursesSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ _loadProfileStats: Nenhum curso ativo encontrado');
      }
      // Valores padrão
      totalXp.value = 0;
      level.value = 1;
      currentStreak.value = 0;
      lessonsCompleted.value = 0;
      return;
    }

    final courseId = coursesSnapshot.docs.first.id;
    if (kDebugMode) {
      debugPrint('✅ _loadProfileStats: Curso ativo: $courseId');
    }
    
    // 2. Buscar stats do curso ativo (estrutura NOVA)
    final statsDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('stats')
        .doc('gamification')
        .get();

    if (statsDoc.exists) {
      final stats = statsDoc.data() as Map<String, dynamic>;
      
      // Estrutura nova (aninhada)
      final xpData = stats['xp'] as Map<String, dynamic>?;
      final streakData = stats['streak'] as Map<String, dynamic>?;
      
      totalXp.value = xpData?['totalXp'] ?? 0;
      level.value = xpData?['level'] ?? 1;
      currentStreak.value = streakData?['currentStreak'] ?? 0;
      
      if (kDebugMode) {
        debugPrint('📊 _loadProfileStats: totalXp=${totalXp.value}, level=${level.value}, streak=${currentStreak.value}');
      }
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ _loadProfileStats: Stats doc NÃO existe');
      }
      // Valores padrão
      totalXp.value = 0;
      level.value = 1;
      currentStreak.value = 0;
    }

    // Contar lições completadas do curso ativo
    final progressSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('progress')
        .where('status', isEqualTo: 'completed')
        .count()
        .get();

    lessonsCompleted.value = progressSnapshot.count ?? 0;
    
    if (kDebugMode) {
      debugPrint('✅ _loadProfileStats: Lições completadas: ${lessonsCompleted.value}');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ _loadProfileStats: Erro - $e');
      debugPrint('Stack trace: $stackTrace');
    }
    rethrow;
  }
}
```

#### Método `_loadUserWeeklyProgress()` - CORRIGIR ESTRUTURA

**ANTES (linha ~1864):**
```dart
Future<List<Map<String, dynamic>>> _loadUserWeeklyProgress(String userId) async {
  // ... código de cálculo de datas ...
  
  // ❌ ERRADO - estrutura antiga
  final dayDoc = await _firestore
      .collection('users')
      .doc(userId)
      .collection('stats')
      .doc('dailyHistory')
      .collection('days')
      .doc(dateStr)
      .get();
  
  // ... resto do código ...
}
```

**DEPOIS:**
```dart
Future<List<Map<String, dynamic>>> _loadUserWeeklyProgress(String userId) async {
  // 1. Buscar curso ativo
  final coursesSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .where('isActive', isEqualTo: true)
      .limit(1)
      .get();

  if (coursesSnapshot.docs.isEmpty) {
    // Retornar semana vazia
    return _getEmptyWeek();
  }

  final courseId = coursesSnapshot.docs.first.id;
  
  // 2. Calcular datas da semana...
  
  // 3. Buscar dados do dia (estrutura NOVA - do curso ativo)
  final dayDoc = await _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)
      .collection('stats')
      .doc('dailyHistory')
      .collection('days')
      .doc(dateStr)
      .get();
  
  // ... resto do código ...
}
```

#### Novo Método: `_getEmptyWeek()`

```dart
/// Retorna uma semana vazia (todos os dias com XP = 0)
List<Map<String, dynamic>> _getEmptyWeek() {
  final now = DateTime.now();
  final currentWeekday = now.weekday;
  final daysToSunday = currentWeekday == 7 ? 0 : currentWeekday;
  final sunday = now.subtract(Duration(days: daysToSunday));
  
  final weekDays = <Map<String, dynamic>>[];
  
  for (int i = 0; i < 7; i++) {
    final date = sunday.add(Duration(days: i));
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    weekDays.add({
      'date': dateStr,
      'day': _getDayAbbreviation(date.weekday),
      'xp': 0,
    });
  }
  
  return weekDays;
}
```

#### Remover Métodos Desnecessários

**REMOVER:**
- `setPrimaryCourse()` - não é mais necessário
- `primaryCourseId` - não é mais necessário
- Toda lógica relacionada a `isPrimary`

### Arquivo 2: `profile_page.dart`

#### Método `_getPrimaryCourseFlag()` - SIMPLIFICAR

**ANTES:**
```dart
String _getPrimaryCourseFlag() {
  // Buscar curso primário
  final primaryCourse = _controller.userCourses.firstWhere(
    (course) => course['isPrimary'] == true,
    orElse: () => <String, dynamic>{},
  );

  if (primaryCourse.isNotEmpty && primaryCourse['flagAsset'] != null) {
    return primaryCourse['flagAsset'] as String;
  }

  // Fallback: usar bandeira do país do usuário
  return _getCountryFlag(_controller.country.value);
}
```

**DEPOIS:**
```dart
String _getActiveCourseFlag() {
  if (kDebugMode) {
    debugPrint('🔍 _getActiveCourseFlag: Buscando curso ativo');
    debugPrint('   Total de cursos: ${_controller.userCourses.length}');
  }

  // Buscar curso ATIVO (não primário)
  final activeCourse = _controller.userCourses.firstWhere(
    (course) => course['isActive'] == true,
    orElse: () => <String, dynamic>{},
  );

  if (kDebugMode) {
    debugPrint('   Curso ativo encontrado: ${activeCourse.isNotEmpty}');
    if (activeCourse.isNotEmpty) {
      debugPrint('   - Idioma: ${activeCourse['languageName']}');
      debugPrint('   - Bandeira: ${activeCourse['flagAsset']}');
    }
  }

  // Se encontrou curso ativo, retornar sua bandeira
  if (activeCourse.isNotEmpty && activeCourse['flagAsset'] != null) {
    return activeCourse['flagAsset'] as String;
  }

  // Fallback: usar bandeira do país do usuário
  if (kDebugMode) {
    debugPrint('   ⚠️ Usando fallback: bandeira do país ${_controller.country.value}');
  }
  return _getCountryFlag(_controller.country.value);
}
```

**ATUALIZAR CHAMADAS:**
```dart
// Linha ~90 (ProfileHeader)
Obx(() => ProfileHeader(
  // ... outros parâmetros ...
  flagAsset: _getActiveCourseFlag(), // ← MUDOU de _getPrimaryCourseFlag()
  // ... outros parâmetros ...
)),

// Linha ~160 (OverviewSection)
SliverToBoxAdapter(
  child: Obx(() => OverviewSection(
    flagAsset: _getActiveCourseFlag(), // ← MUDOU de _getPrimaryCourseFlag()
    useOwnStats: true,
  )),
),
```

---

## 🧪 Testes

### Teste 1: Bandeira Atualiza ao Trocar Curso
1. [ ] Ter curso Chinês ativo
2. [ ] Verificar que bandeira da China aparece no profile
3. [ ] Trocar para curso Alemão
4. [ ] Verificar que bandeira da Alemanha aparece no profile
5. [ ] Voltar para curso Chinês
6. [ ] Verificar que bandeira da China aparece novamente

### Teste 2: Stats Resetam ao Trocar Curso
1. [ ] Ter curso Chinês com XP=20, streak=1
2. [ ] Verificar que profile mostra XP=20, streak=1
3. [ ] Trocar para curso Alemão (novo, XP=0)
4. [ ] Verificar que profile mostra XP=0, streak=0
5. [ ] Voltar para curso Chinês
6. [ ] Verificar que profile mostra XP=20, streak=1 novamente

### Teste 3: Lições Completadas por Curso
1. [ ] Ter curso Chinês com 5 lições completadas
2. [ ] Verificar que profile mostra 5 lições
3. [ ] Trocar para curso Alemão (0 lições)
4. [ ] Verificar que profile mostra 0 lições
5. [ ] Voltar para curso Chinês
6. [ ] Verificar que profile mostra 5 lições novamente

### Teste 4: Gráfico Semanal por Curso
1. [ ] Ter curso Chinês com XP nos últimos 3 dias
2. [ ] Verificar que gráfico mostra barras com XP
3. [ ] Trocar para curso Alemão (sem XP)
4. [ ] Verificar que gráfico mostra barras vazias (XP=0)
5. [ ] Voltar para curso Chinês
6. [ ] Verificar que gráfico mostra barras com XP novamente

---

## ✅ Resultado Final

**Ao trocar de curso:**
- ✅ Bandeira atualiza para o novo idioma
- ✅ XP mostra o valor do novo curso
- ✅ Streak mostra o valor do novo curso
- ✅ Lições completadas mostra o valor do novo curso
- ✅ Gráfico semanal mostra os dados do novo curso
- ✅ Ao voltar para curso anterior, todos os dados são restaurados

**Simplificações:**
- ✅ Removida lógica complexa de `isPrimary`
- ✅ Sistema usa apenas `isActive` (mais simples e consistente)
- ✅ Menos código para manter
- ✅ Menos bugs potenciais

---

## 📊 Ordem de Implementação

1. ✅ Atualizar `_loadProfileStats()` para buscar do curso ativo
2. ✅ Atualizar `_loadUserWeeklyProgress()` para buscar do curso ativo
3. ✅ Criar método `_getEmptyWeek()` para retornar semana vazia
4. ✅ Simplificar `loadUserCourses()` removendo lógica de `isPrimary`
5. ✅ Atualizar `_getPrimaryCourseFlag()` para `_getActiveCourseFlag()`
6. ✅ Remover métodos desnecessários (`setPrimaryCourse()`, etc)
7. ✅ Testar fluxo completo

---

## 🎯 Status

**STATUS:** 🔄 PRONTO PARA IMPLEMENTAR

Todos os problemas foram identificados e as soluções estão documentadas.
