# Requirements Document - Gamification System

## Introduction

The Gamification System is a core feature of Pippo that motivates users to maintain consistent study habits through four interconnected systems: Streak tracking, Energy management, XP & Levels progression, and Gems economy. This system drives user engagement by rewarding daily practice, limiting lesson consumption to prevent burnout, providing clear progression metrics, and offering a virtual economy for customization and power-ups.

**Implementation Context**: This is the 4th module in the implementation sequence. It depends on Firebase (1), Authentication (2), and Onboarding (3), and will be used by Lessons (5), Challenges (6), Ranking (7), Shop (8), and Profile (9). The system is designed to work independently while providing integration points for future modules.

## Glossary

- **Gamification_System**: The complete system managing streak, energy, XP, and gems
- **Streak**: Consecutive days count where user completed at least one lesson
- **Energy**: Resource consumed when starting lessons (max 5, regenerates over time)
- **Spark**: Individual unit of energy (synonym for energy point)
- **XP**: Experience points earned from completing exercises and lessons
- **Level**: User progression tier based on accumulated total XP
- **Gems**: Virtual currency earned through achievements and spent on items
- **Streak_Freeze**: Protection item that prevents streak loss for one day
- **XP_Booster**: Power-up that doubles XP gains for one hour
- **Gem_Multiplier**: Power-up that doubles gem gains for one hour
- **Primary_Course**: The active course for which stats are tracked
- **User_Timezone**: The timezone configured in user's device settings
- **Lesson**: A learning session consisting of multiple exercises
- **Exercise**: Individual question within a lesson
- **Perfect_Lesson**: Lesson completed with 100% accuracy
- **Weekly_XP**: XP accumulated in current week (resets Monday 00:00)
- **Today_XP**: XP accumulated today (resets at midnight)
- **Total_XP**: Cumulative XP that never decreases

## Requirements

### Requirement 1: Streak Tracking

**User Story:** As a language learner, I want to track my consecutive study days, so that I stay motivated to practice daily.

#### Acceptance Criteria

1. WHEN a user completes their first lesson of the day, THE Gamification_System SHALL increment the current streak by 1
2. WHEN midnight passes in the User_Timezone without completing a lesson, THE Gamification_System SHALL reset the current streak to 0
3. WHEN a user's streak reaches a new maximum, THE Gamification_System SHALL update the longest streak record
4. THE Gamification_System SHALL store the last streak date in "YYYY-MM-DD" format using User_Timezone
5. WHEN calculating streak status, THE Gamification_System SHALL use User_Timezone and never UTC
6. WHEN a user completes a lesson, THE Gamification_System SHALL update streak only if it is the first lesson of that day
7. WHERE a Streak_Freeze is active, IF midnight passes without a lesson, THEN THE Gamification_System SHALL maintain the streak and consume the freeze
8. WHEN a streak reaches milestone days (7, 14, 30, 100), THE Gamification_System SHALL award gems (5, 10, 25, 50 respectively)

### Requirement 2: Streak Freeze Protection

**User Story:** As a user with a long streak, I want to protect my streak for days I cannot study, so that I don't lose my progress.

#### Acceptance Criteria

1. WHEN a user purchases a Streak_Freeze for 200 gems, THE Gamification_System SHALL set streakFreezeAvailable to true
2. WHEN midnight passes without a lesson and streakFreezeAvailable is true, THE Gamification_System SHALL maintain the streak, set streakFreezeAvailable to false, and set streakFreezeUsedToday to true
3. WHEN a new day begins, THE Gamification_System SHALL reset streakFreezeUsedToday to false
4. THE Gamification_System SHALL allow only one Streak_Freeze to be active at a time
5. WHEN a Streak_Freeze is consumed, THE Gamification_System SHALL record the protection event in user history

### Requirement 3: Energy Management

**User Story:** As a user, I want a limited energy system that regenerates over time, so that I pace my learning and avoid burnout.

#### Acceptance Criteria

1. THE Gamification_System SHALL set maximum energy to 5 for all users
2. WHEN a user starts a lesson, THE Gamification_System SHALL consume 1 energy before the lesson begins
3. WHEN energy is consumed, THE Gamification_System SHALL update lastEnergyRegenAt to current timestamp
4. WHILE current energy is less than maximum, THE Gamification_System SHALL regenerate 1 energy every 30 minutes
5. WHEN calculating energy regeneration, THE Gamification_System SHALL use the formula: energiesToAdd = minutesPassed ~/ 30
6. WHEN energy reaches maximum, THE Gamification_System SHALL stop regeneration
7. WHEN a user attempts to start a lesson with 0 energy, THE Gamification_System SHALL prevent the action and display energy refill options
8. THE Gamification_System SHALL display "Next energy in X min" when energy is not at maximum

### Requirement 4: Energy Refill Options

**User Story:** As a user who wants to continue learning, I want to refill my energy, so that I can complete more lessons.

#### Acceptance Criteria

1. WHEN a user purchases energy refill for 100 gems, THE Gamification_System SHALL add 5 energy to current energy
2. WHEN adding energy, THE Gamification_System SHALL cap the total at maximum energy (5)
3. WHERE unlimited energy is active, THE Gamification_System SHALL not consume energy when starting lessons
4. WHEN unlimited energy expires, THE Gamification_System SHALL resume normal energy consumption
5. THE Gamification_System SHALL store unlimitedEnergyUntil as a timestamp for expiration checking

### Requirement 5: XP Earning from Exercises

**User Story:** As a user completing exercises, I want to earn XP for correct answers, so that I see immediate progress feedback.

#### Acceptance Criteria

1. WHEN a user answers an exercise correctly, THE Gamification_System SHALL award 1-2 XP based on exercise difficulty
2. WHEN a user completes a lesson, THE Gamification_System SHALL award 10-15 base XP
3. WHERE a lesson is completed with 100% accuracy, THE Gamification_System SHALL award an additional 5 XP bonus
4. WHERE a lesson is the first of the day, THE Gamification_System SHALL award an additional 5 XP bonus
5. WHERE an XP_Booster is active, THE Gamification_System SHALL double all XP gains
6. WHEN XP is awarded, THE Gamification_System SHALL update totalXp, weeklyXp, and todayXp simultaneously

### Requirement 6: Level Progression

**User Story:** As a user, I want to level up based on my total XP, so that I have long-term progression goals.

#### Acceptance Criteria

1. THE Gamification_System SHALL calculate XP required for next level using the formula: xpForNextLevel = currentLevel × 100
2. WHEN totalXp reaches or exceeds xpForNextLevel, THE Gamification_System SHALL increment the level by 1
3. WHEN a user levels up, THE Gamification_System SHALL award 10 gems
4. WHEN a user levels up, THE Gamification_System SHALL recalculate xpForNextLevel for the new level
5. THE Gamification_System SHALL ensure totalXp never decreases
6. WHEN a user levels up multiple times in one action, THE Gamification_System SHALL process each level up sequentially

### Requirement 7: XP Reset Cycles

**User Story:** As a competitive user, I want weekly and daily XP tracking, so that I can compete in leaderboards with fair time windows.

#### Acceptance Criteria

1. WHEN Monday 00:00 arrives in User_Timezone, THE Gamification_System SHALL reset weeklyXp to 0
2. WHEN midnight arrives in User_Timezone, THE Gamification_System SHALL reset todayXp to 0
3. THE Gamification_System SHALL never reset totalXp
4. WHEN calculating reset times, THE Gamification_System SHALL use User_Timezone and never UTC
5. WHEN XP is awarded, THE Gamification_System SHALL update all three XP types (total, weekly, today) in a single transaction

### Requirement 8: Gems Economy - Earning

**User Story:** As a user, I want to earn gems through various achievements, so that I can purchase items and power-ups.

#### Acceptance Criteria

1. WHEN a user completes a lesson, THE Gamification_System SHALL award 1-3 gems based on performance
2. WHEN a user completes a unit, THE Gamification_System SHALL award 10 gems
3. WHEN a user reaches streak milestones (7, 14, 30, 100 days), THE Gamification_System SHALL award gems (5, 10, 25, 50)
4. WHEN a user completes a challenge, THE Gamification_System SHALL award 5-15 gems based on difficulty
5. WHEN a user achieves ranking rewards, THE Gamification_System SHALL award 5-50 gems based on position
6. WHEN a user levels up, THE Gamification_System SHALL award 10 gems
7. WHERE a Gem_Multiplier is active, THE Gamification_System SHALL double all gem gains
8. WHEN gems are earned, THE Gamification_System SHALL update both gems and totalGemsEarned

### Requirement 9: Gems Economy - Spending

**User Story:** As a user with gems, I want to spend them on useful items, so that I can enhance my learning experience.

#### Acceptance Criteria

1. WHEN a user purchases energy refill for 100 gems, THE Gamification_System SHALL deduct 100 gems and add 5 energy
2. WHEN a user purchases Streak_Freeze for 200 gems, THE Gamification_System SHALL deduct 200 gems and activate the freeze
3. WHEN a user purchases XP_Booster for 150 gems, THE Gamification_System SHALL deduct 150 gems and activate 2× XP for 1 hour
4. WHEN a user purchases Gem_Multiplier for 200 gems, THE Gamification_System SHALL deduct 200 gems and activate 2× gems for 1 hour
5. WHEN a user purchases an avatar for 500-1000 gems, THE Gamification_System SHALL deduct the cost and unlock the avatar
6. WHEN gems are spent, THE Gamification_System SHALL update both gems and totalGemsSpent
7. IF a user has insufficient gems, THEN THE Gamification_System SHALL prevent the purchase and display the gem deficit

### Requirement 10: Power-Up Management

**User Story:** As a user, I want to activate time-limited power-ups, so that I can maximize my rewards during focused study sessions.

#### Acceptance Criteria

1. WHEN an XP_Booster is activated, THE Gamification_System SHALL store the expiration timestamp (current time + 1 hour)
2. WHEN a Gem_Multiplier is activated, THE Gamification_System SHALL store the expiration timestamp (current time + 1 hour)
3. WHEN checking if a power-up is active, THE Gamification_System SHALL compare current timestamp with expiration timestamp
4. WHEN a power-up expires, THE Gamification_System SHALL automatically deactivate it
5. THE Gamification_System SHALL allow only one XP_Booster active at a time
6. THE Gamification_System SHALL allow only one Gem_Multiplier active at a time
7. WHEN a power-up is active, THE Gamification_System SHALL display remaining time in the UI

### Requirement 11: Lesson Completion Reward Order

**User Story:** As a system architect, I want a consistent reward calculation order, so that all bonuses and multipliers are applied correctly.

#### Acceptance Criteria

1. WHEN a lesson is completed, THE Gamification_System SHALL execute operations in this exact order: calculate rewards, add XP, add gems, save progress, update streak (if first of day), update challenges, check level up, save history
2. WHEN calculating rewards, THE Gamification_System SHALL determine base XP and gems before applying multipliers
3. WHEN applying multipliers, THE Gamification_System SHALL apply XP_Booster to XP and Gem_Multiplier to gems
4. WHEN updating streak, THE Gamification_System SHALL verify it is the first lesson of the day before incrementing
5. WHEN checking level up, THE Gamification_System SHALL process all level ups that result from the XP gain
6. THE Gamification_System SHALL execute all operations in a single transaction to ensure data consistency

### Requirement 12: Primary Course Management

**User Story:** As a user learning multiple languages, I want one primary course for stat tracking, so that my progress is focused and clear.

#### Acceptance Criteria

1. THE Gamification_System SHALL allow only one Primary_Course to be active at a time
2. WHEN a user sets a new Primary_Course, THE Gamification_System SHALL update the primary flag for that course
3. WHEN a user sets a new Primary_Course, THE Gamification_System SHALL remove the primary flag from the previous course
4. THE Gamification_System SHALL track streak, energy, XP, and gems only for the Primary_Course
5. WHEN a user switches Primary_Course, THE Gamification_System SHALL maintain all existing stats without reset

### Requirement 13: Data Persistence and Synchronization

**User Story:** As a user, I want my gamification stats saved reliably, so that I never lose my progress.

#### Acceptance Criteria

1. THE Gamification_System SHALL store all stats in Firestore at path users/{userId}/stats/gamification
2. WHEN any stat changes, THE Gamification_System SHALL update Firestore within 5 seconds
3. WHEN the app starts, THE Gamification_System SHALL load stats from Firestore before displaying UI
4. IF Firestore is unavailable, THEN THE Gamification_System SHALL cache changes locally and sync when connection is restored
5. THE Gamification_System SHALL use Firestore transactions for operations that modify multiple fields
6. WHEN energy regenerates, THE Gamification_System SHALL update lastEnergyRegenAt in Firestore
7. THE Gamification_System SHALL validate all data types match the schema before saving

### Requirement 14: History and Analytics

**User Story:** As a user, I want to see my historical progress, so that I can track my learning journey over time.

#### Acceptance Criteria

1. WHEN a lesson is completed, THE Gamification_System SHALL record the event with date, XP earned, gems earned, and lesson details
2. WHEN a streak milestone is reached, THE Gamification_System SHALL record the achievement with date and milestone value
3. WHEN a level up occurs, THE Gamification_System SHALL record the event with date and new level
4. THE Gamification_System SHALL store history dates in "YYYY-MM-DD" format using User_Timezone
5. THE Gamification_System SHALL provide methods to query history by date range
6. THE Gamification_System SHALL limit history storage to the most recent 365 days to manage data size

### Requirement 15: Error Handling and Edge Cases

**User Story:** As a system architect, I want robust error handling, so that edge cases don't corrupt user data.

#### Acceptance Criteria

1. IF energy calculation results in negative value, THEN THE Gamification_System SHALL set energy to 0
2. IF energy calculation exceeds maximum, THEN THE Gamification_System SHALL cap energy at maximum value
3. IF XP calculation results in negative value, THEN THE Gamification_System SHALL reject the operation
4. IF gems calculation results in negative balance, THEN THE Gamification_System SHALL prevent the transaction
5. IF level calculation produces invalid result, THEN THE Gamification_System SHALL maintain current level and log error
6. WHEN Firestore operations fail, THE Gamification_System SHALL retry up to 3 times with exponential backoff
7. IF a transaction fails after retries, THEN THE Gamification_System SHALL display user-friendly error message
8. THE Gamification_System SHALL validate all input parameters before processing operations
