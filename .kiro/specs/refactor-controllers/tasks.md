# Implementation Plan: Controllers Refactoring

## Overview

This implementation plan covers the refactoring of 7 oversized controllers into 31 smaller, focused controllers. This is a pure migration task - existing code is moved without modification to improve maintainability and follow the Single Responsibility Principle (SRP).

**IMPORTANT**: This is NOT a rewrite. Every method and state is copied exactly as-is. No logic changes, no improvements, no "while we're at it" modifications. The goal is to reorganize working code into better files.

## Implementation Order

Controllers will be refactored in order from largest to smallest:
1. ProfileController (2045 lines → 5 controllers)
2. LessonController (1810 lines → 4 controllers)
3. GamificationController (1367 lines → 4 controllers)
4. OnboardingController (1228 lines → 3 controllers)
5. TreasureController (897 lines → 2 controllers)
6. HomeController (764 lines → 2 controllers)
7. AuthController (718 lines → 2 controllers)

## Tasks

- [x] 1. Refactor ProfileController (2045 lines → 5 controllers)
  - [x] 1.1 Create ProfileDataController
    - Create `features/inners/profile/controllers/profile_data_controller.dart`
    - Copy standard controller structure (Firebase instances, isLoading, errorMessage)
    - Copy states: userName, username, bio, avatarId, country, email, totalXp, currentStreak, lessonsCompleted, level, profileCompletionPercentage, missingFields, isUsernameAvailable, isCheckingUsername
    - Copy methods: loadOwnProfile(), updateProfile(), checkUsernameAvailability(), _loadProfileStats(), _calculateProfileCompletion()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 4.2, 5.1, 5.2, 5.3_
  
  - [x] 1.2 Create ProfileSettingsController
    - Create `features/inners/profile/controllers/profile_settings_controller.dart`
    - Copy standard controller structure
    - Copy states: soundEffects, listeningExercises, speakingExercises, practiceReminders, reminderTime, leaderboardUpdates, friendActivity, dailyGoal, isLoading, errorMessage
    - Copy methods: loadSettings(), updateSetting()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 4.2, 5.1, 5.2, 5.3_
  
  - [x] 1.3 Create ProfileSocialController
    - Create `features/inners/profile/controllers/profile_social_controller.dart`
    - Copy standard controller structure
    - Copy states: following, followers, followingCount, followersCount, viewedUserId, viewedUserData, isFollowingViewedUser, searchQuery, searchResults, isSearching, searchErrorMessage, weeklyProgress, viewedUserWeeklyProgress, isLoadingProgress, isLoading, errorMessage
    - Copy methods: loadUserProfile(), followUser(), unfollowUser(), loadFollowing(), loadFollowers(), loadUserFollowing(), loadUserFollowers(), isUserFollowed(), searchUsers(), clearSearch(), loadWeeklyProgress(), loadUserWeeklyProgress(), _loadSocialCounts(), _checkIfFollowing(), _getDayAbbreviation()
    - Add dependency on ProfileDataController in onInit()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 4.2, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3_
  
  - [x] 1.4 Create ProfileCoursesController
    - Create `features/inners/profile/controllers/profile_courses_controller.dart`
    - Copy standard controller structure
    - Copy states: userCourses, primaryCourseId, isLoading, errorMessage
    - Copy methods: loadUserCourses(), setPrimaryCourse(), removeCourse(), _getLanguageName(), _getLanguageFlag()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 4.2, 5.1, 5.2, 5.3_
  
  - [x] 1.5 Create ProfileAuthController
    - Create `features/inners/profile/controllers/profile_auth_controller.dart`
    - Copy standard controller structure
    - Copy states: phone, phoneVerified, verificationId, isLoading, errorMessage
    - Copy methods: changePassword(), linkPhoneNumber(), deleteAccount(), _deleteUserSubcollections(), _deleteCoursesWithSubcollections(), _deleteCourseSubcollection(), _deleteCourseStatsSubcollection(), _deleteSubcollection(), _deleteStatsSubcollection(), _reauthenticateForDeletion(), _handleFirebaseAuthError()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 4.2, 5.1, 5.2, 5.3, 9.1, 9.2, 9.3_
  
  - [x] 1.6 Update ProfileBinding
    - Open `features/inners/profile/bindings/profile_binding.dart`
    - Remove `Get.lazyPut(() => ProfileController())`
    - Add `Get.lazyPut(() => ProfileDataController())`
    - Add `Get.lazyPut(() => ProfileSettingsController())`
    - Add `Get.lazyPut(() => ProfileSocialController())`
    - Add `Get.lazyPut(() => ProfileCoursesController())`
    - Add `Get.lazyPut(() => ProfileAuthController())`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [x] 1.7 Update ProfilePage and related views
    - Identify all views that use ProfileController
    - Update `Get.find<ProfileController>()` to appropriate new controllers
    - Update all state and method references
    - Preserve all Obx() wrappers
    - Views to update: profile_page.dart, user_profile_page.dart, edit_profile_page.dart, settings_page.dart, notifications_page.dart, learning_controls_page.dart, courses_page.dart, change_password_page.dart, phone_number_page.dart, verify_phone_page.dart, phone_linked_page.dart
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [x] 1.8 Run all tests for Profile feature
    - Execute unit tests
    - Execute property tests
    - Execute integration tests
    - Verify all tests pass
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  
  - [x] 1.9 Delete old ProfileController
    - Delete `features/inners/profile/controllers/profile_controller.dart`
    - Verify no references remain
    - _Requirements: 1.1, 1.2, 13.3_
  
  - [x] 1.10 Commit ProfileController refactoring
    - Verify all new controllers ≤ 500 lines
    - Commit with message: "refactor: divide ProfileController em 5 controllers menores"
    - Update lista-controllers.md to mark ProfileController as complete
    - _Requirements: 13.1, 13.2, 14.3, 14.4, 15.1_

- [x] 2. Refactor LessonController (1810 lines → 4 controllers + Add code that allows you to run tests that require Firebase to be initialized.)
  - [x] 2.1 Create LessonFlowController
    - Create `features/core/lesson/controllers/lesson_flow_controller.dart`
    - Copy standard controller structure
    - Copy states: currentLesson, currentExercises, currentExerciseIndex, isLoading, errorMessage
    - Copy methods: startLessonFromActiveCourse(), startLesson(), nextExercise(), completeLesson(), exitLesson(), _resetLessonState()
    - Add dependency on GamificationController in onInit()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.2, 4.2, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3_
  
  - [x] 2.2 Create LessonExerciseController
    - Create `features/core/lesson/controllers/lesson_exercise_controller.dart`
    - Copy standard controller structure
    - Copy states: showFeedback, isCorrectAnswer, correctAnswerText, isLoading, errorMessage
    - Copy methods: submitAnswer(), validateImageExercise(), validateTranslationExercise(), validateWordExercise(), validateMatchExercise(), closeFeedback()
    - Add dependency on LessonFlowController in onInit()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.2, 4.2, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3_
  
  - [x] 2.3 Create LessonProgressController
    - Create `features/core/lesson/controllers/lesson_progress_controller.dart`
    - Copy standard controller structure
    - Copy states: hearts, correctAnswers, totalAnswers, startTime, pauseTime, accumulatedTime, lessonFailed, isLoading, errorMessage
    - Copy methods: loseHeart(), addCorrectAnswer(), addWrongAnswer(), startTimer(), pauseTimer(), resumeTimer(), getElapsedTime()
    - Copy getters: progress, accuracy, isPerfect
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.2, 4.2, 5.1, 5.2, 5.3_
  
  - [x] 2.4 Create LessonRewardsController
    - Create `features/core/lesson/controllers/lesson_rewards_controller.dart`
    - Copy standard controller structure
    - Copy states: calculatedXp, calculatedGems, isLoading, errorMessage
    - Copy methods: calculateRewards(), applyRewards(), _updateLessonProgress(), _updateSectionProgress()
    - Add dependencies on GamificationController and LessonProgressController in onInit()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.2, 4.2, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3_
  
  - [x] 2.5 Update LessonBinding
    - Open `features/core/lesson/bindings/lesson_binding.dart`
    - Remove `Get.lazyPut(() => LessonController())`
    - Add `Get.lazyPut(() => LessonFlowController())`
    - Add `Get.lazyPut(() => LessonExerciseController())`
    - Add `Get.lazyPut(() => LessonProgressController())`
    - Add `Get.lazyPut(() => LessonRewardsController())`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [x] 2.6 Update Lesson views
    - Identify all views that use LessonController
    - Update `Get.find<LessonController>()` to appropriate new controllers
    - Update all state and method references
    - Preserve all Obx() wrappers
    - Views to update: sections_page.dart, image_exercise_page.dart, translation_exercise_page.dart, word_exercise_page.dart, match_exercise_page.dart, complete_page.dart
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [x] 2.7 Run all tests for Lesson feature
    - Fix the old tests with the new controllers
    - Execute unit tests
    - Execute property tests
    - Execute integration tests
    - Verify all tests pass
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  
  - [x] 2.8 Delete old LessonController
    - Delete `features/core/lesson/controllers/lesson_controller.dart`
    - Verify no references remain
    - _Requirements: 1.1, 1.2, 13.3_
  
  - [x] 2.9 Commit LessonController refactoring
    - Verify all new controllers ≤ 500 lines
    - Commit with message: "refactor: divide LessonController em 4 controllers menores"
    - Update lista-controllers.md to mark LessonController as complete
    - _Requirements: 13.1, 13.2, 14.3, 14.4, 15.1_

- [-] 3. Refactor GamificationController (1367 lines → 4 controllers  + Add code that allows you to run tests that require Firebase to be initialized.)
  - [x] 3.1 Create StreakController
    - Create `features/inners/gamification/controllers/streak_controller.dart`
    - Copy standard controller structure
    - Copy states: currentStreak, longestStreak, _lastStreakDate, _streakFreezeAvailable, _streakFreezeUsedToday, _milestonesReached, isLoading, errorMessage
    - Copy methods: loadStreak(), updateStreak(), useStreakFreeze(), checkStreakMilestone()
    - Copy getter: streakFreezeAvailable
    - Add dependency on GemsController in onInit()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.3, 4.2, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3_
  
  - [x] 3.2 Create EnergyController
    - Create `features/inners/gamification/controllers/energy_controller.dart`
    - Copy standard controller structure
    - Copy states: currentEnergy, _lastEnergyRegenAt, _unlimitedEnergyUntil, isLoading, errorMessage
    - Copy methods: loadEnergy(), consumeEnergy(), regenerateEnergy(), activateUnlimitedEnergy(), refillEnergy()
    - Copy getter: hasUnlimitedEnergy
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.3, 4.2, 5.1, 5.2, 5.3_
  
  - [x] 3.3 Create XpLevelController
    - Create `features/inners/gamification/controllers/xp_level_controller.dart`
    - Copy standard controller structure
    - Copy states: totalXp, weeklyXP, todayXp, level, xpToNextLevel, _xpBoosterUntil, _lastWeeklyResetDate, _lastDailyResetDate, isLoading, errorMessage
    - Copy methods: loadXpAndLevel(), addXp(), activateXpBooster(), resetWeeklyXp(), resetDailyXp(), _calculateLevel(), _calculateXpToNextLevel()
    - Copy getters: hasXpBooster, xpBoosterUntil, getXpBoosterTimeRemaining()
    - Add dependency on GemsController in onInit()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.3, 4.2, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3_
  
  - [x] 3.4 Create GemsController
    - Create `features/inners/gamification/controllers/gems_controller.dart`
    - Copy standard controller structure
    - Copy states: gems, totalGemsEarned, totalGemsSpent, _gemMultiplierUntil, isLoading, errorMessage
    - Copy methods: loadGems(), addGems(), spendGems(), activateGemMultiplier()
    - Copy getters: hasGemMultiplier, gemMultiplierUntil, getGemMultiplierTimeRemaining()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.3, 4.2, 5.1, 5.2, 5.3_
  
  - [x] 3.5 Update HomeBinding (gamification is instantiated here)
    - Open `features/inners/home/bindings/home_binding.dart`
    - Remove `Get.lazyPut(() => GamificationController())`
    - Add `Get.lazyPut(() => GemsController())` (first - no dependencies)
    - Add `Get.lazyPut(() => EnergyController())`
    - Add `Get.lazyPut(() => StreakController())` (depends on GemsController)
    - Add `Get.lazyPut(() => XpLevelController())` (depends on GemsController)
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [x] 3.6 Update Home views (AppBar, modals)
    - Update home_appbar.dart to use new controllers
    - Update streak_modal.dart to use StreakController
    - Update energy_modal.dart to use EnergyController
    - Update gems_modal.dart to use GemsController
    - Preserve all Obx() wrappers
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [x] 3.7 Update Shop views (boost purchases)
    - Update boost_item.dart to use appropriate controllers
    - Energy refill → EnergyController
    - XP booster → XpLevelController
    - Gem multiplier → GemsController
    - Streak freeze → StreakController
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [x] 3.8 Update Profile views (stats display)
    - Update profile_page.dart to use XpLevelController and StreakController
    - Update overview cards to display stats from new controllers
    - Preserve all Obx() wrappers
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [x] 3.9 Update Lesson integration
    - Update LessonFlowController to use EnergyController for canStartLesson()
    - Update LessonRewardsController to use XpLevelController and GemsController
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [x] 3.10 Run all tests for Gamification feature
    - Fix the old tests with the new controllers
    - Execute unit tests
    - Execute property tests
    - Execute integration tests
    - Verify all tests pass
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  
  - [x] 3.11 Delete old GamificationController
    - Delete `features/inners/gamification/controllers/gamification_controller.dart`
    - Verify no references remain
    - _Requirements: 1.1, 1.2, 13.3_
  
  - [x] 3.12 Commit GamificationController refactoring
    - Verify all new controllers ≤ 500 lines
    - Commit with message: "refactor: divide GamificationController em 4 controllers menores"
    - Update lista-controllers.md to mark GamificationController as complete
    - _Requirements: 13.1, 13.2, 14.3, 14.4, 15.1_

- [ ] 4. Refactor OnboardingController (1228 lines → 3 controllers  + Add code that allows you to run tests that require Firebase to be initialized.)
  - [ ] 4.1 Create OnboardingFlowController
    - Create `features/core/onboarding/controllers/onboarding_flow_controller.dart`
    - Copy standard controller structure
    - Copy states: currentStep, isLoading, errorMessage
    - Copy all navigation methods (goToSelectLanguage, goToLanguageLevel, etc)
    - Copy method: finishOnboarding()
    - Add dependency on OnboardingDataController in onInit()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.4, 4.2, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3_
  
  - [ ] 4.2 Create OnboardingDataController
    - Create `features/core/onboarding/controllers/onboarding_data_controller.dart`
    - Copy standard controller structure
    - Copy states: selectedLanguage, languageLevel, learningReason, studyTime, userName, userAge, userEmail, userPassword, isLoading, errorMessage
    - Copy methods: setLanguage(), setLanguageLevel(), setLearningReason(), setStudyTime(), setUserName(), setUserAge(), setUserEmail(), setUserPassword(), saveUserData()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.4, 4.2, 5.1, 5.2, 5.3_
  
  - [ ] 4.3 Create OnboardingValidationController
    - Create `features/core/onboarding/controllers/onboarding_validation_controller.dart`
    - Copy standard controller structure
    - Copy states: isLoading, errorMessage
    - Copy methods: validateEmail(), validatePassword(), validateName(), sendVerificationCode(), verifyCode(), checkUsernameAvailability()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.4, 4.2, 5.1, 5.2, 5.3_
  
  - [ ] 4.4 Update OnboardingBinding
    - Open `features/core/onboarding/bindings/onboarding_binding.dart`
    - Remove `Get.lazyPut(() => OnboardingController())`
    - Add `Get.lazyPut(() => OnboardingDataController())`
    - Add `Get.lazyPut(() => OnboardingValidationController())`
    - Add `Get.lazyPut(() => OnboardingFlowController())`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [ ] 4.5 Update Onboarding views
    - Identify all views that use OnboardingController
    - Update `Get.find<OnboardingController>()` to appropriate new controllers
    - Update all state and method references
    - Preserve all Obx() wrappers
    - Views to update: welcome_view.dart, select_language_page.dart, language_level_page.dart, learning_reason_page.dart, intro_page.dart, study_time_page.dart, pause_one_page.dart, user_name_page.dart, user_age_page.dart, pause_two_page.dart, user_email_page.dart, user_password_page.dart, verify_code_page.dart, conclusion_page.dart
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [ ] 4.6 Run all tests for Onboarding feature
    - Fix the old tests with the new controllers
    - Execute unit tests
    - Execute property tests
    - Execute integration tests
    - Verify all tests pass
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  
  - [ ] 4.7 Delete old OnboardingController
    - Delete `features/core/onboarding/controllers/onboarding_controller.dart`
    - Carefully check that the imports are correct
    - Verify no references remain
    - _Requirements: 1.1, 1.2, 13.3_
  
  - [ ] 4.8 Commit OnboardingController refactoring
    - Verify all new controllers ≤ 500 lines
    - Commit with message: "refactor: divide OnboardingController em 3 controllers menores"
    - Update lista-controllers.md to mark OnboardingController as complete
    - _Requirements: 13.1, 13.2, 14.3, 14.4, 15.1_

- [ ] 5. Refactor TreasureController (897 lines → 2 controllers + Add code that allows you to run tests that require Firebase to be initialized.)
  - [ ] 5.1 Create TreasureChallengesController
    - Create `features/inners/treasure/controllers/treasure_challenges_controller.dart`
    - Copy standard controller structure
    - Copy states: dailyChallenges, weeklyChallenges, challengeProgress, isLoading, errorMessage
    - Copy methods: loadChallenges(), updateChallengeProgress(), checkChallengeCompletion()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.5, 4.2, 5.1, 5.2, 5.3_
  
  - [ ] 5.2 Create TreasureRewardsController
    - Create `features/inners/treasure/controllers/treasure_rewards_controller.dart`
    - Copy standard controller structure
    - Copy states: claimedRewards, pendingRewards, isLoading, errorMessage
    - Copy methods: claimReward(), loadRewardHistory(), calculateReward()
    - Add dependency on GamificationController (or new controllers) in onInit()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.5, 4.2, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3_
  
  - [ ] 5.3 Update TreasureBinding
    - Open `features/inners/treasure/bindings/treasure_binding.dart`
    - Remove `Get.lazyPut(() => TreasureController())`
    - Add `Get.lazyPut(() => TreasureChallengesController())`
    - Add `Get.lazyPut(() => TreasureRewardsController())`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [ ] 5.4 Update Treasure views
    - Update treasure_page.dart to use new controllers
    - Update challenge_card.dart to use TreasureChallengesController
    - Preserve all Obx() wrappers
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [ ] 5.5 Run all tests for Treasure feature
    - Fix the old tests with the new controllers
    - Execute unit tests
    - Execute property tests
    - Execute integration tests
    - Verify all tests pass
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  
  - [ ] 5.6 Delete old TreasureController
    - Delete `features/inners/treasure/controllers/treasure_controller.dart`
    - Carefully check that the imports are correct
    - Verify no references remain
    - _Requirements: 1.1, 1.2, 13.3_
  
  - [ ] 5.7 Commit TreasureController refactoring
    - Verify all new controllers ≤ 500 lines
    - Commit with message: "refactor: divide TreasureController em 2 controllers menores"
    - Update lista-controllers.md to mark TreasureController as complete
    - _Requirements: 13.1, 13.2, 14.3, 14.4, 15.1_

- [ ] 6. Refactor HomeController (764 lines → 2 controllers  + Add code that allows you to run tests that require Firebase to be initialized.)
  - [ ] 6.1 Create HomeNavigationController
    - Create `features/inners/home/controllers/home_navigation_controller.dart`
    - Copy standard controller structure
    - Copy states: currentNavIndex, isLoading, errorMessage
    - Copy methods: changeTab(), showStreakModal(), showEnergyModal(), showGemsModal(), showCoursesModal()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.6, 4.2, 5.1, 5.2, 5.3_
  
  - [ ] 6.2 Create HomeStatsController
    - Create `features/inners/home/controllers/home_stats_controller.dart`
    - Copy standard controller structure
    - Copy states: displayStreak, displayEnergy, displayGems, isLoading, errorMessage
    - Copy methods: loadStats(), refreshStats(), syncWithGamification()
    - Add dependency on GamificationController (or new controllers) in onInit()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.6, 4.2, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3_
  
  - [ ] 6.3 Update HomeBinding
    - Open `features/inners/home/bindings/home_binding.dart`
    - Remove `Get.lazyPut(() => HomeController())`
    - Add `Get.lazyPut(() => HomeNavigationController())`
    - Add `Get.lazyPut(() => HomeStatsController())`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [ ] 6.4 Update Home views
    - Update home_view.dart to use HomeNavigationController
    - Update home_appbar.dart to use HomeStatsController
    - Preserve all Obx() wrappers
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [ ] 6.5 Run all tests for Home feature
    - Fix the old tests with the new controllers
    - Execute unit tests
    - Execute property tests
    - Execute integration tests
    - Verify all tests pass
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  
  - [ ] 6.6 Delete old HomeController
    - Delete `features/inners/home/controllers/home_controller.dart`
    - Carefully check that the imports are correct
    - Verify no references remain
    - _Requirements: 1.1, 1.2, 13.3_
  
  - [ ] 6.7 Commit HomeController refactoring
    - Verify all new controllers ≤ 500 lines
    - Commit with message: "refactor: divide HomeController em 2 controllers menores"
    - Update lista-controllers.md to mark HomeController as complete
    - _Requirements: 13.1, 13.2, 14.3, 14.4, 15.1_

- [ ] 7. Refactor AuthController (718 lines → 2 controllers + Add code that allows you to run tests that require Firebase to be initialized.)
  - [ ] 7.1 Create AuthCredentialsController
    - Create `features/core/auth/controllers/auth_credentials_controller.dart`
    - Copy standard controller structure
    - Copy states: isLoading, errorMessage
    - Copy methods: login(), register(), validateEmail(), validatePassword()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.7, 4.2, 5.1, 5.2, 5.3_
  
  - [ ] 7.2 Create AuthProvidersController
    - Create `features/core/auth/controllers/auth_providers_controller.dart`
    - Copy standard controller structure
    - Copy states: isLoading, errorMessage
    - Copy methods: signInWithGoogle(), signInWithFacebook(), sendPasswordResetEmail(), verifyResetCode(), resetPassword(), logout()
    - Verify file is ≤ 500 lines
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.7, 4.2, 5.1, 5.2, 5.3_
  
  - [ ] 7.3 Update AuthBinding
    - Open `features/core/auth/bindings/auth_binding.dart`
    - Remove `Get.lazyPut(() => AuthController())`
    - Add `Get.lazyPut(() => AuthCredentialsController())`
    - Add `Get.lazyPut(() => AuthProvidersController())`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [ ] 7.4 Update Auth views
    - Update signin_view.dart to use AuthCredentialsController
    - Update forgot_password_view.dart to use AuthProvidersController
    - Update verify_code_view.dart to use AuthProvidersController
    - Update new_password_view.dart to use AuthProvidersController
    - Preserve all Obx() wrappers
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [ ] 7.5 Run all tests for Auth feature
    - Fix the old tests with the new controllers
    - Execute unit tests
    - Execute property tests
    - Execute integration tests
    - Verify all tests pass
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  
  - [ ] 7.6 Delete old AuthController
    - Delete `features/core/auth/controllers/auth_controller.dart`
    - Verify no references remain
    - _Requirements: 1.1, 1.2, 13.3_
  
  - [ ] 7.7 Commit AuthController refactoring
    - Verify all new controllers ≤ 500 lines
    - Commit with message: "refactor: divide AuthController em 2 controllers menores"
    - Update lista-controllers.md to mark AuthController as complete
    - _Requirements: 13.1, 13.2, 14.3, 14.4, 15.1_

- [ ] 8. Final validation and documentation
  - [ ] 8.1 Verify all controllers refactored
    - Confirm 7 old controllers deleted
    - Confirm 31 new controllers created
    - Confirm all new controllers ≤ 500 lines
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  
  - [ ] 8.2 Verify all tests passing
    - Run complete test suite
    - Verify no regressions
    - _Requirements: 10.1, 10.2, 10.3_
  
  - [ ] 8.3 Update documentation
    - Verify lista-controllers.md is fully updated
    - Update any architecture docs that reference old controllers
    - _Requirements: 12.1, 12.2, 12.3_
  
  - [ ] 8.4 Final commit
    - Create summary commit if needed
    - Tag release if appropriate
    - _Requirements: 14.3, 14.4_

## Notes

- Each controller refactoring is independent and can be done incrementally
- Always run tests after each controller refactoring before proceeding
- Use git to track changes and enable easy rollback if needed
- Follow the commit message format exactly for consistency
- Update lista-controllers.md after each controller is complete
- Never work on multiple controllers simultaneously
- If a refactoring fails validation, fix it before proceeding to the next controller
- This is a migration, not a rewrite - copy code exactly as-is
