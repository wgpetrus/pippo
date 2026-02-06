# Design Document - Controllers Refactoring

## Overview

The Controllers Refactoring is a pure code migration project that reorganizes 7 oversized controllers into 31 smaller, focused controllers. This is NOT a rewrite - it's a careful copy-paste operation that moves existing, working code into better-organized files. The refactoring follows the Single Responsibility Principle (SRP) while maintaining 100% backward compatibility with existing functionality.

### Key Design Decisions

1. **Migration, Not Rewrite**: All code is copied exactly as-is. No logic changes, no algorithm improvements, no "while we're at it" modifications. This ensures zero risk of introducing bugs.

2. **Atomic Method Migration**: Methods are moved as complete units. We never split a method across controllers or modify its internal logic during migration.

3. **Controller Communication via Get.find()**: New controllers communicate through GetX's dependency injection. Dependencies are declared in `onInit()` with clear error handling for optional dependencies.

4. **Incremental Validation**: Each controller is refactored, tested, and committed individually. We never work on multiple controllers simultaneously.

5. **Binding-First Approach**: Update bindings before updating views. This ensures controllers are available when views try to access them.

## Architecture

### Refactoring Strategy

```
Old Structure (7 oversized controllers):
- ProfileController (2045 lines)
- LessonController (1810 lines)
- GamificationController (1367 lines)
- OnboardingController (1228 lines)
- TreasureController (897 lines)
- HomeController (764 lines)
- AuthController (718 lines)

New Structure (31 focused controllers):
- 5 Profile controllers (~400 lines each)
- 4 Lesson controllers (~450 lines each)
- 4 Gamification controllers (~340 lines each)
- 3 Onboarding controllers (~410 lines each)
- 2 Treasure controllers (~450 lines each)
- 2 Home controllers (~380 lines each)
- 2 Auth controllers (~360 lines each)
```

### Controller Naming Convention

All new controllers follow this pattern:
- `{Feature}{Responsibility}Controller`
- Examples: `ProfileDataController`, `LessonFlowController`, `GamificationStreakController`

### File Organization

```
features/
├── core/
│   ├── auth/
│   │   └── controllers/
│   │       ├── auth_credentials_controller.dart (NEW)
│   │       └── auth_providers_controller.dart (NEW)
│   ├── lesson/
│   │   └── controllers/
│   │       ├── lesson_flow_controller.dart (NEW)
│   │       ├── lesson_exercise_controller.dart (NEW)
│   │       ├── lesson_progress_controller.dart (NEW)
│   │       └── lesson_rewards_controller.dart (NEW)
│   └── onboarding/
│       └── controllers/
│           ├── onboarding_flow_controller.dart (NEW)
│           ├── onboarding_data_controller.dart (NEW)
│           └── onboarding_validation_controller.dart (NEW)
└── inners/
    ├── gamification/
    │   └── controllers/
    │       ├── streak_controller.dart (NEW)
    │       ├── energy_controller.dart (NEW)
    │       ├── xp_level_controller.dart (NEW)
    │       └── gems_controller.dart (NEW)
    ├── home/
    │   └── controllers/
    │       ├── home_navigation_controller.dart (NEW)
    │       └── home_stats_controller.dart (NEW)
    ├── profile/
    │   └── controllers/
    │       ├── profile_data_controller.dart (NEW)
    │       ├── profile_settings_controller.dart (NEW)
    │       ├── profile_social_controller.dart (NEW)
    │       ├── profile_courses_controller.dart (NEW)
    │       └── profile_auth_controller.dart (NEW)
    └── treasure/
        └── controllers/
            ├── treasure_challenges_controller.dart (NEW)
            └── treasure_rewards_controller.dart (NEW)
```

## Components and Interfaces

### Standard Controller Structure

Every new controller follows this exact structure:

```dart
class {Feature}{Responsibility}Controller extends GetxController {
  // Firebase instances (if needed)
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados específicos
  // ... (migrated from old controller)

  // Dependencies (if needed)
  late final OtherController _otherController;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    // Initialize dependencies
    try {
      _otherController = Get.find<OtherController>();
    } catch (e) {
      // Optional dependency - controller works without it
    }
    // Load initial data if needed
  }

  // Métodos públicos
  // ... (migrated from old controller)

  // Métodos privados
  // ... (migrated from old controller)

  // Handlers de erro
  // ... (migrated from old controller or shared)
}
```

### Controller Communication Pattern

```dart
// Example: ProfileDataController needs GamificationController
class ProfileDataController extends GetxController {
  late final GamificationController _gamificationController;

  @override
  void onInit() {
    super.onInit();
    try {
      _gamificationController = Get.find<GamificationController>();
    } catch (e) {
      // Gamification not available - profile works without it
      debugPrint('GamificationController not found: $e');
    }
  }

  Future<void> loadStats() async {
    // Use gamification if available
    if (_gamificationController != null) {
      totalXp.value = _gamificationController.totalXp.value;
      level.value = _gamificationController.level.value;
    }
  }
}
```

## Data Models

### No Model Changes

This refactoring does NOT change any data models. All Firestore schemas, data structures, and type definitions remain exactly as they are. We're only moving code between files, not changing how data is structured or stored.

## Key Algorithms

### Migration Algorithm

```
FOR EACH oversized controller:
  1. Read lista-controllers.md to get the division plan
  2. Create new controller files with standard structure
  3. Copy observable states to appropriate controllers
  4. Copy methods to appropriate controllers
  5. Update controller dependencies (Get.find())
  6. Update binding to instantiate new controllers
  7. Update all views to use new controllers
  8. Run all tests to verify functionality
  9. Delete old controller file
  10. Commit changes with standard message
  11. Mark as complete in lista-controllers.md
```

### Dependency Resolution Algorithm

```
WHEN initializing a controller with dependencies:
  1. Declare dependency as late final variable
  2. In onInit(), try to Get.find() the dependency
  3. IF dependency is optional:
       Wrap in try-catch, log if not found
  4. IF dependency is required:
       Let Get.find() throw exception
  5. Document dependency in code comment
```

## Correctness Properties

Since this is a refactoring (not new functionality), correctness is defined as "behavior preservation":

**Property 1: Functional Equivalence**
*For any* user action before and after refactoring, the system behavior should be identical (same outputs, same side effects, same error messages).

**Property 2: Test Continuity**
*For any* existing test (unit, property, or integration), the test should pass both before and after refactoring without modification.

**Property 3: State Preservation**
*For any* observable state in the old controller, there should be an equivalent observable state in one of the new controllers with the same initial value and type.

**Property 4: Method Preservation**
*For any* public method in the old controller, there should be an equivalent public method in one of the new controllers with the same signature and behavior.

**Property 5: Line Limit Compliance**
*For any* new controller file, the line count should be ≤ 500 lines.

**Property 6: No Logic Changes**
*For any* migrated method, the method body should be byte-for-byte identical to the original (excluding whitespace normalization).

**Property 7: Dependency Correctness**
*For any* controller that depends on another controller, the dependency should be declared in onInit() and accessed via Get.find().

**Property 8: Binding Completeness**
*For any* new controller, there should be a corresponding Get.lazyPut() in the feature's binding.

**Property 9: View Update Completeness**
*For any* view that used the old controller, all references should be updated to use the appropriate new controller(s).

**Property 10: No Circular Dependencies**
*For any* pair of controllers A and B, if A depends on B, then B should NOT depend on A.

## Error Handling

### Error Handler Migration Strategy

```dart
// Option 1: Shared error handler (when used by multiple controllers)
// Create: features/{feature}/controllers/{feature}_error_handler.dart
class ProfileErrorHandler {
  static String handleFirestoreError(FirebaseException e) {
    // ... (copied from old controller)
  }
}

// Option 2: Private method (when used by single controller)
class ProfileDataController extends GetxController {
  String _handleFirestoreError(FirebaseException e) {
    // ... (copied from old controller)
  }
}
```

### Error Handling Preservation

All error handlers are migrated exactly as-is:
- Same error codes
- Same error messages
- Same error handling logic
- Same user-facing text

## Testing Strategy

### Testing Approach for Refactoring

**No New Tests Required**: This is a refactoring, not a new feature. Existing tests should continue to pass without modification.

**Test Execution Strategy**:
1. Run all tests BEFORE starting refactoring (establish baseline)
2. After each controller refactoring, run all tests again
3. IF any test fails, investigate immediately
4. IF failure is due to refactoring error, fix it
5. IF failure is unrelated, document and continue

**Test Categories**:
- **Unit Tests**: Should pass without changes (test behavior, not implementation)
- **Property Tests**: Should pass without changes (test universal properties)
- **Integration Tests**: May need minor updates if they directly instantiate controllers

### Validation Checklist Per Controller

After refactoring each controller:
- [ ] All new controllers created
- [ ] All new controllers ≤ 500 lines
- [ ] Binding updated
- [ ] All views updated
- [ ] All tests passing
- [ ] Old controller deleted
- [ ] Changes committed
- [ ] lista-controllers.md updated

## Integration with Existing Features

### Binding Updates

```dart
// BEFORE: ProfileBinding
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
  }
}

// AFTER: ProfileBinding
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Instantiate in dependency order
    Get.lazyPut(() => ProfileDataController());
    Get.lazyPut(() => ProfileSettingsController());
    Get.lazyPut(() => ProfileSocialController());
    Get.lazyPut(() => ProfileCoursesController());
    Get.lazyPut(() => ProfileAuthController());
  }
}
```

### View Updates

```dart
// BEFORE: ProfilePage
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    
    return Scaffold(
      body: Obx(() => Text(controller.userName.value)),
    );
  }
}

// AFTER: ProfilePage
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataController = Get.find<ProfileDataController>();
    final socialController = Get.find<ProfileSocialController>();
    
    return Scaffold(
      body: Column(
        children: [
          Obx(() => Text(dataController.userName.value)),
          Obx(() => Text('${socialController.followersCount.value} followers')),
        ],
      ),
    );
  }
}
```

### Controller Dependencies

```dart
// Example: ProfileSocialController depends on ProfileDataController
class ProfileSocialController extends GetxController {
  late final ProfileDataController _dataController;

  @override
  void onInit() {
    super.onInit();
    _dataController = Get.find<ProfileDataController>();
  }

  Future<void> loadFollowers() async {
    final userId = _dataController.userId; // Access data from other controller
    // ... load followers
  }
}
```

## Detailed Controller Divisions

### 1. ProfileController → 5 Controllers

#### ProfileDataController (~400 lines)
**Responsibility**: Manage user profile data (name, avatar, bio, stats)

**States to migrate**:
- userName, username, bio, avatarId, country, email
- totalXp, currentStreak, lessonsCompleted, level
- profileCompletionPercentage, missingFields
- isLoading, errorMessage, isUsernameAvailable, isCheckingUsername

**Methods to migrate**:
- `loadOwnProfile()`
- `updateProfile(Map<String, dynamic> updates)`
- `checkUsernameAvailability(String newUsername)`
- `_loadProfileStats(String userId)`
- `_calculateProfileCompletion(Map<String, dynamic> userData)`

**Dependencies**: None

#### ProfileSettingsController (~400 lines)
**Responsibility**: Manage user settings (notifications, learning controls)

**States to migrate**:
- soundEffects, listeningExercises, speakingExercises
- practiceReminders, reminderTime
- leaderboardUpdates, friendActivity, dailyGoal
- isLoading, errorMessage

**Methods to migrate**:
- `loadSettings()`
- `updateSetting(String key, dynamic value)`

**Dependencies**: None

#### ProfileSocialController (~400 lines)
**Responsibility**: Manage social features (following, followers, search)

**States to migrate**:
- following, followers, followingCount, followersCount
- viewedUserId, viewedUserData, isFollowingViewedUser
- searchQuery, searchResults, isSearching, searchErrorMessage
- weeklyProgress, viewedUserWeeklyProgress, isLoadingProgress
- isLoading, errorMessage

**Methods to migrate**:
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

**Dependencies**: ProfileDataController (for userId)

#### ProfileCoursesController (~400 lines)
**Responsibility**: Manage user courses (add, remove, set primary)

**States to migrate**:
- userCourses, primaryCourseId
- isLoading, errorMessage

**Methods to migrate**:
- `loadUserCourses()`
- `setPrimaryCourse(String courseId, {bool showSnackbar = true})`
- `removeCourse(String courseId)`
- `_getLanguageName(String code)`
- `_getLanguageFlag(String code)`

**Dependencies**: None

#### ProfileAuthController (~400 lines)
**Responsibility**: Manage authentication actions (password, phone, delete account)

**States to migrate**:
- phone, phoneVerified, verificationId
- isLoading, errorMessage

**Methods to migrate**:
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

**Dependencies**: None

### 2. LessonController → 4 Controllers

#### LessonFlowController (~450 lines)
**Responsibility**: Manage lesson flow (start, navigation, completion)

**States to migrate**:
- currentLesson, currentExercises, currentExerciseIndex
- isLoading, errorMessage

**Methods to migrate**:
- `startLessonFromActiveCourse(String lessonId)`
- `startLesson(String courseId, String lessonId)`
- `nextExercise()`
- `completeLesson()`
- `exitLesson()`
- `_resetLessonState()`

**Dependencies**: GamificationController (for energy check)

#### LessonExerciseController (~450 lines)
**Responsibility**: Manage exercises (current, validation, feedback)

**States to migrate**:
- showFeedback, isCorrectAnswer, correctAnswerText
- isLoading, errorMessage

**Methods to migrate**:
- `submitAnswer(dynamic answer)`
- `validateImageExercise(String selectedImage)`
- `validateTranslationExercise(String selectedTranslation)`
- `validateWordExercise(List<String> words)`
- `validateMatchExercise(Map<String, String> matches)`
- `closeFeedback()`

**Dependencies**: LessonFlowController (for current exercise)

#### LessonProgressController (~450 lines)
**Responsibility**: Manage progress (hearts, accuracy, time, stats)

**States to migrate**:
- hearts, correctAnswers, totalAnswers
- startTime, pauseTime, accumulatedTime
- lessonFailed
- isLoading, errorMessage

**Methods to migrate**:
- `loseHeart()`
- `addCorrectAnswer()`
- `addWrongAnswer()`
- `startTimer()`
- `pauseTimer()`
- `resumeTimer()`
- `getElapsedTime()`
- Getters: `progress`, `accuracy`, `isPerfect`

**Dependencies**: None

#### LessonRewardsController (~450 lines)
**Responsibility**: Manage rewards (XP, gems, achievements)

**States to migrate**:
- calculatedXp, calculatedGems
- isLoading, errorMessage

**Methods to migrate**:
- `calculateRewards()`
- `applyRewards()`
- `_updateLessonProgress(String courseId, String lessonId)`
- `_updateSectionProgress(String courseId, String sectionId)`

**Dependencies**: GamificationController (for applying rewards), LessonProgressController (for accuracy)

### 3. GamificationController → 4 Controllers

#### StreakController (~340 lines)
**Responsibility**: Manage streak (days consecutive, freeze, milestones)

**States to migrate**:
- currentStreak, longestStreak
- _lastStreakDate, _streakFreezeAvailable, _streakFreezeUsedToday
- _milestonesReached
- isLoading, errorMessage

**Methods to migrate**:
- `loadStreak()`
- `updateStreak()`
- `useStreakFreeze()`
- `checkStreakMilestone()`
- Getter: `streakFreezeAvailable`

**Dependencies**: GemsController (for milestone rewards)

#### EnergyController (~340 lines)
**Responsibility**: Manage energy (regeneration, unlimited, consumption)

**States to migrate**:
- currentEnergy
- _lastEnergyRegenAt, _unlimitedEnergyUntil
- isLoading, errorMessage

**Methods to migrate**:
- `loadEnergy()`
- `consumeEnergy(int amount)`
- `regenerateEnergy()`
- `activateUnlimitedEnergy(int minutes)`
- `refillEnergy()`
- Getter: `hasUnlimitedEnergy`

**Dependencies**: None

#### XpLevelController (~340 lines)
**Responsibility**: Manage XP and levels (progression, booster, weekly/daily)

**States to migrate**:
- totalXp, weeklyXP, todayXp, level, xpToNextLevel
- _xpBoosterUntil
- _lastWeeklyResetDate, _lastDailyResetDate
- isLoading, errorMessage

**Methods to migrate**:
- `loadXpAndLevel()`
- `addXp(int amount)`
- `activateXpBooster(int minutes)`
- `resetWeeklyXp()`
- `resetDailyXp()`
- `_calculateLevel(int xp)`
- `_calculateXpToNextLevel(int level)`
- Getters: `hasXpBooster`, `xpBoosterUntil`, `getXpBoosterTimeRemaining()`

**Dependencies**: GemsController (for level up rewards)

#### GemsController (~340 lines)
**Responsibility**: Manage gems (earning, spending, multiplier)

**States to migrate**:
- gems, totalGemsEarned, totalGemsSpent
- _gemMultiplierUntil
- isLoading, errorMessage

**Methods to migrate**:
- `loadGems()`
- `addGems(int amount)`
- `spendGems(int amount)`
- `activateGemMultiplier(int minutes)`
- Getters: `hasGemMultiplier`, `gemMultiplierUntil`, `getGemMultiplierTimeRemaining()`

**Dependencies**: None

### 4. OnboardingController → 3 Controllers

#### OnboardingFlowController (~410 lines)
**Responsibility**: Manage navigation and flow between screens

**States to migrate**:
- currentStep
- isLoading, errorMessage

**Methods to migrate**:
- All navigation methods (goToSelectLanguage, goToLanguageLevel, etc)
- `finishOnboarding()`

**Dependencies**: OnboardingDataController (for saving data)

#### OnboardingDataController (~410 lines)
**Responsibility**: Manage collection of user data

**States to migrate**:
- selectedLanguage, languageLevel, learningReason
- studyTime, userName, userAge, userEmail, userPassword
- isLoading, errorMessage

**Methods to migrate**:
- `setLanguage(String language)`
- `setLanguageLevel(String level)`
- `setLearningReason(String reason)`
- `setStudyTime(int minutes)`
- `setUserName(String name)`
- `setUserAge(String ageRange)`
- `setUserEmail(String email)`
- `setUserPassword(String password)`
- `saveUserData()`

**Dependencies**: None

#### OnboardingValidationController (~410 lines)
**Responsibility**: Manage validations and verifications

**States to migrate**:
- isLoading, errorMessage

**Methods to migrate**:
- `validateEmail(String? value)`
- `validatePassword(String? value)`
- `validateName(String? value)`
- `sendVerificationCode(String email)`
- `verifyCode(String code)`
- `checkUsernameAvailability(String username)`

**Dependencies**: None

### 5. TreasureController → 2 Controllers

#### TreasureChallengesController (~450 lines)
**Responsibility**: Manage challenges (daily, weekly, progress)

**States to migrate**:
- dailyChallenges, weeklyChallenges
- challengeProgress
- isLoading, errorMessage

**Methods to migrate**:
- `loadChallenges()`
- `updateChallengeProgress(String challengeId, int progress)`
- `checkChallengeCompletion(String challengeId)`

**Dependencies**: None

#### TreasureRewardsController (~450 lines)
**Responsibility**: Manage rewards (claim, tracking, history)

**States to migrate**:
- claimedRewards, pendingRewards
- isLoading, errorMessage

**Methods to migrate**:
- `claimReward(String challengeId)`
- `loadRewardHistory()`
- `calculateReward(String challengeId)`

**Dependencies**: GamificationController (for applying rewards)

### 6. HomeController → 2 Controllers

#### HomeNavigationController (~380 lines)
**Responsibility**: Manage navigation between tabs and modals

**States to migrate**:
- currentNavIndex
- isLoading, errorMessage

**Methods to migrate**:
- `changeTab(int index)`
- `showStreakModal()`
- `showEnergyModal()`
- `showGemsModal()`
- `showCoursesModal()`

**Dependencies**: None

#### HomeStatsController (~380 lines)
**Responsibility**: Manage display of stats (streak, energy, gems)

**States to migrate**:
- displayStreak, displayEnergy, displayGems
- isLoading, errorMessage

**Methods to migrate**:
- `loadStats()`
- `refreshStats()`
- `syncWithGamification()`

**Dependencies**: GamificationController (for reading stats)

### 7. AuthController → 2 Controllers

#### AuthCredentialsController (~360 lines)
**Responsibility**: Manage login/register with email/password

**States to migrate**:
- isLoading, errorMessage

**Methods to migrate**:
- `login(String email, String password)`
- `register(String email, String password)`
- `validateEmail(String? value)`
- `validatePassword(String? value)`

**Dependencies**: None

#### AuthProvidersController (~360 lines)
**Responsibility**: Manage social login and password recovery

**States to migrate**:
- isLoading, errorMessage

**Methods to migrate**:
- `signInWithGoogle()`
- `signInWithFacebook()`
- `sendPasswordResetEmail(String email)`
- `verifyResetCode(String code)`
- `resetPassword(String code, String newPassword)`
- `logout()`

**Dependencies**: None

## Implementation Order

The refactoring will proceed in this exact order (largest to smallest):

1. **ProfileController** (2045 lines → 5 controllers)
2. **LessonController** (1810 lines → 4 controllers)
3. **GamificationController** (1367 lines → 4 controllers)
4. **OnboardingController** (1228 lines → 3 controllers)
5. **TreasureController** (897 lines → 2 controllers)
6. **HomeController** (764 lines → 2 controllers)
7. **AuthController** (718 lines → 2 controllers)

Each controller must be:
- Fully refactored
- All tests passing
- Committed to git
- Marked complete in lista-controllers.md

Before proceeding to the next controller.

## Commit Message Format

```
refactor: divide {ControllerName} em {N} controllers menores

- Cria {Controller1} (~XXX linhas)
- Cria {Controller2} (~XXX linhas)
...
- Atualiza {Feature}Binding
- Atualiza views para usar controllers corretos
- Remove {ControllerName} antigo (XXXX linhas)

Ref: spec refactor-controllers
```

**Example**:
```
refactor: divide ProfileController em 5 controllers menores

- Cria ProfileDataController (~400 linhas)
- Cria ProfileSettingsController (~400 linhas)
- Cria ProfileSocialController (~400 linhas)
- Cria ProfileCoursesController (~400 linhas)
- Cria ProfileAuthController (~400 linhas)
- Atualiza ProfileBinding
- Atualiza views para usar controllers corretos
- Remove ProfileController antigo (2045 linhas)

Ref: spec refactor-controllers
```

## Risk Mitigation

### Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing functionality | Run all tests after each controller refactoring |
| Introducing circular dependencies | Document dependencies in code comments, review before committing |
| Missing view updates | Use IDE search to find all references to old controller |
| Incorrect method placement | Follow lista-controllers.md mapping exactly |
| Merge conflicts | Work on one controller at a time, commit frequently |
| Lost code during migration | Use git to track all changes, never delete before verifying |

### Rollback Procedure

If issues are discovered after refactoring a controller:

1. Identify the problematic commit
2. Run `git revert <commit-hash>`
3. Investigate the issue
4. Fix the problem
5. Re-apply the refactoring correctly
6. Commit with updated message

## Success Criteria

The refactoring is considered successful when:

- [ ] All 7 controllers refactored
- [ ] All 31 new controllers created
- [ ] All new controllers ≤ 500 lines
- [ ] All old controllers deleted
- [ ] All bindings updated
- [ ] All views updated
- [ ] All tests passing
- [ ] All changes committed
- [ ] lista-controllers.md fully updated
- [ ] No functionality changes
- [ ] No UI changes
- [ ] No data model changes
