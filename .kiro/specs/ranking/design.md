# Design Document: Ranking/Leaderboard System

## Overview

The ranking system is a competitive gamification feature that organizes users into weekly leaderboards within league tiers. Users compete in groups of exactly 30 players, earning XP throughout the week to climb rankings and potentially advance to higher leagues. The system integrates with the existing gamification infrastructure and follows GetX patterns for state management.

### Key Design Principles

1. **Simplicity**: No models, repositories, or services - all logic in LeaderboardController
2. **Reactivity**: Use GetX observables (.obs) for real-time UI updates
3. **Scalability**: Firestore structure supports millions of users
4. **Performance**: Efficient queries and minimal real-time listeners
5. **Reliability**: Atomic operations and error handling

### Technology Stack

- **State Management**: GetX (observables and controller)
- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth
- **Backend**: Cloud Functions (for weekly reset)
- **UI**: Existing components (LeaderboardPage, RankItem, LeagueInfo, StatusModal)

---

## Architecture

### Component Structure

```
LeaderboardPage (View)
    ↓ observes
LeaderboardController (GetX Controller)
    ↓ reads/writes
Cloud Firestore
    ├── users/{userId}/stats/gamification (user stats)
    ├── leaderboardGroups/{groupId} (30-user groups)
    └── weeklyResults/{weekId} (historical data)
```

### Data Flow

1. **User earns XP** → GamificationController updates weeklyXP in Firestore
2. **Firestore updates** → LeaderboardController recalculates rankings
3. **Rankings change** → UI updates reactively via Obx()
4. **Week ends** → Cloud Function processes promotions/demotions/rewards
5. **New week starts** → Cloud Function forms new random groups

### Integration Points

- **GamificationController**: Provides weeklyXP updates
- **TreasureController**: May award gems for ranking achievements
- **ProfileController**: Displays league badge and stats
- **NotificationController**: Sends league change notifications

---

## Firestore Collections Design

### 1. users/{userId}/stats/gamification

Stores individual user gamification data including leaderboard-related fields.

**Structure:**
```typescript
{
  // Existing fields (from GamificationController)
  xp: number,              // Total lifetime XP
  gems: number,            // Current gem balance
  streak: number,          // Current streak days
  
  // Leaderboard fields (NEW)
  weeklyXP: number,        // XP earned this week (resets Monday 00:00)
  currentLeague: string,   // 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond'
  leagueRank: number,      // Position within leaderboard group (1-30)
  leaderboardGroupId: string,  // Reference to current group
  userStatus: string?,     // Optional emoji status
  
  // Metadata
  lastWeeklyReset: Timestamp,  // Last time weeklyXP was reset
  updatedAt: Timestamp
}
```

**Indexes Required:**
- `currentLeague` (for group formation)
- `weeklyXP` (for ranking within group)

**Access Patterns:**
- Read: When loading leaderboard data
- Write: When XP is earned, status is updated, or weekly reset occurs

### 2. leaderboardGroups/{groupId}

Stores information about 30-user competition groups.

**Structure:**
```typescript
{
  league: string,          // 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond'
  weekStartDate: Timestamp,  // Monday 00:00 of current week
  weekEndDate: Timestamp,    // Sunday 23:59 of current week
  memberIds: string[],     // Array of 30 user IDs
  createdAt: Timestamp,
  status: string           // 'active' | 'completed'
}
```

**Document ID Format:** `{league}_{weekStartDate}_{randomId}`
Example: `bronze_2024-01-15_abc123`

**Indexes Required:**
- `league` + `weekStartDate` (for finding active groups)
- `status` (for cleanup)

**Access Patterns:**
- Read: When loading leaderboard members
- Write: When forming new groups (weekly reset)

### 3. weeklyResults/{weekId}

Archives final rankings and rewards for historical tracking.

**Structure:**
```typescript
{
  weekStartDate: Timestamp,
  weekEndDate: Timestamp,
  league: string,
  groupId: string,
  rankings: [
    {
      userId: string,
      rank: number,
      weeklyXP: number,
      gemsAwarded: number,
      wasPromoted: boolean,
      wasDemoted: boolean,
      newLeague: string
    }
  ],
  processedAt: Timestamp
}
```

**Document ID Format:** `{groupId}_{weekStartDate}`

**Access Patterns:**
- Write: When week ends (Cloud Function)
- Read: For user history/statistics (future feature)

---

## LeaderboardController Design

### Observable States

```dart
class LeaderboardController extends GetxController {
  // Estados obrigatórios (padrão da empresa)
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Estados específicos do leaderboard
  final leaderboardData = <Map<String, dynamic>>[].obs;  // 30 users
  final currentUserRank = 0.obs;
  final currentLeague = 'bronze'.obs;
  final daysRemaining = 0.obs;
  final isUpdatingStatus = false.obs;
  
  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  // Listener para atualizações em tempo real (opcional)
  StreamSubscription<QuerySnapshot>? _leaderboardListener;
}
```

### Public Methods

#### loadLeaderboardData()

Loads the current user's leaderboard group and calculates rankings.

**Algorithm:**
1. Get current user ID from Firebase Auth
2. Read user's `leaderboardGroupId` from Firestore
3. Query all 30 users in the same group
4. Sort by `weeklyXP` descending
5. Assign ranks 1-30
6. Calculate days remaining until Sunday 23:59
7. Update observable states

**Error Handling:**
- User not authenticated → show auth error
- No leaderboard group → show "waiting for group formation"
- Firestore error → use `_handleFirestoreError()`

**Pseudo-code:**
```dart
Future<void> loadLeaderboardData() async {
  isLoading.value = true;
  errorMessage.value = '';
  
  try {
    // 1. Verificar autenticação
    final user = _auth.currentUser;
    if (user == null) throw Exception('Não autenticado');
    
    // 2. Buscar grupo do usuário
    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    
    final groupId = userDoc.data()?['stats']?['gamification']?['leaderboardGroupId'];
    if (groupId == null) {
      // Usuário ainda não tem grupo (aguardando reset semanal)
      leaderboardData.value = [];
      return;
    }
    
    // 3. Buscar membros do grupo
    final groupDoc = await _firestore
        .collection('leaderboardGroups')
        .doc(groupId)
        .get();
    
    final memberIds = List<String>.from(groupDoc.data()?['memberIds'] ?? []);
    
    // 4. Buscar dados de cada membro (batch read)
    final memberDataList = <Map<String, dynamic>>[];
    for (final memberId in memberIds) {
      final memberDoc = await _firestore
          .collection('users')
          .doc(memberId)
          .get();
      
      final data = memberDoc.data();
      if (data != null) {
        memberDataList.add({
          'userId': memberId,
          'name': data['name'] ?? 'Usuário',
          'avatar': data['avatar'] ?? AppAssets.charDiogo,
          'weeklyXP': data['stats']?['gamification']?['weeklyXP'] ?? 0,
          'userStatus': data['stats']?['gamification']?['userStatus'],
          'isCurrentUser': memberId == user.uid,
        });
      }
    }
    
    // 5. Ordenar por weeklyXP (descending)
    memberDataList.sort((a, b) => 
        (b['weeklyXP'] as int).compareTo(a['weeklyXP'] as int));
    
    // 6. Atribuir ranks
    for (int i = 0; i < memberDataList.length; i++) {
      memberDataList[i]['rank'] = i + 1;
      
      // Determinar zona
      if (i < 10) {
        memberDataList[i]['zone'] = 'promotion';
      } else if (i < 25) {
        memberDataList[i]['zone'] = 'safe';
      } else {
        memberDataList[i]['zone'] = 'demotion';
      }
    }
    
    // 7. Calcular dias restantes
    final now = DateTime.now();
    final daysUntilSunday = DateTime.sunday - now.weekday;
    final nextSunday = daysUntilSunday == 0 
        ? now 
        : now.add(Duration(days: daysUntilSunday));
    daysRemaining.value = nextSunday.difference(now).inDays;
    
    // 8. Atualizar estados
    leaderboardData.value = memberDataList;
    currentUserRank.value = memberDataList
        .firstWhere((m) => m['isCurrentUser'] == true)['rank'];
    currentLeague.value = userDoc.data()?['stats']?['gamification']?['currentLeague'] ?? 'bronze';
    
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    errorMessage.value = 'Erro ao carregar ranking. Tente novamente.';
  } finally {
    isLoading.value = false;
  }
}
```

#### updateUserStatus(String? emoji)

Updates the user's emoji status on their leaderboard profile.

**Algorithm:**
1. Validate user is authenticated
2. Update `userStatus` field in Firestore
3. Update local leaderboard data
4. Refresh UI

**Pseudo-code:**
```dart
Future<void> updateUserStatus(String? emoji) async {
  isUpdatingStatus.value = true;
  errorMessage.value = '';
  
  try {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Não autenticado');
    
    // Atualizar no Firestore
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'stats.gamification.userStatus': emoji,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Atualizar localmente
    final userIndex = leaderboardData.indexWhere(
        (m) => m['isCurrentUser'] == true);
    if (userIndex != -1) {
      leaderboardData[userIndex]['userStatus'] = emoji;
      leaderboardData.refresh();
    }
    
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    errorMessage.value = 'Erro ao atualizar status. Tente novamente.';
  } finally {
    isUpdatingStatus.value = false;
  }
}
```

#### getUserZone(int rank)

Determines which zone a user is in based on their rank.

**Returns:** `'promotion'` | `'safe'` | `'demotion'`

**Algorithm:**
```dart
String getUserZone(int rank) {
  if (rank >= 1 && rank <= 10) return 'promotion';
  if (rank >= 11 && rank <= 25) return 'safe';
  if (rank >= 26 && rank <= 30) return 'demotion';
  return 'safe'; // fallback
}
```

#### getRewardForRank(int rank)

Calculates gem reward based on final rank position.

**Returns:** `int` (gems)

**Algorithm:**
```dart
int getRewardForRank(int rank) {
  if (rank == 1) return 50;
  if (rank == 2) return 30;
  if (rank == 3) return 20;
  if (rank >= 4 && rank <= 10) return 10;
  if (rank >= 11 && rank <= 30) return 5;
  return 0; // fallback
}
```

### Private Methods

#### _handleFirestoreError(FirebaseException e)

Converts Firestore error codes to user-friendly Portuguese messages.

**Implementation:** Use the same handler from TreasureController (already in steering rules).

```dart
String _handleFirestoreError(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
    case 'unavailable':
      return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
    case 'deadline-exceeded':
      return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    // ... (complete list from steering rules)
    default:
      return 'Erro ao carregar dados. Verifique sua conexão e tente novamente.';
  }
}
```

#### _calculateDaysRemaining()

Calculates days remaining until Sunday 23:59.

```dart
int _calculateDaysRemaining() {
  final now = DateTime.now();
  final daysUntilSunday = DateTime.sunday - now.weekday;
  final nextSunday = daysUntilSunday == 0 
      ? now 
      : now.add(Duration(days: daysUntilSunday));
  return nextSunday.difference(now).inDays;
}
```

---

## UI Component Integration

### LeaderboardPage

**Current State:** UI complete with mock data

**Integration Changes:**
1. Add `Get.find<LeaderboardController>()` in `initState()`
2. Replace mock data with `Obx(() => controller.leaderboardData)`
3. Connect `StatusModal.onStatusSelected` to `controller.updateUserStatus()`
4. Show loading indicator when `controller.isLoading.value == true`
5. Show error message when `controller.errorMessage.value.isNotEmpty`

**Updated Build Method:**
```dart
@override
Widget build(BuildContext context) {
  final controller = Get.find<LeaderboardController>();
  
  return Scaffold(
    backgroundColor: AppTheme.white,
    body: Obx(() {
      // Loading state
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      
      // Error state
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage.value),
              SizedBox(height: 16),
              AppButton(
                text: 'Tentar novamente',
                onPressed: () => controller.loadLeaderboardData(),
              ),
            ],
          ),
        );
      }
      
      // Success state
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          LeaderboardHeader(...),
          SliverToBoxAdapter(
            child: LeagueInfo(
              leagueName: _getLeagueName(controller.currentLeague.value),
              daysLeft: controller.daysRemaining.value,
              description: _getLeagueDescription(controller.currentLeague.value),
            ),
          ),
          _buildRankingList(controller),
        ],
      );
    }),
  );
}
```

### RankItem

**Current State:** Complete, no changes needed

**Usage:** Already supports all required props:
- `rank`: Position (1-30)
- `avatarAsset`: User avatar
- `name`: User name (or "Me")
- `xp`: Weekly XP
- `isCurrentUser`: Highlight in orange
- `statusEmoji`: Optional emoji
- `onTap`: Opens StatusModal for current user

### LeagueInfo

**Current State:** Complete, no changes needed

**Usage:** Displays league name, days remaining, and description.

**Helper Method for League Names:**
```dart
String _getLeagueName(String league) {
  switch (league) {
    case 'bronze': return 'Liga Bronze';
    case 'silver': return 'Liga Prata';
    case 'gold': return 'Liga Ouro';
    case 'platinum': return 'Liga Platina';
    case 'diamond': return 'Liga Diamante';
    default: return 'Liga';
  }
}
```

### StatusModal

**Current State:** UI complete, needs emoji options

**Integration Changes:**
1. Replace character assets with actual emoji options
2. Connect `onStatusSelected` callback to controller

**Emoji Options:**
```dart
static const _statusOptions = [
  '😊', '😎', '🔥', '💪', '🎯', '🎭', '🚀', '⭐', '💎', '👑',
  '🎉', '😴', '🤔', '😤', '🥳', '🤓', '😇', '🤩', '😈', '🥶'
];
```

---

## Business Logic

### Ranking Calculation Algorithm

**Input:** List of users with weeklyXP
**Output:** Sorted list with ranks 1-30

**Steps:**
1. Sort users by weeklyXP (descending)
2. Assign sequential ranks (1, 2, 3, ...)
3. Handle ties: Users with same XP get sequential ranks (no gaps)

**Example:**
```
User A: 100 XP → Rank 1
User B: 100 XP → Rank 2  (tie, but sequential)
User C: 95 XP  → Rank 3
User D: 90 XP  → Rank 4
```

**Implementation:**
```dart
void _assignRanks(List<Map<String, dynamic>> users) {
  // Sort by weeklyXP descending
  users.sort((a, b) => 
      (b['weeklyXP'] as int).compareTo(a['weeklyXP'] as int));
  
  // Assign sequential ranks
  for (int i = 0; i < users.length; i++) {
    users[i]['rank'] = i + 1;
  }
}
```

### Zone Determination

**Zones:**
- **Promotion Zone**: Ranks 1-10 → Advance to next league
- **Safe Zone**: Ranks 11-25 → Stay in current league
- **Demotion Zone**: Ranks 26-30 → Drop to previous league

**Edge Cases:**
- Diamond league: No promotion (already highest)
- Bronze league: No demotion (already lowest)

**Implementation:**
```dart
String _determineZone(int rank, String currentLeague) {
  // Promotion zone
  if (rank >= 1 && rank <= 10) {
    // Cannot promote from Diamond
    if (currentLeague == 'diamond') return 'safe';
    return 'promotion';
  }
  
  // Safe zone
  if (rank >= 11 && rank <= 25) {
    return 'safe';
  }
  
  // Demotion zone
  if (rank >= 26 && rank <= 30) {
    // Cannot demote from Bronze
    if (currentLeague == 'bronze') return 'safe';
    return 'demotion';
  }
  
  return 'safe'; // fallback
}
```

### Reward Calculation

**Rank-based Rewards:**
- 1st place: 50 gems
- 2nd place: 30 gems
- 3rd place: 20 gems
- 4th-10th: 10 gems each
- 11th-30th: 5 gems each

**Promotion Bonus:**
- +20 gems for advancing to next league

**Total Reward Formula:**
```
totalReward = rankReward + (wasPromoted ? 20 : 0)
```

**Implementation:**
```dart
int _calculateTotalReward(int rank, bool wasPromoted) {
  int rankReward = getRewardForRank(rank);
  int promotionBonus = wasPromoted ? 20 : 0;
  return rankReward + promotionBonus;
}
```

### Weekly Reset Process (Cloud Function)

**Trigger:** Every Monday at 00:00 (UTC or local timezone)

**Steps:**
1. **Process All Active Groups:**
   - Query all groups with `status: 'active'`
   - For each group:
     - Finalize rankings
     - Calculate rewards
     - Determine promotions/demotions
     - Archive to `weeklyResults`
     - Mark group as `status: 'completed'`

2. **Update User Stats:**
   - For each user in completed groups:
     - Award gems (rank reward + promotion bonus)
     - Update `currentLeague` (promote/demote/stay)
     - Reset `weeklyXP` to 0
     - Clear `leaderboardGroupId`
     - Update `lastWeeklyReset` timestamp

3. **Form New Groups:**
   - For each league (bronze, silver, gold, platinum, diamond):
     - Query all users with `currentLeague == league`
     - Shuffle users randomly
     - Create groups of exactly 30 users
     - If insufficient users, fill with placeholder bots
     - Create `leaderboardGroups` documents
     - Update each user's `leaderboardGroupId`

4. **Send Notifications:**
   - Notify users of league changes
   - Notify users of rewards received
   - Notify users of new competition week

**Pseudo-code:**
```typescript
export const weeklyLeaderboardReset = functions.pubsub
  .schedule('0 0 * * 1') // Every Monday at 00:00
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    
    // 1. Process active groups
    const activeGroups = await db.collection('leaderboardGroups')
      .where('status', '==', 'active')
      .get();
    
    for (const groupDoc of activeGroups.docs) {
      await processGroupEnd(groupDoc);
    }
    
    // 2. Form new groups for each league
    const leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    for (const league of leagues) {
      await formNewGroups(league);
    }
    
    // 3. Send notifications
    await sendWeeklyNotifications();
    
    return null;
  });
```

---

## Mock Data Structure

### File: lib/shared/mocks/leaderboard_mocks.dart

**Purpose:** Provide realistic test data for UI development

**Structure:**
```dart
class LeaderboardMocks {
  static final List<Map<String, dynamic>> mockLeaderboardData = [
    {
      'rank': 1,
      'userId': 'user1',
      'name': 'Sami',
      'avatar': AppAssets.charMara,
      'weeklyXP': 520,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 2,
      'userId': 'currentUser',
      'name': 'Me',
      'avatar': AppAssets.charFrancilene,
      'weeklyXP': 495,
      'userStatus': '🎭',
      'isCurrentUser': true,
      'zone': 'promotion',
    },
    {
      'rank': 3,
      'userId': 'user3',
      'name': 'Haruto',
      'avatar': AppAssets.charGlauciane,
      'weeklyXP': 480,
      'userStatus': '😊',
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 4,
      'userId': 'user4',
      'name': 'Hakan',
      'avatar': AppAssets.charLindoedson,
      'weeklyXP': 465,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 5,
      'userId': 'user5',
      'name': 'Mayumi',
      'avatar': AppAssets.charRenner,
      'weeklyXP': 450,
      'userStatus': '😊',
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 6,
      'userId': 'user6',
      'name': 'Yuki',
      'avatar': AppAssets.charDafny,
      'weeklyXP': 420,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 7,
      'userId': 'user7',
      'name': 'Carlos',
      'avatar': AppAssets.charDiogo,
      'weeklyXP': 400,
      'userStatus': '🔥',
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 8,
      'userId': 'user8',
      'name': 'Luna',
      'avatar': AppAssets.charMara,
      'weeklyXP': 380,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 9,
      'userId': 'user9',
      'name': 'Akira',
      'avatar': AppAssets.charGlauciane,
      'weeklyXP': 360,
      'userStatus': '😎',
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 10,
      'userId': 'user10',
      'name': 'Sofia',
      'avatar': AppAssets.charLindoedson,
      'weeklyXP': 340,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'promotion',
    },
  ];
  
  static const String mockCurrentLeague = 'silver';
  static const int mockDaysRemaining = 6;
  static const int mockCurrentUserRank = 2;
}
```

---

## Error Handling

### Error Categories

1. **Authentication Errors**
   - User not logged in
   - Session expired
   - Invalid credentials

2. **Firestore Errors**
   - Permission denied
   - Network unavailable
   - Timeout
   - Document not found

3. **Data Validation Errors**
   - Missing leaderboard group
   - Invalid rank data
   - Corrupted user stats

4. **Business Logic Errors**
   - Insufficient users for group
   - Invalid league transition
   - Reward calculation failure

### Error Handling Strategy

**Principle:** Never crash the app. Always show user-friendly messages in Portuguese.

**Implementation:**
```dart
try {
  // Operation
} on FirebaseAuthException catch (e) {
  errorMessage.value = _handleAuthError(e);
} on FirebaseException catch (e) {
  errorMessage.value = _handleFirestoreError(e);
} on TimeoutException {
  errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
} catch (e) {
  errorMessage.value = 'Erro inesperado. Tente novamente.';
  // Log error for debugging
  debugPrint('Leaderboard error: $e');
}
```

### Retry Logic

For transient errors (network, timeout), implement exponential backoff:

```dart
Future<T> _retryOperation<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  int retryCount = 0;
  Duration delay = initialDelay;
  
  while (true) {
    try {
      return await operation();
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) rethrow;
      
      await Future.delayed(delay);
      delay *= 2; // Exponential backoff
    }
  }
}
```

---

## Testing Strategy

### Unit Tests

**Location:** `test/unit/features/inners/leaderboard/controllers/`

**Test Cases:**
1. **Ranking Calculation**
   - Sort users by weeklyXP correctly
   - Assign sequential ranks
   - Handle ties properly

2. **Zone Determination**
   - Correctly identify promotion zone (1-10)
   - Correctly identify safe zone (11-25)
   - Correctly identify demotion zone (26-30)
   - Handle edge cases (Diamond promotion, Bronze demotion)

3. **Reward Calculation**
   - Calculate rank rewards correctly
   - Add promotion bonus when applicable
   - Handle all rank positions (1-30)

4. **Days Remaining Calculation**
   - Calculate days until Sunday correctly
   - Handle edge case when today is Sunday

5. **Error Handling**
   - Convert Firestore errors to Portuguese messages
   - Handle authentication errors
   - Handle timeout errors

**Example Test:**
```dart
test('getUserZone returns promotion for ranks 1-10', () {
  final controller = LeaderboardController();
  
  for (int rank = 1; rank <= 10; rank++) {
    expect(controller.getUserZone(rank), 'promotion');
  }
});
```

### Property-Based Tests

**Location:** `test/property/features/inners/leaderboard/controllers/`

**Purpose:** Verify universal properties that must hold for ALL inputs

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, the following properties have been identified as testable through property-based testing. These properties represent universal truths that must hold for all valid inputs.

### Property Reflection

Before listing the final properties, I performed a reflection to eliminate redundancy:

**Redundancies Identified:**
- Requirements 1.5, 7.2, and 9.5 all test the same invariant (groups have exactly 30 users) → Combined into Property 1
- Requirements 2.7 and 7.3 both test league consistency in groups → Combined into Property 2
- Requirements 3.5 and 9.6 both test data completeness → Combined into Property 6
- Requirements 4.1-4.5 all test reward calculation → Combined into Property 9

**Final Property Set (after removing redundancies):**

### Property 1: Group Size Invariant

*For any* leaderboard group, the number of members SHALL always equal exactly 30.

**Validates: Requirements 1.5, 7.2, 7.4, 9.5**

**Rationale:** This is a fundamental invariant of the system. Every competition group must have exactly 30 users to ensure fair competition. When there are insufficient real users, the system fills remaining slots with placeholders.

**Test Implementation:**
```dart
test('Property 1: All leaderboard groups have exactly 30 members', () {
  fc.assert(fc.property(
    fc.record({
      'realUsers': fc.integer(min: 0, max: 100),
      'league': fc.constantFrom('bronze', 'silver', 'gold', 'platinum', 'diamond'),
    }),
    (data) {
      final groups = formLeaderboardGroups(
        userCount: data['realUsers'],
        league: data['league'],
      );
      
      for (final group in groups) {
        expect(group.memberIds.length, equals(30));
      }
    },
  ));
});
```

### Property 2: League Consistency in Groups

*For any* leaderboard group, all members SHALL have the same league value.

**Validates: Requirements 2.7, 7.3**

**Rationale:** Users should only compete against others in the same league tier. Mixing leagues would create unfair competition.

**Test Implementation:**
```dart
test('Property 2: All members in a group have the same league', () {
  fc.assert(fc.property(
    fc.array(fc.record({
      'userId': fc.string(),
      'league': fc.constantFrom('bronze', 'silver', 'gold', 'platinum', 'diamond'),
      'weeklyXP': fc.integer(min: 0, max: 1000),
    }), minLength: 30, maxLength: 30),
    (users) {
      final group = createLeaderboardGroup(users);
      final firstLeague = users[0]['league'];
      
      for (final user in users) {
        expect(user['league'], equals(firstLeague));
      }
    },
  ));
});
```

### Property 3: Ranking Sort Order

*For any* list of users, after ranking, each user's weeklyXP SHALL be greater than or equal to the next user's weeklyXP.

**Validates: Requirements 3.1**

**Rationale:** Rankings must be sorted in descending order by XP. This ensures the highest XP earner is rank 1.

**Test Implementation:**
```dart
test('Property 3: Rankings are sorted by weeklyXP descending', () {
  fc.assert(fc.property(
    fc.array(fc.record({
      'userId': fc.string(),
      'weeklyXP': fc.integer(min: 0, max: 10000),
    }), minLength: 30, maxLength: 30),
    (users) {
      final ranked = calculateRankings(users);
      
      for (int i = 0; i < ranked.length - 1; i++) {
        expect(
          ranked[i]['weeklyXP'],
          greaterThanOrEqualTo(ranked[i + 1]['weeklyXP']),
        );
      }
    },
  ));
});
```

### Property 4: Sequential Ranks Without Gaps

*For any* ranked list of 30 users, the ranks SHALL be sequential integers from 1 to 30 with no gaps, regardless of XP ties.

**Validates: Requirements 3.2, 3.3**

**Rationale:** Even when users have identical XP, they receive sequential ranks. This ensures all positions 1-30 are filled.

**Test Implementation:**
```dart
test('Property 4: Ranks are sequential 1-30 with no gaps', () {
  fc.assert(fc.property(
    fc.array(fc.record({
      'userId': fc.string(),
      'weeklyXP': fc.integer(min: 0, max: 1000),
    }), minLength: 30, maxLength: 30),
    (users) {
      final ranked = calculateRankings(users);
      final ranks = ranked.map((u) => u['rank'] as int).toList()..sort();
      
      expect(ranks, equals(List.generate(30, (i) => i + 1)));
    },
  ));
});
```

### Property 5: Zone Determination Correctness

*For any* rank position, the zone SHALL be 'promotion' for ranks 1-10, 'safe' for ranks 11-25, and 'demotion' for ranks 26-30.

**Validates: Requirements 5.4**

**Rationale:** Zone determination is critical for league progression. Each rank must map to the correct zone.

**Test Implementation:**
```dart
test('Property 5: Zone determination is correct for all ranks', () {
  fc.assert(fc.property(
    fc.integer(min: 1, max: 30),
    (rank) {
      final zone = getUserZone(rank);
      
      if (rank >= 1 && rank <= 10) {
        expect(zone, equals('promotion'));
      } else if (rank >= 11 && rank <= 25) {
        expect(zone, equals('safe'));
      } else if (rank >= 26 && rank <= 30) {
        expect(zone, equals('demotion'));
      }
    },
  ));
});
```

### Property 6: Data Completeness

*For any* user in the leaderboard data, all required fields (userId, name, avatar, weeklyXP, rank, zone) SHALL be present and non-null.

**Validates: Requirements 3.5, 9.6**

**Rationale:** The UI depends on these fields being present. Missing data would cause rendering errors.

**Test Implementation:**
```dart
test('Property 6: All leaderboard entries have required fields', () {
  fc.assert(fc.property(
    fc.array(fc.record({
      'userId': fc.string(),
      'name': fc.string(),
      'avatar': fc.string(),
      'weeklyXP': fc.integer(min: 0, max: 10000),
    }), minLength: 30, maxLength: 30),
    (users) {
      final leaderboardData = processLeaderboardData(users);
      
      for (final entry in leaderboardData) {
        expect(entry.containsKey('userId'), isTrue);
        expect(entry.containsKey('name'), isTrue);
        expect(entry.containsKey('avatar'), isTrue);
        expect(entry.containsKey('weeklyXP'), isTrue);
        expect(entry.containsKey('rank'), isTrue);
        expect(entry.containsKey('zone'), isTrue);
        
        expect(entry['userId'], isNotNull);
        expect(entry['name'], isNotNull);
        expect(entry['avatar'], isNotNull);
        expect(entry['weeklyXP'], isNotNull);
        expect(entry['rank'], isNotNull);
        expect(entry['zone'], isNotNull);
      }
    },
  ));
});
```

### Property 7: Days Remaining Calculation

*For any* date during the week (Monday-Saturday), the days remaining until Sunday SHALL be calculated correctly.

**Validates: Requirements 1.3**

**Rationale:** Users need accurate information about when the competition ends. Incorrect calculation would mislead users.

**Test Implementation:**
```dart
test('Property 7: Days remaining calculation is correct', () {
  fc.assert(fc.property(
    fc.date(min: DateTime(2024, 1, 1), max: DateTime(2025, 12, 31)),
    (date) {
      final daysRemaining = calculateDaysRemaining(date);
      final daysUntilSunday = DateTime.sunday - date.weekday;
      final expectedDays = daysUntilSunday == 0 ? 0 : daysUntilSunday;
      
      expect(daysRemaining, equals(expectedDays));
    },
  ));
});
```

### Property 8: League Progression Logic

*For any* user with a final rank, the new league SHALL be determined correctly: promote if rank 1-10 (unless Diamond), stay if rank 11-25, demote if rank 26-30 (unless Bronze).

**Validates: Requirements 2.2, 2.3, 2.4**

**Rationale:** League progression is the core mechanic of the ranking system. Incorrect progression would break the competitive ladder.

**Test Implementation:**
```dart
test('Property 8: League progression follows correct rules', () {
  fc.assert(fc.property(
    fc.record({
      'rank': fc.integer(min: 1, max: 30),
      'currentLeague': fc.constantFrom('bronze', 'silver', 'gold', 'platinum', 'diamond'),
    }),
    (data) {
      final newLeague = calculateNewLeague(
        rank: data['rank'],
        currentLeague: data['currentLeague'],
      );
      
      if (data['rank'] >= 1 && data['rank'] <= 10) {
        // Promotion zone
        if (data['currentLeague'] == 'diamond') {
          expect(newLeague, equals('diamond')); // Cannot promote from Diamond
        } else {
          expect(newLeague, equals(getNextLeague(data['currentLeague'])));
        }
      } else if (data['rank'] >= 11 && data['rank'] <= 25) {
        // Safe zone
        expect(newLeague, equals(data['currentLeague']));
      } else if (data['rank'] >= 26 && data['rank'] <= 30) {
        // Demotion zone
        if (data['currentLeague'] == 'bronze') {
          expect(newLeague, equals('bronze')); // Cannot demote from Bronze
        } else {
          expect(newLeague, equals(getPreviousLeague(data['currentLeague'])));
        }
      }
    },
  ));
});
```

### Property 9: Reward Calculation Correctness

*For any* rank from 1 to 30, the gem reward SHALL match the specified reward table: 50 for rank 1, 30 for rank 2, 20 for rank 3, 10 for ranks 4-10, 5 for ranks 11-30.

**Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**

**Rationale:** Rewards must be consistent and predictable. Users expect specific rewards for their final rank.

**Test Implementation:**
```dart
test('Property 9: Reward calculation matches reward table', () {
  fc.assert(fc.property(
    fc.integer(min: 1, max: 30),
    (rank) {
      final reward = getRewardForRank(rank);
      
      if (rank == 1) {
        expect(reward, equals(50));
      } else if (rank == 2) {
        expect(reward, equals(30));
      } else if (rank == 3) {
        expect(reward, equals(20));
      } else if (rank >= 4 && rank <= 10) {
        expect(reward, equals(10));
      } else if (rank >= 11 && rank <= 30) {
        expect(reward, equals(5));
      }
    },
  ));
});
```

### Property 10: Promotion Bonus Application

*For any* user who is promoted to a higher league, the total reward SHALL equal the rank reward plus 20 gems.

**Validates: Requirements 4.6**

**Rationale:** Promotion bonus incentivizes climbing the competitive ladder. The bonus must be applied consistently.

**Test Implementation:**
```dart
test('Property 10: Promotion bonus is added correctly', () {
  fc.assert(fc.property(
    fc.record({
      'rank': fc.integer(min: 1, max: 30),
      'wasPromoted': fc.boolean(),
    }),
    (data) {
      final rankReward = getRewardForRank(data['rank']);
      final totalReward = calculateTotalReward(
        rank: data['rank'],
        wasPromoted: data['wasPromoted'],
      );
      
      if (data['wasPromoted']) {
        expect(totalReward, equals(rankReward + 20));
      } else {
        expect(totalReward, equals(rankReward));
      }
    },
  ));
});
```

### Property 11: XP Accumulation

*For any* user and any positive XP amount, adding XP to weeklyXP SHALL increase the total by exactly that amount.

**Validates: Requirements 1.2**

**Rationale:** XP accumulation must be accurate. Any error would corrupt the ranking system.

**Test Implementation:**
```dart
test('Property 11: XP accumulation is accurate', () {
  fc.assert(fc.property(
    fc.record({
      'initialXP': fc.integer(min: 0, max: 10000),
      'addedXP': fc.integer(min: 1, max: 1000),
    }),
    (data) {
      final user = {'weeklyXP': data['initialXP']};
      addWeeklyXP(user, data['addedXP']);
      
      expect(user['weeklyXP'], equals(data['initialXP'] + data['addedXP']));
    },
  ));
});
```

### Property 12: Weekly Reset Completeness

*For any* list of users, after a weekly reset, all users SHALL have weeklyXP equal to 0.

**Validates: Requirements 1.1, 11.4**

**Rationale:** Weekly reset must clear all XP to start fresh competition. Incomplete reset would carry over advantages.

**Test Implementation:**
```dart
test('Property 12: Weekly reset clears all weeklyXP', () {
  fc.assert(fc.property(
    fc.array(fc.record({
      'userId': fc.string(),
      'weeklyXP': fc.integer(min: 0, max: 10000),
    }), minLength: 1, maxLength: 100),
    (users) {
      performWeeklyReset(users);
      
      for (final user in users) {
        expect(user['weeklyXP'], equals(0));
      }
    },
  ));
});
```

### Property 13: Rank Recalculation After XP Change

*For any* leaderboard state, when any user's weeklyXP changes, recalculating rankings SHALL produce a correctly sorted list with sequential ranks 1-30.

**Validates: Requirements 5.2**

**Rationale:** Rankings must update correctly when XP changes. This ensures real-time leaderboard accuracy.

**Test Implementation:**
```dart
test('Property 13: Rank recalculation maintains invariants', () {
  fc.assert(fc.property(
    fc.record({
      'users': fc.array(fc.record({
        'userId': fc.string(),
        'weeklyXP': fc.integer(min: 0, max: 1000),
      }), minLength: 30, maxLength: 30),
      'changedUserIndex': fc.integer(min: 0, max: 29),
      'xpChange': fc.integer(min: -500, max: 500),
    }),
    (data) {
      final users = List<Map<String, dynamic>>.from(data['users']);
      users[data['changedUserIndex']]['weeklyXP'] = 
          max(0, users[data['changedUserIndex']]['weeklyXP'] + data['xpChange']);
      
      final ranked = calculateRankings(users);
      
      // Check sort order
      for (int i = 0; i < ranked.length - 1; i++) {
        expect(
          ranked[i]['weeklyXP'],
          greaterThanOrEqualTo(ranked[i + 1]['weeklyXP']),
        );
      }
      
      // Check sequential ranks
      final ranks = ranked.map((u) => u['rank'] as int).toList()..sort();
      expect(ranks, equals(List.generate(30, (i) => i + 1)));
    },
  ));
});
```

### Property 14: Error Message Localization

*For any* Firestore error code, the error handler SHALL return a non-empty Portuguese message.

**Validates: Requirements 10.2**

**Rationale:** All error messages must be user-friendly and in Portuguese. Technical error codes confuse users.

**Test Implementation:**
```dart
test('Property 14: All Firestore errors have Portuguese messages', () {
  final errorCodes = [
    'permission-denied',
    'unavailable',
    'deadline-exceeded',
    'resource-exhausted',
    'failed-precondition',
    'aborted',
    'out-of-range',
    'unimplemented',
    'internal',
    'unauthenticated',
    'not-found',
    'already-exists',
    'cancelled',
    'data-loss',
    'invalid-argument',
  ];
  
  for (final code in errorCodes) {
    final message = handleFirestoreError(FirebaseException(
      plugin: 'firestore',
      code: code,
    ));
    
    expect(message, isNotEmpty);
    expect(message, isNot(contains(code))); // Should not expose technical codes
  }
});
```

### Property 15: User Status Persistence

*For any* user, when userStatus is set to a non-null emoji, it SHALL appear in the leaderboard data; when set to null, it SHALL not appear.

**Validates: Requirements 6.4**

**Rationale:** User status is optional. The system must correctly handle both presence and absence of status.

**Test Implementation:**
```dart
test('Property 15: User status presence matches set value', () {
  fc.assert(fc.property(
    fc.record({
      'userId': fc.string(),
      'userStatus': fc.option(fc.constantFrom('😊', '😎', '🔥', '💪', '🎯')),
    }),
    (data) {
      final user = {
        'userId': data['userId'],
        'userStatus': data['userStatus'],
      };
      
      final leaderboardEntry = createLeaderboardEntry(user);
      
      if (data['userStatus'] != null) {
        expect(leaderboardEntry.containsKey('userStatus'), isTrue);
        expect(leaderboardEntry['userStatus'], equals(data['userStatus']));
      } else {
        // When null, field may be absent or explicitly null
        if (leaderboardEntry.containsKey('userStatus')) {
          expect(leaderboardEntry['userStatus'], isNull);
        }
      }
    },
  ));
});
```

---

## Implementation Notes

### Performance Considerations

1. **Batch Reads**: When loading leaderboard data, fetch all 30 users in parallel using `Future.wait()` instead of sequential reads.

2. **Caching**: Consider caching leaderboard data for 5-10 seconds to reduce Firestore reads during rapid UI updates.

3. **Indexes**: Ensure Firestore indexes exist for:
   - `currentLeague` (for group formation)
   - `weeklyXP` (for ranking within group)
   - `leaderboardGroupId` (for finding group members)

4. **Real-time Listeners**: Use sparingly. Only listen to current user's own data, not entire leaderboard.

### Security Rules

Firestore security rules must enforce:

```javascript
// Users can read their own leaderboard group
match /leaderboardGroups/{groupId} {
  allow read: if request.auth != null && 
    request.auth.uid in resource.data.memberIds;
}

// Users can read other users' public data
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;
}

// Only Cloud Functions can write to leaderboardGroups
match /leaderboardGroups/{groupId} {
  allow write: if false; // Only server-side
}

// Only Cloud Functions can write to weeklyResults
match /weeklyResults/{weekId} {
  allow write: if false; // Only server-side
}
```

### Scalability Considerations

1. **Group Formation**: With millions of users, group formation must be done in batches. Process one league at a time.

2. **Sharding**: For very large leagues (e.g., Bronze with millions of users), consider sharding into multiple sub-leagues.

3. **Archival**: Move old `weeklyResults` to cold storage after 3 months to reduce query costs.

4. **Rate Limiting**: Implement rate limiting on status updates to prevent abuse.

### Edge Cases to Handle

1. **User Deleted Mid-Week**: If a user deletes their account, their slot becomes a placeholder.

2. **Timezone Issues**: All timestamps must use consistent timezone (UTC or America/Sao_Paulo).

3. **Concurrent Updates**: Use Firestore transactions for critical operations (reward distribution, league changes).

4. **First Week**: New users start in Bronze league with no group until first Monday reset.

5. **Insufficient Users**: If a league has < 30 users, fill with bot placeholders that have 0 XP.

---

## Summary

This design document provides a complete specification for implementing the ranking/leaderboard system in Pippo. The system follows GetX patterns, integrates with existing gamification infrastructure, and uses Firestore for scalable data storage.

**Key Design Decisions:**
- No models/repositories - all logic in LeaderboardController
- Firestore collections for groups and historical data
- Cloud Functions for weekly reset automation
- Property-based testing for comprehensive correctness verification
- Portuguese error messages for user-friendly experience

**Next Steps:**
1. Review and approve this design document
2. Create tasks.md with implementation plan
3. Implement LeaderboardController with unit tests
4. Implement property-based tests
5. Create Cloud Function for weekly reset
6. Integrate with existing UI components
7. Deploy and monitor

