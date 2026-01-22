# OTP Bypass Release Mode Verification

## Overview
This document provides instructions for manually verifying that the OTP bypass feature (code "00000") works ONLY in debug mode and is properly disabled in release builds.

## Background
The OTP bypass uses Flutter's `kDebugMode` constant, which is a compile-time constant that is:
- `true` in debug builds
- `false` in release builds

This ensures the bypass is automatically disabled in production without any runtime checks.

## Automated Tests Status
✅ All automated tests pass (run in debug mode):
- Debug mode bypass logic verified
- Release mode behavior simulated
- Security checks validated

```bash
flutter test test/unit/features/core/onboarding/controllers/otp_bypass_test.dart
```

Result: **14/14 tests passed**

## Manual Verification Required

### Prerequisites
- Android device or emulator
- Flutter SDK installed
- Access to Firebase Console (to view real OTP codes)

### Step 1: Test Debug Build (Bypass Should Work)

1. **Build and run debug version:**
   ```bash
   flutter run --debug
   ```

2. **Navigate to OTP verification screen:**
   - Complete onboarding steps until you reach the "Verify Code" screen
   - You should see a yellow debug banner at the top:
     ```
     🔓 DEBUG MODE
     Use test code 00000 to skip verification
     ```

3. **Test bypass code:**
   - Enter code: `00000`
   - Expected result: ✅ Code is accepted immediately
   - Expected result: ✅ Onboarding proceeds to next screen
   - Expected result: ✅ No Firestore verification occurs

4. **Verify debug banner visibility:**
   - Confirm the yellow debug banner is visible
   - Confirm it shows the bypass code hint

### Step 2: Test Release Build (Bypass Should Fail)

1. **Build release APK:**
   ```bash
   flutter build apk --release
   ```

2. **Install release APK on device:**
   ```bash
   flutter install --release
   ```
   
   Or manually install from:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Navigate to OTP verification screen:**
   - Complete onboarding steps until you reach the "Verify Code" screen
   - Verify: ❌ NO debug banner should be visible
   - Verify: ❌ NO mention of test code "00000"

4. **Test bypass code (should fail):**
   - Enter code: `00000`
   - Expected result: ❌ Code is rejected
   - Expected error message: "Código inválido. Verifique e tente novamente."
   - Expected result: ❌ Onboarding does NOT proceed
   - Expected result: ✅ Code is validated against Firestore

5. **Test with real OTP code:**
   - Open Firebase Console
   - Navigate to: Firestore Database → emailVerifications collection
   - Find document with your email
   - Copy the 5-digit code from the `code` field
   - Enter the real code in the app
   - Expected result: ✅ Code is accepted
   - Expected result: ✅ Onboarding proceeds to next screen

### Step 3: Security Verification

1. **Verify no bypass hints in release:**
   - Check all error messages
   - Confirm no mention of "00000", "bypass", or "debug"
   - Confirm no debug banner or hints

2. **Verify code validation:**
   - Try invalid codes: `12345`, `99999`, `11111`
   - All should be rejected with appropriate error messages
   - Only the real Firestore code should work

3. **Verify kDebugMode behavior:**
   - In debug: `kDebugMode = true` → bypass works
   - In release: `kDebugMode = false` → bypass disabled

## Verification Checklist

### Debug Build
- [ ] Debug banner is visible
- [ ] Banner shows "🔓 DEBUG MODE"
- [ ] Banner shows hint: "Use test code 00000 to skip verification"
- [ ] Code "00000" is accepted
- [ ] Bypass works without Firestore check
- [ ] Onboarding proceeds after entering "00000"

### Release Build
- [ ] NO debug banner visible
- [ ] NO mention of test code anywhere
- [ ] Code "00000" is REJECTED
- [ ] Error message shown: "Código inválido. Verifique e tente novamente."
- [ ] Real Firestore code is required
- [ ] Real code from Firestore works correctly
- [ ] Onboarding proceeds only with real code

### Security
- [ ] No bypass hints in error messages
- [ ] No debug information exposed in release
- [ ] Code validation works correctly in release
- [ ] Only valid Firestore codes are accepted in release

## Expected Results Summary

| Build Type | Code "00000" | Debug Banner | Firestore Check | Result |
|------------|--------------|--------------|-----------------|--------|
| Debug      | ✅ Accepted  | ✅ Visible   | ❌ Skipped      | Bypass works |
| Release    | ❌ Rejected  | ❌ Hidden    | ✅ Required     | Bypass disabled |

## Troubleshooting

### If bypass works in release build:
🚨 **CRITICAL SECURITY BUG** - Do not deploy to production!

Possible causes:
1. App was built in debug mode instead of release
2. `kDebugMode` check is not working correctly
3. Code was modified incorrectly

Solution:
1. Verify build command: `flutter build apk --release`
2. Check OnboardingController.verifyCode() implementation
3. Ensure bypass check is: `if (kDebugMode && sanitizedCode == '00000')`

### If bypass doesn't work in debug build:
Possible causes:
1. Code was not trimmed before check
2. Typo in bypass code
3. Logic error in controller

Solution:
1. Verify code is trimmed: `sanitizedCode = code.trim()`
2. Verify bypass code is exactly: `'00000'`
3. Check controller implementation matches design

## Implementation Reference

### Controller Code (OnboardingController.verifyCode)
```dart
Future<void> verifyCode(String code) async {
  // Sanitizar código (remover espaços)
  final sanitizedCode = code.trim();

  // BYPASS EM DEBUG MODE
  if (kDebugMode && sanitizedCode == '00000') {
    debugPrint('🔓 DEBUG MODE: Bypass OTP com código $sanitizedCode');
    await finalizeAccount();
    return;
  }

  // Normal validation continues...
}
```

### View Code (VerifyCodePage)
```dart
// Debug banner
if (kDebugMode)
  Container(
    width: double.infinity,
    padding: EdgeInsets.all(r.spacing16),
    color: AppTheme.warning.withOpacity(0.2),
    child: Column(
      children: [
        Text(
          '🔓 DEBUG MODE',
          style: AppTheme.textSmBold.copyWith(color: AppTheme.warning),
        ),
        SizedBox(height: r.spacing4),
        Text(
          'Use test code 00000 to skip verification',
          style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray600),
        ),
      ],
    ),
  ),
```

## Conclusion

The OTP bypass feature is properly implemented with:
- ✅ Compile-time constant (`kDebugMode`) for security
- ✅ Automatic disable in release builds
- ✅ Clear debug indicators in debug builds
- ✅ No security hints in release builds
- ✅ Comprehensive automated tests
- ✅ Manual verification procedures

**Status:** Ready for production deployment after manual verification is completed.

## Sign-off

After completing manual verification, sign off below:

- [ ] Debug build tested - bypass works ✅
- [ ] Release build tested - bypass disabled ✅
- [ ] Security verified - no leaks in release ✅
- [ ] Tested by: ________________
- [ ] Date: ________________
- [ ] Device: ________________
- [ ] Build version: ________________

---

**Last Updated:** 2026-01-21
**Test File:** test/unit/features/core/onboarding/controllers/otp_bypass_test.dart
**Implementation:** lib/features/core/onboarding/controllers/onboarding_controller.dart
