# Lições - Fluxo Completo

> Processo completo de uma lição do início ao fim

---

## Antes de Iniciar

### Verificações (ordem exata)

```dart
Future<bool> canStartLesson(String lessonId) async {
  // 1. Verificar se lição está desbloqueada
  if (!await isLessonUnlocked(lessonId)) {
    showMessage('Complete a lição anterior primeiro');
    return false;
  }
  
  // 2. Verificar energia ilimitada
  if (hasUnlimitedEnergy()) {
    return true;
  }
  
  // 3. Verificar energia disponível
  if (currentEnergy > 0) {
    return true;
  }
  
  // 4. Sem energia
  showLowEnergyModal();
  return false;
}
```

---

## Ao Iniciar Lição

```dart
Future<void> startLesson(String lessonId) async {
  // 1. Consumir energia (se não tiver ilimitada)
  if (!hasUnlimitedEnergy()) {
    currentEnergy--;
    await saveEnergy();
  }
  
  // 2. Carregar exercícios do Firestore
  final exercises = await loadExercises(lessonId);
  
  // 3. Embaralhar ordem (opcional)
  exercises.shuffle();
  
  // 4. Inicializar estado da lição
  currentExerciseIndex = 0;
  correctAnswers = 0;
  totalAnswers = 0;
  hearts = 3;
  startTime = DateTime.now();
  
  // 5. Navegar para primeiro exercício
  navigateToExercise(exercises[0]);
}
```

---

## Durante a Lição

### Ao responder exercício

```dart
Future<void> submitAnswer(String answerId) async {
  // 1. Desabilitar interação
  isAnswering.value = true;
  
  // 2. Validar resposta
  final isCorrect = validateAnswer(answerId);
  
  // 3. Incrementar contadores
  totalAnswers++;
  if (isCorrect) {
    correctAnswers++;
  }
  
  // 4. Mostrar feedback
  if (isCorrect) {
    showCorrectFeedback();
  } else {
    hearts--;
    showWrongFeedback();
    
    // 5. Verificar se perdeu todos corações
    if (hearts == 0) {
      await failLesson();
      return;
    }
  }
  
  // 6. Próximo exercício ou finalizar
  if (currentExerciseIndex < exercises.length - 1) {
    currentExerciseIndex++;
    navigateToExercise(exercises[currentExerciseIndex]);
  } else {
    await completeLesson();
  }
}
```

---

## Ao Falhar Lição

```dart
Future<void> failLesson() async {
  // 1. Parar timer
  final timeSpent = DateTime.now().difference(startTime).inSeconds;
  
  // 2. Mostrar tela de falha
  navigateToFailScreen(
    correctAnswers: correctAnswers,
    totalAnswers: totalAnswers,
    timeSpent: timeSpent,
  );
  
  // Consequências:
  // - Não ganha XP nem gems
  // - Não conta como lição completada
  // - Não atualiza progresso
  // - Energia já foi consumida
}
```

---

## Ao Completar Lição

### Ordem EXATA de operações

```dart
Future<void> completeLesson() async {
  // 1. Parar timer
  final timeSpent = DateTime.now().difference(startTime).inSeconds;
  
  // 2. Calcular accuracy
  final accuracy = (correctAnswers / totalAnswers) * 100;
  
  // 3. Verificar se foi perfeito
  final isPerfect = (accuracy == 100);
  
  // 4. Verificar se é primeira do dia
  final isFirstToday = await isFirstLessonToday();
  
  // 5. Calcular recompensas
  int xp = lesson.xpReward; // XP base
  int gems = lesson.gemsReward; // Gems base
  
  // Bônus
  if (isPerfect) xp += 5;
  if (isFirstToday) xp += 5;
  if (hasActiveXpBooster()) xp *= 2;
  if (hasActiveGemMultiplier()) gems *= 2;
  
  // 6. Adicionar XP
  totalXp += xp;
  weeklyXp += xp;
  todayXp += xp;
  
  // 7. Adicionar gems
  this.gems += gems;
  totalGemsEarned += gems;
  
  // 8. Salvar progresso da lição
  await saveLessonProgress(
    lessonId: lesson.id,
    unitId: lesson.unitId,
    status: LessonStatus.completed,
    attempts: 1,
    accuracy: accuracy,
    xpEarned: xp,
    timeSpent: timeSpent,
    mistakes: mistakes,
  );
  
  // 9. Atualizar streak (se primeira do dia)
  if (isFirstToday) {
    await updateStreak();
  }
  
  // 10. Atualizar desafios
  await updateChallenges(type: 'lessons', amount: 1);
  await updateChallenges(type: 'xp', amount: xp);
  await updateChallenges(type: 'correct_exercises', amount: correctAnswers);
  
  // 11. Verificar level up
  await checkLevelUp();
  
  // 12. Salvar histórico do dia
  await saveHistory(
    date: DateFormat('yyyy-MM-DD').format(DateTime.now()),
    lessonsCompleted: 1,
    xpEarned: xp,
    timeSpent: timeSpent,
    exercisesCorrect: correctAnswers,
    exercisesTotal: totalAnswers,
  );
  
  // 13. Atualizar curso
  await updateCourseProgress(lesson.id);
  
  // 14. Mostrar tela de conclusão
  navigateToCompleteScreen(
    xpGained: xp,
    accuracy: accuracy,
    timeSpent: timeSpent,
    gemsGained: gems,
  );
}
```

---

## Sistema de Corações

- Iniciar com 3 corações
- Perder 1 a cada erro
- Se chegar a 0: lição falha
- Não regeneram durante lição

---

## Botão Fechar (X)

```dart
void onClosePressed() {
  showDialog(
    title: 'Tem certeza que quer sair?',
    message: 'Você perderá todo o progresso desta lição.',
    actions: [
      TextButton(
        text: 'Continuar Aprendendo',
        onPressed: () => Get.back(),
      ),
      TextButton(
        text: 'Sair',
        onPressed: () {
          // Voltar para trilha
          // Perder progresso
          Get.back();
          Get.back();
        },
      ),
    ],
  );
}
```
