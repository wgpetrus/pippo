# Requirements Document

## Introduction

The Lesson System is the core feature of Pippo, a language learning application. This system enables users to complete interactive exercises to learn new languages through a gamified experience. The system manages lesson progression, exercise execution, reward distribution, energy consumption, and progress tracking with strict order-of-operations requirements to ensure data consistency and fair gameplay.

## Glossary

- **Lesson**: A learning unit containing multiple exercises that users complete to progress
- **Exercise**: An individual learning activity within a lesson (image, translation, word order, or match type)
- **Energy**: A consumable resource (max 5) required to start lessons, regenerates 1 per 30 minutes
- **Hearts**: Lives during a lesson (start with 3), lost on wrong answers, 0 hearts = lesson fails
- **XP (Experience Points)**: Points earned for completing lessons, used for leveling up
- **Gems**: Virtual currency earned from lessons, used in the shop
- **Streak**: Consecutive days of completing at least one lesson
- **Accuracy**: Percentage of correct answers in a lesson (correctAnswers / totalAnswers * 100)
- **Progress**: User's completion state for a specific lesson (locked, not_started, in_progress, completed)
- **Booster**: Temporary multiplier for XP or gems (2× for 1 hour)
- **History**: Daily statistics saved with date as ID (YYYY-MM-DD format)
- **Challenge**: Daily or weekly goals that update after lesson completion

## Requirements

### Requirement 1: Lesson Initialization and Energy Management

**User Story:** As a user, I want the system to validate my eligibility and consume energy before starting a lesson, so that I cannot bypass resource requirements.

#### Acceptance Criteria

1. WHEN a user attempts to start a lesson, THE System SHALL verify the lesson is unlocked before proceeding
2. WHEN a user attempts to start an unlocked lesson, THE System SHALL verify the user has at least 1 energy before proceeding
3. WHEN a user has 0 energy, THE System SHALL display the Low Energy Modal and prevent lesson start
4. WHEN a user has sufficient energy and starts a lesson, THE System SHALL consume exactly 1 energy immediately
5. WHEN a user has unlimited energy active, THE System SHALL allow lesson start without consuming energy
6. THE System SHALL calculate energy regeneration using the formula: minutesPassed ~/ 30
7. THE System SHALL calculate next energy time using the formula: 30 - (minutesPassed % 30)

### Requirement 2: Exercise Execution and Validation

**User Story:** As a user, I want to complete different types of exercises with accurate validation, so that I can learn effectively.

#### Acceptance Criteria

1. WHEN an Image Exercise is presented, THE System SHALL display a word and 4 image options
2. WHEN a user selects an image in Image Exercise, THE System SHALL validate against the correct image ID
3. WHEN a Translation Exercise is presented, THE System SHALL display a word with audio and 4 translation options
4. WHEN a user selects a translation, THE System SHALL validate against the correct translation text
5. WHEN a Word Order Exercise is presented, THE System SHALL display draggable word chips and a word zone
6. WHEN a user arranges words, THE System SHALL validate the exact order against the correct sentence
7. WHEN a Match Exercise is presented, THE System SHALL display 4 audio-text pairs to connect
8. WHEN a user connects a pair in Match Exercise, THE System SHALL provide instant feedback on correctness
9. WHEN a user completes all pairs in Match Exercise, THE System SHALL validate all 4 pairs are correct

### Requirement 3: Hearts System and Lesson Failure

**User Story:** As a user, I want to lose hearts for wrong answers and fail the lesson at 0 hearts, so that there are consequences for mistakes.

#### Acceptance Criteria

1. WHEN a lesson starts, THE System SHALL initialize hearts to exactly 3
2. WHEN a user answers incorrectly, THE System SHALL decrease hearts by exactly 1
3. WHEN hearts reach 0, THE System SHALL immediately end the lesson as failed
4. WHEN a lesson fails, THE System SHALL display the fail screen with no rewards
5. WHEN a lesson fails, THE System SHALL NOT refund the consumed energy
6. THE System SHALL ensure hearts never go below 0 or above 3 during a lesson

### Requirement 4: Answer Feedback and Progress Tracking

**User Story:** As a user, I want immediate feedback on my answers and accurate tracking of my performance, so that I can learn from mistakes.

#### Acceptance Criteria

1. WHEN a user answers correctly, THE System SHALL display green background with "Correto!" message
2. WHEN a user answers incorrectly, THE System SHALL display red background with sad mascot and correct answer
3. WHEN a user answers incorrectly, THE System SHALL decrement hearts before showing feedback
4. WHEN an answer is submitted, THE System SHALL increment totalAnswers counter
5. WHEN a correct answer is submitted, THE System SHALL increment correctAnswers counter
6. THE System SHALL track elapsed time from lesson start to completion
7. THE System SHALL calculate accuracy using the formula: (correctAnswers / totalAnswers) * 100

### Requirement 5: Lesson Completion and Reward Calculation

**User Story:** As a user, I want to receive rewards when I complete a lesson, so that I feel motivated to continue learning.

#### Acceptance Criteria

1. WHEN a user completes all exercises with hearts remaining, THE System SHALL mark the lesson as completed
2. WHEN calculating rewards, THE System SHALL start with base XP from lesson.xpReward
3. WHEN calculating rewards, THE System SHALL start with base gems from lesson.gemsReward
4. WHEN accuracy is 100%, THE System SHALL add +5 XP as perfect bonus
5. WHEN this is the first lesson completed today, THE System SHALL add +5 XP as first today bonus
6. WHEN XP Booster is active, THE System SHALL multiply all XP by 2
7. WHEN Gem Multiplier is active, THE System SHALL multiply all gems by 2
8. THE System SHALL calculate total XP before applying booster multiplier
9. THE System SHALL calculate total gems before applying multiplier

### Requirement 6: XP Distribution and Level Up

**User Story:** As a user, I want my XP to be distributed correctly across different counters and level up when I reach thresholds, so that my progress is accurately tracked.

#### Acceptance Criteria

1. WHEN XP is earned, THE System SHALL add it to totalXp (never resets)
2. WHEN XP is earned, THE System SHALL add it to weeklyXp (resets Monday 00:00)
3. WHEN XP is earned, THE System SHALL add it to todayXp (resets daily at midnight)
4. WHEN totalXp reaches or exceeds currentLevel * 100, THE System SHALL increment currentLevel by 1
5. WHEN a level up occurs, THE System SHALL NOT reset totalXp
6. THE System SHALL calculate XP for next level using the formula: currentLevel * 100
7. THE System SHALL add XP to all three counters in a single atomic operation

### Requirement 7: Streak Management

**User Story:** As a user, I want my streak to update only on my first lesson of each day, so that completing multiple lessons doesn't incorrectly increment my streak.

#### Acceptance Criteria

1. WHEN a lesson is completed, THE System SHALL check if this is the first lesson completed today
2. WHEN determining "today", THE System SHALL use the user's timezone, not UTC
3. WHEN this is the first lesson of the day, THE System SHALL check the last streak date
4. WHEN the last streak date is yesterday, THE System SHALL increment currentStreak by 1
5. WHEN the last streak date is today, THE System SHALL NOT modify currentStreak
6. WHEN the last streak date is before yesterday, THE System SHALL reset currentStreak to 1
7. WHEN currentStreak exceeds longestStreak, THE System SHALL update longestStreak
8. WHEN streak is updated, THE System SHALL save the current date as lastStreakDate

### Requirement 8: Progress and History Persistence

**User Story:** As a user, I want my lesson progress and daily history to be saved accurately, so that I can track my learning over time.

#### Acceptance Criteria

1. WHEN a lesson is completed, THE System SHALL save progress to users/{userId}/courses/{courseId}/progress/{lessonId}
2. WHEN saving progress, THE System SHALL include accuracy, xpEarned, gemsEarned, timeSpent, and mistakes
3. WHEN saving progress, THE System SHALL use FieldValue.serverTimestamp() for completedAt
4. WHEN a lesson is completed, THE System SHALL save or update daily history with date as ID (YYYY-MM-DD format)
5. WHEN saving history, THE System SHALL use user's timezone for date calculation, not UTC
6. WHEN updating history, THE System SHALL increment lessonsCompleted, totalXp, totalGems, and totalTime
7. THE System SHALL unlock the next lesson (lessonId + 1) after successful completion

### Requirement 9: Challenge Updates

**User Story:** As a user, I want my challenges to update after completing lessons, so that I can track my progress toward goals.

#### Acceptance Criteria

1. WHEN a lesson is completed, THE System SHALL update all active challenges
2. WHEN updating challenges, THE System SHALL increment relevant counters (lessonsCompleted, xpEarned, etc.)
3. WHEN a challenge reaches its goal, THE System SHALL mark it as completed
4. WHEN a challenge is completed, THE System SHALL award challenge rewards
5. THE System SHALL update challenges after saving progress but before navigation

### Requirement 10: Lesson Progression and Unlocking

**User Story:** As a user, I want lessons to unlock linearly as I complete them, so that I progress through the course in order.

#### Acceptance Criteria

1. THE System SHALL ensure the first lesson (lessonId = 1) is always unlocked
2. WHEN checking if a lesson is unlocked, THE System SHALL verify the previous lesson (lessonId - 1) is completed
3. WHEN a user attempts to start a locked lesson, THE System SHALL prevent access and show a message
4. WHEN a lesson is completed, THE System SHALL unlock exactly the next lesson (lessonId + 1)
5. THE System SHALL maintain lesson states: locked, not_started, in_progress, completed

### Requirement 11: Exercise Type Validation

**User Story:** As a developer, I want each exercise type to have specific validation logic, so that answers are checked correctly.

#### Acceptance Criteria

1. WHEN validating Image Exercise, THE System SHALL compare selected imageId with correct imageId
2. WHEN validating Translation Exercise, THE System SHALL compare selected translation text with correct translation
3. WHEN validating Word Order Exercise, THE System SHALL compare the ordered array of word IDs with correct order
4. WHEN validating Match Exercise, THE System SHALL verify all 4 pairs match correctly
5. THE System SHALL handle case-sensitive comparison for text-based exercises
6. THE System SHALL trim whitespace from user inputs before validation

### Requirement 12: Error Handling and Edge Cases

**User Story:** As a user, I want the system to handle errors gracefully, so that I don't lose progress due to technical issues.

#### Acceptance Criteria

1. WHEN a network error occurs during lesson start, THE System SHALL display an error message and NOT consume energy
2. WHEN a network error occurs during lesson completion, THE System SHALL retry saving progress up to 3 times
3. WHEN saving progress fails after retries, THE System SHALL cache progress locally and retry on next app open
4. WHEN loading lesson data fails, THE System SHALL display an error message and allow retry
5. WHEN Firestore timestamp conversion fails, THE System SHALL handle the error and use fallback date
6. THE System SHALL validate all exercise data exists before starting a lesson
7. THE System SHALL prevent concurrent lesson starts by the same user

### Requirement 13: Booster Management

**User Story:** As a user, I want boosters to apply correctly to my rewards and expire after 1 hour, so that I can maximize my gains.

#### Acceptance Criteria

1. WHEN an XP Booster is active, THE System SHALL multiply all XP rewards by 2
2. WHEN a Gem Multiplier is active, THE System SHALL multiply all gem rewards by 2
3. WHEN checking booster status, THE System SHALL compare current time with booster expiration time
4. WHEN a booster expires, THE System SHALL NOT apply the multiplier to subsequent lessons
5. THE System SHALL apply boosters to base rewards plus bonuses (perfect, first today)
6. THE System SHALL save booster activation time and calculate expiration as activationTime + 1 hour

### Requirement 14: Lesson State Management

**User Story:** As a user, I want my lesson state to be managed correctly during execution, so that I can pause and resume if needed.

#### Acceptance Criteria

1. WHEN a lesson starts, THE System SHALL initialize state with currentExerciseIndex = 0
2. WHEN an exercise is completed, THE System SHALL increment currentExerciseIndex by 1
3. WHEN currentExerciseIndex equals total exercises, THE System SHALL trigger lesson completion
4. WHEN a user closes the lesson mid-way, THE System SHALL save in_progress state
5. WHEN a user resumes an in_progress lesson, THE System SHALL restore from currentExerciseIndex
6. THE System SHALL NOT consume additional energy when resuming an in_progress lesson

### Requirement 15: Time Tracking and Performance Metrics

**User Story:** As a user, I want my lesson completion time to be tracked accurately, so that I can see my performance metrics.

#### Acceptance Criteria

1. WHEN a lesson starts, THE System SHALL record the start timestamp
2. WHEN a lesson completes, THE System SHALL calculate elapsed time as completionTime - startTime
3. WHEN calculating elapsed time, THE System SHALL use milliseconds precision
4. WHEN saving progress, THE System SHALL store timeSpent in seconds
5. THE System SHALL track time only for active lesson time, not pause time
6. WHEN a lesson is resumed, THE System SHALL add to existing elapsed time
