# Estrutura Firestore - Pippo

> Estrutura completa de dados no Firebase Firestore

---

## users/{userId}

**Identificação:**
- `id` - Firebase Auth UID (gerado automaticamente pelo Firebase Auth)
- `email` - Email de cadastro
- `name` - Nome completo
- `username` - Nome de usuário único (@username)
- `avatarId` - ID do avatar escolhido (ex: "avatar_01")
- `bio` - Biografia curta (opcional)
- `country` - Código do país (ex: "BR", "US")
- `phone` - Telefone (opcional)
- `phoneVerified` - Boolean

**Datas:**
- `createdAt` - Timestamp
- `updatedAt` - Timestamp
- `lastActiveAt` - Timestamp

**Onboarding:**
- `onboardingCompleted` - Boolean
- `age` - Faixa etária (ex: "18-24", "25-34")

**Configurações (subcoleção settings):**
- `soundEffects` - Boolean
- `listeningExercises` - Boolean
- `speakingExercises` - Boolean
- `practiceReminders` - Boolean
- `reminderTime` - String (ex: "18:00")
- `leaderboardUpdates` - Boolean
- `friendActivity` - Boolean

---

## users/{userId}/courses/{courseId}

**Identificação:**
- `id` - Firestore auto-generated ID (gerado via .doc() sem parâmetros)
- `languageCode` - String (ex: "fr", "es", "de")
- `languageName` - String (ex: "French", "Spanish")
- `level` - String (beginner, intermediate, advanced)
- `learningReason` - String (travel, work, culture, brain, other)
- `dailyGoal` - Number (5, 10, 15, 20 minutos)

**Progresso:**
- `currentUnitId` - String
- `currentLessonId` - String
- `totalXp` - Number
- `lessonsCompleted` - Number

**Datas:**
- `startedAt` - Timestamp
- `lastPracticedAt` - Timestamp

**Status:**
- `isActive` - Boolean
- `isPrimary` - Boolean (apenas 1 pode ser true)

---

## users/{userId}/stats/gamification

**Streak:**
- `currentStreak` - Number
- `longestStreak` - Number
- `lastStreakDate` - String ("YYYY-MM-DD")
- `streakFreezeAvailable` - Number
- `streakFreezeUsedToday` - Boolean

**Energia:**
- `currentEnergy` - Number (0-5)
- `maxEnergy` - Number (padrão 5)
- `lastEnergyRegenAt` - Timestamp
- `unlimitedEnergyUntil` - Timestamp ou null

**Gems:**
- `gems` - Number
- `totalGemsEarned` - Number
- `totalGemsSpent` - Number

**XP e Level:**
- `totalXp` - Number
- `weeklyXp` - Number (reseta toda segunda 00:00)
- `todayXp` - Number (reseta à meia-noite)
- `level` - Number
- `xpToNextLevel` - Number

**Ranking:**
- `currentLeague` - String (bronze, silver, gold, platinum, diamond)
- `leagueRank` - Number (1-30)
- `promotionZone` - Boolean (top 10)
- `demotionZone` - Boolean (bottom 5)

---

## users/{userId}/courses/{courseId}/progress/{lessonId}

- `lessonId` - String
- `unitId` - String
- `status` - String (not_started, in_progress, completed)
- `completedAt` - Timestamp
- `attempts` - Number
- `bestScore` - Number (porcentagem)
- `xpEarned` - Number
- `timeSpent` - Number (segundos)
- `mistakes` - Array<String> (IDs dos exercícios errados)

---

## users/{userId}/history/{date}

**date = "YYYY-MM-DD"**

- `date` - String
- `lessonsCompleted` - Number
- `xpEarned` - Number
- `timeSpent` - Number (segundos)
- `streakMaintained` - Boolean
- `exercisesCorrect` - Number
- `exercisesTotal` - Number

---

## courses/{courseId}

**Gerenciado pelo admin**

- `id` - String
- `languageCode` - String
- `languageName` - String
- `flagAsset` - String
- `description` - String
- `totalUnits` - Number
- `totalLessons` - Number
- `isActive` - Boolean

---

## courses/{courseId}/units/{unitId}

- `id` - String
- `name` - String (ex: "Basics")
- `description` - String
- `order` - Number
- `sectionsCount` - Number
- `totalLessons` - Number
- `iconAsset` - String

---

## courses/{courseId}/units/{unitId}/sections/{sectionId}

- `id` - String
- `name` - String (ex: "Greetings")
- `order` - Number
- `lessonsCount` - Number
- `mascotAsset` - String

---

## courses/{courseId}/lessons/{lessonId}

- `id` - String
- `unitId` - String
- `sectionId` - String
- `order` - Number
- `exercisesCount` - Number
- `estimatedTime` - Number (minutos)
- `xpReward` - Number
- `gemsReward` - Number

---

## courses/{courseId}/lessons/{lessonId}/exercises/{exerciseId}

**Campos Comuns:**
- `id` - String
- `type` - String (image, translation, word_order, match)
- `order` - Number
- `prompt` - String

**Type: image**
- `word` - String
- `wordAudio` - String (path)
- `options` - Array de 4 objetos:
  - `id` - String
  - `image` - String (path)
  - `isCorrect` - Boolean

**Type: translation**
- `image` - String (path, opcional)
- `word` - String
- `wordAudio` - String (path)
- `options` - Array de 4 objetos:
  - `id` - String
  - `text` - String
  - `isCorrect` - Boolean

**Type: word_order**
- `sentence` - String
- `sentenceAudio` - String (path)
- `correctOrder` - Array<String>
- `availableWords` - Array<String> (inclui distratores)

**Type: match**
- `pairs` - Array de 4 objetos:
  - `audio` - String (path)
  - `text` - String

---

## challenges/{challengeId}

**Gerenciado pelo admin**

- `id` - String
- `type` - String (daily, weekly, special)
- `title` - String
- `description` - String
- `target` - Number
- `rewardType` - String (gems, xp, item)
- `rewardAmount` - Number
- `iconAsset` - String
- `expiresAt` - Timestamp

---

## users/{userId}/activeChallenges/{challengeId}

- `challengeId` - String
- `current` - Number
- `target` - Number
- `completed` - Boolean
- `claimedAt` - Timestamp ou null
