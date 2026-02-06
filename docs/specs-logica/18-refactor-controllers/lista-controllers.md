# Lista de Controllers - Refatoração

## Status Geral

- **Total de controllers:** 10
- **Dentro do limite (≤500):** 3 controllers ✅
- **Acima do limite (>500):** 7 controllers 🔴
- **Necessitam refatoração:** 7 controllers

---

## Checklist de Refatoração

### 🔴 Críticos (>800 linhas)

- [x] **01-ProfileController** (2045 → 6 controllers: ProfileData 346, ProfileSettings 147, ProfileSocial 500, ProfileSearch 117, ProfileCourses 263, ProfileAuth 360) ✅
- [x] **02-LessonController** (1810 → 4 controllers: LessonFlow 371, LessonExercise 127, LessonProgress 245, LessonRewards 731) ✅
- [x] **03-GamificationController** (1367 → 4 controllers: Streak 376, Energy 323, XpLevel 473, Gems 267) ✅
- [x] **04-OnboardingController** (1228 → 3 controllers: OnboardingFlow 218, OnboardingData 500, OnboardingValidation 419) ✅
- [x] **05-TreasureController** (897 → 2 controllers: TreasureChallenges 700, TreasureRewards 350) ✅

### 🟡 Acima do Limite (500-800 linhas)

- [ ] **06-HomeController** (764 → 2 controllers de ~380)
- [ ] **07-AuthController** (718 → 2 controllers de ~360)

### ✅ Dentro do Limite (≤500 linhas)

- ✅ **LeaderboardController** (427 linhas) - OK
- ✅ **ShopController** (330 linhas) - OK
- ✅ **SplashController** (169 linhas) - OK

---

## Mapeamento Completo

### 01. ProfileController (2045 linhas)

**Controller Atual:**
- `lib/features/inners/profile/controllers/profile_controller.dart`

**Controllers Novos (5):**

#### ProfileDataController (~400 linhas)
**Arquivo:** `lib/features/inners/profile/controllers/profile_data_controller.dart`

**Estados:**
- userName, username, bio, avatarId, country, email
- totalXp, currentStreak, lessonsCompleted, level
- profileCompletionPercentage, missingFields
- isLoading, errorMessage, isUsernameAvailable, isCheckingUsername

**Métodos a migrar:**
- `loadOwnProfile()`
- `updateProfile(Map<String, dynamic> updates)`
- `checkUsernameAvailability(String newUsername)`
- `_loadProfileStats(String userId)`
- `_calculateProfileCompletion(Map<String, dynamic> userData)`

---

#### ProfileSettingsController (~400 linhas)
**Arquivo:** `lib/features/inners/profile/controllers/profile_settings_controller.dart`

**Estados:**
- soundEffects, listeningExercises, speakingExercises
- practiceReminders, reminderTime
- leaderboardUpdates, friendActivity, dailyGoal
- isLoading, errorMessage

**Métodos a migrar:**
- `loadSettings()`
- `updateSetting(String key, dynamic value)`

---

#### ProfileSocialController (~400 linhas)
**Arquivo:** `lib/features/inners/profile/controllers/profile_social_controller.dart`

**Estados:**
- following, followers, followingCount, followersCount
- viewedUserId, viewedUserData, isFollowingViewedUser
- searchQuery, searchResults, isSearching, searchErrorMessage
- weeklyProgress, viewedUserWeeklyProgress, isLoadingProgress
- isLoading, errorMessage

**Métodos a migrar:**
- `loadUserProfile(String userId)`
- `followUser(String targetUserId)`
- `unfollowUser(String targetUserId)`
- `loadFollowing()`
- `loadFollowers()`
- `loadUserFollowing(String userId)`
- `loadUserFollowers(String userId)`
- `isUserFollowed(String targetUserId)`
- `searchUsers(String query)`
- `clearSearch()`
- `loadWeeklyProgress()`
- `loadUserWeeklyProgress(String userId)`
- `_loadSocialCounts(String userId)`
- `_checkIfFollowing(String currentUserId, String targetUserId)`
- `_getDayAbbreviation(int weekday)`

---

#### ProfileCoursesController (~400 linhas)
**Arquivo:** `lib/features/inners/profile/controllers/profile_courses_controller.dart`

**Estados:**
- userCourses, primaryCourseId
- isLoading, errorMessage

**Métodos a migrar:**
- `loadUserCourses()`
- `setPrimaryCourse(String courseId, {bool showSnackbar = true})`
- `removeCourse(String courseId)`
- `_getLanguageName(String code)`
- `_getLanguageFlag(String code)`

---

#### ProfileAuthController (~400 linhas)
**Arquivo:** `lib/features/inners/profile/controllers/profile_auth_controller.dart`

**Estados:**
- phone, phoneVerified, verificationId
- isLoading, errorMessage

**Métodos a migrar:**
- `changePassword(String currentPassword, String newPassword)`
- `linkPhoneNumber(String phoneNumber, String verificationCode)`
- `deleteAccount()`
- `_deleteUserSubcollections(String userId)`
- `_deleteCoursesWithSubcollections(String userId)`
- `_deleteCourseSubcollection(String userId, String courseId, String subcollectionName)`
- `_deleteCourseStatsSubcollection(String userId, String courseId)`
- `_deleteSubcollection(String userId, String subcollectionName)`
- `_deleteStatsSubcollection(String userId)`
- `_reauthenticateForDeletion()`
- `_handleFirebaseAuthError(FirebaseAuthException e)`

---

#### Handlers Compartilhados
**Arquivo:** `lib/features/inners/profile/controllers/profile_error_handler.dart` (opcional)

**Métodos:**
- `_handleFirestoreError(FirebaseException e)`

---

### 02. LessonController (1810 linhas)

**Controller Atual:**
- `lib/features/core/lesson/controllers/lesson_controller.dart`

**Controllers Novos (4):**

#### LessonFlowController (~450 linhas)
**Arquivo:** `lib/features/core/lesson/controllers/lesson_flow_controller.dart`

**Responsabilidade:** Gerenciar fluxo da lição (start, navigation, completion)

**Estados:**
- currentLesson, currentExercises, currentExerciseIndex
- isLoading, errorMessage

**Métodos a migrar:**
- `startLessonFromActiveCourse(String lessonId)`
- `startLesson(String courseId, String lessonId)`
- `nextExercise()`
- `completeLesson()`
- `exitLesson()`
- `_resetLessonState()`

---

#### LessonExerciseController (~450 linhas)
**Arquivo:** `lib/features/core/lesson/controllers/lesson_exercise_controller.dart`

**Responsabilidade:** Gerenciar exercícios (current, validation, feedback)

**Estados:**
- showFeedback, isCorrectAnswer, correctAnswerText
- isLoading, errorMessage

**Métodos a migrar:**
- `submitAnswer(dynamic answer)`
- `validateImageExercise(String selectedImage)`
- `validateTranslationExercise(String selectedTranslation)`
- `validateWordExercise(List<String> words)`
- `validateMatchExercise(Map<String, String> matches)`
- `closeFeedback()`

---

#### LessonProgressController (~450 linhas)
**Arquivo:** `lib/features/core/lesson/controllers/lesson_progress_controller.dart`

**Responsabilidade:** Gerenciar progresso (hearts, accuracy, time, stats)

**Estados:**
- hearts, correctAnswers, totalAnswers
- startTime, pauseTime, accumulatedTime
- lessonFailed
- isLoading, errorMessage

**Métodos a migrar:**
- `loseHeart()`
- `addCorrectAnswer()`
- `addWrongAnswer()`
- `startTimer()`
- `pauseTimer()`
- `resumeTimer()`
- `getElapsedTime()`
- Getters: `progress`, `accuracy`, `isPerfect`

---

#### LessonRewardsController (~450 linhas)
**Arquivo:** `lib/features/core/lesson/controllers/lesson_rewards_controller.dart`

**Responsabilidade:** Gerenciar recompensas (XP, gems, achievements)

**Estados:**
- calculatedXp, calculatedGems
- isLoading, errorMessage

**Métodos a migrar:**
- `calculateRewards()`
- `applyRewards()`
- `_updateLessonProgress(String courseId, String lessonId)`
- `_updateSectionProgress(String courseId, String sectionId)`

---

### 03. GamificationController (1367 linhas)

**Controller Atual:**
- `lib/features/inners/gamification/controllers/gamification_controller.dart`

**Controllers Novos (4):**

#### StreakController (~340 linhas)
**Arquivo:** `lib/features/inners/gamification/controllers/streak_controller.dart`

**Responsabilidade:** Gerenciar streak (dias consecutivos, freeze, milestones)

**Estados:**
- currentStreak, longestStreak
- _lastStreakDate, _streakFreezeAvailable, _streakFreezeUsedToday
- _milestonesReached
- isLoading, errorMessage

**Métodos a migrar:**
- `loadStreak()`
- `updateStreak()`
- `useStreakFreeze()`
- `checkStreakMilestone()`
- Getter: `streakFreezeAvailable`

---

#### EnergyController (~340 linhas)
**Arquivo:** `lib/features/inners/gamification/controllers/energy_controller.dart`

**Responsabilidade:** Gerenciar energia (regeneração, unlimited, consumo)

**Estados:**
- currentEnergy
- _lastEnergyRegenAt, _unlimitedEnergyUntil
- isLoading, errorMessage

**Métodos a migrar:**
- `loadEnergy()`
- `consumeEnergy(int amount)`
- `regenerateEnergy()`
- `activateUnlimitedEnergy(int minutes)`
- `refillEnergy()`
- Getter: `hasUnlimitedEnergy`

---

#### XpLevelController (~340 linhas)
**Arquivo:** `lib/features/inners/gamification/controllers/xp_level_controller.dart`

**Responsabilidade:** Gerenciar XP e níveis (progressão, booster, weekly/daily)

**Estados:**
- totalXp, weeklyXP, todayXp, level, xpToNextLevel
- _xpBoosterUntil
- _lastWeeklyResetDate, _lastDailyResetDate
- isLoading, errorMessage

**Métodos a migrar:**
- `loadXpAndLevel()`
- `addXp(int amount)`
- `activateXpBooster(int minutes)`
- `resetWeeklyXp()`
- `resetDailyXp()`
- `_calculateLevel(int xp)`
- `_calculateXpToNextLevel(int level)`
- Getters: `hasXpBooster`, `xpBoosterUntil`, `getXpBoosterTimeRemaining()`

---

#### GemsController (~340 linhas)
**Arquivo:** `lib/features/inners/gamification/controllers/gems_controller.dart`

**Responsabilidade:** Gerenciar gems (ganho, gasto, multiplier)

**Estados:**
- gems, totalGemsEarned, totalGemsSpent
- _gemMultiplierUntil
- isLoading, errorMessage

**Métodos a migrar:**
- `loadGems()`
- `addGems(int amount)`
- `spendGems(int amount)`
- `activateGemMultiplier(int minutes)`
- Getters: `hasGemMultiplier`, `gemMultiplierUntil`, `getGemMultiplierTimeRemaining()`

---

### 04. OnboardingController (1228 linhas)

**Controller Atual:**
- `lib/features/core/onboarding/controllers/onboarding_controller.dart`

**Controllers Novos (3):**

#### OnboardingFlowController (~410 linhas)
**Arquivo:** `lib/features/core/onboarding/controllers/onboarding_flow_controller.dart`

**Responsabilidade:** Gerenciar navegação e fluxo entre telas

**Estados:**
- currentStep
- isLoading, errorMessage

**Métodos a migrar:**
- Todos os métodos de navegação (goToSelectLanguage, goToLanguageLevel, etc)
- `finishOnboarding()`

---

#### OnboardingDataController (~410 linhas)
**Arquivo:** `lib/features/core/onboarding/controllers/onboarding_data_controller.dart`

**Responsabilidade:** Gerenciar coleta de dados do usuário

**Estados:**
- selectedLanguage, languageLevel, learningReason
- studyTime, userName, userAge, userEmail, userPassword
- isLoading, errorMessage

**Métodos a migrar:**
- `setLanguage(String language)`
- `setLanguageLevel(String level)`
- `setLearningReason(String reason)`
- `setStudyTime(int minutes)`
- `setUserName(String name)`
- `setUserAge(String ageRange)`
- `setUserEmail(String email)`
- `setUserPassword(String password)`
- `saveUserData()`

---

#### OnboardingValidationController (~410 linhas)
**Arquivo:** `lib/features/core/onboarding/controllers/onboarding_validation_controller.dart`

**Responsabilidade:** Gerenciar validações e verificações

**Estados:**
- isLoading, errorMessage

**Métodos a migrar:**
- `validateEmail(String? value)`
- `validatePassword(String? value)`
- `validateName(String? value)`
- `sendVerificationCode(String email)`
- `verifyCode(String code)`
- `checkUsernameAvailability(String username)`

---

### 05. TreasureController (897 linhas)

**Controller Atual:**
- `lib/features/inners/treasure/controllers/treasure_controller.dart`

**Controllers Novos (2):**

#### TreasureChallengesController (~450 linhas)
**Arquivo:** `lib/features/inners/treasure/controllers/treasure_challenges_controller.dart`

**Responsabilidade:** Gerenciar desafios (daily, weekly, progress)

**Estados:**
- dailyChallenges, weeklyChallenges
- challengeProgress
- isLoading, errorMessage

**Métodos a migrar:**
- `loadChallenges()`
- `updateChallengeProgress(String challengeId, int progress)`
- `checkChallengeCompletion(String challengeId)`

---

#### TreasureRewardsController (~450 linhas)
**Arquivo:** `lib/features/inners/treasure/controllers/treasure_rewards_controller.dart`

**Responsabilidade:** Gerenciar recompensas (claim, tracking, history)

**Estados:**
- claimedRewards, pendingRewards
- isLoading, errorMessage

**Métodos a migrar:**
- `claimReward(String challengeId)`
- `loadRewardHistory()`
- `calculateReward(String challengeId)`

---

### 06. HomeController (764 linhas)

**Controller Atual:**
- `lib/features/inners/home/controllers/home_controller.dart`

**Controllers Novos (2):**

#### HomeNavigationController (~380 linhas)
**Arquivo:** `lib/features/inners/home/controllers/home_navigation_controller.dart`

**Responsabilidade:** Gerenciar navegação entre tabs e modais

**Estados:**
- currentNavIndex
- isLoading, errorMessage

**Métodos a migrar:**
- `changeTab(int index)`
- `showStreakModal()`
- `showEnergyModal()`
- `showGemsModal()`
- `showCoursesModal()`

---

#### HomeStatsController (~380 linhas)
**Arquivo:** `lib/features/inners/home/controllers/home_stats_controller.dart`

**Responsabilidade:** Gerenciar exibição de stats (streak, energy, gems)

**Estados:**
- displayStreak, displayEnergy, displayGems
- isLoading, errorMessage

**Métodos a migrar:**
- `loadStats()`
- `refreshStats()`
- `syncWithGamification()`

---

### 07. AuthController (718 linhas)

**Controller Atual:**
- `lib/features/core/auth/controllers/auth_controller.dart`

**Controllers Novos (2):**

#### AuthCredentialsController (~360 linhas)
**Arquivo:** `lib/features/core/auth/controllers/auth_credentials_controller.dart`

**Responsabilidade:** Gerenciar login/registro com email/senha

**Estados:**
- isLoading, errorMessage

**Métodos a migrar:**
- `login(String email, String password)`
- `register(String email, String password)`
- `validateEmail(String? value)`
- `validatePassword(String? value)`

---

#### AuthProvidersController (~360 linhas)
**Arquivo:** `lib/features/core/auth/controllers/auth_providers_controller.dart`

**Responsabilidade:** Gerenciar login social e recuperação

**Estados:**
- isLoading, errorMessage

**Métodos a migrar:**
- `signInWithGoogle()`
- `signInWithFacebook()`
- `sendPasswordResetEmail(String email)`
- `verifyResetCode(String code)`
- `resetPassword(String code, String newPassword)`
- `logout()`

---

## Resumo de Arquivos

### Antes da Refatoração
- 10 controllers
- 7 acima do limite

### Depois da Refatoração
- 31 controllers
- 0 acima do limite
- Todos ≤500 linhas

### Arquivos Criados
- 21 novos controllers
- 7 controllers deletados (antigos)
- Saldo: +14 arquivos de controller
