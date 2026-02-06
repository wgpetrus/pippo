// Dart SDK
import 'dart:async';
import 'dart:math';

// Flutter
import 'package:flutter/foundation.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Imports locais
import '../../../../shared/utils/validation_helper.dart';
import '../navigation/onboarding_navigation.dart';
import 'onboarding_data_controller.dart';
import 'onboarding_flow_controller.dart';

/// Controller de validação do onboarding
class OnboardingValidationController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

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

      if (kDebugMode) {
        debugPrint('🔍 Verificando se email já existe no Firestore');
      }

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
        if (kDebugMode) {
          debugPrint('📝 Tentando criar usuário');
        }

        await _auth.createUserWithEmailAndPassword(
          email: sanitizedEmail,
          password: _dataController.tempPassword!,
        );

        if (kDebugMode) {
          debugPrint('✅ Usuário criado com sucesso');
        }
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
        if (kDebugMode) {
          debugPrint('🗑️ Deletando usuário criado: ${user.uid}');
        }
        await user.delete();
        if (kDebugMode) {
          debugPrint('✅ Usuário deletado com sucesso');
        }
      }

      _dataController.tempEmail = null;
      _dataController.setUserPassword('');
      _resendCountdownTimer?.cancel();
      resendTimer.value = 0;
      errorMessage.value = '';
      _dataController.showLoginOption.value = false;
      Get.back();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro Firebase ao cancelar verificação: ${e.code}');
      }
      _dataController.tempEmail = null;
      _dataController.setUserPassword('');
      Get.back();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao cancelar verificação: $e');
      }
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

      if (kDebugMode) {
        debugPrint('🔓 DEBUG MODE: Código OTP salvo no Firestore');
        debugPrint('📧 Email: ${_dataController.userEmail.value}');
        debugPrint('🔑 Código: $code (copie do Firestore Console)');
      }

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

      if (kDebugMode) {
        debugPrint('🔓 DEBUG MODE: Novo código OTP salvo no Firestore');
        debugPrint('📧 Email: ${_dataController.tempEmail}');
        debugPrint('🔑 Código: $code (copie do Firestore Console)');
      }

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

    if (kDebugMode && sanitizedCode == '00000') {
      debugPrint('🔓 DEBUG MODE: Bypass OTP com código $sanitizedCode');
      final flowController = Get.find<OnboardingFlowController>();
      await flowController.finishOnboarding();
      return;
    }

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

      debugPrint('✅ verifyCode: Código verificado com sucesso. Chamando finishOnboarding...');

      final flowController = Get.find<OnboardingFlowController>();
      await flowController.finishOnboarding();

      debugPrint('✅ verifyCode: finishOnboarding finalizado.');
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
          .where('username', isEqualTo: username)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 30));

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao verificar username: $e');
      }
      return false;
    }
  }

  // Métodos privados

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
