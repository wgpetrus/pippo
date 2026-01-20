# Design Document - Gamification System

## Overview

The Gamification System is implemented as a centralized controller (`GamificationController`) that manages four interconnected subsystems: Streak, Energy, XP/Levels, and Gems. The system follows GetX patterns with reactive state management, uses Firestore for persistence, and ensures all operations maintain data consistency through transactional updates.

### Key Design Decisions

1. **Single Controller Architecture**: All gamification logic is centralized in `GamificationController` to ensure consistent state management and simplify cross-system interactions (e.g., gems affecting energy, XP affecting levels).

2. **Timezone-Aware Date Handling**: All date calculations use the user's device timezone (never UTC) to ensure streak tracking and XP resets align with the user's local day boundaries.

3. **Transactional Updates**: Critical operations (lesson completion, purchases) use Firestore transactions to prevent race conditions and ensure atomic updates across multiple fields.

4. **Lazy Energy Regeneration**: Energy regenerates on-demand when accessed rather than through background timers, reducing battery usage and ensuring accurate calculations.

5. **Immutable Total XP**: The `totalXp` field never decreases, providing a permanent record of user achievement while `weeklyXp` and `todayXp` reset on schedule.

## Architecture

### Component Structure

```
features/inners/gamification/
└── controllers/
    └── gamification_controller.dart
```

**Note**: 
- This feature has NO binding because it doesn't have its own route. The controller is instantiated by `HomeBinding` since gamification stats are displayed in the home AppBar.
- This feature has NO widgets folder because all UI widgets already exist in `features/inners/home/widgets/` (home_appbar.dart, streak_modal.dart, energy_modal.dart, gems_modal.dart)

### Controller Responsibilities

**GamificationController**:
- Manages reactive state (.obs variables)
- Handles UI interactions
- Performs Firestore operations directly
- Implements all business logic calculations
- Handles timezone conversions
- Manages transactions
- Implements retry logic
- Validates user actions
- Manages loading states



## Components and Interfaces

### GamificationController

```dart
class GamificationController extends GetxController {
  // Dependencies
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable States (obrigatórios)
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Gamification Stats (reactive)
  final currentStreak = 0.obs;
  final longestStreak = 0.obs;
  final currentEnergy = 5.obs;
  final gems = 0.obs;
  final totalXp = 0.obs;
  final weeklyXp = 0.obs;
  final todayXp = 0.obs;
  final level = 1.obs;
  final xpToNextLevel = 100.obs;
  
  // Internal state
  String _lastStreakDate = '';
  bool _streakFreezeAvailable = false;
  DateTime _lastEnergyRegenAt = DateTime.now();
  DateTime? _unlimitedEnergyUntil;
  DateTime? _xpBoosterUntil;
  DateTime? _gemMultiplierUntil;
  String _lastWeeklyResetDate = '';
  String _lastDailyResetDate = '';
  
  // Computed Properties
  bool get hasUnlimitedEnergy => 
    _unlimitedEnergyUntil != null && DateTime.now().isBefore(_unlimitedEnergyUntil!);
  bool get hasXpBooster => 
    _xpBoosterUntil != null && DateTime.now().isBefore(_xpBoosterUntil!);
  bool get hasGemMultiplier => 
    _gemMultiplierUntil != null && DateTime.now().isBefore(_gemMultiplierUntil!);
  
  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadStats();
  }
  
  // Public Methods
  Future<void> loadStats();
  Future<void> onLessonStart();
  Future<void> onLessonComplete(int baseXp, int baseGems, bool isPerfect);
  Future<void> purchaseEnergyRefill();
  Future<void> purchaseStreakFreeze();
  Future<void> purchaseXpBooster();
  Future<void> purchaseGemMultiplier();
  bool canStartLesson();
  String getNextEnergyTime();
  
  // Private Methods (business logic)
  void _calculateEnergyRegeneration();
  void _consumeEnergy();
  void _addXp(int xp);
  void _addGems(int gemsAmount);
  void _updateStreak();
  void _checkLevelUp();
  bool _isFirstLessonOfDay();
  void _checkXpResets();
  String _formatDateForStreak(DateTime date);
  bool _isSameDay(DateTime date1, DateTime date2);
}
```



## Data Models

### Firestore Schema

All gamification data is stored directly in Firestore without intermediate model classes. The controller reads/writes directly to Firestore using Map<String, dynamic>.

```
users/{userId}/stats/gamification
{
  "streak": {
    "currentStreak": 0,
    "longestStreak": 0,
    "lastStreakDate": "",
    "streakFreezeAvailable": false,
    "streakFreezeUsedToday": false,
    "milestonesReached": []
  },
  "energy": {
    "currentEnergy": 5,
    "maxEnergy": 5,
    "lastEnergyRegenAt": Timestamp,
    "unlimitedEnergyUntil": Timestamp | null
  },
  "xp": {
    "totalXp": 0,
    "weeklyXp": 0,
    "todayXp": 0,
    "level": 1,
    "xpToNextLevel": 100,
    "xpBoosterUntil": Timestamp | null,
    "lastWeeklyResetDate": "",
    "lastDailyResetDate": ""
  },
  "gems": {
    "gems": 0,
    "totalGemsEarned": 0,
    "totalGemsSpent": 0,
    "gemMultiplierUntil": Timestamp | null
  },
  "lastUpdated": Timestamp
}
```

### Data Conversion Helpers

Simple helper methods in the controller for Firestore timestamp conversion:

```dart
// No Firebase Date Helper - usar conversão direta
DateTime _timestampToDateTime(Timestamp? timestamp) {
  return timestamp?.toDate() ?? DateTime.now();
}

Timestamp _dateTimeToTimestamp(DateTime date) {
  return Timestamp.fromDate(date);
}
```



## Key Algorithms

### Energy Regeneration Algorithm

```dart
// Método privado no GamificationController
void _calculateEnergyRegeneration() {
  // Skip if unlimited energy is active
  if (hasUnlimitedEnergy) return;
  
  // Skip if already at max
  if (currentEnergy.value >= 5) return;
  
  final now = DateTime.now();
  final minutesPassed = now.difference(_lastEnergyRegenAt).inMinutes;
  
  // Calculate energy to add: 1 energy per 30 minutes
  final energiesToAdd = minutesPassed ~/ 30;
  
  if (energiesToAdd == 0) return;
  
  // Calculate new energy (capped at max)
  final newEnergy = min(currentEnergy.value + energiesToAdd, 5);
  
  // Update last regen time by the amount of energy actually regenerated
  final minutesConsumed = (newEnergy - currentEnergy.value) * 30;
  _lastEnergyRegenAt = _lastEnergyRegenAt.add(Duration(minutes: minutesConsumed));
  
  currentEnergy.value = newEnergy;
}
```

### Streak Update Algorithm

```dart
// Método privado no GamificationController
void _updateStreak() {
  final now = DateTime.now();
  final today = _formatDateForStreak(now);
  
  // First lesson ever
  if (_lastStreakDate.isEmpty) {
    currentStreak.value = 1;
    longestStreak.value = 1;
    _lastStreakDate = today;
    return;
  }
  
  // Already completed today
  if (_lastStreakDate == today) return;
  
  final lastDateTime = DateTime.parse(_lastStreakDate);
  final daysDifference = now.difference(lastDateTime).inDays;
  
  // Consecutive day
  if (daysDifference == 1) {
    currentStreak.value++;
    longestStreak.value = max(currentStreak.value, longestStreak.value);
    _lastStreakDate = today;
    return;
  }
  
  // Missed a day - check for freeze
  if (daysDifference == 2 && _streakFreezeAvailable) {
    _lastStreakDate = today;
    _streakFreezeAvailable = false;
    return;
  }
  
  // Streak broken - reset
  currentStreak.value = 1;
  _lastStreakDate = today;
}
```

### Level Up Algorithm

```dart
// Método privado no GamificationController
void _checkLevelUp() {
  // Process all level ups that result from current XP
  while (totalXp.value >= xpToNextLevel.value) {
    level.value++;
    xpToNextLevel.value = level.value * 100;
    
    // Award 10 gems for level up
    _addGems(10);
  }
}
```

### XP Addition Algorithm

```dart
// Método privado no GamificationController
void _addXp(int baseXp) {
  // Apply booster if active
  final xpToAdd = hasXpBooster ? baseXp * 2 : baseXp;
  
  // Check for resets before adding
  _checkXpResets();
  
  // Add XP to all three counters
  totalXp.value += xpToAdd;
  weeklyXp.value += xpToAdd;
  todayXp.value += xpToAdd;
}
```

### Lesson Completion Flow

```dart
// Método público no GamificationController
Future<void> onLessonComplete(int baseXp, int baseGems, bool isPerfect) async {
  isLoading.value = true;
  errorMessage.value = '';
  
  try {
    final userId = Get.find<AuthController>().userId;
    
    // 1. Calculate rewards
    var totalXp = baseXp;
    var totalGems = baseGems;
    
    if (isPerfect) totalXp += 5;
    if (_isFirstLessonOfDay()) totalXp += 5;
    
    // 2. Add XP (with booster if active)
    _addXp(totalXp);
    
    // 3. Add gems (with multiplier if active)
    _addGems(totalGems);
    
    // 4. Update streak (if first lesson of day)
    if (_isFirstLessonOfDay()) {
      _updateStreak();
      _checkStreakMilestones();
    }
    
    // 5. Check level up
    _checkLevelUp();
    
    // 6. Save to Firestore
    await _saveStats(userId);
    
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } finally {
    isLoading.value = false;
  }
}
```



## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property Reflection

After analyzing all acceptance criteria, several redundancies were identified and consolidated:

- Properties 1.3 and 6.5 both test that certain values never decrease (longestStreak, totalXp) - consolidated into invariant properties
- Properties 3.2 and 3.3 both relate to energy consumption - combined into single comprehensive property
- Properties 5.6, 7.5, and 8.8 all test atomic dual/triple updates - consolidated into transaction properties
- Properties 6.2 and 6.4 both relate to level up mechanics - combined into single level up property
- Properties 10.1 and 10.2 test identical logic for different power-ups - combined into single power-up activation property
- Properties 10.5 and 10.6 test identical idempotence for different power-ups - combined into single idempotence property

### Core Invariants

**Property 1: Streak Invariant**
*For any* gamification state, the longestStreak value should always be greater than or equal to the currentStreak value.
**Validates: Requirements 1.3**

**Property 2: Total XP Never Decreases**
*For any* operation on gamification stats, the totalXp after the operation should be greater than or equal to the totalXp before the operation.
**Validates: Requirements 6.5, 7.3**

**Property 3: Energy Bounds**
*For any* gamification state, the currentEnergy should always be between 0 and maxEnergy (inclusive), and maxEnergy should always equal 5.
**Validates: Requirements 3.1, 15.1, 15.2**

**Property 4: Non-Negative Resources**
*For any* gamification state, gems, totalXp, weeklyXp, todayXp, currentStreak, and currentEnergy should all be non-negative values.
**Validates: Requirements 15.3, 15.4**

### Streak System Properties

**Property 5: First Lesson Increments Streak**
*For any* user completing their first lesson of a day, the currentStreak should increment by exactly 1 and lastStreakDate should update to today's date in "YYYY-MM-DD" format.
**Validates: Requirements 1.1, 1.4**

**Property 6: Missed Day Resets Streak**
*For any* streak state where the last lesson was more than 1 day ago and no streak freeze is available, the currentStreak should reset to 1 when the next lesson is completed.
**Validates: Requirements 1.2**

**Property 7: Multiple Lessons Same Day**
*For any* user completing N lessons in the same day (N > 1), the streak should increment only once regardless of N.
**Validates: Requirements 1.6**

**Property 8: Streak Freeze Consumption**
*For any* streak state with streakFreezeAvailable=true, when a day is missed, the streak should be maintained, streakFreezeAvailable should become false, and streakFreezeUsedToday should become true.
**Validates: Requirements 1.7, 2.2**

**Property 9: Streak Freeze Purchase Idempotence**
*For any* user with streakFreezeAvailable=true, attempting to purchase another freeze should not deduct gems or change state.
**Validates: Requirements 2.4**

**Property 10: Daily Freeze Reset**
*For any* streak state with streakFreezeUsedToday=true, when a new day begins, streakFreezeUsedToday should reset to false.
**Validates: Requirements 2.3**

### Energy System Properties

**Property 11: Energy Regeneration Formula**
*For any* time delta in minutes, the energy regenerated should equal minutesPassed ~/ 30, capped at (maxEnergy - currentEnergy).
**Validates: Requirements 3.4, 3.5**

**Property 12: Energy Consumption and Timestamp Update**
*For any* lesson start with currentEnergy > 0, the energy should decrease by 1 and lastEnergyRegenAt should update to the current timestamp.
**Validates: Requirements 3.2, 3.3**

**Property 13: Energy Regeneration Stops at Max**
*For any* energy state at maxEnergy, time passing should not increase energy beyond maxEnergy.
**Validates: Requirements 3.6**

**Property 14: Zero Energy Prevents Lesson Start**
*For any* user with currentEnergy = 0 and no unlimited energy active, canStartLesson() should return false.
**Validates: Requirements 3.7**

**Property 15: Energy Refill Transaction**
*For any* user with gems >= 100, purchasing energy refill should atomically deduct 100 gems and add 5 energy (capped at maxEnergy).
**Validates: Requirements 4.1, 4.2, 9.1**

**Property 16: Unlimited Energy Bypass**
*For any* user with active unlimited energy (current time < unlimitedEnergyUntil), starting a lesson should not consume energy.
**Validates: Requirements 4.3**

### XP and Level System Properties

**Property 17: Level Formula Correctness**
*For any* level value L, the XP required for the next level should equal L × 100.
**Validates: Requirements 6.1**

**Property 18: Level Up Trigger and Reward**
*For any* XP addition that causes totalXp >= xpToNextLevel, the level should increment by 1, xpToNextLevel should recalculate using the new level, and gems should increase by 10.
**Validates: Requirements 6.2, 6.3, 6.4**

**Property 19: Multiple Level Ups**
*For any* XP addition large enough to cross multiple level thresholds, all level ups should be processed sequentially with correct gem rewards for each.
**Validates: Requirements 6.6**

**Property 20: XP Triple Update Atomicity**
*For any* XP addition of amount X, totalXp, weeklyXp, and todayXp should all increase by X (after applying multipliers) in a single atomic operation.
**Validates: Requirements 5.6, 7.5**

**Property 21: XP Booster Doubles Gains**
*For any* XP gain with active XP booster, the final XP added should be exactly 2× the base XP amount.
**Validates: Requirements 5.5**

**Property 22: Perfect Lesson Bonus**
*For any* lesson completion with isPerfect=true, the XP awarded should be exactly 5 more than the same lesson with isPerfect=false.
**Validates: Requirements 5.3**

**Property 23: First Lesson Bonus**
*For any* first lesson of the day, the XP awarded should be exactly 5 more than subsequent lessons on the same day.
**Validates: Requirements 5.4**

**Property 24: Weekly XP Reset**
*For any* XP state where the current day is Monday and lastWeeklyResetDate is not today, weeklyXp should reset to 0 while totalXp and todayXp remain unchanged.
**Validates: Requirements 7.1**

**Property 25: Daily XP Reset**
*For any* XP state where a new day has begun and lastDailyResetDate is not today, todayXp should reset to 0 while totalXp and weeklyXp remain unchanged.
**Validates: Requirements 7.2**

### Gems Economy Properties

**Property 26: Gem Multiplier Doubles Gains**
*For any* gem gain with active gem multiplier, the final gems added should be exactly 2× the base gem amount.
**Validates: Requirements 8.7**

**Property 27: Gems Dual Update Atomicity**
*For any* gem earning of amount G, both gems and totalGemsEarned should increase by G in a single atomic operation.
**Validates: Requirements 8.8**

**Property 28: Gems Spending Dual Update**
*For any* gem spending of amount S, gems should decrease by S and totalGemsSpent should increase by S in a single atomic operation.
**Validates: Requirements 9.6**

**Property 29: Insufficient Gems Prevention**
*For any* purchase attempt where gems < cost, the purchase should be prevented and no state changes should occur.
**Validates: Requirements 9.7**

**Property 30: Streak Freeze Purchase Transaction**
*For any* user with gems >= 200, purchasing streak freeze should atomically deduct 200 gems and set streakFreezeAvailable=true.
**Validates: Requirements 9.2, 2.1**

### Power-Up Properties

**Property 31: Power-Up Activation Timestamp**
*For any* power-up activation (XP booster or gem multiplier), the expiration timestamp should be set to exactly current time + 1 hour.
**Validates: Requirements 10.1, 10.2**

**Property 32: Power-Up Expiration Check**
*For any* power-up state, the power-up should be considered active if and only if current time < expiration timestamp.
**Validates: Requirements 10.3, 10.4**

**Property 33: Power-Up Purchase Idempotence**
*For any* user with an active power-up, attempting to purchase the same power-up again should not deduct gems or extend the duration.
**Validates: Requirements 10.5, 10.6**

### Lesson Completion Properties

**Property 34: Reward Calculation Order**
*For any* lesson completion, operations should execute in this exact order: calculate base rewards → apply multipliers → add XP → add gems → update streak (if first of day) → check level up, with each step completing before the next begins.
**Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5**

**Property 35: Transaction Atomicity**
*For any* lesson completion, all stat updates (XP, gems, streak, level) should succeed together or fail together with no partial updates.
**Validates: Requirements 11.6**

### Primary Course Properties

**Property 36: Single Primary Course**
*For any* user's course list, exactly one course should have primary=true at any given time.
**Validates: Requirements 12.1**

**Property 37: Primary Course Transfer**
*For any* primary course change, the new course should have primary=true and the old course should have primary=false after the operation.
**Validates: Requirements 12.2, 12.3**

**Property 38: Stats Preservation on Course Switch**
*For any* primary course switch, all gamification stats (streak, energy, XP, gems) should remain unchanged.
**Validates: Requirements 12.5**

### Data Persistence Properties

**Property 39: Firestore Schema Validation**
*For any* data saved to Firestore, all field types should match the defined schema (integers as numbers, timestamps as Timestamp objects, dates as "YYYY-MM-DD" strings).
**Validates: Requirements 13.7**

**Property 40: Energy Regeneration Timestamp Update**
*For any* energy regeneration event, lastEnergyRegenAt should be updated in Firestore to reflect the regeneration time.
**Validates: Requirements 13.6**

### History and Analytics Properties

**Property 41: Lesson History Recording**
*For any* completed lesson, a history entry should be created containing date (in "YYYY-MM-DD" format), XP earned, gems earned, and lesson identifier.
**Validates: Requirements 14.1, 14.4**

**Property 42: History Date Format**
*For any* history entry, the date field should match the regex pattern "^\d{4}-\d{2}-\d{2}$" and represent a valid date in the user's timezone.
**Validates: Requirements 14.4**

**Property 43: History Retention Limit**
*For any* history query, entries older than 365 days from the current date should not be returned.
**Validates: Requirements 14.6**

### Timezone Properties

**Property 44: User Timezone for Date Operations**
*For any* date-based operation (streak tracking, XP resets), the date should be calculated using the user's device timezone, not UTC.
**Validates: Requirements 1.5, 7.4**



## Error Handling

### Firestore Error Handling

All Firestore operations should use the standardized error handler from `firebase.md`:

```dart
String _handleFirestoreError(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
    case 'unavailable':
      return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
    case 'deadline-exceeded':
      return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    case 'resource-exhausted':
      return 'Muitas requisições. Aguarde alguns minutos e tente novamente.';
    case 'unauthenticated':
      return 'Usuário não autenticado. Faça login novamente.';
    case 'not-found':
      return 'Dados não encontrados.';
    default:
      return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
  }
}
```

### Retry Logic

```dart
Future<T> _retryOperation<T>(Future<T> Function() operation) async {
  int attempts = 0;
  const maxAttempts = 3;
  
  while (attempts < maxAttempts) {
    try {
      return await operation();
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      
      // Exponential backoff: 1s, 2s, 4s
      await Future.delayed(Duration(seconds: pow(2, attempts - 1).toInt()));
    }
  }
  
  throw Exception('Operation failed after $maxAttempts attempts');
}
```

### Validation Errors

```dart
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

void _validateEnergyConsumption(int currentEnergy) {
  if (currentEnergy <= 0) {
    throw ValidationException('Energia insuficiente para iniciar a lição.');
  }
}

void _validateGemPurchase(int currentGems, int cost) {
  if (currentGems < cost) {
    throw ValidationException('Você precisa de ${cost - currentGems} gemas a mais.');
  }
}

void _validateXpAmount(int xp) {
  if (xp < 0) {
    throw ValidationException('Quantidade de XP inválida.');
  }
}
```

### Edge Case Handling

```dart
// Energy bounds
int _clampEnergy(int energy, int maxEnergy) {
  return max(0, min(energy, maxEnergy));
}

// Prevent negative gems
bool _canAfford(int currentGems, int cost) {
  return currentGems >= cost;
}

// Prevent XP underflow
int _safeAddXp(int currentXp, int xpToAdd) {
  if (xpToAdd < 0) {
    throw ValidationException('Cannot add negative XP');
  }
  return currentXp + xpToAdd;
}
```

### Offline Handling

```dart
class OfflineCache {
  final SharedPreferences _prefs;
  
  Future<void> cacheStats(GamificationStats stats) async {
    await _prefs.setString('cached_stats', jsonEncode(stats.toFirestore()));
  }
  
  Future<GamificationStats?> getCachedStats() async {
    final cached = _prefs.getString('cached_stats');
    if (cached == null) return null;
    return GamificationStats.fromFirestore(jsonDecode(cached));
  }
  
  Future<void> clearCache() async {
    await _prefs.remove('cached_stats');
  }
}
```

## Testing Strategy

### Dual Testing Approach

The gamification system requires both unit tests and property-based tests for comprehensive coverage:

**Unit Tests** focus on:
- Specific examples (e.g., level 5 requires 500 XP)
- Edge cases (e.g., energy at 0, gems insufficient)
- Error conditions (e.g., Firestore failures)
- Integration points (e.g., controller-service interaction)

**Property-Based Tests** focus on:
- Universal properties (e.g., totalXp never decreases)
- Formulas (e.g., energy regeneration, level calculation)
- Invariants (e.g., longestStreak >= currentStreak)
- State transitions (e.g., streak updates, level ups)

### Property-Based Testing Configuration

All property tests should:
- Run minimum 100 iterations per test
- Use appropriate generators for test data
- Tag tests with format: `Feature: gamification-system, Property N: [description]`
- Reference the design document property number

Example property test structure:

```dart
import 'package:test/test.dart';
import 'package:fast_check/fast_check.dart';

void main() {
  group('Gamification System Property Tests', () {
    test('Feature: gamification-system, Property 2: Total XP Never Decreases', () {
      property('totalXp should never decrease after any operation', () {
        forAll(
          totalXpArbitrary(),
          xpAmountArbitrary(),
          (initialXp, xpToAdd) {
            final controller = GamificationController();
            controller.totalXp.value = initialXp;
            
            controller._addXp(xpToAdd);
            
            expect(controller.totalXp.value, greaterThanOrEqualTo(initialXp));
          },
        );
      }, iterations: 100);
    });
    
    test('Feature: gamification-system, Property 17: Level Formula Correctness', () {
      property('xpForNextLevel should equal level × 100', () {
        forAll(
          levelArbitrary(min: 1, max: 100),
          (level) {
            final expectedXp = level * 100;
            
            expect(expectedXp, equals(level * 100));
          },
        );
      }, iterations: 100);
    });
  });
}
```

### Test Data Generators

```dart
// Arbitrary generators for property tests
Arbitrary<int> totalXpArbitrary() {
  return Arbitrary.integer(min: 0, max: 100000);
}

Arbitrary<int> xpAmountArbitrary() {
  return Arbitrary.integer(min: 0, max: 1000);
}

Arbitrary<int> levelArbitrary({int min = 1, int max = 100}) {
  return Arbitrary.integer(min: min, max: max);
}

Arbitrary<int> energyArbitrary() {
  return Arbitrary.integer(min: 0, max: 5);
}

Arbitrary<int> gemsArbitrary() {
  return Arbitrary.integer(min: 0, max: 10000);
}

Arbitrary<int> streakArbitrary() {
  return Arbitrary.integer(min: 0, max: 365);
}
```

### Unit Test Examples

```dart
group('Energy System Unit Tests', () {
  test('Energy refill adds exactly 5 energy', () async {
    final controller = GamificationController();
    controller.currentEnergy.value = 2;
    controller.gems.value = 100;
    
    await controller.purchaseEnergyRefill();
    
    expect(controller.currentEnergy.value, equals(5)); // 2 + 5 = 7, capped at 5
    expect(controller.gems.value, equals(0)); // 100 - 100
  });
  
  test('Cannot start lesson with 0 energy', () {
    final controller = GamificationController();
    controller.currentEnergy.value = 0;
    
    expect(controller.canStartLesson(), isFalse);
  });
});

group('Streak System Unit Tests', () {
  test('Streak milestone at 7 days awards 5 gems', () {
    final controller = GamificationController();
    controller.currentStreak.value = 6;
    
    controller._updateStreak();
    controller._checkStreakMilestones();
    
    expect(controller.gems.value, equals(5));
  });
});
```

### Integration Tests

```dart
group('Lesson Completion Integration Tests', () {
  test('Complete lesson flow updates all stats correctly', () async {
    final controller = GamificationController();
    await controller.loadStats();
    
    final initialStreak = controller.currentStreak.value;
    final initialXp = controller.totalXp.value;
    final initialGems = controller.gems.value;
    
    await controller.onLessonComplete(
      baseXp: 12,
      baseGems: 2,
      isPerfect: true,
    );
    
    expect(controller.currentStreak.value, greaterThanOrEqualTo(initialStreak));
    expect(controller.totalXp.value, greaterThan(initialXp));
    expect(controller.gems.value, greaterThan(initialGems));
  });
});
```

### Test Coverage Goals

- **Unit Tests**: 80% code coverage minimum
- **Property Tests**: All 44 correctness properties implemented
- **Integration Tests**: All major user flows covered
- **Edge Cases**: All error conditions tested

### Critical Test Scenarios

Priority test scenarios that must be covered:

1. **Energy regeneration** with various time deltas
2. **Streak tracking** across day boundaries
3. **Level up** with single and multiple levels
4. **XP resets** at midnight and Monday
5. **Gem transactions** with sufficient and insufficient funds
6. **Power-up activation** and expiration
7. **Lesson completion** with all bonus combinations
8. **Timezone handling** for date-based operations
9. **Transaction atomicity** for multi-field updates
10. **Error recovery** from Firestore failures



## Integration with Existing Features

### Integration with HomeBinding

The `GamificationController` is instantiated by `HomeBinding` since gamification stats are displayed in the home AppBar:

```dart
// features/inners/home/bindings/home_binding.dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<GamificationController>(() => GamificationController());
  }
}
```

### Integration with HomeAppbar

The `HomeAppbar` widget displays gamification stats and opens modals:

```dart
// features/inners/home/widgets/home_appbar.dart
class HomeAppbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gamification = Get.find<GamificationController>();
    
    return AppBar(
      title: Row(
        children: [
          // Streak
          Obx(() => GestureDetector(
            onTap: () => _showStreakModal(context),
            child: Row(
              children: [
                Icon(Icons.local_fire_department),
                Text('${gamification.currentStreak.value}'),
              ],
            ),
          )),
          
          // Energy
          Obx(() => GestureDetector(
            onTap: () => _showEnergyModal(context),
            child: Row(
              children: [
                Icon(Icons.bolt),
                Text('${gamification.currentEnergy.value}'),
              ],
            ),
          )),
          
          // Gems
          Obx(() => GestureDetector(
            onTap: () => _showGemsModal(context),
            child: Row(
              children: [
                Icon(Icons.diamond),
                Text('${gamification.gems.value}'),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
```

### Integration with Lesson Feature

Lesson controllers call gamification methods when starting and completing lessons:

```dart
// features/core/lesson/controllers/lesson_controller.dart
class LessonController extends GetxController {
  final _gamification = Get.find<GamificationController>();
  
  Future<void> startLesson() async {
    // Check if can start
    if (!_gamification.canStartLesson()) {
      // Show low energy modal
      Get.dialog(LowEnergyModal());
      return;
    }
    
    // Consume energy
    await _gamification.onLessonStart();
    
    // Start lesson...
  }
  
  Future<void> completeLesson() async {
    // Calculate performance
    final baseXp = 12;
    final baseGems = 2;
    final isPerfect = accuracy == 100;
    
    // Award rewards
    await _gamification.onLessonComplete(baseXp, baseGems, isPerfect);
    
    // Navigate to complete page...
  }
}
```

### Integration with Shop Feature

Shop widgets call gamification purchase methods:

```dart
// features/inners/shop/widgets/boost_item.dart
class BoostItem extends StatelessWidget {
  final String type; // 'energy', 'xp_booster', 'gem_multiplier', 'streak_freeze'
  
  void _onPurchase() async {
    final gamification = Get.find<GamificationController>();
    
    switch (type) {
      case 'energy':
        await gamification.purchaseEnergyRefill();
        break;
      case 'xp_booster':
        await gamification.purchaseXpBooster();
        break;
      case 'gem_multiplier':
        await gamification.purchaseGemMultiplier();
        break;
      case 'streak_freeze':
        await gamification.purchaseStreakFreeze();
        break;
    }
    
    // Show success/error message
    if (gamification.errorMessage.value.isNotEmpty) {
      Get.snackbar('Erro', gamification.errorMessage.value);
    } else {
      Get.snackbar('Sucesso', 'Item comprado!');
    }
  }
}
```

### Integration with Profile Feature

Profile displays gamification stats:

```dart
// features/inners/profile/views/profile_page.dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gamification = Get.find<GamificationController>();
    
    return Column(
      children: [
        ProfileHeader(),
        
        // Stats overview
        Obx(() => OverviewCard(
          title: 'Total XP',
          value: '${gamification.totalXp.value}',
        )),
        
        Obx(() => OverviewCard(
          title: 'Level',
          value: '${gamification.level.value}',
        )),
        
        Obx(() => OverviewCard(
          title: 'Current Streak',
          value: '${gamification.currentStreak.value} days',
        )),
        
        Obx(() => OverviewCard(
          title: 'Longest Streak',
          value: '${gamification.longestStreak.value} days',
        )),
      ],
    );
  }
}
```

### Dependency on AuthController

The `GamificationController` depends on `AuthController` to get the current user ID:

```dart
// In GamificationController
Future<void> loadStats() async {
  isLoading.value = true;
  errorMessage.value = '';
  
  try {
    final userId = Get.find<AuthController>().userId;
    
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification')
        .get();
    
    // Load stats...
  } catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } finally {
    isLoading.value = false;
  }
}
```

**Note**: `AuthController` must be instantiated before `GamificationController`. This is already handled by the app's initialization flow since `AuthController` is instantiated at app startup.



## Future Module Integration Points

The Gamification System is designed to integrate with future modules in the following order:

### 5. Lessons Module (Next Implementation)

**Integration Points:**
- `LessonController` will call `gamification.canStartLesson()` before starting
- `LessonController` will call `gamification.onLessonStart()` to consume energy
- `LessonController` will call `gamification.onLessonComplete(baseXp, baseGems, isPerfect)` after completion
- Lesson completion triggers: XP gain, gems gain, streak update, level up check

**Methods Already Prepared:**
```dart
// In GamificationController
bool canStartLesson(); // Check energy availability
Future<void> onLessonStart(); // Consume energy
Future<void> onLessonComplete(int baseXp, int baseGems, bool isPerfect); // Award rewards
```

**Data Flow:**
```
Lesson Complete → Calculate Performance → Call gamification.onLessonComplete()
                                        ↓
                                   Update XP, Gems, Streak, Level
                                        ↓
                                   Update Challenges (future)
```

### 6. Challenges Module (Treasure)

**Integration Points:**
- Gamification will call `challenges.updateProgress()` after lesson completion
- Challenges will award gems/XP through gamification methods
- Challenge completion triggers gem/XP rewards

**Methods to be Called by Gamification:**
```dart
// In future ChallengesController
Future<void> updateProgress({
  required String type, // 'lessons', 'xp', 'correct_exercises', 'streak'
  required int amount,
});
```

**Integration in GamificationController:**
```dart
// In onLessonComplete() - after step 5 (check level up)
// Step 6: Update challenges (when implemented)
if (Get.isRegistered<ChallengesController>()) {
  final challenges = Get.find<ChallengesController>();
  await challenges.updateProgress(type: 'lessons', amount: 1);
  await challenges.updateProgress(type: 'xp', amount: totalXp);
  await challenges.updateProgress(type: 'correct_exercises', amount: correctAnswers);
}
```

### 7. Ranking Module (Leaderboard)

**Integration Points:**
- Ranking uses `weeklyXp` from gamification stats
- Weekly reset handled by Cloud Function (not by gamification)
- Ranking rewards (gems) added through gamification methods

**Data Dependencies:**
```dart
// Ranking reads from gamification
final weeklyXp = gamification.weeklyXp.value;
final currentLeague = gamification.currentLeague.value;

// Ranking awards gems through gamification
await gamification._addGems(rewardAmount);
```

**Weekly Reset (Cloud Function):**
```dart
// Cloud Function resets weeklyXp every Monday 00:00
// Gamification controller loads the reset value from Firestore
// No direct integration needed - data sync through Firestore
```

### 8. Shop Module (Store)

**Integration Points:**
- Shop widgets call gamification purchase methods
- Shop displays current gems balance
- Shop validates purchases through gamification

**Methods Already Prepared:**
```dart
// In GamificationController
Future<void> purchaseEnergyRefill(); // 100 gems → +5 energy
Future<void> purchaseStreakFreeze(); // 200 gems → activate freeze
Future<void> purchaseXpBooster(); // 150 gems → 2× XP for 1 hour
Future<void> purchaseGemMultiplier(); // 200 gems → 2× gems for 1 hour
```

**Shop Integration Pattern:**
```dart
// In ShopPage/BoostItem widgets
final gamification = Get.find<GamificationController>();

// Display balance
Obx(() => Text('${gamification.gems.value} gems'));

// Purchase item
await gamification.purchaseXpBooster();

// Handle result
if (gamification.errorMessage.value.isNotEmpty) {
  // Show error
} else {
  // Show success
}
```

### 9. Profile Module

**Integration Points:**
- Profile displays gamification stats (already implemented)
- Profile shows level, XP, streak, longest streak
- Profile uses Obx for reactive updates

**Methods Already Available:**
```dart
// In ProfilePage
final gamification = Get.find<GamificationController>();

Obx(() => OverviewCard(
  title: 'Total XP',
  value: '${gamification.totalXp.value}',
));

Obx(() => OverviewCard(
  title: 'Level',
  value: '${gamification.level.value}',
));
```

### Implementation Order Considerations

**Current Module (Gamification):**
- ✅ Provides all methods needed by future modules
- ✅ Designed to be called by Lessons, Shop, Profile
- ✅ Prepared to call Challenges when implemented
- ✅ Data structure supports Ranking integration

**Next Module (Lessons):**
- Will implement `LessonController`
- Will call gamification methods for energy and rewards
- Will provide performance data (correctAnswers, isPerfect)

**Future Modules:**
- Challenges: Will be called by gamification after lesson completion
- Ranking: Will read weeklyXp from gamification stats
- Shop: Will call gamification purchase methods
- Profile: Will display gamification stats (already working)

### Data Flow Summary

```
User Action (Lesson) → LessonController
                            ↓
                    GamificationController
                            ↓
                    ┌───────┴───────┐
                    ↓               ↓
            Update Stats      Call Challenges
                    ↓               ↓
            Save Firestore    Update Progress
                    ↓
            Trigger Level Up
                    ↓
            Award Gems
```

### Critical Notes for Future Implementation

1. **Lessons Module**: Must calculate `baseXp`, `baseGems`, and `isPerfect` before calling gamification
2. **Challenges Module**: Must expose `updateProgress()` method that gamification can call
3. **Ranking Module**: Reads `weeklyXp` directly from Firestore, no direct method calls needed
4. **Shop Module**: Uses existing purchase methods, no new methods needed
5. **Profile Module**: Already integrated, uses Obx for reactive display

### Backward Compatibility

The gamification system is designed to work independently:
- If Challenges module is not implemented yet, gamification works without it
- Uses `Get.isRegistered<ChallengesController>()` to check before calling
- All core functionality (streak, energy, XP, gems) works standalone
- Future modules enhance functionality but are not required

