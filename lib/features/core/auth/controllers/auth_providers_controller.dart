import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../inners/gamification/controllers/gems_controller.dart';
import '../../../inners/gamification/controllers/xp_level_controller.dart';
import '../../../inners/gamification/controllers/streak_controller.dart';
import '../../../inners/gamification/controllers/energy_controller.dart';
import '../../../../shared/utils/error_handler.dart';
import '../views/forgot_password_view.dart';
import '../views/new_password_view.dart';
import '../views/verify_code_view.dart';

class AuthProvidersController extends GetxController {
  // Dependency Injection com valores padrão (backward compatible)
  AuthProvidersController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FlutterSecureStorage? secureStorage,
    GoogleSignIn? googleSignIn,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final resendTimer = 0.obs;

  final showLoginButton = false.obs;

  String? _tempEmail;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;
  final GoogleSignIn _googleSignIn;

  Timer? _resendCountdownTimer;

  @override
  void onClose() {
    _resendCountdownTimer?.cancel();
    super.onClose();
  }

  void onFacebookTap() {
    Get.snackbar(
      'coming_soon_title'.tr,
      'facebook_login_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    showLoginButton.value = false;

    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: googleUser.email)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 30));

      if (emailQuery.docs.isNotEmpty) {
        final existingUserData = emailQuery.docs.first.data();
        final existingProvider = existingUserData['authProvider'] as String?;

        if (existingProvider == 'email') {
          errorMessage.value = 'Já existe uma conta com este e-mail usando login por email/senha. Por favor, faça login com email e senha.';
          showLoginButton.value = true;

          return;
        }
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get()
          .timeout(const Duration(seconds: 30));

      if (!userDoc.exists) {
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'id': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'authProvider': 'google',
          'onboardingCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 30));

        Get.offAllNamed('/onboarding', arguments: {'skipWelcome': true});
      } else {
        final userData = userDoc.data()!;
        final onboardingCompleted = userData['onboardingCompleted'] ?? false;

        if (!onboardingCompleted) {
          Get.offAllNamed('/onboarding', arguments: {'skipWelcome': true});
        } else {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({
            'lastActiveAt': FieldValue.serverTimestamp(),
          }).timeout(const Duration(seconds: 30));

          Get.offAllNamed('/home');
        }
      }
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on PlatformException catch (e) {
      errorMessage.value = _handleGoogleSignInError(e);
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleGoogleSignInError(e);
    } catch (e) {
      errorMessage.value = 'Ocorreu um erro inesperado. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  void cancelPasswordReset() {
    _tempEmail = null;
    
    _resendCountdownTimer?.cancel();
    resendTimer.value = 0;
    
    errorMessage.value = '';
    
    backToSignin();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final sanitizedEmail = email.trim().toLowerCase();
    
    if (sanitizedEmail.isEmpty) {
      errorMessage.value = 'E-mail é obrigatório.';
      return;
    }
    if (!GetUtils.isEmail(sanitizedEmail)) {
      errorMessage.value = 'Por favor, insira um e-mail válido.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final code = _generateOTP();

      await _firestore.collection('passwordResets').doc(sanitizedEmail).set({
        'code': code,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 30));

      _tempEmail = sanitizedEmail;

      _startResendTimer();

      goToVerifyCode();
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível enviar o código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetLink(String email) async {
    final sanitizedEmail = email.trim().toLowerCase();
    
    if (sanitizedEmail.isEmpty) {
      errorMessage.value = 'E-mail é obrigatório.';
      return;
    }
    if (!GetUtils.isEmail(sanitizedEmail)) {
      errorMessage.value = 'Por favor, insira um e-mail válido.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _auth.sendPasswordResetEmail(email: sanitizedEmail);

      Get.snackbar(
        'reset_link_sent_title'.tr,
        'reset_link_sent_message'.trParams({'email': sanitizedEmail}),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      backToSignin();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseResetPasswordError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível enviar o link. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendPasswordResetCode() async {
    if (_tempEmail == null) {
      errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final code = _generateOTP();

      await _firestore.collection('passwordResets').doc(_tempEmail!).set({
        'code': code,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 30));

      _startResendTimer();

      Get.snackbar(
        'code_resent_title'.tr,
        'code_resent_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseResetPasswordError(e);
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível reenviar o código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyResetCode(String code) async {
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
      if (_tempEmail == null) {
        errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
        return;
      }

      final doc = await _firestore.collection('passwordResets').doc(_tempEmail!).get()
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

      goToNewPassword();
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'Erro ao verificar código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String newPassword) async {
    if (newPassword.isEmpty) {
      errorMessage.value = 'Senha é obrigatória.';
      return;
    }
    if (newPassword.length < 6) {
      errorMessage.value = 'A senha deve ter pelo menos 6 caracteres.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (_tempEmail == null) {
        errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
        return;
      }

      await _auth.sendPasswordResetEmail(email: _tempEmail!);

      await _firestore.collection('passwordResets').doc(_tempEmail!).delete()
          .timeout(const Duration(seconds: 30));

      _tempEmail = null;

      Get.snackbar(
        'reset_link_sent_title'.tr,
        'reset_link_sent_email'.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      backToSignin();
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseResetPasswordError(e);
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível redefinir a senha. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.deleteAll();

      await _auth.signOut();

      if (Get.isRegistered<GemsController>()) {
        Get.delete<GemsController>(force: true);
      }
      if (Get.isRegistered<XpLevelController>()) {
        Get.delete<XpLevelController>(force: true);
      }
      if (Get.isRegistered<StreakController>()) {
        Get.delete<StreakController>(force: true);
      }
      if (Get.isRegistered<EnergyController>()) {
        Get.delete<EnergyController>(force: true);
      }
      
      final controllersToDelete = [
        'HomeNavigationController',
        'HomeStatsController',
        'LessonFlowController',
        'LessonExerciseController',
        'LessonProgressController',
        'LessonRewardsController',
        'TreasureChallengesController',
        'TreasureRewardsController',
        'ShopController',
        'LeaderboardController',
        'ProfileDataController',
        'ProfileSettingsController',
        'ProfileSocialController',
        'ProfileCoursesController',
        'ProfileAuthController',
        'FriendsController',
      ];
      
      for (final controllerName in controllersToDelete) {
        try {
          Get.delete(tag: controllerName, force: true);
        } catch (e) {
        }
      }
      
      try {
        Get.deleteAll(force: true);
      } catch (e) {
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', true);

      Get.offAllNamed('/onboarding');
    } catch (e) {
      errorMessage.value = 'Erro ao fazer logout. Tente novamente.';
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

  String _handleFirebaseResetPasswordError(FirebaseAuthException e) {
    return ErrorHandler.getResetPasswordErrorMessage(e);
  }

  String _handleGoogleSignInError(dynamic error) {
    if (error is PlatformException && error.code == 'sign_in_canceled') {
      return '';
    }
    if (error is PlatformException && error.code == 'network_error') {
      return 'Verifique sua conexão com a internet.';
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
          showLoginButton.value = true;
          return 'Este e-mail já tem uma conta. Faça login com e-mail e senha.';
        case 'invalid-credential':
          return 'Credenciais inválidas. Tente novamente.';
        case 'operation-not-allowed':
          return 'Login com Google não está habilitado. Entre em contato com o suporte.';
        case 'user-disabled':
          return 'Esta conta foi desativada. Entre em contato com o suporte.';
        default:
          return 'Não foi possível fazer login com Google. Tente novamente.';
      }
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }

  void goToForgotPassword() => Get.to(() => const ForgotPasswordView());
  void goToVerifyCode() => Get.to(() => const VerifyCodeView());
  void goToNewPassword() => Get.to(() => const NewPasswordView());
  void backToSignin() => Get.offAllNamed('/auth');
}
