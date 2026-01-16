import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../views/forgot_password_view.dart';
import '../views/new_password_view.dart';
import '../views/verify_code_view.dart';

/// Controller de autenticação
class AuthController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados para recuperação de senha (públicos para UI)
  final resendTimer = 0.obs;

  // Email temporário para reenvio de código
  String? _tempEmail;

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _secureStorage = const FlutterSecureStorage();

  // Timer para countdown de reenvio
  Timer? _resendCountdownTimer;

  // Lifecycle

  @override
  void onClose() {
    _resendCountdownTimer?.cancel();
    super.onClose();
  }

  // Validadores

  /// Valida email (retorna mensagem de erro ou null se válido)
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório.';
    if (!GetUtils.isEmail(value)) return 'Por favor, insira um e-mail válido.';
    return null;
  }

  /// Valida senha (retorna mensagem de erro ou null se válido)
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória.';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
    return null;
  }

  // Métodos de ação

  /// Realiza login com email e senha
  /// Assume que os dados já foram validados pela View
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Autenticar via Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Buscar documento do usuário no Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        errorMessage.value = 'Dados do usuário não encontrados.';
        return;
      }

      final userData = userDoc.data()!;
      final onboardingCompleted = userData['onboardingCompleted'] ?? false;

      if (!onboardingCompleted) {
        // Onboarding incompleto - navegar para onboarding
        Get.offAllNamed('/onboarding');
      } else {
        // Onboarding completo - atualizar lastActiveAt e navegar para home
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
          'lastActiveAt': FieldValue.serverTimestamp(),
        });

        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseLoginError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível fazer login. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos de recuperação de senha

  /// Gera código OTP de 5 dígitos
  String _generateOTP() {
    final random = Random();
    final code = (10000 + random.nextInt(90000)).toString();
    return code;
  }

  /// Armazena OTP no FlutterSecureStorage com expiração de 10 minutos
  Future<void> _storeOTP(String code, String email) async {
    final expirationTime = DateTime.now().add(const Duration(minutes: 10));

    await _secureStorage.write(key: 'otp_code', value: code);
    await _secureStorage.write(key: 'otp_email', value: email);
    await _secureStorage.write(
      key: 'otp_expiration',
      value: expirationTime.toIso8601String(),
    );
  }

  /// Envia código de recuperação de senha por email
  Future<void> sendPasswordResetCode(String email) async {
    // Sanitizar e validar email
    final sanitizedEmail = email.trim();
    final emailError = validateEmail(sanitizedEmail);
    if (emailError != null) {
      errorMessage.value = emailError;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Gerar código OTP
      final code = _generateOTP();

      // Enviar email via Firebase Auth
      await _auth.sendPasswordResetEmail(email: sanitizedEmail);

      // Armazenar código com expiração
      await _storeOTP(code, sanitizedEmail);

      // Armazenar email temporariamente para reenvio
      _tempEmail = sanitizedEmail;

      // Iniciar timer de reenvio (60 segundos)
      _startResendTimer();

      // Navegar para tela de verificação
      goToVerifyCode();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseResetPasswordError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível enviar o código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Reenvia código de recuperação de senha
  Future<void> resendPasswordResetCode() async {
    if (_tempEmail == null) {
      errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Gerar novo código OTP
      final code = _generateOTP();

      // Enviar email via Firebase Auth
      await _auth.sendPasswordResetEmail(email: _tempEmail!);

      // Armazenar novo código com expiração
      await _storeOTP(code, _tempEmail!);

      // Reiniciar timer de reenvio (60 segundos)
      _startResendTimer();

      // Feedback de sucesso
      Get.snackbar(
        'Código reenviado',
        'Um novo código foi enviado para seu e-mail.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseResetPasswordError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível reenviar o código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Inicia timer de reenvio de 60 segundos
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

  /// Verifica código OTP
  Future<void> verifyCode(String code) async {
    // Sanitizar código (remover espaços)
    final sanitizedCode = code.trim();

    // Validar que o código tem exatamente 5 dígitos
    if (sanitizedCode.length != 5) {
      errorMessage.value = 'O código deve ter 5 dígitos.';
      return;
    }

    // Validar que o código contém apenas números
    final digitRegex = RegExp(r'^\d{5}$');
    if (!digitRegex.hasMatch(sanitizedCode)) {
      errorMessage.value = 'O código deve conter apenas números.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Recuperar OTP armazenado
      final storedCode = await _secureStorage.read(key: 'otp_code');
      final storedExpirationStr = await _secureStorage.read(key: 'otp_expiration');

      if (storedCode == null || storedExpirationStr == null) {
        errorMessage.value = 'Código não encontrado. Solicite um novo código.';
        return;
      }

      // Verificar se o código expirou (> 10 minutos)
      final storedExpiration = DateTime.parse(storedExpirationStr);
      if (DateTime.now().isAfter(storedExpiration)) {
        errorMessage.value = 'Código expirado. Solicite um novo código.';
        return;
      }

      // Verificar se o código corresponde
      if (sanitizedCode != storedCode) {
        errorMessage.value = 'Código inválido. Verifique e tente novamente.';
        return;
      }

      // Código válido - navegar para tela de nova senha
      goToNewPassword();
    } catch (e) {
      errorMessage.value = 'Erro ao verificar código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Redefine senha do usuário
  Future<void> resetPassword(String newPassword) async {
    // Validar senha
    final passwordError = validatePassword(newPassword);
    if (passwordError != null) {
      errorMessage.value = passwordError;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Recuperar email armazenado
      final email = await _secureStorage.read(key: 'otp_email');

      if (email == null) {
        errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
        return;
      }

      // Obter usuário atual
      final user = _auth.currentUser;

      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      // Atualizar senha via Firebase Auth
      await user.updatePassword(newPassword);

      // Limpar OTP do secure storage
      await _secureStorage.delete(key: 'otp_code');
      await _secureStorage.delete(key: 'otp_email');
      await _secureStorage.delete(key: 'otp_expiration');

      // Limpar email temporário
      _tempEmail = null;

      // Navegar para login com mensagem de sucesso
      Get.snackbar(
        'Sucesso',
        'Senha redefinida com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      backToSignin();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseResetPasswordError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível redefinir a senha. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Error handlers

  /// Handler de erros de login do Firebase Auth (mensagens em português)
  String _handleFirebaseLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Verifique e tente novamente.';
      case 'invalid-email':
        return 'Por favor, insira um e-mail válido.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Entre em contato com o suporte.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Não foi possível fazer login. Tente novamente.';
    }
  }

  /// Handler de erros de reset de senha do Firebase Auth
  String _handleFirebaseResetPasswordError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail.';
      case 'invalid-email':
        return 'Por favor, insira um e-mail válido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      default:
        return 'Não foi possível enviar o e-mail de recuperação. Tente novamente.';
    }
  }

  // Navegação
  void goToForgotPassword() => Get.to(() => const ForgotPasswordView());
  void goToVerifyCode() => Get.to(() => const VerifyCodeView());
  void goToNewPassword() => Get.to(() => const NewPasswordView());
  void backToSignin() => Get.offAllNamed('/auth');

  // Logout

  /// Realiza logout do usuário mantendo isFirstAccess = false
  Future<void> logout() async {
    try {
      // Limpar dados sensíveis do FlutterSecureStorage
      await _secureStorage.deleteAll();

      // Logout do Firebase Auth
      await _auth.signOut();

      // IMPORTANTE: NÃO resetar isFirstAccess para true
      // O usuário já passou pelo onboarding, então isFirstAccess deve permanecer false
      // Apenas limpar outros dados se necessário

      // Navegar para tela de autenticação
      Get.offAllNamed('/auth');
    } catch (e) {
      errorMessage.value = 'Erro ao fazer logout. Tente novamente.';
    }
  }
}
