# AuthController Pattern Updates for Onboarding Spec

## Summary

The AuthController has been enhanced with additional validation, sanitization, and documentation patterns that should be reflected in the onboarding spec.

## Key Additions to Implement

### 1. Email Sanitization

**Pattern from AuthController:**
```dart
// Sanitize and validate email
final sanitizedEmail = email.trim().toLowerCase();
final emailError = validateEmail(sanitizedEmail);
if (emailError != null) {
  errorMessage.value = emailError;
  return;
}
```

**Apply to:**
- `createAccount()` method
- `sendVerificationCode()` method
- All email handling operations

**Benefit:** Prevents issues with whitespace and case sensitivity

### 2. OTP Code Format Validation

**Pattern from AuthController:**
```dart
/// Verifies OTP code
/// 
/// FLUXO ATUAL (DESENVOLVIMENTO):
/// 1. Busca código no Firestore
/// 2. Valida formato, expiração e correspondência
/// 3. Se válido, navega para tela de nova senha
/// 
/// COMO TESTAR AGORA:
/// 1. Executar sendPasswordResetCode()
/// 2. Acessar Firebase Console > Firestore > passwordResets > [seu-email]
/// 3. Copiar o valor do campo "code"
/// 4. Colar na tela de verificação
/// 
/// ⚠️ Em produção, o usuário receberá o código por email (quando implementado)
Future<void> verifyCode(String code) async {
  // Sanitize code (remove spaces)
  final sanitizedCode = code.trim();

  // Validate code is exactly 5 digits
  if (sanitizedCode.length != 5) {
    errorMessage.value = 'O código deve ter 5 dígitos.';
    return;
  }

  // Validate code contains only numbers
  final digitRegex = RegExp(r'^\d{5}$');
  if (!digitRegex.hasMatch(sanitizedCode)) {
    errorMessage.value = 'O código deve conter apenas números.';
    return;
  }

  isLoading.value = true;
  errorMessage.value = '';

  try {
    // ... rest of verification logic
  }
}
```

**Apply to:**
- `verifyCode()` method in OnboardingController

**Benefit:** 
- Validates format before Firestore query (faster feedback)
- Prevents unnecessary Firestore reads
- Better user experience with immediate validation

### 3. Enhanced Documentation Comments

**Pattern from AuthController:**
```dart
/// Generates 5-digit OTP code
/// 
/// ⚠️ ATENÇÃO: Este código é gerado mas NÃO é enviado por email automaticamente
/// Para testar em desenvolvimento: acessar Firestore Console e copiar o código
/// Para produção: implementar envio de email (ver comentários em sendPasswordResetCode)
String _generateOTP() {
  final random = Random();
  final code = (10000 + random.nextInt(90000)).toString();
  return code;
}
```

**Apply to:**
- `_generateOTP()` helper method
- `sendVerificationCode()` method
- `verifyCode()` method

**Benefit:** Clear documentation for developers about testing and production requirements

### 4. Success Feedback with Get.snackbar

**Pattern from AuthController:**
```dart
// Success feedback
Get.snackbar(
  'Código reenviado',
  'Um novo código foi enviado para seu e-mail.',
  snackPosition: SnackPosition.BOTTOM,
  duration: const Duration(seconds: 2),
);
```

**Apply to:**
- `resendVerificationCode()` method

**Benefit:** Immediate user feedback on successful resend

### 5. Session Expiration Check

**Pattern from AuthController:**
```dart
if (_tempEmail == null) {
  errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
  return;
}
```

**Apply to:**
- `resendVerificationCode()` method
- `verifyCode()` method

**Benefit:** Prevents errors when session data is lost

## Updated Requirements

### Requirement 6: Email Verification (Updated Acceptance Criteria)

Add these new criteria:

20. WHEN verifying code, THE System SHALL sanitize code by trimming whitespace
21. WHEN code length is not 5 digits, THE System SHALL display error "O código deve ter 5 dígitos."
22. WHEN code contains non-numeric characters, THE System SHALL display error "O código deve conter apenas números."
23. WHEN resend is successful, THE System SHALL display snackbar "Código reenviado"
24. WHEN session has expired (_tempEmail is null), THE System SHALL display error "Sessão expirada. Inicie o processo novamente."

### Requirement 5: Account Creation (Updated Acceptance Criteria)

Add these new criteria:

20. WHEN creating account, THE System SHALL sanitize email with trim() and toLowerCase()
21. WHEN email is sanitized, THE System SHALL update userEmail observable with sanitized value

## Updated Tasks

### Phase 3: OTP Generation and Verification

Update Task 3.4:

```markdown
- [ ] 3.4 Implement verifyCode method with format validation
  - Sanitize code with trim()
  - Validate code length is exactly 5 digits BEFORE Firestore query
  - Validate code contains only numbers using RegExp(r'^\d{5}$')
  - Display format errors immediately without loading state
  - Check _tempEmail for session expiration
  - Retrieve OTP document from Firestore using _tempEmail as key
  - Parse document to get code, expiresAt, attempts
  - Validate entered code matches stored code
  - Check if current time is before expiresAt (10 minutes)
  - Display appropriate error messages in Portuguese
  - On success: delete OTP document and proceed to finalization
  - Add comprehensive documentation comments explaining testing process
  - _Requirements: 6.5, 6.6, 6.7, 6.8, 6.18, 6.19, 6.20, 6.21, 6.22, 6.24_
```

Update Task 3.2:

```markdown
- [ ] 3.2 Implement sendVerificationCode method with email sanitization
  - Sanitize email with trim().toLowerCase()
  - Validate sanitized email
  - Generate OTP code using _generateOTP()
  - Store OTP in Firestore collection 'emailVerifications' with sanitized email as key
  - Store _tempEmail with sanitized email for session management
  - Start 60-second resend timer using _startResendTimer()
  - Navigate to verification screen
  - Add comprehensive ⚠️ CRITICAL comments about email sending
  - _Requirements: 5.13, 5.14, 5.20, 5.21, 6.3, 6.9, 6.13_
```

Update Task 3.3:

```markdown
- [ ] 3.3 Implement resendVerificationCode method with feedback
  - Check _tempEmail for session expiration
  - Display error if session expired
  - Generate new OTP code
  - Store in Firestore with _tempEmail as key
  - Restart 60-second timer
  - Display success snackbar "Código reenviado"
  - _Requirements: 6.9, 6.11, 6.13, 6.23, 6.24_
```

### Phase 2: Firebase Auth Integration

Update Task 2.1:

```markdown
- [ ] 2.1 Implement createAccount method with email sanitization
  - Sanitize email with trim().toLowerCase()
  - Validate sanitized email using validateEmail
  - Validate password using validatePassword
  - Set isLoading to true
  - Clear previous error messages
  - Call Firebase Auth createUserWithEmailAndPassword with sanitized email
  - Update userEmail observable with sanitized value
  - On success: call sendVerificationCode
  - On error: use standardized error handler
  - Set isLoading to false in finally block
  - _Requirements: 5.5, 5.11, 5.12, 5.13, 5.19, 5.20, 5.21, 12.1, 12.2, 12.3_
```

## Implementation Checklist

- [ ] Update design.md with email sanitization in createAccount
- [ ] Update design.md with OTP format validation in verifyCode
- [ ] Update design.md with enhanced documentation comments
- [ ] Update design.md with Get.snackbar feedback in resend
- [ ] Update design.md with session expiration checks
- [ ] Update requirements.md with new acceptance criteria for Requirement 6
- [ ] Update requirements.md with new acceptance criteria for Requirement 5
- [ ] Update tasks.md Phase 3 with format validation details
- [ ] Update tasks.md Phase 2 with email sanitization details
- [ ] Update IMPLEMENTATION_NOTES.md with new patterns

## Testing Implications

### New Unit Tests Required

1. **Email Sanitization Tests:**
   - Test email with leading/trailing whitespace
   - Test email with mixed case
   - Test email with both whitespace and mixed case

2. **OTP Format Validation Tests:**
   - Test code with less than 5 digits
   - Test code with more than 5 digits
   - Test code with letters
   - Test code with special characters
   - Test code with whitespace
   - Test valid 5-digit code

3. **Session Expiration Tests:**
   - Test resend when _tempEmail is null
   - Test verify when _tempEmail is null

### Updated Property Tests

**Property 7: OTP Lifecycle Management** (update):
- Add validation that format checks happen before Firestore queries
- Add validation that error messages are immediate (no loading state)
- Add validation that session expiration is checked

## Code Examples

### Complete verifyCode Implementation

```dart
/// Verifies OTP code (follows AuthController pattern)
/// 
/// CURRENT FLOW (DEVELOPMENT):
/// 1. Validates code format (5 digits, numbers only)
/// 2. Checks session validity (_tempEmail)
/// 3. Retrieves code from Firestore
/// 4. Validates expiration and match
/// 5. If valid, proceeds to account finalization
/// 
/// HOW TO TEST NOW:
/// 1. Execute sendVerificationCode()
/// 2. Access Firebase Console > Firestore > emailVerifications > [your-email]
/// 3. Copy the "code" field value
/// 4. Paste in verification screen
/// 
/// ⚠️ In production, user will receive code via email (when implemented)
Future<void> verifyCode(String code) async {
  // Sanitize code (remove spaces)
  final sanitizedCode = code.trim();

  // Validate code is exactly 5 digits
  if (sanitizedCode.length != 5) {
    errorMessage.value = 'O código deve ter 5 dígitos.';
    return;
  }

  // Validate code contains only numbers
  final digitRegex = RegExp(r'^\d{5}$');
  if (!digitRegex.hasMatch(sanitizedCode)) {
    errorMessage.value = 'O código deve conter apenas números.';
    return;
  }

  isLoading.value = true;
  errorMessage.value = '';

  try {
    if (_tempEmail == null) {
      errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
      return;
    }

    // Retrieve code from Firestore
    final doc = await _firestore
        .collection('emailVerifications')
        .doc(_tempEmail!)
        .get();

    if (!doc.exists) {
      errorMessage.value = 'Código não encontrado. Solicite um novo código.';
      return;
    }

    final data = doc.data()!;
    final storedCode = data['code'] as String;
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();

    // Check if code has expired (> 10 minutes)
    if (DateTime.now().isAfter(expiresAt)) {
      errorMessage.value = 'Código expirado. Solicite um novo código.';
      return;
    }

    // Check if code matches
    if (sanitizedCode != storedCode) {
      errorMessage.value = 'Código inválido. Verifique e tente novamente.';
      return;
    }

    // Delete OTP document after successful verification
    await _firestore
        .collection('emailVerifications')
        .doc(_tempEmail!)
        .delete();

    // Code is valid - proceed to account finalization
    await finalizeAccount();
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    errorMessage.value = 'Erro ao verificar código. Tente novamente.';
  } finally {
    isLoading.value = false;
  }
}
```

### Complete createAccount Implementation

```dart
/// Creates Firebase Auth account and sends verification code
Future<void> createAccount() async {
  // Sanitize and validate email
  final sanitizedEmail = userEmail.value.trim().toLowerCase();
  final emailError = validateEmail(sanitizedEmail);
  if (emailError != null) {
    errorMessage.value = emailError;
    return;
  }

  // Validate password
  final passwordError = validatePassword(userPassword.value);
  if (passwordError != null) {
    errorMessage.value = passwordError;
    return;
  }

  isLoading.value = true;
  errorMessage.value = '';

  try {
    // Create Firebase Auth user with sanitized email
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: sanitizedEmail,
      password: userPassword.value,
    );

    // Update email observable with sanitized version
    userEmail.value = sanitizedEmail;

    // Send verification code
    await sendVerificationCode();
  } on FirebaseAuthException catch (e) {
    errorMessage.value = _handleFirebaseAuthError(e);
  } catch (e) {
    errorMessage.value = 'Não foi possível criar sua conta. Tente novamente.';
  } finally {
    isLoading.value = false;
  }
}
```

### Complete resendVerificationCode Implementation

```dart
/// Resends verification code (follows AuthController pattern)
Future<void> resendVerificationCode() async {
  if (_tempEmail == null) {
    errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
    return;
  }

  isLoading.value = true;
  errorMessage.value = '';

  try {
    // Generate new OTP code
    final code = _generateOTP();

    // Store code in Firestore with expiration
    await _firestore.collection('emailVerifications').doc(_tempEmail!).set({
      'code': code,
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 10))
      ),
      'attempts': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ⚠️ CRITICAL - SAME PROBLEM AS sendVerificationCode ⚠️
    // TODO: [PRODUCTION REQUIRED] Implement email sending
    // Code is generated but user does NOT receive email
    // See detailed comments in sendVerificationCode()

    // Restart 60-second resend timer
    _startResendTimer();

    // Success feedback
    Get.snackbar(
      'Código reenviado',
      'Um novo código foi enviado para seu e-mail.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    errorMessage.value = 'Não foi possível reenviar o código. Tente novamente.';
  } finally {
    isLoading.value = false;
  }
}
```

## Priority

**HIGH PRIORITY** - These patterns improve:
1. User experience (immediate validation feedback)
2. Performance (fewer Firestore queries)
3. Security (email sanitization prevents issues)
4. Developer experience (better documentation)
5. Consistency (matches AuthController implementation)

## Next Steps

1. Review this document
2. Update design.md with all code examples
3. Update requirements.md with new acceptance criteria
4. Update tasks.md with enhanced task descriptions
5. Update IMPLEMENTATION_NOTES.md with summary
6. Proceed with implementation following updated spec
