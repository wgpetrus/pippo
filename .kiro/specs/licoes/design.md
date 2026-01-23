# Design Document

## ⚠️ IMPORTANT: No Model Classes

Following company architecture rules, this feature does **NOT** use model classes. All data is handled as:
- `Map<String, dynamic>` from Firestore documents
- Primitive observable variables (`.obs`) in the controller
- No separate model files or classes

---

## Overview

The Lesson System is the core learning engine of Pippo, orchestrating the complete lifecycle of language learning exercises from initialization through completion. The system implements a strict order-of-operations architecture to ensure data consistency, fair gameplay, and accurate progress tracking across multiple interconnected subsystems (energy, XP, streaks, challenges, and history).

The design follows a state machine pattern for lesson execution, with clear transitions between states (not_started → in_progress → completed/failed) and atomic operations for reward distribution. All critical operations follow the EXACT sequence defined in requirements to prevent race conditions and data inconsistencies.

## Architecture

### High-Level Components

```
┌─────────────────────────────────────────────────────────────┐
│                     LessonController                         │
│  - State management (GetX)                                   │
│  - Orchestrates all operations                               │
│  - Enforces order-of-operations                              │
│  - Lesson validation (unlocked, energy)                      │
│  - Exercise validation (all types)                           │
│  - Energy management (consume, regenerate)                   │
│  - Reward calculation (base, bonuses, boosters)              │
│  - XP distribution (totalXp, weeklyXp, todayXp)              │
│  - Streak management (first today, update logic)             │
│  - Progress persistence (Firestore save)                     │
│  - History updates (YYYY-MM-DD format)                       │
│  - Challenge updates                                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ├──────────────────────────────┐
                              │                              │
                              ▼                              ▼
┌──────────────────────────────────────┐  ┌──────────────────────────────────┐
│         Firebase Firestore           │  │         GetX State (.obs)        │
│  - users/{userId}/courses/...        │  │  - isLoading                     │
│  - users/{userId}/stats/...          │  │  - errorMessage                  │
│  - users/{userId}/history/...        │  │  - currentLesson                 │
│  - courses/{courseId}/lessons/...    │  │  - hearts, correctAnswers        │
└──────────────────────────────────────┘  │  - currentExerciseIndex          │
                                          └──────────────────────────────────┘
```

**Note:** All logic is contained within the LessonController. No separate service classes are created, following the company's architecture standards.

### State Machine

```
┌─────────────┐
│ not_started │
└──────┬──────┘
       │ startLesson()
       │ (validate → consume energy)
       ▼
┌─────────────┐
│ in_progress │◄──────┐
└──────┬──────┘       │
       │              │ resumeLesson()
       │ submitAnswer()
       │ (validate → update hearts/counters)
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌───────────┐   ┌──────────┐
│ completed │   │  failed  │
└─────┬─────┘   └────┬─────┘
      │              │
      │ (calculate   │ (no rewards,
      │  rewards →   │  energy not
      │  distribute  │  refunded)
      │  XP/gems →   │
      │  update      │
      │  streak →    │
      │  save        │
      │  progress)   │
      │              │
      ▼              ▼
┌─────────────────────┐
│   End of Lesson     │
└─────────────────────┘
```

### Critical Order of Operations

**Lesson Start Sequence (MUST be exact order):**
1. Validate lesson is unlocked
2. Validate user has energy (or unlimited active)
3. Consume energy (atomic operation)
4. Initialize lesson state (hearts=3, counters=0, startTime)
5. Load exercises
6. Navigate to first exercise

**Lesson Completion Sequence (MUST be exact order):**
1. Calculate base rewards (lesson.xpReward, lesson.gemsReward)
2. Apply perfect bonus (+5 XP if 100% accuracy)
3. Apply first today bonus (+5 XP if first lesson today)
4. Apply booster multipliers (2× if active)
5. Add XP to totalXp, weeklyXp, todayXp (atomic)
6. Add gems to totalGems
7. Check and execute level up if threshold reached
8. Update streak (only if first lesson today, user timezone)
9. Save lesson progress to Firestore
10. Update daily history (YYYY-MM-DD format, user timezone)
11. Update challenges
12. Unlock next lesson
13. Navigate to completion screen

**Answer Submission Sequence:**
1. Validate answer against correct answer
2. Increment totalAnswers
3. If correct: increment correctAnswers
4. If incorrect: decrement hearts, check if 0 (fail lesson)
5. Show feedback (correct/incorrect)
6. If last exercise and hearts > 0: trigger completion sequence

## Components and Interfaces

### LessonController (GetX)

**Responsibilities:**
- Orchestrate all lesson operations
- Manage lesson state (reactive)
- Enforce order-of-operations
- Handle navigation
- Validate lesson unlock status and energy
- Validate exercise answers (all types)
- Manage energy consumption and regeneration
- Calculate rewards (base, bonuses, boosters)
- Distribute XP to all counters
- Manage streak updates
- Persist progress to Firestore
- Update daily history and challenges

**State Variables (Observable):**
```dart
// Mandatory states
final isLoading = false.obs;
final errorMessage = ''.obs;

// Lesson state
final currentLesson = Rx<Lesson?>(null);
final currentExercises = <Exercise>[].obs;
final currentExerciseIndex = 0.obs;

// Lesson execution state
final hearts = 3.obs;
final correctAnswers = 0.obs;
final totalAnswers = 0.obs;
final startTime = Rx<DateTime?>(null);

// Feedback state
final showFeedback = false.obs;
final isCorrectAnswer = false.obs;
final correctAnswerText = ''.obs;
```

**Key Methods:**
```dart
// Lesson lifecycle
Future<void> startLesson(String courseId, String lessonId)
Future<void> submitAnswer(dynamic userAnswer, dynamic correctAnswer, ExerciseType type)
Future<void> completeLesson()
void failLesson()
Future<void> resumeLesson(String courseId, String lessonId)

// Validation methods
Future<bool> _isLessonUnlocked(String courseId, String lessonId)
Future<bool> _hasEnergy()
bool _validateImageExercise(String selectedImageId, String correctImageId)
bool _validateTranslationExercise(String selectedTranslation, String correctTranslation)
bool _validateWordOrderExercise(List<String> userOrder, List<String> correctOrder)
bool _validateMatchExercise(Map<String, String> userPairs, Map<String, String> correctPairs)

// Energy management
Future<void> _consumeEnergy()
int _calculateAvailableEnergy(DateTime lastEnergyUpdate, int currentEnergy)
int _calculateMinutesUntilNextEnergy(DateTime lastEnergyUpdate)

// Reward calculation
int _calculateTotalXP(Lesson lesson, double accuracy, bool isFirstToday, bool hasXPBooster)
int _calculateTotalGems(Lesson lesson, bool hasGemMultiplier)

// XP distribution
Future<void> _distributeXP(int xpAmount)
Future<bool> _checkAndLevelUp(int totalXp, int currentLevel)
int _calculateXPForNextLevel(int currentLevel)

// Streak management
Future<bool> _isFirstLessonToday()
Future<void> _updateStreak()
String _getTodayDateString()
bool _isYesterday(String lastStreakDate, String todayDate)

// Progress persistence
Future<void> _saveLessonProgress(String courseId, String lessonId, LessonProgress progress)
Future<void> _updateDailyHistory(int xp, int gems, int timeSpent)
Future<void> _unlockNextLesson(String courseId, String lessonId)

// Helpers
double calculateAccuracy()
```

**Formulas:**
- Available energy: `min(5, currentEnergy + (minutesPassed ~/ 30))`
- Minutes until next: `30 - (minutesPassed % 30)`
- Base XP: `lesson.xpReward`
- Perfect bonus: `+5 if accuracy == 100%`
- First today bonus: `+5 if isFirstToday`
- XP Booster: `totalXP * 2 if active`
- Gem Multiplier: `totalGems * 2 if active`
- XP for next level: `currentLevel * 100`

**Firestore Paths:**
- Progress: `users/{userId}/courses/{courseId}/progress/{lessonId}`
- History: `users/{userId}/history/{YYYY-MM-DD}`
- Stats: `users/{userId}/stats/gamification`
- Lessons: `courses/{courseId}/lessons/{lessonId}`
- Exercises: `courses/{courseId}/lessons/{lessonId}/exercises/{exerciseId}`

## Data Structure (No Models - Maps Only)

**IMPORTANT:** Following company architecture rules, we do NOT create model classes. All data is handled as `Map<String, dynamic>` from Firestore and primitive observable variables in the controller.

### Lesson Data (Map from Firestore)
```dart
// Loaded as Map<String, dynamic> from courses/{courseId}/lessons/{lessonId}
{
  'id': String,
  'unitId': String,
  'sectionId': String,
  'order': int,
  'exercisesCount': int,
  'estimatedTime': int,
  'xpReward': int,
  'gemsReward': int,
}
```

### Exercise Data (Maps from Firestore)
```dart
// All exercises as Map<String, dynamic>
// Type determined by 'type' field: 'image', 'translation', 'word_order', 'match'

// Image Exercise
{
  'id': String,
  'type': 'image',
  'order': int,
  'prompt': String,
  'word': String,
  'wordAudio': String,
  'options': [
    {'id': String, 'image': String, 'isCorrect': bool},
    // ... 4 options total
  ]
}

// Translation Exercise
{
  'id': String,
  'type': 'translation',
  'order': int,
  'prompt': String,
  'image': String?, // optional
  'word': String,
  'wordAudio': String,
  'options': [
    {'id': String, 'text': String, 'isCorrect': bool},
    // ... 4 options total
  ]
}

// Word Order Exercise
{
  'id': String,
  'type': 'word_order',
  'order': int,
  'prompt': String,
  'sentence': String,
  'sentenceAudio': String,
  'correctOrder': List<String>,
  'availableWords': List<String>, // includes distractors
}

// Match Exercise
{
  'id': String,
  'type': 'match',
  'order': int,
  'prompt': String,
  'pairs': [
    {'audio': String, 'text': String},
    // ... 4 pairs total
  ]
}
```

### Controller State Variables (LessonController)
```dart
// Current lesson and exercises (loaded from Firestore)
final currentLesson = Rx<Map<String, dynamic>?>(null);
final exercises = <Map<String, dynamic>>[].obs;

// Lesson state
final currentExerciseIndex = 0.obs;
final hearts = 3.obs;
final correctAnswers = 0.obs;
final totalAnswers = 0.obs;
final startTime = Rx<DateTime?>(null);
final mistakes = <String>[].obs;

// Gamification stats (loaded from users/{userId}/stats/gamification)
final currentEnergy = 0.obs;
final maxEnergy = 5.obs;
final lastEnergyRegenAt = Rx<DateTime?>(null);
final unlimitedEnergyUntil = Rx<DateTime?>(null);

final totalXp = 0.obs;
final weeklyXp = 0.obs;
final todayXp = 0.obs;
final level = 1.obs;
final xpToNextLevel = 100.obs;

final gems = 0.obs;
final totalGemsEarned = 0.obs;

final currentStreak = 0.obs;
final longestStreak = 0.obs;
final lastStreakDate = ''.obs;

final xpBoosterExpiresAt = Rx<DateTime?>(null);
final gemMultiplierExpiresAt = Rx<DateTime?>(null);

// Computed values (getters in controller)
double get accuracy => totalAnswers.value > 0 
    ? (correctAnswers.value / totalAnswers.value) * 100 
    : 0.0;
bool get isComplete => currentExerciseIndex.value >= exercises.length;
bool get hasFailed => hearts.value <= 0;
```

### Firestore Document Structures

**Progress Document** (`users/{userId}/courses/{courseId}/progress/{lessonId}`):
```dart
{
  'lessonId': String,
  'unitId': String,
  'status': String, // 'locked', 'not_started', 'in_progress', 'completed'
  'completedAt': Timestamp?,
  'attempts': int,
  'bestScore': double,
  'xpEarned': int,
  'timeSpent': int,
  'mistakes': List<String>,
}
```

**History Document** (`users/{userId}/history/{YYYY-MM-DD}`):
```dart
{
  'date': String, // YYYY-MM-DD format
  'lessonsCompleted': int,
  'xpEarned': int,
  'timeSpent': int,
  'streakMaintained': bool,
  'exercisesCorrect': int,
  'exercisesTotal': int,
}
```

**Stats Document** (`users/{userId}/stats/gamification`):
```dart
{
  // Energy
  'currentEnergy': int,
  'maxEnergy': int,
  'lastEnergyRegenAt': Timestamp,
  'unlimitedEnergyUntil': Timestamp?,
  
  // XP
  'totalXp': int,
  'weeklyXp': int,
  'todayXp': int,
  'level': int,
  'xpToNextLevel': int,
  
  // Gems
  'gems': int,
  'totalGemsEarned': int,
  'totalGemsSpent': int,
  
  // Streak
  'currentStreak': int,
  'longestStreak': int,
  'lastStreakDate': String, // YYYY-MM-DD
  
  // Boosters
  'xpBoosterExpiresAt': Timestamp?,
  'gemMultiplierExpiresAt': Timestamp?,
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: Lesson Start Order of Operations

*For any* lesson start attempt, the system SHALL execute operations in this exact order: (1) validate lesson unlocked, (2) validate energy available, (3) consume energy, (4) initialize state. No operation SHALL occur before its predecessor completes.

**Validates: Requirements 1.1, 1.2, 1.4**

### Property 2: Energy Consumption Atomicity

*For any* successful lesson start with sufficient energy, the system SHALL consume exactly 1 energy in a single atomic operation, and energy SHALL never be consumed if validation fails or unlimited energy is active.

**Validates: Requirements 1.4, 1.5, 12.1**

### Property 3: Energy Regeneration Formula Consistency

*For any* time duration in minutes, the available energy SHALL equal `min(5, currentEnergy + (minutesPassed ~/ 30))` and the minutes until next energy SHALL equal `30 - (minutesPassed % 30)`.

**Validates: Requirements 1.6, 1.7**

### Property 4: Exercise Validation Type Safety

*For any* exercise submission, the validation method SHALL match the exercise type: Image exercises compare imageIds, Translation exercises compare text strings, Word Order exercises compare ordered arrays, and Match exercises verify all 4 pairs match.

**Validates: Requirements 2.2, 2.4, 2.6, 2.9, 11.1, 11.2, 11.3, 11.4**

### Property 5: Hearts Invariant

*For any* lesson state during execution, hearts SHALL remain in the range [0, 3], initializing at exactly 3, decreasing by exactly 1 per wrong answer, and triggering lesson failure when reaching 0.

**Validates: Requirements 3.1, 3.2, 3.3, 3.6**

### Property 6: Failed Lesson Consequences

*For any* lesson that fails (hearts = 0), the system SHALL display fail screen, award zero rewards (XP = 0, gems = 0), and NOT refund the consumed energy.

**Validates: Requirements 3.4, 3.5**

### Property 7: Answer Counter Consistency

*For any* answer submission, totalAnswers SHALL increment by 1, and correctAnswers SHALL increment by 1 if and only if the answer is correct, ensuring accuracy = (correctAnswers / totalAnswers) * 100.

**Validates: Requirements 4.4, 4.5, 4.7**

### Property 8: Hearts Decrement Before Feedback

*For any* incorrect answer, hearts SHALL be decremented before the feedback state is set, ensuring the hearts count is updated before UI feedback is displayed.

**Validates: Requirements 4.3**

### Property 9: Reward Calculation Order

*For any* completed lesson, rewards SHALL be calculated in this exact order: (1) base XP/gems from lesson, (2) add perfect bonus (+5 XP if 100% accuracy), (3) add first today bonus (+5 XP if first lesson), (4) apply booster multipliers (2× if active).

**Validates: Requirements 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 13.5**

### Property 10: XP Distribution Atomicity

*For any* XP earned, the system SHALL add it to all three counters (totalXp, weeklyXp, todayXp) in a single atomic operation, ensuring all counters are updated together or none are updated.

**Validates: Requirements 6.1, 6.2, 6.3, 6.7**

### Property 11: Level Up Formula

*For any* level, the XP required for next level SHALL equal `currentLevel * 100`, and when totalXp reaches or exceeds this threshold, currentLevel SHALL increment by 1 without resetting totalXp.

**Validates: Requirements 6.4, 6.5, 6.6**

### Property 12: Streak Update Logic

*For any* first lesson completed today (user timezone), if last streak date is yesterday then increment currentStreak by 1, if last streak date is today then no change, if last streak date is before yesterday then reset currentStreak to 1, and update longestStreak if currentStreak exceeds it.

**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8**

### Property 13: Completion Sequence Order

*For any* lesson completion, operations SHALL execute in this exact order: (1) calculate rewards, (2) distribute XP, (3) add gems, (4) check level up, (5) update streak (if first today), (6) save progress, (7) update history, (8) update challenges, (9) unlock next lesson.

**Validates: Requirements 5.1, 8.1, 8.4, 8.7, 9.5**

### Property 14: Progress Data Completeness

*For any* lesson progress saved, the data SHALL include all required fields: accuracy, xpEarned, gemsEarned, timeSpent (in seconds), mistakes, and completedAt (using FieldValue.serverTimestamp()).

**Validates: Requirements 8.2, 8.3**

### Property 15: History Date Format

*For any* daily history record, the date ID SHALL be in YYYY-MM-DD format calculated using the user's timezone (not UTC), and SHALL increment lessonsCompleted, totalXp, totalGems, and totalTime.

**Validates: Requirements 8.4, 8.5, 8.6**

### Property 16: Linear Progression

*For any* lesson N where N > 1, the lesson SHALL be unlocked if and only if lesson N-1 is completed, and lesson 1 SHALL always be unlocked. Completing lesson N SHALL unlock exactly lesson N+1.

**Validates: Requirements 10.1, 10.2, 10.3, 10.4**

### Property 17: Input Sanitization

*For any* text-based exercise validation, the system SHALL trim whitespace from user inputs before comparison and SHALL perform case-sensitive comparison.

**Validates: Requirements 11.5, 11.6**

### Property 18: Booster Expiration

*For any* booster (XP or Gem), the system SHALL apply the 2× multiplier if and only if current time is before expiration time (activationTime + 1 hour), and SHALL NOT apply multiplier after expiration.

**Validates: Requirements 13.1, 13.2, 13.3, 13.4, 13.6**

### Property 19: Exercise Index Progression

*For any* lesson execution, currentExerciseIndex SHALL initialize at 0, increment by exactly 1 per completed exercise, and trigger lesson completion when equal to total exercises count.

**Validates: Requirements 14.1, 14.2, 14.3**

### Property 20: Resume Without Energy Cost

*For any* lesson in in_progress state, resuming SHALL restore from currentExerciseIndex and SHALL NOT consume additional energy.

**Validates: Requirements 14.5, 14.6**

### Property 21: Time Tracking Accuracy

*For any* lesson, elapsed time SHALL equal completionTime - startTime in milliseconds, SHALL be stored as seconds in progress, SHALL exclude pause time, and SHALL accumulate across resume sessions.

**Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.5, 15.6**

### Property 22: Error Handling Without Side Effects

*For any* network error during lesson start, the system SHALL display error message and SHALL NOT consume energy. For errors during completion, the system SHALL retry up to 3 times and cache locally if all retries fail.

**Validates: Requirements 12.1, 12.2, 12.3**

### Property 23: Challenge Update Consistency

*For any* lesson completion, all active challenges SHALL be updated with incremented counters (lessonsCompleted, xpEarned), challenges reaching goal SHALL be marked completed, and challenge rewards SHALL be awarded.

**Validates: Requirements 9.1, 9.2, 9.3, 9.4**

### Property 24: Lesson State Validity

*For any* lesson, the state SHALL be one of: locked, not_started, in_progress, completed, or failed, and state transitions SHALL follow the defined state machine.

**Validates: Requirements 10.5**

### Property 25: Concurrency Prevention

*For any* user, only one lesson SHALL be in in_progress state at a time, preventing concurrent lesson starts.

**Validates: Requirements 12.7**

## Error Handling

### Network Errors

**Lesson Start Failures:**
- Display user-friendly error message
- Do NOT consume energy
- Allow retry without penalty
- Log error for debugging

**Lesson Completion Failures:**
- Retry up to 3 times with exponential backoff
- Cache progress locally if all retries fail
- Sync on next app open
- Notify user of sync status

**Data Loading Failures:**
- Display error with retry button
- Validate data integrity before use
- Provide fallback for missing data
- Log errors for monitoring

### Data Validation Errors

**Missing Exercise Data:**
- Validate all exercises exist before lesson start
- Show error if data incomplete
- Prevent lesson start with incomplete data

**Invalid State Transitions:**
- Log invalid transition attempts
- Recover to last valid state
- Prevent data corruption

**Timestamp Conversion Errors:**
- Use fallback date (current date in user timezone)
- Log conversion errors
- Continue operation with fallback

### Concurrency Errors

**Multiple Lesson Starts:**
- Check for existing in_progress lesson
- Prevent new lesson start if one active
- Show message to complete current lesson

**Race Conditions:**
- Use Firestore transactions for critical operations
- Implement optimistic locking where needed
- Retry on transaction conflicts

### User-Facing Error Messages

All error messages SHALL be in Portuguese and user-friendly:

- Network error: "Verifique sua conexão com a internet e tente novamente."
- Locked lesson: "Complete a lição anterior para desbloquear esta."
- No energy: "Você não tem energia suficiente. Aguarde a regeneração ou compre mais energia."
- Data loading error: "Não foi possível carregar a lição. Tente novamente."
- Save error: "Não foi possível salvar seu progresso. Tentaremos novamente automaticamente."

## Testing Strategy

### Dual Testing Approach

The lesson system requires both unit tests and property-based tests for comprehensive coverage:

**Unit Tests** focus on:
- Specific examples of each exercise type
- Edge cases (0 energy, 0 hearts, 100% accuracy)
- Error conditions (network failures, invalid data)
- State transitions (not_started → in_progress → completed)
- Integration between components

**Property-Based Tests** focus on:
- Universal properties that hold for all inputs
- Order of operations (critical for data consistency)
- Formula correctness (energy regen, XP calculation, accuracy)
- Invariants (hearts range, state validity)
- Comprehensive input coverage through randomization

### Property-Based Testing Configuration

**Library:** Use `faker` package for Dart to generate random test data

**Configuration:**
- Minimum 100 iterations per property test
- Each test tagged with: `Feature: lesson-system, Property N: [property description]`
- Generate random: lesson data, user states, exercise answers, timestamps
- Test edge values: 0, 1, max values, boundary conditions

**Example Property Test Structure:**
```dart
// Feature: lesson-system, Property 5: Hearts Invariant
test('hearts remain in range [0, 3] throughout lesson', () {
  final faker = Faker();
  
  for (int i = 0; i < 100; i++) {
    // Generate random lesson with random number of exercises
    final lesson = generateRandomLesson(faker);
    final answers = generateRandomAnswers(faker, lesson.exercises.length);
    
    // Execute lesson
    final state = executeLessonWithAnswers(lesson, answers);
    
    // Verify hearts invariant
    expect(state.hearts, greaterThanOrEqualTo(0));
    expect(state.hearts, lessThanOrEqualTo(3));
    
    // Verify hearts decrease by 1 per wrong answer
    final wrongAnswers = answers.where((a) => !a.isCorrect).length;
    expect(state.hearts, equals(3 - min(3, wrongAnswers)));
  }
});
```

### Test Coverage Requirements

**Critical Paths (100% coverage required):**
- Lesson start sequence
- Lesson completion sequence
- Energy consumption and regeneration
- Reward calculation and distribution
- Streak update logic
- Progress persistence

**Important Paths (90% coverage required):**
- Exercise validation (all types)
- Hearts management
- Error handling and retries
- State transitions
- Challenge updates

**Supporting Paths (80% coverage required):**
- UI feedback logic
- Time tracking
- Booster application
- History updates

### Integration Testing

**Firebase Integration:**
- Test Firestore read/write operations
- Test transaction handling
- Test timestamp conversion
- Test offline persistence

**State Management:**
- Test GetX reactive updates
- Test state synchronization
- Test concurrent access prevention

**End-to-End Flows:**
- Complete lesson flow (start → exercises → completion)
- Failed lesson flow (start → wrong answers → failure)
- Resume lesson flow (start → pause → resume → complete)
- Multiple lessons per day (streak logic)

### Performance Testing

**Benchmarks:**
- Lesson start: < 500ms
- Exercise validation: < 50ms
- Reward calculation: < 100ms
- Progress save: < 1000ms
- History update: < 500ms

**Load Testing:**
- Multiple concurrent users
- Rapid lesson completions
- Large exercise sets
- Network latency simulation

### Manual Testing Checklist

- [ ]Complete lesson with 100% accuracy (perfect bonus)
- [ ]Complete lesson with mistakes (hearts decrease)
- [ ]Fail lesson (0 hearts, no rewards)
- [ ]Complete first lesson of day (first today bonus, streak update)
- [ ]Complete multiple lessons same day (no duplicate streak)
- [ ]Resume in-progress lesson (no energy cost)- [ ] Complete lesson with XP Booster (2× XP)
- [ ]Complete lesson with Gem Multiplier (2× gems)
- [ ]Level up during lesson completion
- [ ]Break streak (last lesson > 1 day ago)
- [ ]Try locked lesson (prevented)
- [ ]Try lesson with 0 energy (Low Energy Modal)
- [ ]Network error during start (energy not consumed)
- [ ]Network error during completion (retry logic)
- [ ]All exercise types validate correctly
- [ ]Time tracking accurate across pause/resume
- [ ]History updates with correct date (user timezone)
- [ ]Challenges update after completion
- [ ]Next lesson unlocks after completion

### Regression Testing

**Critical Regressions to Prevent:**
- Energy consumed before validation
- Streak updated multiple times per day
- XP not distributed to all counters
- Hearts going negative
- Rewards calculated in wrong order
- Booster applied after expiration
- UTC used instead of user timezone
- Next lesson not unlocked
- Progress not saved on network error
- Concurrent lessons allowed

Each regression SHALL have a dedicated test to prevent recurrence.
