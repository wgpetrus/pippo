# Firestore Schema Documentation: Ranking System

## Overview

This document defines the complete Firestore database schema for the ranking/leaderboard system. The schema supports weekly competitions with 30-user groups, league progression, and reward distribution.

---

## Collections Structure

```
firestore/
├── users/{userId}/
│   └── stats/
│       └── gamification/
│           ├── weeklyXP
│           ├── currentLeague
│           ├── leagueRank
│           ├── leaderboardGroupId
│           ├── userStatus
│           └── lastWeeklyReset
│
├── leaderboardGroups/{groupId}/
│   ├── league
│   ├── weekStartDate
│   ├── weekEndDate
│   ├── memberIds[]
│   ├── createdAt
│   └── status
│
└── weeklyResults/{weekId}/
    ├── weekStartDate
    ├── weekEndDate
    ├── league
    ├── groupId
    ├── rankings[]
    └── processedAt
```

---

## Collection 1: users/{userId}/stats/gamification

### Purpose
Stores individual user gamification data including leaderboard-related fields. This is a subcollection within the existing users collection.

### Path
`users/{userId}/stats/gamification`

### Document Structure

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `xp` | number | Yes | Total lifetime XP | >= 0 |
| `gems` | number | Yes | Current gem balance | >= 0 |
| `streak` | number | Yes | Current streak days | >= 0 |
| `weeklyXP` | number | Yes | XP earned this week (resets Monday 00:00) | >= 0 |
| `currentLeague` | string | Yes | User's current league tier | 'bronze' \| 'silver' \| 'gold' \| 'platinum' \| 'diamond' |
| `leagueRank` | number | Yes | Position within leaderboard group | 1-30 |
| `leaderboardGroupId` | string | Yes | Reference to current group | Format: `{league}_{weekStartDate}_{randomId}` |
| `userStatus` | string | No | Optional emoji status | Single emoji character or null |
| `lastWeeklyReset` | Timestamp | Yes | Last time weeklyXP was reset | Firebase Timestamp |
| `updatedAt` | Timestamp | Yes | Last update timestamp | Firebase Timestamp |

### Example Document

```json
{
  "xp": 5420,
  "gems": 350,
  "streak": 12,
  "weeklyXP": 495,
  "currentLeague": "silver",
  "leagueRank": 2,
  "leaderboardGroupId": "silver_2024-01-15_abc123",
  "userStatus": "🎭",
  "lastWeeklyReset": Timestamp(2024, 1, 15, 0, 0, 0),
  "updatedAt": Timestamp(2024, 1, 18, 14, 30, 0)
}
```

### Indexes Required

```javascript
// Composite index for group formation
{
  collection: "users",
  fields: [
    { fieldPath: "stats.gamification.currentLeague", order: "ASCENDING" },
    { fieldPath: "stats.gamification.weeklyXP", order: "DESCENDING" }
  ]
}
```

### Access Patterns

1. **Read**: When loading leaderboard data for a user's group
2. **Write**: When XP is earned, status is updated, or weekly reset occurs
3. **Query**: When forming new groups (query by `currentLeague`)

### Security Rules

```javascript
match /users/{userId}/stats/gamification {
  // Users can read their own stats
  allow read: if request.auth != null && request.auth.uid == userId;
  
  // Users can update their own status
  allow update: if request.auth != null 
    && request.auth.uid == userId
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['userStatus', 'updatedAt']);
  
  // Only Cloud Functions can update other fields
  allow write: if request.auth.token.admin == true;
}
```

### Validation Requirements

- **weeklyXP**: Must be non-negative integer
- **currentLeague**: Must be one of the 5 valid league values
- **leagueRank**: Must be between 1 and 30
- **userStatus**: If present, must be a single emoji character (1-4 bytes UTF-8)
- **leaderboardGroupId**: Must reference an existing group document

---

## Collection 2: leaderboardGroups/{groupId}

### Purpose
Stores information about 30-user competition groups. Each group represents one leaderboard for a specific league and week.

### Path
`leaderboardGroups/{groupId}`

### Document ID Format
`{league}_{weekStartDate}_{randomId}`

**Examples:**
- `bronze_2024-01-15_abc123`
- `silver_2024-01-15_def456`
- `gold_2024-01-15_ghi789`

### Document Structure

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `league` | string | Yes | League tier for this group | 'bronze' \| 'silver' \| 'gold' \| 'platinum' \| 'diamond' |
| `weekStartDate` | Timestamp | Yes | Monday 00:00 of current week | Firebase Timestamp |
| `weekEndDate` | Timestamp | Yes | Sunday 23:59 of current week | Firebase Timestamp |
| `memberIds` | array | Yes | Array of 30 user IDs | Length must be exactly 30 |
| `createdAt` | Timestamp | Yes | Group creation timestamp | Firebase Timestamp |
| `status` | string | Yes | Group lifecycle status | 'active' \| 'completed' |

### Example Document

```json
{
  "league": "silver",
  "weekStartDate": Timestamp(2024, 1, 15, 0, 0, 0),
  "weekEndDate": Timestamp(2024, 1, 21, 23, 59, 59),
  "memberIds": [
    "user1_uid",
    "user2_uid",
    "user3_uid",
    // ... 27 more user IDs
  ],
  "createdAt": Timestamp(2024, 1, 15, 0, 0, 5),
  "status": "active"
}
```

### Indexes Required

```javascript
// Index for finding active groups by league
{
  collection: "leaderboardGroups",
  fields: [
    { fieldPath: "league", order: "ASCENDING" },
    { fieldPath: "weekStartDate", order: "DESCENDING" },
    { fieldPath: "status", order: "ASCENDING" }
  ]
}

// Index for cleanup queries
{
  collection: "leaderboardGroups",
  fields: [
    { fieldPath: "status", order: "ASCENDING" },
    { fieldPath: "weekEndDate", order: "ASCENDING" }
  ]
}
```

### Access Patterns

1. **Read**: When loading leaderboard members for display
2. **Write**: When forming new groups (weekly reset)
3. **Query**: Finding active groups for a specific league and week
4. **Update**: Marking groups as 'completed' after week ends

### Security Rules

```javascript
match /leaderboardGroups/{groupId} {
  // Anyone authenticated can read groups
  allow read: if request.auth != null;
  
  // Only Cloud Functions can write
  allow write: if request.auth.token.admin == true;
}
```

### Validation Requirements

- **league**: Must be one of the 5 valid league values
- **weekStartDate**: Must be a Monday at 00:00:00
- **weekEndDate**: Must be the following Sunday at 23:59:59
- **memberIds**: Must contain exactly 30 unique user IDs
- **status**: Must be 'active' or 'completed'
- **memberIds**: All referenced users must exist and have matching `currentLeague`

### Group Formation Algorithm

When forming new groups (Cloud Function):

1. Query all users with `currentLeague == targetLeague`
2. Shuffle users randomly
3. Create groups of exactly 30 users
4. If insufficient users (< 30), fill with placeholder bot users
5. Create `leaderboardGroups` documents
6. Update each user's `leaderboardGroupId`

**Placeholder Bot Format:**
```json
{
  "userId": "bot_{league}_{index}",
  "isBot": true,
  "weeklyXP": randomInt(50, 300)
}
```

---

## Collection 3: weeklyResults/{weekId}

### Purpose
Archives final rankings and rewards for historical tracking and analytics. Created when a week ends.

### Path
`weeklyResults/{weekId}`

### Document ID Format
`{groupId}_{weekStartDate}`

**Example:** `silver_2024-01-15_abc123_2024-01-15`

### Document Structure

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `weekStartDate` | Timestamp | Yes | Monday 00:00 of the week | Firebase Timestamp |
| `weekEndDate` | Timestamp | Yes | Sunday 23:59 of the week | Firebase Timestamp |
| `league` | string | Yes | League tier | 'bronze' \| 'silver' \| 'gold' \| 'platinum' \| 'diamond' |
| `groupId` | string | Yes | Reference to leaderboardGroups document | Must match existing group |
| `rankings` | array | Yes | Array of user ranking objects | Length 1-30 |
| `processedAt` | Timestamp | Yes | When results were processed | Firebase Timestamp |

### Rankings Array Structure

Each element in the `rankings` array:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `userId` | string | Yes | User ID | Must be valid user |
| `rank` | number | Yes | Final rank position | 1-30 |
| `weeklyXP` | number | Yes | Final weekly XP | >= 0 |
| `gemsAwarded` | number | Yes | Gems awarded for rank | >= 0 |
| `wasPromoted` | boolean | Yes | Whether user was promoted | true \| false |
| `wasDemoted` | boolean | Yes | Whether user was demoted | true \| false |
| `newLeague` | string | Yes | League after promotion/demotion | Valid league value |

### Example Document

```json
{
  "weekStartDate": Timestamp(2024, 1, 15, 0, 0, 0),
  "weekEndDate": Timestamp(2024, 1, 21, 23, 59, 59),
  "league": "silver",
  "groupId": "silver_2024-01-15_abc123",
  "rankings": [
    {
      "userId": "user1_uid",
      "rank": 1,
      "weeklyXP": 520,
      "gemsAwarded": 50,
      "wasPromoted": true,
      "wasDemoted": false,
      "newLeague": "gold"
    },
    {
      "userId": "user2_uid",
      "rank": 2,
      "weeklyXP": 495,
      "gemsAwarded": 30,
      "wasPromoted": true,
      "wasDemoted": false,
      "newLeague": "gold"
    },
    // ... 28 more ranking objects
  ],
  "processedAt": Timestamp(2024, 1, 22, 0, 0, 15)
}
```

### Indexes Required

```javascript
// Index for user history queries
{
  collection: "weeklyResults",
  fields: [
    { fieldPath: "rankings.userId", order: "ASCENDING" },
    { fieldPath: "weekStartDate", order: "DESCENDING" }
  ]
}

// Index for league analytics
{
  collection: "weeklyResults",
  fields: [
    { fieldPath: "league", order: "ASCENDING" },
    { fieldPath: "weekStartDate", order: "DESCENDING" }
  ]
}
```

### Access Patterns

1. **Write**: When week ends (Cloud Function creates document)
2. **Read**: For user history/statistics (future feature)
3. **Query**: Analytics and reporting

### Security Rules

```javascript
match /weeklyResults/{weekId} {
  // Anyone authenticated can read historical results
  allow read: if request.auth != null;
  
  // Only Cloud Functions can write
  allow write: if request.auth.token.admin == true;
}
```

### Validation Requirements

- **weekStartDate**: Must be a Monday at 00:00:00
- **weekEndDate**: Must be the following Sunday at 23:59:59
- **league**: Must be one of the 5 valid league values
- **groupId**: Must reference an existing (completed) group
- **rankings**: Must contain 1-30 elements
- **rankings[].rank**: Must be sequential 1-30 with no gaps
- **rankings[].gemsAwarded**: Must match reward calculation rules
- **rankings[].wasPromoted** and **rankings[].wasDemoted**: Cannot both be true

---

## Data Lifecycle

### Weekly Cycle

```
Monday 00:00 (Week Start)
├── Cloud Function triggers
├── Process all active groups:
│   ├── Calculate final rankings
│   ├── Determine promotions/demotions
│   ├── Award gems
│   ├── Archive to weeklyResults
│   └── Mark groups as 'completed'
├── Update user stats:
│   ├── Update currentLeague
│   ├── Reset weeklyXP to 0
│   ├── Clear leaderboardGroupId
│   └── Set lastWeeklyReset
└── Form new groups:
    ├── Query users by league
    ├── Shuffle randomly
    ├── Create groups of 30
    ├── Create leaderboardGroups docs
    └── Update user leaderboardGroupId
```

### During Week

```
User earns XP
├── GamificationController updates weeklyXP
├── Firestore triggers update
├── LeaderboardController recalculates rankings
└── UI updates reactively
```

### User Updates Status

```
User taps rank item
├── StatusModal opens
├── User selects emoji
├── LeaderboardController.updateUserStatus()
├── Firestore updates userStatus field
└── UI updates reactively
```

---

## Data Integrity Rules

### Constraints

1. **Group Size Invariant**: Every `leaderboardGroups` document MUST have exactly 30 `memberIds`
2. **League Consistency**: All users in a group MUST have the same `currentLeague`
3. **Rank Uniqueness**: Within a group, ranks 1-30 MUST be assigned with no gaps
4. **Status Validity**: `status` field MUST be 'active' or 'completed'
5. **Timestamp Ordering**: `weekStartDate` < `weekEndDate`
6. **Promotion/Demotion Exclusivity**: A user cannot be both promoted and demoted in the same week

### Validation Functions (Cloud Functions)

```typescript
// Validate group has exactly 30 members
function validateGroupSize(memberIds: string[]): boolean {
  return memberIds.length === 30;
}

// Validate all members have same league
async function validateLeagueConsistency(
  memberIds: string[], 
  expectedLeague: string
): Promise<boolean> {
  const users = await Promise.all(
    memberIds.map(id => db.collection('users').doc(id).get())
  );
  return users.every(
    user => user.data()?.stats?.gamification?.currentLeague === expectedLeague
  );
}

// Validate ranks are sequential 1-30
function validateRankSequence(rankings: Ranking[]): boolean {
  const ranks = rankings.map(r => r.rank).sort((a, b) => a - b);
  return ranks.length === 30 && 
         ranks[0] === 1 && 
         ranks[29] === 30 &&
         ranks.every((rank, i) => rank === i + 1);
}
```

---

## Migration Strategy

### Adding Leaderboard Fields to Existing Users

```typescript
// Cloud Function to migrate existing users
async function migrateUsersToLeaderboard() {
  const usersSnapshot = await db.collection('users').get();
  
  const batch = db.batch();
  let count = 0;
  
  for (const userDoc of usersSnapshot.docs) {
    const userRef = userDoc.ref;
    
    batch.update(userRef, {
      'stats.gamification.weeklyXP': 0,
      'stats.gamification.currentLeague': 'bronze',
      'stats.gamification.leagueRank': 0,
      'stats.gamification.leaderboardGroupId': '',
      'stats.gamification.userStatus': null,
      'stats.gamification.lastWeeklyReset': FieldValue.serverTimestamp(),
    });
    
    count++;
    
    // Firestore batch limit is 500
    if (count % 500 === 0) {
      await batch.commit();
      batch = db.batch();
    }
  }
  
  if (count % 500 !== 0) {
    await batch.commit();
  }
  
  console.log(`Migrated ${count} users`);
}
```

---

## Performance Considerations

### Read Optimization

1. **Denormalization**: Store user avatar and name in `leaderboardGroups.memberIds` to avoid 30 reads
   ```json
   "memberIds": [
     {
       "userId": "user1_uid",
       "name": "Sami",
       "avatar": "charMara"
     }
   ]
   ```

2. **Caching**: Cache leaderboard data in app for 5 minutes to reduce reads

3. **Pagination**: If showing more than 30 users, implement pagination

### Write Optimization

1. **Batch Writes**: Use batched writes when updating multiple users
2. **Transactions**: Use transactions for critical operations (weekly reset)
3. **Async Processing**: Process rewards and notifications asynchronously

### Cost Estimation

**Per User Per Week:**
- Reads: ~50 (loading leaderboard multiple times)
- Writes: ~20 (XP updates, status changes)
- Weekly reset: 3 writes per user

**For 10,000 users:**
- Monthly reads: ~2,000,000
- Monthly writes: ~1,000,000
- Estimated cost: ~$50-100/month

---

## Monitoring and Alerts

### Key Metrics to Track

1. **Group Formation Success Rate**: % of groups with exactly 30 members
2. **Weekly Reset Duration**: Time to process all groups
3. **Failed Transactions**: Count of failed weekly resets
4. **Orphaned Users**: Users without a `leaderboardGroupId`
5. **Data Inconsistencies**: Groups with wrong league or member count

### Recommended Alerts

```typescript
// Alert if group formation fails
if (groupsCreated < expectedGroups) {
  sendAlert('Group formation incomplete');
}

// Alert if weekly reset takes too long
if (resetDuration > 5 * 60 * 1000) { // 5 minutes
  sendAlert('Weekly reset timeout');
}

// Alert if users are orphaned
if (usersWithoutGroup > 0) {
  sendAlert(`${usersWithoutGroup} users without leaderboard group`);
}
```

---

## Testing Data

### Sample Test Documents

```typescript
// Test user
{
  "stats": {
    "gamification": {
      "xp": 1000,
      "gems": 100,
      "streak": 5,
      "weeklyXP": 250,
      "currentLeague": "bronze",
      "leagueRank": 5,
      "leaderboardGroupId": "bronze_2024-01-15_test123",
      "userStatus": "😊",
      "lastWeeklyReset": Timestamp.now(),
      "updatedAt": Timestamp.now()
    }
  }
}

// Test group
{
  "league": "bronze",
  "weekStartDate": Timestamp.now(),
  "weekEndDate": Timestamp.now(),
  "memberIds": Array(30).fill(null).map((_, i) => `test_user_${i}`),
  "createdAt": Timestamp.now(),
  "status": "active"
}
```

---

## Appendix: Field Type Reference

| Firestore Type | Dart Type | Description |
|----------------|-----------|-------------|
| `string` | `String` | Text data |
| `number` | `int` or `double` | Numeric data |
| `boolean` | `bool` | True/false |
| `Timestamp` | `Timestamp` | Date/time (convert to `DateTime` in Dart) |
| `array` | `List<dynamic>` | Ordered list |
| `map` | `Map<String, dynamic>` | Key-value pairs |

### Timestamp Conversion

```dart
// Firestore → Dart
final Timestamp timestamp = data['weekStartDate'];
final DateTime date = timestamp.toDate();

// Dart → Firestore
final DateTime date = DateTime.now();
final Timestamp timestamp = Timestamp.fromDate(date);

// Server timestamp
await doc.set({
  'createdAt': FieldValue.serverTimestamp(),
});
```

---

## Document Version

- **Version**: 1.0
- **Last Updated**: 2026-01-27
- **Author**: Kiro AI
- **Status**: Complete

---

## Related Documents

- [Requirements Document](requirements.md)
- [Design Document](design.md)
- [Implementation Tasks](tasks.md)
