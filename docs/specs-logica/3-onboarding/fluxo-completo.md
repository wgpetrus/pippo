# Onboarding - Fluxo Completo

> Processo de primeiro acesso e criação de conta

---

## Dados Coletados (armazenar temporariamente no controller)

- `selectedLanguage` - Código e nome do idioma
- `languageLevel` - Nível (beginner, intermediate, advanced)
- `learningReason` - Motivo (travel, work, culture, brain, other)
- `studyTime` - Meta diária (5, 10, 15, 20 minutos)
- `userName` - Nome do usuário
- `userAge` - Faixa etária (under_13, 13-17, 18-24, 25-34, 35+)
- `userEmail` - Email
- `userPassword` - Senha

---

## Processo ao Finalizar

### 1. Criar usuário no Firebase Auth

```dart
final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: userEmail,
  password: userPassword,
);
```

---

### 2. Enviar código de verificação

- Código de 5 dígitos
- Expira em 10 minutos
- Usuário digita na tela VerifyCode

---

### 3. Criar documento do usuário

```dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(userCredential.user!.uid)
    .set({
  'id': userCredential.user!.uid,
  'email': userEmail,
  'name': userName,
  'username': generateUsername(userName), // gerar único
  'avatarId': 'avatar_01', // padrão
  'age': userAge,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
  'lastActiveAt': FieldValue.serverTimestamp(),
  'onboardingCompleted': true,
});
```

---

### 4. Criar primeiro curso

**Nota**: Usar Firestore auto-generated ID (não UUID):

```dart
// Gerar ID automaticamente via Firestore
final courseRef = FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('courses')
    .doc(); // Auto-generated ID

final courseId = courseRef.id;

await courseRef.set({
  'id': courseId,
  'languageCode': selectedLanguage.code,
  'languageName': selectedLanguage.name,
  'level': languageLevel,
  'learningReason': learningReason,
  'dailyGoal': studyTime,
  'currentUnitId': 'unit_1',
  'currentLessonId': 'lesson_1',
  'totalXp': 0,
  'lessonsCompleted': 0,
  'startedAt': FieldValue.serverTimestamp(),
  'isActive': true,
  'isPrimary': true,
});
```

---

### 5. Inicializar stats de gamificação

```dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('stats')
    .doc('gamification')
    .set({
  // Streak
  'currentStreak': 0,
  'longestStreak': 0,
  'lastStreakDate': '',
  'streakFreezeAvailable': 0,
  'streakFreezeUsedToday': false,
  
  // Energia
  'currentEnergy': 5,
  'maxEnergy': 5,
  'lastEnergyRegenAt': FieldValue.serverTimestamp(),
  'unlimitedEnergyUntil': null,
  
  // Gems
  'gems': 0,
  'totalGemsEarned': 0,
  'totalGemsSpent': 0,
  
  // XP e Level
  'totalXp': 0,
  'weeklyXp': 0,
  'todayXp': 0,
  'level': 1,
  'xpToNextLevel': 100,
  
  // Ranking
  'currentLeague': 'bronze',
  'leagueRank': 0,
  'promotionZone': false,
  'demotionZone': false,
});
```

---

### 6. Navegar para Home

```dart
Get.offAllNamed('/home');
```

---

## Barra de Progresso

- **Total de telas**: 14
- **Cálculo**: `(telaAtual / 14) * 100`
- **Telas de pausa NÃO contam**: Intro, PauseOne, PauseTow, Conclusion

---

## Fluxo de Adicionar Curso

**Flag especial**: `isAddingCourse = true`

**Diferenças:**
- Apenas 3 telas: SelectLanguage, LanguageLevel, LearningReason
- Não cria conta (usuário já existe)
- Apenas cria novo curso no Firestore
- Voltar para CoursesPage ao finalizar

**Ao finalizar:**
```dart
if (isAddingCourse) {
  // Criar novo curso
  await createCourse();
  Get.back(); // volta para CoursesPage
} else {
  // Fluxo completo de onboarding
  await finishOnboarding();
  Get.offAllNamed('/home');
}
```

---

## Validações

**Username:**
- Gerar automaticamente a partir do nome
- Verificar se já existe no Firestore
- Se existir, adicionar número ao final (ex: "joao123")
