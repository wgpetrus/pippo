# Perfil - Gerenciar Cursos

> Lógica de adicionar, remover e trocar cursos

---

## Marcar Curso como Primário

```dart
Future<void> setPrimaryCourse(String courseId) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  
  // 1. Desmarcar todos os cursos como primário
  final courses = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('courses')
      .get();
  
  final batch = FirebaseFirestore.instance.batch();
  
  for (final doc in courses.docs) {
    batch.update(doc.reference, {'isPrimary': false});
  }
  
  // 2. Marcar curso selecionado como primário
  final courseRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId);
  
  batch.update(courseRef, {'isPrimary': true});
  
  // 3. Executar batch
  await batch.commit();
  
  // 4. Atualizar UI
  update();
}
```

---

## Remover Curso

```dart
Future<void> removeCourse(String courseId) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  
  // 1. Mostrar confirmação
  final confirmed = await showConfirmDialog(
    title: 'Remover curso?',
    message: 'Tem certeza que deseja remover este curso? '
             'Todo o progresso será perdido.',
  );
  
  if (!confirmed) return;
  
  // 2. Verificar se é o curso primário
  final course = await getCourse(courseId);
  final wasPrimary = course.isPrimary;
  
  // 3. Deletar curso
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)
      .delete();
  
  // 4. Se era primário, marcar outro como primário
  if (wasPrimary) {
    final remainingCourses = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('courses')
        .limit(1)
        .get();
    
    if (remainingCourses.docs.isNotEmpty) {
      await setPrimaryCourse(remainingCourses.docs.first.id);
    }
  }
  
  // 5. Atualizar UI
  courses.removeWhere((c) => c.id == courseId);
  update();
}
```

---

## Adicionar Novo Curso

```dart
Future<void> addNewCourse() async {
  // 1. Marcar flag
  isAddingCourse.value = true;
  
  // 2. Navegar para onboarding reduzido
  Get.toNamed('/onboarding');
  
  // Fluxo reduzido:
  // - SelectLanguage
  // - LanguageLevel
  // - LearningReason
  // - Criar curso
  // - Voltar para CoursesPage
}

Future<void> createNewCourse({
  required String languageCode,
  required String languageName,
  required String level,
  required String learningReason,
  required int dailyGoal,
}) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  
  // Usar uuid package para gerar ID único
  import 'package:uuid/uuid.dart';
  const uuid = Uuid();
  final courseId = uuid.v4();
  
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)
      .set({
    'id': courseId,
    'languageCode': languageCode,
    'languageName': languageName,
    'level': level,
    'learningReason': learningReason,
    'dailyGoal': dailyGoal,
    'currentUnitId': 'unit_1',
    'currentLessonId': 'lesson_1',
    'totalXp': 0,
    'lessonsCompleted': 0,
    'startedAt': FieldValue.serverTimestamp(),
    'isActive': true,
    'isPrimary': false, // não é primário por padrão
  });
  
  // Voltar para CoursesPage
  Get.back();
}
```

---

## Calcular Progresso do Curso

```dart
double getCourseProgress(Course course) {
  if (course.totalLessons == 0) return 0;
  
  return (course.lessonsCompleted / course.totalLessons) * 100;
}
```

---

## Buscar Curso Primário

```dart
Future<Course?> getPrimaryCourse() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  
  final query = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('courses')
      .where('isPrimary', isEqualTo: true)
      .limit(1)
      .get();
  
  if (query.docs.isEmpty) return null;
  
  return Course.fromFirestore(query.docs.first);
}
```
