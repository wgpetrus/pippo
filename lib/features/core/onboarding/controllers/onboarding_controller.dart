import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/onboarding_navigation.dart';

/// Controller do fluxo de onboarding
class OnboardingController extends GetxController {
  // Flag estático para pular WelcomeView (setado antes da navegação)
  static bool shouldSkipWelcome = false;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Estados adicionais
  final isAddingCourse = false.obs;
  
  // Flag para pular WelcomeView (quando vem de login social)
  final skipWelcome = false.obs;

  // Navegação
  final nav = OnboardingNavigation();

  // Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Dados do onboarding - Idioma
  final selectedLanguage = ''.obs;
  final languageLevel = ''.obs;
  final learningReason = ''.obs;

  // Dados do onboarding - Tempo
  final studyTime = ''.obs;

  // Dados do onboarding - Perfil
  final userName = ''.obs;
  final userAge = ''.obs;
  final userEmail = ''.obs;
  final userPassword = ''.obs;

  // OTP data (follows AuthController pattern)
  final resendTimer = 0.obs; // Countdown timer for resend (60 seconds)

  // Private state
  String? _tempEmail; // Temporary email storage for OTP operations
  Timer? _resendCountdownTimer; // Timer instance for countdown

  // Lifecycle
  @override
  void onClose() {
    _resendCountdownTimer?.cancel();
    super.onClose();
  }

  // Validadores

  /// Valida nome do usuário
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório.';
    }
    return null;
  }

  /// Valida e-mail do usuário
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório.';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  /// Valida senha do usuário
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória.';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  // Métodos públicos

  /// Cria conta no Firebase Auth e envia código OTP
  Future<void> createAccount() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
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

      // Update with sanitized email
      userEmail.value = sanitizedEmail;

      // Criar usuário no Firebase Auth
      await _auth.createUserWithEmailAndPassword(
        email: sanitizedEmail,
        password: userPassword.value,
      );

      // Gerar e enviar código OTP
      await sendVerificationCode();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseAuthError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível criar sua conta. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Envia código de verificação OTP
  Future<void> sendVerificationCode() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Generate OTP code
      final code = _generateOTP();

      // Store code in Firestore with expiration
      await _firestore.collection('emailVerifications').doc(userEmail.value).set({
        'code': code,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ⚠️ CRITICAL - INCOMPLETE IMPLEMENTATION ⚠️
      // TODO: [PRODUCTION REQUIRED] Implement email sending
      // 
      // CURRENT PROBLEM:
      // - Code is generated and saved to Firestore ✅
      // - BUT user does NOT receive email with code ❌
      // - For testing now: access Firestore Console and copy code manually
      // 
      // PRODUCTION SOLUTION:
      // Option 1 (Recommended): Cloud Function
      //   1. Create Cloud Function that listens to new documents in 'emailVerifications'
      //   2. Function sends email via SendGrid/Mailgun/AWS SES
      //   3. Code never exposed in client (more secure)
      // 
      // Option 2 (Alternative): Direct Email Service
      //   1. Integrate email package (emailjs, sendgrid_mailer)
      //   2. Send email directly from app
      //   3. Less secure (API key in client)
      // 
      // REFERENCES:
      // - Firebase Cloud Functions: https://firebase.google.com/docs/functions
      // - SendGrid: https://sendgrid.com/
      // - Mailgun: https://www.mailgun.com/
      // 
      // ⚠️ DO NOT DEPLOY TO PRODUCTION WITHOUT IMPLEMENTING EMAIL SENDING ⚠️

      // Store email temporarily for resend
      _tempEmail = userEmail.value;

      // Start 60-second resend timer
      _startResendTimer();

      // Navigate to verification screen
      nav.goToVerifyCode();
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível enviar o código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Reenvia código de verificação OTP (segue padrão do AuthController)
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
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
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

  /// Verifica código OTP (segue padrão do AuthController)
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
      final doc = await _firestore.collection('emailVerifications').doc(_tempEmail!).get();

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

      // Code is valid - delete OTP document
      await _firestore.collection('emailVerifications').doc(_tempEmail!).delete();

      // Cancel resend timer
      _resendCountdownTimer?.cancel();
      resendTimer.value = 0;

      // Proceed to account finalization
      await finalizeAccount();
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao verificar código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Gera username único a partir do nome do usuário
  /// Converte para lowercase, remove espaços, e adiciona número se necessário
  Future<String> generateUniqueUsername(String name) async {
    try {
      // Sanitize name: convert to lowercase, remove spaces and special characters
      String baseUsername = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), ''); // Remove non-alphanumeric characters
      
      // Ensure username is not empty after sanitization
      if (baseUsername.isEmpty) {
        baseUsername = 'user';
      }
      
      String username = baseUsername;
      int attempts = 0;
      const maxAttempts = 100;

      while (attempts < maxAttempts) {
        // Query Firestore for existing username
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        // If username doesn't exist, return it
        if (querySnapshot.docs.isEmpty) {
          return username;
        }

        // Username exists, append random number (1-9999)
        final random = Random().nextInt(9999) + 1;
        username = '$baseUsername$random';
        attempts++;
      }

      // Max attempts reached
      throw Exception('Não foi possível gerar um nome de usuário único.');
    } on FirebaseException catch (e) {
      throw Exception(_handleFirestoreError(e));
    } catch (e) {
      throw Exception('Erro ao verificar nome de usuário. Tente novamente.');
    }
  }

  /// Cria documento do usuário no Firestore
  Future<void> createUserDocument(String userId, String username) async {
    try {
      // Sanitize inputs before saving
      final sanitizedEmail = userEmail.value.trim().toLowerCase();
      final sanitizedName = userName.value.trim();
      
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'email': sanitizedEmail,
        'name': sanitizedName,
        'username': username,
        'age': userAge.value,
        'onboardingCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception(_handleFirestoreError(e));
    } catch (e) {
      throw Exception('Erro ao criar documento do usuário. Tente novamente.');
    }
  }

  /// Cria primeiro curso do usuário no Firestore
  Future<void> createFirstCourse(String userId) async {
    try {
      // Validate studyTime is a valid integer
      final studyTimeValue = int.tryParse(studyTime.value);
      if (studyTimeValue == null || studyTimeValue <= 0) {
        throw Exception('Tempo de estudo inválido.');
      }
      
      // Generate course ID using Firestore auto-generated ID
      final courseRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(); // Auto-generated ID
      
      final courseId = courseRef.id;

      await courseRef.set({
        'id': courseId,
        'language': selectedLanguage.value,
        'languageName': _getLanguageName(selectedLanguage.value),
        'level': languageLevel.value,
        'reason': learningReason.value,
        'studyTime': studyTimeValue,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception(_handleFirestoreError(e));
    } catch (e) {
      throw Exception('Erro ao criar curso. Tente novamente.');
    }
  }

  /// Inicializa estatísticas de gamificação do usuário
  Future<void> initializeGamificationStats(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('gamification')
          .set({
        'xp': 0,
        'level': 1,
        'streak': 0,
        'energy': 5,
        'gems': 0,
        'hearts': 5,
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception(_handleFirestoreError(e));
    } catch (e) {
      throw Exception('Erro ao inicializar estatísticas. Tente novamente.');
    }
  }

  /// Finaliza a criação da conta (cria documentos no Firestore)
  Future<void> finalizeAccount() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Get current Firebase Auth user ID
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      // Generate unique username from userName
      final username = await generateUniqueUsername(userName.value);

      // Create user document
      await createUserDocument(user.uid, username);

      // Create first course
      await createFirstCourse(user.uid);

      // Initialize gamification stats
      await initializeGamificationStats(user.uid);

      // Save isFirstAccess = false to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);

      // Navigate to conclusion screen
      nav.goToConclusion();
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Adiciona novo curso para usuário existente (modo add course)
  /// Não modifica documento do usuário nem estatísticas de gamificação
  Future<void> addNewCourse() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Verify user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      // Get user ID from authenticated user
      final userId = user.uid;

      // Validate studyTime is a valid integer
      final studyTimeValue = int.tryParse(studyTime.value);
      if (studyTimeValue == null || studyTimeValue <= 0) {
        errorMessage.value = 'Tempo de estudo inválido.';
        return;
      }

      // Generate course ID using Firestore auto-generated ID
      final courseRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(); // Auto-generated ID
      
      final courseId = courseRef.id;

      // Create course document at users/{userId}/courses/{courseId}
      await courseRef.set({
        'id': courseId,
        'language': selectedLanguage.value,
        'languageName': _getLanguageName(selectedLanguage.value),
        'level': languageLevel.value,
        'reason': learningReason.value,
        'studyTime': studyTimeValue,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Do NOT modify user document
      // Do NOT modify gamification stats
      // Do NOT update SharedPreferences

      // Navigate to conclusion screen
      nav.goToConclusion();
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao adicionar curso. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Completa o onboarding
  /// Verifica o modo (add course ou novo usuário) e chama o método apropriado
  Future<void> completeOnboarding() async {
    // Check isAddingCourse flag
    if (isAddingCourse.value) {
      // Add course mode: only create new course
      await addNewCourse();
    } else {
      // New user mode: create user document, first course, and stats
      await finalizeAccount();
    }

    // Navigate to /home using Get.offAllNamed in both cases
    nav.finishOnboarding();
  }

  /// Calcula o progresso atual do onboarding
  /// Retorna a posição atual e o total de telas (ex: {current: 1, total: 9})
  /// Exclui telas de transição da contagem
  Map<String, int> calculateProgress(String currentScreen) {
    // Define screen order for full onboarding (9 screens - excludes transitions)
    final fullOnboardingScreens = [
      'select_language',
      'language_level',
      'learning_reason',
      'study_time',
      'user_name',
      'user_age',
      'user_email',
      'user_password',
      'verify_code',
    ];

    // Define screen order for add course mode (4 screens)
    final addCourseScreens = [
      'select_language',
      'language_level',
      'learning_reason',
      'study_time',
    ];

    // Select appropriate screen list based on mode
    final screens = isAddingCourse.value ? addCourseScreens : fullOnboardingScreens;
    final total = screens.length;

    // Find current position (1-indexed)
    final index = screens.indexOf(currentScreen);
    final current = index >= 0 ? index + 1 : 1;

    return {'current': current, 'total': total};
  }

  // Métodos privados

  /// Retorna o nome do idioma a partir do código
  String _getLanguageName(String code) {
    final languageMap = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ar': 'Arabic',
    };
    return languageMap[code] ?? code;
  }

  /// Gera código OTP de 5 dígitos (segue padrão do AuthController)
  String _generateOTP() {
    final random = Random();
    final code = (10000 + random.nextInt(90000)).toString();
    return code;
  }

  /// Inicia timer de reenvio de 60 segundos (segue padrão do AuthController)
  void _startResendTimer() {
    resendTimer.value = 60;
    _resendCountdownTimer?.cancel();

    _resendCountdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (resendTimer.value > 0) {
          resendTimer.value--;
        } else {
          timer.cancel();
        }
      },
    );
  }

  // Handlers

  /// Handler de erros do Firebase Auth (padrão da empresa)
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está sendo usado por outra conta.';
      case 'invalid-email':
        return 'Por favor, insira um e-mail válido.';
      case 'operation-not-allowed':
        return 'Operação não permitida no momento.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      default:
        return 'Não foi possível criar sua conta. Tente novamente.';
    }
  }

  /// Handler de erros do Firestore (padrão da empresa)
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
      case 'failed-precondition':
        return 'Operação não permitida no estado atual. Tente novamente.';
      case 'aborted':
        return 'Operação cancelada. Tente novamente.';
      case 'out-of-range':
        return 'Valor fora do intervalo permitido.';
      case 'unimplemented':
        return 'Operação não implementada.';
      case 'internal':
        return 'Erro interno do servidor. Tente novamente em alguns instantes.';
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'not-found':
        return 'Recurso não encontrado.';
      case 'already-exists':
        return 'Recurso já existe.';
      case 'cancelled':
        return 'Operação cancelada.';
      case 'data-loss':
        return 'Erro de integridade de dados.';
      case 'invalid-argument':
        return 'Argumento inválido.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }
}
