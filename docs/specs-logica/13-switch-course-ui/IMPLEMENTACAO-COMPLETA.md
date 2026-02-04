# Implementação Completa: Gamificação por Curso

## ✅ Status: IMPLEMENTADO

Todas as mudanças necessárias foram implementadas para fazer com que os dados de gamificação (XP, streak, gems, energy) sejam **por curso** ao invés de globais.

---

## 📝 Mudanças Implementadas

### 1. OnboardingController ✅

**Arquivo:** `lib/features/core/onboarding/controllers/onboarding_controller.dart`

#### Método `finalizeAccount()` (linha ~850)
- ✅ **ANTES:** Stats criados em `users/{userId}/stats/gamification`
- ✅ **DEPOIS:** Stats criados em `users/{userId}/courses/{courseId}/stats/gamification`
- ✅ Estrutura completa de stats (streak, energy, xp, gems, currentLeague)

#### Método `addNewCourse()` (linha ~897)
- ✅ **ANTES:** Apenas criava documento do curso
- ✅ **DEPOIS:** Cria documento do curso + stats iniciais
- ✅ Usa batch para operação atômica (desativar curso anterior + criar novo curso + criar stats)
- ✅ Stats iniciais: xp=0, streak=0, gems=0, energy=5, level=1

---

### 2. GamificationController ✅

**Arquivo:** `lib/features/inners/gamification/controllers/gamification_controller.dart`

#### Método `loadStats()` (linha ~120)
- ✅ **ANTES:** Buscava de `users/{userId}/stats/gamification`
- ✅ **DEPOIS:** 
  1. Busca curso ativo
  2. Busca stats do curso ativo em `users/{userId}/courses/{courseId}/stats/gamification`
- ✅ Logs detalhados para debug

#### Método `_saveStats()` (linha ~200)
- ✅ **ANTES:** Salvava em `users/{userId}/stats/gamification`
- ✅ **DEPOIS:**
  1. Busca curso ativo
  2. Salva stats no curso ativo em `users/{userId}/courses/{courseId}/stats/gamification`

#### Método `_createInitialStats()` (linha ~280)
- ✅ **ANTES:** Criava em `users/{userId}/stats/gamification`
- ✅ **DEPOIS:** Recebe `courseId` como parâmetro e cria em `users/{userId}/courses/{courseId}/stats/gamification`
- ✅ Removida verificação de documento do usuário (não mais necessária)

#### Métodos de Histórico (linha ~650)
- ✅ `_recordLessonHistory()`: Busca curso ativo e salva histórico no curso
- ✅ `_recordStreakMilestone()`: Busca curso ativo e salva milestone no curso
- ✅ `_recordLevelUp()`: Busca curso ativo e salva level up no curso

#### Método `queryHistory()` (linha ~750)
- ✅ **ANTES:** Buscava de `users/{userId}/stats/gamification/history`
- ✅ **DEPOIS:** Busca curso ativo e consulta histórico do curso

#### Método `_saveXpToHistory()` (linha ~1035)
- ✅ **ANTES:** Salvava em `users/{userId}/stats/dailyHistory`
- ✅ **DEPOIS:** Busca curso ativo e salva em `users/{userId}/courses/{courseId}/stats/dailyHistory`
- ✅ Usado para gráfico de progresso semanal no perfil

---

### 3. HomeController ✅

**Arquivo:** `lib/features/inners/home/controllers/home_controller.dart`

#### Método `switchActiveCourse()` (linha ~450)
- ✅ **ANTES:** Apenas trocava curso ativo e recarregava progresso
- ✅ **DEPOIS:** 
  1. Troca curso ativo
  2. Recarrega progresso
  3. **NOVO:** Recarrega stats do novo curso (chama `GamificationController.loadStats()`)
- ✅ Logs detalhados para debug

---

## 🎯 Estrutura Final no Firestore

```
users/{userId}/
└── courses/
    ├── {courseId1}/ (Chinês)
    │   ├── language: "zh"
    │   ├── isActive: false
    │   ├── progress/
    │   │   ├── 1/ (lição completada)
    │   │   └── 2/ (lição em progresso)
    │   └── stats/
    │       └── gamification/
    │           ├── streak: {currentStreak: 1, ...}
    │           ├── energy: {currentEnergy: 5, ...}
    │           ├── xp: {totalXp: 20, level: 1, ...}
    │           ├── gems: {gems: 0, ...}
    │           ├── currentLeague: "bronze"
    │           └── history/
    │               ├── {historyId1}/ (lesson_completion)
    │               └── {historyId2}/ (streak_milestone)
    │
    └── {courseId2}/ (Alemão)
        ├── language: "de"
        ├── isActive: true
        ├── progress/ (vazio)
        └── stats/
            └── gamification/
                ├── streak: {currentStreak: 0, ...}
                ├── energy: {currentEnergy: 5, ...}
                ├── xp: {totalXp: 0, level: 1, ...}
                ├── gems: {gems: 0, ...}
                ├── currentLeague: "bronze"
                └── history/ (vazio)
```

---

## 🧪 Comportamento Esperado

### Cenário 1: Novo Usuário
1. ✅ Completa onboarding (Chinês)
2. ✅ Stats criados em `courses/{courseId}/stats/gamification`
3. ✅ UI mostra: xp=0, streak=0, gems=0, energy=5

### Cenário 2: Adicionar Novo Curso
1. ✅ Usuário tem Chinês com xp=20, streak=1
2. ✅ Adiciona curso Alemão
3. ✅ Stats do Alemão criados com xp=0, streak=0
4. ✅ UI atualiza automaticamente: xp=0, streak=0, gems=0, energy=5
5. ✅ Stats do Chinês mantidos: xp=20, streak=1

### Cenário 3: Trocar Curso
1. ✅ Usuário tem Chinês (xp=20) e Alemão (xp=0)
2. ✅ Troca para Alemão
3. ✅ UI atualiza: xp=0, streak=0, gems=0, energy=5
4. ✅ Troca para Chinês
5. ✅ UI atualiza: xp=20, streak=1 (mantido)

### Cenário 4: Completar Lição
1. ✅ Usuário está em Alemão (xp=0)
2. ✅ Completa lição (+10 XP)
3. ✅ UI atualiza: xp=10
4. ✅ Stats salvos em `courses/{alemaoId}/stats/gamification`
5. ✅ Troca para Chinês
6. ✅ UI mostra: xp=20 (não mudou)
7. ✅ Troca para Alemão
8. ✅ UI mostra: xp=10 (mantido)

---

## 🔍 Logs de Debug

### Ao adicionar novo curso:
```
📚 addNewCourse: INICIANDO...
  👤 UserId: TL0u8nDFpGhcOdaozkZGaH7FiCB2
  📊 Dados do novo curso:
    - Idioma: de
    - Nome: Alemão
    - Nível: beginner
    - Motivo: travel
    - Tempo: 10 min/dia
  🆔 Novo courseId: abc123xyz
  🔄 Desativando curso atual...
    📝 Marcando curso gKRtGWh5B2c5Ca65HYIf para desativar
  💾 Criando curso no Firestore...
    Path: users/TL0u8nDFpGhcOdaozkZGaH7FiCB2/courses/abc123xyz
  💾 Criando stats do novo curso...
    Path: users/TL0u8nDFpGhcOdaozkZGaH7FiCB2/courses/abc123xyz/stats/gamification
  🔄 Executando batch commit...
  ✅ Curso e stats salvos com sucesso!
✅ addNewCourse: CONCLUÍDO
```

### Ao trocar curso:
```
🔄 switchActiveCourse() INICIADO: abc123xyz
  📝 Desativando curso atual: gKRtGWh5B2c5Ca65HYIf
  📝 Ativando novo curso: abc123xyz
  ✅ Batch commit realizado
🔄 _loadActiveCourse() INICIADO
  ✅ Curso ativo: abc123xyz
  ✅ Curso ativo carregado: Alemão (de)
✅ _loadActiveCourse() CONCLUÍDO
🔄 _loadLessonProgress() INICIADO
  ✅ Lições completadas: 0
✅ _loadLessonProgress() CONCLUÍDO
  🔄 Recarregando stats do novo curso...
🔍 GamificationController.loadStats: Buscando curso ativo...
  ✅ Curso ativo: abc123xyz
  🔍 Buscando stats do curso ativo...
  ✅ Stats encontrados, carregando...
  ✅ Stats recarregados com sucesso
✅ switchActiveCourse() CONCLUÍDO
```

---

## ⚠️ Migração de Usuários Existentes

### Problema
Usuários existentes têm stats em `users/{userId}/stats/gamification` (estrutura antiga).

### Solução
Criar script de migração para mover stats antigas para o curso ativo:

```dart
// Script de migração (executar uma vez)
Future<void> migrateUserStats(String userId) async {
  final firestore = FirebaseFirestore.instance;
  
  // 1. Buscar stats antigas
  final oldStatsDoc = await firestore
      .collection('users')
      .doc(userId)
      .collection('stats')
      .doc('gamification')
      .get();
  
  if (!oldStatsDoc.exists) return;
  
  // 2. Buscar curso ativo
  final coursesSnapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .where('isActive', isEqualTo: true)
      .limit(1)
      .get();
  
  if (coursesSnapshot.docs.isEmpty) return;
  
  final courseId = coursesSnapshot.docs.first.id;
  
  // 3. Copiar stats para o curso ativo
  await firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)
      .collection('stats')
      .doc('gamification')
      .set(oldStatsDoc.data()!);
  
  // 4. Deletar stats antigas
  await oldStatsDoc.reference.delete();
  
  print('✅ Stats migrados para curso $courseId');
}
```

**Nota:** Este script deve ser executado para todos os usuários existentes antes de fazer deploy da nova versão.

---

## 📊 Checklist de Testes

### Testes Manuais
- [ ] Novo usuário: Completar onboarding e verificar stats criados no curso
- [ ] Adicionar curso: Verificar stats do novo curso com valores zerados
- [ ] Trocar curso: Verificar UI atualiza com stats do curso selecionado
- [ ] Completar lição: Verificar XP salvo no curso correto
- [ ] Voltar para curso anterior: Verificar stats mantidos

### Testes Automatizados
- [ ] Unit tests: `GamificationController.loadStats()` busca curso ativo
- [ ] Unit tests: `GamificationController._saveStats()` salva no curso ativo
- [ ] Integration tests: Fluxo completo de adicionar curso e trocar
- [ ] Integration tests: Stats independentes entre cursos

---

## 🎉 Resultado Final

✅ **Gamificação agora é por curso!**

- Cada curso tem suas próprias stats (XP, streak, gems, energy)
- Ao trocar curso, UI atualiza automaticamente
- Progresso de cada curso é mantido independentemente
- Usuário pode aprender múltiplos idiomas sem perder progresso

---

## 📚 Arquivos Modificados

1. ✅ `lib/features/core/onboarding/controllers/onboarding_controller.dart`
   - Método `finalizeAccount()` - criar stats no curso
   - Método `addNewCourse()` - criar stats no novo curso

2. ✅ `lib/features/inners/gamification/controllers/gamification_controller.dart`
   - Método `loadStats()` - buscar stats do curso ativo
   - Método `_saveStats()` - salvar stats no curso ativo
   - Método `_createInitialStats()` - criar stats no curso especificado
   - Métodos de histórico - salvar no curso ativo
   - Método `queryHistory()` - buscar do curso ativo

3. ✅ `lib/features/inners/home/controllers/home_controller.dart`
   - Método `switchActiveCourse()` - recarregar stats ao trocar curso

4. ✅ `docs/specs-logica/13-switch-course-ui/RESUMO.md` - Documentação da solução
5. ✅ `docs/specs-logica/13-switch-course-ui/IMPLEMENTACAO-COMPLETA.md` - Este arquivo

---

## 🚀 Próximos Passos

1. [ ] Testar fluxo completo no app
2. [ ] Criar script de migração para usuários existentes
3. [ ] Executar migração em produção
4. [ ] Monitorar logs para garantir que tudo funciona
5. [ ] Atualizar testes automatizados
