# Requirements Document

## Introduction

The ranking/leaderboard system is a competitive feature for the Pippo language learning app that motivates users through weekly competitions, league progression, and rewards. Users compete in groups of 30 players within their league tier, earning XP throughout the week to climb rankings and potentially advance to higher leagues.

## Glossary

- **Leaderboard_System**: The complete ranking and competition system
- **Weekly_Competition**: A 7-day competition period running Monday 00:00 to Sunday 23:59
- **League**: A tier level in the ranking system (Bronze, Silver, Gold, Platinum, Diamond)
- **Leaderboard_Group**: A group of exactly 30 users competing together in the same league
- **Weekly_XP**: Experience points earned during the current week (resets every Monday)
- **Rank_Position**: User's position within their leaderboard group (1-30)
- **Promotion_Zone**: Top 10 positions that advance to the next league
- **Safe_Zone**: Positions 11-25 that remain in the current league
- **Demotion_Zone**: Bottom 5 positions (26-30) that drop to the previous league
- **User_Status**: An optional emoji that users can display on their rank item
- **Weekly_Rewards**: Gems awarded based on final rank position at week end
- **Firestore**: Firebase's NoSQL database for storing user and leaderboard data

## Requirements

### Requirement 1: Weekly Competition Structure

**User Story:** As a user, I want to compete in weekly leaderboards with other learners, so that I can measure my progress and stay motivated.

#### Acceptance Criteria

1. WHEN a new week begins (Monday 00:00), THE Leaderboard_System SHALL reset all users' Weekly_XP to zero
2. WHEN a user earns XP during the week, THE Leaderboard_System SHALL add it to their Weekly_XP total
3. WHILE the week is active, THE Leaderboard_System SHALL display days remaining until Sunday 23:59
4. WHEN the week ends (Sunday 23:59), THE Leaderboard_System SHALL finalize rankings and process league changes
5. THE Leaderboard_System SHALL ensure each Leaderboard_Group contains exactly 30 users

### Requirement 2: League System

**User Story:** As a user, I want to progress through different league tiers, so that I can challenge myself against increasingly skilled players.

#### Acceptance Criteria

1. THE Leaderboard_System SHALL support five leagues: Bronze, Silver, Gold, Platinum, and Diamond
2. WHEN a user finishes in the Promotion_Zone (positions 1-10), THE Leaderboard_System SHALL move them to the next higher league
3. WHEN a user finishes in the Safe_Zone (positions 11-25), THE Leaderboard_System SHALL keep them in their current league
4. WHEN a user finishes in the Demotion_Zone (positions 26-30), THE Leaderboard_System SHALL move them to the next lower league
5. IF a user is in Diamond league, THEN THE Leaderboard_System SHALL not promote them (Diamond is the highest)
6. IF a user is in Bronze league, THEN THE Leaderboard_System SHALL not demote them (Bronze is the lowest)
7. WHEN forming new Leaderboard_Groups, THE Leaderboard_System SHALL only group users from the same league

### Requirement 3: Ranking and Sorting

**User Story:** As a user, I want to see my current rank and how I compare to others, so that I know where I stand in the competition.

#### Acceptance Criteria

1. THE Leaderboard_System SHALL sort users by Weekly_XP in descending order
2. WHEN multiple users have the same Weekly_XP, THE Leaderboard_System SHALL assign them sequential ranks without gaps
3. THE Leaderboard_System SHALL assign Rank_Position from 1 to 30 for each Leaderboard_Group
4. WHEN displaying the leaderboard, THE Leaderboard_System SHALL highlight the current user's rank in orange
5. THE Leaderboard_System SHALL display each user's avatar, name, Weekly_XP, and optional User_Status
6. WHEN a user is viewing their own rank, THE Leaderboard_System SHALL display "Me" instead of their name

### Requirement 4: Weekly Rewards

**User Story:** As a user, I want to receive rewards based on my final ranking, so that I feel recognized for my effort and performance.

#### Acceptance Criteria

1. WHEN a user finishes in 1st place, THE Leaderboard_System SHALL award 50 gems
2. WHEN a user finishes in 2nd place, THE Leaderboard_System SHALL award 30 gems
3. WHEN a user finishes in 3rd place, THE Leaderboard_System SHALL award 20 gems
4. WHEN a user finishes in positions 4-10, THE Leaderboard_System SHALL award 10 gems
5. WHEN a user finishes in positions 11-30, THE Leaderboard_System SHALL award 5 gems
6. WHEN a user is promoted to a higher league, THE Leaderboard_System SHALL award an additional 20 gems
7. THE Leaderboard_System SHALL add all earned gems to the user's gem balance

### Requirement 5: Real-time Updates

**User Story:** As a user, I want to see my rank update immediately when I earn XP, so that I can track my progress in real-time.

#### Acceptance Criteria

1. WHEN a user earns XP, THE Leaderboard_System SHALL update their Weekly_XP in Firestore
2. WHEN Weekly_XP changes, THE Leaderboard_System SHALL recalculate the user's Rank_Position
3. WHEN the leaderboard is displayed, THE Leaderboard_System SHALL show the current state from Firestore
4. THE Leaderboard_System SHALL display the user's current zone status (Promotion_Zone, Safe_Zone, or Demotion_Zone)
5. WHEN the leaderboard page is opened, THE Leaderboard_System SHALL load the latest data from Firestore

### Requirement 6: User Status Feature

**User Story:** As a user, I want to set an emoji status on my leaderboard profile, so that I can express my mood or personality to other competitors.

#### Acceptance Criteria

1. WHEN a user taps their own rank item, THE Leaderboard_System SHALL display a status selection modal
2. THE Leaderboard_System SHALL provide a selection of emoji options for User_Status
3. WHEN a user selects an emoji, THE Leaderboard_System SHALL save it as their User_Status
4. WHEN a user has a User_Status set, THE Leaderboard_System SHALL display it on their rank item
5. WHEN a user clears their status, THE Leaderboard_System SHALL remove the User_Status from display
6. THE Leaderboard_System SHALL persist User_Status in Firestore

### Requirement 7: Leaderboard Group Formation

**User Story:** As a system administrator, I want users to be grouped fairly into leaderboards, so that competition is balanced and engaging.

#### Acceptance Criteria

1. WHEN forming new Leaderboard_Groups, THE Leaderboard_System SHALL randomly assign users to groups
2. THE Leaderboard_System SHALL ensure each Leaderboard_Group has exactly 30 users
3. THE Leaderboard_System SHALL only group users from the same league together
4. WHEN there are insufficient users for a complete group, THE Leaderboard_System SHALL fill remaining slots with placeholder users
5. THE Leaderboard_System SHALL form new Leaderboard_Groups every Monday at 00:00

### Requirement 8: Data Persistence

**User Story:** As a developer, I want all leaderboard data stored reliably in Firestore, so that the system is scalable and data is preserved.

#### Acceptance Criteria

1. THE Leaderboard_System SHALL store Weekly_XP in users/{userId}/stats/gamification
2. THE Leaderboard_System SHALL store currentLeague in users/{userId}/stats/gamification
3. THE Leaderboard_System SHALL store leagueRank in users/{userId}/stats/gamification
4. THE Leaderboard_System SHALL store User_Status in users/{userId}/stats/gamification
5. THE Leaderboard_System SHALL create a leaderboardGroups collection for managing 30-user groups
6. THE Leaderboard_System SHALL create a weeklyResults collection for historical competition data
7. WHEN the week ends, THE Leaderboard_System SHALL archive final rankings to weeklyResults

### Requirement 9: UI Display Requirements

**User Story:** As a user, I want a clear and attractive leaderboard interface, so that I can easily understand my standing and competition status.

#### Acceptance Criteria

1. THE Leaderboard_System SHALL display the league name prominently at the top
2. THE Leaderboard_System SHALL show days remaining in the current week
3. THE Leaderboard_System SHALL display a description of the promotion/demotion rules
4. WHEN displaying rank 1, THE Leaderboard_System SHALL show a gold medal icon instead of the number
5. THE Leaderboard_System SHALL display all 30 users in the Leaderboard_Group
6. THE Leaderboard_System SHALL show each user's avatar, name (or "Me"), Weekly_XP, and optional User_Status
7. THE Leaderboard_System SHALL use orange background for the current user's rank item
8. THE Leaderboard_System SHALL display a collapsible header with league shields

### Requirement 10: Error Handling and Loading States

**User Story:** As a user, I want clear feedback when data is loading or if errors occur, so that I understand the system status.

#### Acceptance Criteria

1. WHEN loading leaderboard data, THE Leaderboard_System SHALL display a loading indicator
2. IF Firestore returns an error, THEN THE Leaderboard_System SHALL display a user-friendly error message
3. WHEN no internet connection is available, THE Leaderboard_System SHALL inform the user to check their connection
4. THE Leaderboard_System SHALL handle Firestore permission errors gracefully
5. IF data loading fails, THE Leaderboard_System SHALL provide a retry option

### Requirement 11: Weekly Reset Process

**User Story:** As a system administrator, I want the weekly reset to happen automatically and reliably, so that competitions run smoothly without manual intervention.

#### Acceptance Criteria

1. THE Leaderboard_System SHALL execute the weekly reset every Monday at 00:00
2. WHEN the reset occurs, THE Leaderboard_System SHALL process all promotions and demotions
3. WHEN the reset occurs, THE Leaderboard_System SHALL distribute Weekly_Rewards to all users
4. WHEN the reset occurs, THE Leaderboard_System SHALL reset all Weekly_XP values to zero
5. WHEN the reset occurs, THE Leaderboard_System SHALL form new random Leaderboard_Groups
6. THE Leaderboard_System SHALL send notifications to users about their league changes and rewards
7. IF the reset process fails, THE Leaderboard_System SHALL log errors and retry

### Requirement 12: Mock Data for Development

**User Story:** As a developer, I want realistic mock data for testing, so that I can develop and test the UI without requiring a full backend.

#### Acceptance Criteria

1. THE Leaderboard_System SHALL provide mock data with 10 realistic users
2. THE Leaderboard_System SHALL include varied Weekly_XP values in mock data
3. THE Leaderboard_System SHALL include users with and without User_Status in mock data
4. THE Leaderboard_System SHALL use existing character assets from AppAssets for mock avatars
5. THE Leaderboard_System SHALL mark one user as "Me" (isCurrentUser: true) in mock data
6. THE Leaderboard_System SHALL store mock data in lib/shared/mocks/leaderboard_mocks.dart
