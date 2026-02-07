// Dart SDK
import 'dart:async';
import 'dart:math';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Imports locais
import '../../../../shared/utils/error_handler.dart';
import '../../../../shared/utils/validation_helper.dart';
import '../navigation/onboarding_navigation.dart';
import 'onboarding_data_controller.dart';
import 'onboarding_flow_controller.dart';

/// Controller de validação do onboarding
class OnboardingValidationController extends GetxController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Constructor com DI
  OnboardingValidationController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final resendTimer = 0.obs;

  // Navegação
  final nav = OnboardingNavigation();

  // Dependency
  late final OnboardingDataController _dataController;

  // Estado privado
  Timer? _resendCountdownTimer;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _dataController = Get.find<OnboardingDataController>();
  }

  @override
  void onClose() {
    _resendCountdownTimer?.cancel();
    super.onClose();
  }

  // Validadores
  String? validateName(String? value) => ValidationHelper.validateName(value);
  String? validateEmail(String? value) => ValidationHelper.validateEmail(value);
  String? validatePassword(String? value) => ValidationHelper.validatePassword(value);

  // Métodos de verificação de fluxo
  bool shouldSkipEmail() => _dataController.authProvider.value == 'google';
  bool shouldSkipPassword() => _dataController.authProvider.value == 'google';
  bool shouldSkipVerifyCode() => _dataController.authProvider.value == 'google';

  // Métodos públicos

  /// Cria conta no Firebase Auth e envia código OTP
  Future<void> createAccount() async {
    isLoading.value = true;
    errorMessage.value = '';
    _dataController.showLoginOption.value = false;

    try {
      final sanitizedName = ValidationHelper.sanitizeName(_dataController.userName.value);
      final nameError = validateName(sanitizedName);
      if (nameError != null) {
        errorMessage.value = nameError;
        return;
      }

      final sanitizedEmail =
          ValidationHelper.sanitizeEmail(_dataController.userEmail.value);
      final emailError = validateEmail(sanitizedEmail);
      if (emailError != null) {
        errorMessage.value = emailError;
        return;
      }

      if (_dataController.tempPassword == null ||
          _dataController.tempPassword!.isEmpty) {
        errorMessage.value = 'Senha é obrigatória.';
        return;
      }

      final passwordError = validatePassword(_dataController.tempPassword);
      if (passwordError != null) {
        errorMessage.value = passwordError;
        return;
      }

      _dataController.userName.value = sanitizedName;
      _dataController.userEmail.value = sanitizedEmail;

      try {
        final emailQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: sanitizedEmail)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 30));

        if (emailQuery.docs.isNotEmpty) {
          final existingUserData = emailQuery.docs.first.data();
          final existingProvider = existingUserData['authProvider'] as String?;

          if (existingProvider == 'google') {
            errorMessage.value =
                'Já existe uma conta com este e-mail usando login do Google. Por favor, faça login com Google.';
            _dataController.showLoginOption.value = true;
          } else {
            errorMessage.value = 'Este e-mail já está sendo usado por outra conta.';
            _dataController.showLoginOption.value = true;
          }
          return;
        }
      } on TimeoutException {
        errorMessage.value =
            'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
        return;
      } on FirebaseException catch (e) {
        errorMessage.value = _handleFirestoreError(e);
        return;
      }

      await _dataController.retryWithBackoff(() async {
        await _auth.createUserWithEmailAndPassword(
          email: sanitizedEmail,
          password: _dataController.tempPassword!,
        );
      });

      _dataController.setUserPassword('');
      await sendVerificationCode();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        errorMessage.value = 'Este e-mail já está sendo usado por outra conta.';
        _dataController.showLoginOption.value = true;
      } else {
        errorMessage.value = _handleFirebaseAuthError(e);
      }
      _dataController.setUserPassword('');
    } catch (e) {
      errorMessage.value = 'Não foi possível criar sua conta. Tente novamente.';
      _dataController.setUserPassword('');
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancela o processo de verificação
  Future<void> cancelVerification() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await user.delete();
      }

      _dataController.tempEmail = null;
      _dataController.setUserPassword('');
      _resendCountdownTimer?.cancel();
      resendTimer.value = 0;
      errorMessage.value = '';
      _dataController.showLoginOption.value = false;
      Get.back();
    } on FirebaseAuthException catch (_) {
      _dataController.tempEmail = null;
      _dataController.setUserPassword('');
      Get.back();
    } catch (_) {
      _dataController.tempEmail = null;
      _dataController.setUserPassword('');
      Get.back();
    }
  }

  /// Envia código de verificação OTP
  Future<void> sendVerificationCode() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final code = _generateOTP();

      await _dataController.retryWithBackoff(() async {
        await _firestore
            .collection('emailVerifications')
            .doc(_dataController.userEmail.value)
            .set({
          'code': code,
          'expiresAt':
              Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
          'attempts': 0,
          'createdAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 30));
      });

      // TODO: [PRODUÇÃO] Implementar envio de email
      // Opção 1: Cloud Function (recomendada)
      // Opção 2: Serviço de Email Direto

      _dataController.tempEmail = _dataController.userEmail.value;
      _startResendTimer();

      nav.goToVerifyCode();
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível enviar o código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Reenvia código de verificação OTP
  Future<void> resendVerificationCode() async {
    if (_dataController.tempEmail == null) {
      errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final code = _generateOTP();

      await _firestore
          .collection('emailVerifications')
          .doc(_dataController.tempEmail!)
          .set({
        'code': code,
        'expiresAt':
            Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 30));

      // TODO: [PRODUÇÃO] Implementar envio de email

      _startResendTimer();

      Get.snackbar(
        'Código reenviado',
        'Um novo código foi enviado para seu e-mail.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível reenviar o código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifica código OTP com bypass em debug mode
  Future<void> verifyCode(String code) async {
    final sanitizedCode = code.trim();

    if (sanitizedCode.length != 5) {
      errorMessage.value = 'O código deve ter 5 dígitos.';
      return;
    }

    final digitRegex = RegExp(r'^\d{5}$');
    if (!digitRegex.hasMatch(sanitizedCode)) {
      errorMessage.value = 'O código deve conter apenas números.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (_dataController.tempEmail == null) {
        errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
        return;
      }

      final doc = await _firestore
          .collection('emailVerifications')
          .doc(_dataController.tempEmail!)
          .get()
          .timeout(const Duration(seconds: 30));

      if (!doc.exists) {
        errorMessage.value = 'Código não encontrado. Solicite um novo código.';
        return;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        errorMessage.value = 'Código expirado. Solicite um novo código.';
        return;
      }

      if (sanitizedCode != storedCode) {
        errorMessage.value = 'Código inválido. Verifique e tente novamente.';
        return;
      }

      await _firestore
          .collection('emailVerifications')
          .doc(_dataController.tempEmail!)
          .delete()
          .timeout(const Duration(seconds: 30));

      _resendCountdownTimer?.cancel();
      resendTimer.value = 0;
      _dataController.tempEmail = null;
      final flowController = Get.find<OnboardingFlowController>();
      await flowController.finishOnboarding();
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao verificar código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  String _generateOTP() {
    final random = Random();
    final code = (10000 + random.nextInt(90000)).toString();
    return code;
  }

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

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    return ErrorHandler.getRegisterErrorMessage(e);
  }

  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
  }
}
