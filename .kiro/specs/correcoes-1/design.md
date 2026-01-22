# Design - Critical App Fixes

## Architecture

### Affected Components

```
lib/
├── main.dart                           # [MODIFY] Register global controllers
├── shared/
│   └── utils/
│       └── validation_helper.dart      # [CREATE] Centralized validators
├── features/
│   ├── core/
│   │   ├── auth/
│   │   │   └── controllers/
│   │   │       └── auth_controller.dart        # [MODIFY] Global registration
│   │   └── onboarding/
│   │       ├── controllers/
│   │       │   └── onboarding_controller.dart  # [MODIFY] OTP bypass + validation
│   │       └── views/
│   │           └── profile_view/
│   │               ├── user_name_page.dart     # [MODIFY] Real-time validation
│   │               ├── user_email_page.dart    # [MODIFY] Real-time validation
│   │               ├── user_password_page.dart # [MODIFY] Real-time validation
│   │               └── verify_code_page.dart   # [MODIFY] Debug bypass
│   └── inners/
│       ├── home/
│       │   ├── controllers/
│       │   │   └── home_controller.dart        # [MODIFY] goToShop method
│       │   └── widgets/
│       │       └── gems_modal.dart             # [MODIFY] Correct callback
│       └── gamification/
│           └── controllers/
│               └── gamification_controller.dart # [MODIFY] Global registration
```

---

## 1. Input Validation

### 1.1 ValidationHelper (New)

**Location:** `shared/utils/validation_helper.dart`

```dart
class ValidationHelper {
  // Regex patterns
  static final _nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]{2,50}$');
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  // Validators
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters.';
    }
    
    if (!_nameRegex.hasMatch(trimmed)) {
      return 'Name must contain only letters and spaces.';
    }
    
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    
    final trimmed = value.trim();
    
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email.';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    
    return null;
  }
  
  // Sanitizers
  static String sanitizeName(String value) {
    return value.trim();
  }
  
  static String sanitizeEmail(String value) {
    return value.trim().toLowerCase();
  }
}
```

### 1.2 Real-time Validation in Views

**Pattern for all input views:**

```dart
class _UserNamePageState extends State<UserNamePage> {
  final _nameController = TextEditingController();
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateInput);
  }
  
  void _validateInput() {
    setState(() {
      _errorMessage = ValidationHelper.validateName(_nameController.text);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return OnboardingTextField(
      controller: _nameController,
      hint: 'type your name',
      errorText: _errorMessage,
      // Red border if error
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: _errorMessage != null ? AppTheme.error : AppTheme.gray300,
          ),
        ),
      ),
    );
  }
}
```

---

## 2. OTP Flow with Bypass

### 2.1 OnboardingController - Debug Bypass

```dart
import 'package:flutter/foundation.dart'; // kDebugMode

class OnboardingController extends GetxController {
  // Fixed code for debug
  static const _debugOtpCode = '00000';
  
  Future<void> verifyCode(String code) async {
    final sanitizedCode = code.trim();
    
    // BYPASS IN DEBUG
    if (kDebugMode && sanitizedCode == _debugOtpCode) {
      debugPrint('🔓 DEBUG MODE: Bypass OTP with code $sanitizedCode');
      await finalizeAccount();
      return;
    }
    
    // Normal validation
    if (sanitizedCode.length != 5) {
      errorMessage.value = 'Code must be 5 digits.';
      return;
    }
    
    // ... rest of validation
  }
  
  Future<void> sendVerificationCode() async {
    // ... existing code
    
    // Log in debug
    if (kDebugMode) {
      debugPrint('🔓 DEBUG MODE: Use code 00000 for bypass');
      debugPrint('📧 Real code saved in Firestore: ${userEmail.value}');
    }
    
    // ... rest of code
  }
}
```

### 2.2 VerifyCodePage - Debug Banner

```dart
class _VerifyCodePageState extends State<VerifyCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Debug banner
          if (kDebugMode)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: AppTheme.warning.withOpacity(0.2),
              child: Column(
                children: [
                  Text(
                    '🔓 DEBUG MODE',
                    style: AppTheme.textSmBold.copyWith(color: AppTheme.warning),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Use code 00000 to skip verification',
                    style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray600),
                  ),
                ],
              ),
            ),
          
          // Rest of UI
          // ...
        ],
      ),
    );
  }
}
```

---

## 3. Global Controllers

### 3.1 Registration in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Register global controllers
  Get.put(AuthController(), permanent: true);
  Get.put(GamificationController(), permanent: true);
  
  runApp(MyApp());
}
```

### 3.2 Remove Duplicate Bindings

**AuthBinding - REMOVE AuthController registration:**

```dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // REMOVE: Get.lazyPut(() => AuthController());
    // AuthController is already registered globally in main.dart
  }
}
```

**HomeBinding - REMOVE GamificationController registration:**

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    // REMOVE: Get.lazyPut(() => GamificationController());
    // GamificationController is already registered globally in main.dart
  }
}
```

---

## 4. Correct Navigation

### 4.1 HomeController - goToShop Method

```dart
class HomeController extends GetxController {
  // ... existing code
  
  void goToShop() {
    currentNavIndex.value = 2; // Tab 2 = Shop
  }
}
```

### 4.2 GemsModal - Correct Callback

```dart
class GemsModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ... gem packs
        
        AppButton(
          text: 'Go to shop',
          isPrimary: false,
          onPressed: () {
            Navigator.of(context).pop(); // Close modal
            onGoToShop?.call(); // Call callback
          },
        ),
      ],
    );
  }
  
  static void show(BuildContext context) {
    final homeController = Get.find<HomeController>();
    
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          child: GemsModal(
            onGoToShop: () => homeController.goToShop(),
          ),
        ),
      ],
    );
  }
}
```

---

## 5. Social Login (Google)

### 5.1 AuthController - Differentiated Flow

```dart
class AuthController extends GetxController {
  Future<void> signInWithGoogle() async {
    // ... Google authentication
    
    if (!userDoc.exists) {
      // Create document with authProvider
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'email': userCredential.user!.email,
        'displayName': userCredential.user!.displayName,
        'photoURL': userCredential.user!.photoURL,
        'authProvider': 'google',
        'onboardingCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Navigate to onboarding with flag
      final onboardingController = Get.find<OnboardingController>();
      onboardingController.skipWelcome.value = true;
      onboardingController.authProvider.value = 'google'; // NEW
      onboardingController.userEmail.value = userCredential.user!.email!;
      onboardingController.userName.value = userCredential.user!.displayName ?? '';
      
      Get.offAllNamed('/onboarding');
    }
  }
}
```

### 5.2 OnboardingController - Detect Social Login

```dart
class OnboardingController extends GetxController {
  final authProvider = ''.obs; // NEW
  
  // Check if should skip screens
  bool shouldSkipEmail() => authProvider.value == 'google';
  bool shouldSkipPassword() => authProvider.value == 'google';
  bool shouldSkipVerifyCode() => authProvider.value == 'google';
}
```

### 5.3 OnboardingNavigation - Skip Screens

```dart
class OnboardingNavigation {
  final _controller = Get.find<OnboardingController>();
  
  void goToUserEmail() {
    // Skip if social login
    if (_controller.shouldSkipEmail()) {
      goToConclusion();
      return;
    }
    
    Get.to(() => const UserEmailPage());
  }
  
  void goToUserPassword() {
    // Skip if social login
    if (_controller.shouldSkipPassword()) {
      goToConclusion();
      return;
    }
    
    Get.to(() => const UserPasswordPage());
  }
}
```

---

## 6. Atomic Saving

### 6.1 OnboardingController - Batch Write

```dart
class OnboardingController extends GetxController {
  Future<void> finalizeAccount() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated.';
        return;
      }
      
      // Validate all data before saving
      final validationError = _validateAllData();
      if (validationError != null) {
        errorMessage.value = validationError;
        return;
      }
      
      // Generate username
      final username = await generateUniqueUsername(userName.value);
      
      // BATCH WRITE - All or nothing
      final batch = _firestore.batch();
      
      // 1. User document
      final userRef = _firestore.collection('users').doc(user.uid);
      batch.set(userRef, {
        'id': user.uid,
        'email': ValidationHelper.sanitizeEmail(userEmail.value),
        'name': ValidationHelper.sanitizeName(userName.value),
        'username': username,
        'age': userAge.value,
        'authProvider': authProvider.value.isEmpty ? 'email' : authProvider.value,
        'onboardingCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // 2. Course document
      final courseRef = userRef.collection('courses').doc();
      batch.set(courseRef, {
        'id': courseRef.id,
        'language': selectedLanguage.value,
        'languageName': _getLanguageName(selectedLanguage.value),
        'level': languageLevel.value,
        'reason': learningReason.value,
        'studyTime': int.parse(studyTime.value),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 3. Gamification stats
      final statsRef = userRef.collection('stats').doc('gamification');
      batch.set(statsRef, {
        'streak': {
          'currentStreak': 0,
          'longestStreak': 0,
          'lastStreakDate': '',
          'streakFreezeAvailable': false,
          'streakFreezeUsedToday': false,
          'milestonesReached': [],
        },
        'energy': {
          'currentEnergy': 5,
          'maxEnergy': 5,
          'lastEnergyRegenAt': FieldValue.serverTimestamp(),
          'unlimitedEnergyUntil': null,
        },
        'xp': {
          'totalXp': 0,
          'weeklyXp': 0,
          'todayXp': 0,
          'level': 1,
          'xpToNextLevel': 100,
          'xpBoosterUntil': null,
          'lastWeeklyResetDate': '',
          'lastDailyResetDate': '',
        },
        'gems': {
          'gems': 0,
          'totalGemsEarned': 0,
          'totalGemsSpent': 0,
          'gemMultiplierUntil': null,
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Commit batch
      await batch.commit();
      
      // Save SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);
      
      // Navigate
      nav.goToConclusion();
      
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
  
  String? _validateAllData() {
    // Validate name
    final nameError = ValidationHelper.validateName(userName.value);
    if (nameError != null) return nameError;
    
    // Validate email (if not social login)
    if (authProvider.value != 'google') {
      final emailError = ValidationHelper.validateEmail(userEmail.value);
      if (emailError != null) return emailError;
      
      final passwordError = ValidationHelper.validatePassword(userPassword.value);
      if (passwordError != null) return passwordError;
    }
    
    // Validate other fields
    if (selectedLanguage.value.isEmpty) return 'Select a language.';
    if (languageLevel.value.isEmpty) return 'Select a level.';
    if (studyTime.value.isEmpty) return 'Select study time.';
    
    return null;
  }
}
```

---

## Data Flow

### Normal Onboarding (Email/Password)

```
1. UserNamePage → real-time validation → userName
2. UserAgePage → selection → userAge
3. UserEmailPage → real-time validation → userEmail
4. UserPasswordPage → real-time validation → userPassword
5. VerifyCodePage → debug bypass (00000) → verification
6. finalizeAccount() → batch write → Firestore
7. ConclusionPage → navigation → /home
```

### Google Onboarding

```
1. SignInWithGoogle → authProvider = 'google'
2. UserNamePage → pre-filled with displayName
3. UserAgePage → selection → userAge
4. SelectLanguagePage → selection → selectedLanguage
5. LanguageLevelPage → selection → languageLevel
6. StudyTimePage → selection → studyTime
7. finalizeAccount() → batch write → Firestore (skips email/password/OTP)
8. ConclusionPage → navigation → /home
```

---

## Correctness Properties

### P1: Immediate Validation
- **Property:** Every invalid input must show error before allowing submit
- **Test:** Type "123" in name → error visible → button disabled

### P2: Safe OTP Bypass
- **Property:** Code "00000" only works in kDebugMode
- **Test:** Release build → code "00000" → error "invalid code"

### P3: Atomic Saving
- **Property:** If any operation fails, no data is saved
- **Test:** Simulate error mid-batch → verify Firestore empty

### P4: Controllers Always Available
- **Property:** AuthController and GamificationController never give "not found"
- **Test:** Access settings from any screen → logout works

### P5: Correct Navigation
- **Property:** Gems modal always navigates to shop (tab 2)
- **Test:** Click "Go to shop" → verify currentNavIndex.value == 2

---

## Required Tests

### Unit Tests
- `validation_helper_test.dart` - All validators
- `onboarding_controller_test.dart` - OTP bypass, batch write
- `auth_controller_test.dart` - Google login, global registration

### Integration Tests
- `onboarding_flow_test.dart` - Complete email/password flow
- `google_signin_flow_test.dart` - Complete Google flow
- `navigation_test.dart` - All critical navigations

### Property Tests
- Validation never accepts invalid data
- Batch write always atomic
- Global controllers always available

---

## Implementation Notes

### Implementation Order
1. ValidationHelper (base for everything)
2. Global controllers (prevents crashes)
3. Real-time validation in views
4. OTP bypass in debug
5. Google differentiated flow
6. Atomic batch write
7. Correct navigation
8. Tests

### Compatibility
- Flutter 3.x
- Firebase 10.x
- GetX 4.x
- No breaking changes

### Performance
- Real-time validation: O(1) per keystroke
- Batch write: 1 operation vs 3 separate
- Global controllers: +2MB RAM (acceptable)
