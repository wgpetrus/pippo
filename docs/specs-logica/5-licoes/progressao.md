# Lições - Progressão e Desbloqueio

> Sistema de progressão linear de lições

---

## Hierarquia

```
Curso (ex: French)
  └── Unidade (ex: Unit 1: Basics)
      └── Seção (ex: Section 1: Greetings)
          └── Lição (ex: Lesson 1)
              └── Exercícios (5-10 por lição)
```

---

## Regras de Desbloqueio

### Lições
- **Primeira lição de cada curso**: sempre desbloqueada
- **Próximas lições**: desbloqueiam ao completar anterior

### Seções
- Desbloqueiam ao completar todas lições da anterior

### Unidades
- Desbloqueiam ao completar todas seções da anterior

---

## Estados de Lição

```dart
enum LessonStatus {
  locked,       // Bloqueada (cadeado, fundo cinza)
  not_started,  // Disponível mas não iniciada (botão "COMEÇAR")
  in_progress,  // Iniciada mas não completada (barra parcial)
  completed,    // Completada (barra verde, troféu, sparkles)
}
```

---

## Verificação de Desbloqueio

```dart
Future<bool> isLessonUnlocked(String lessonId) async {
  // 1. Primeira lição sempre desbloqueada
  if (lessonId == 'lesson_1') return true;
  
  // 2. Buscar lição anterior
  final previousLesson = await getPreviousLesson(lessonId);
  
  // 3. Verificar se anterior foi completada
  final progress = await getLessonProgress(previousLesson.id);
  
  return progress.status == LessonStatus.completed;
}
```

---

## Salvar Progresso

```dart
Future<void> saveLessonProgress({
  required String lessonId,
  required String unitId,
  required LessonStatus status,
  required int attempts,
  required double accuracy,
  required int xpEarned,
  required int timeSpent,
  required List<String> mistakes,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)
      .collection('progress')
      .doc(lessonId)
      .set({
    'lessonId': lessonId,
    'unitId': unitId,
    'status': status.name,
    'completedAt': status == LessonStatus.completed 
        ? FieldValue.serverTimestamp() 
        : null,
    'attempts': attempts,
    'bestScore': accuracy,
    'xpEarned': xpEarned,
    'timeSpent': timeSpent,
    'mistakes': mistakes,
  }, SetOptions(merge: true));
}
```

---

## Atualizar Curso

```dart
// Ao completar lição
Future<void> updateCourseProgress(String lessonId) async {
  final course = await getCurrentCourse();
  
  // Incrementar lições completadas
  course.lessonsCompleted++;
  
  // Atualizar lição atual
  final nextLesson = await getNextLesson(lessonId);
  if (nextLesson != null) {
    course.currentLessonId = nextLesson.id;
    course.currentUnitId = nextLesson.unitId;
  }
  
  // Atualizar última prática
  course.lastPracticedAt = DateTime.now();
  
  // Salvar no Firestore
  await saveCourse(course);
}
```
