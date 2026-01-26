// Dart SDK
import 'dart:async';
import 'dart:math';

// Flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports locais
import '../views/forgot_password_view.dart';
import '../views/new_password_view.dart';
import '../views/verify_code_view.dart';

/// Controller de autenticação
class AuthController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados para recuperação de senha
  final resendTimer = 0.obs;

  // Estado para mostrar botão de login (erro account-exists-with-different-credential)
  final showLoginButton = false.obs;

  // Email temporário para reenvio de código
  String? _tempEmail;

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _secureStorage = const FlutterSecureStorage();
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

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

  // Métodos públicos

  /// Realiza login com email e senha
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    showLoginButton.value = false; // Resetar estado

    try {
      // VERIFICAR ANTES DE AUTENTICAR: Se email existe no Firestore com provider Google
      if (kDebugMode) {
        debugPrint('🔍 Verificando se email $email já existe no Firestore');
      }
      
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 30));
      
      if (emailQuery.docs.isNotEmpty) {
        // Email já existe - verificar provider
        final existingUserData = emailQuery.docs.first.data();
        final existingProvider = existingUserData['authProvider'] as String?;
        
        if (kDebugMode) {
          debugPrint('⚠️ Email já existe com provider: $existingProvider');
        }
        
        if (existingProvider == 'google') {
          // Email já existe com login do Google - BLOQUEAR
          errorMessage.value = 'Já existe uma conta com este e-mail usando login do Google. Por favor, faça login com Google.';
          
          if (kDebugMode) {
            debugPrint('🚫 Login com email/senha bloqueado - email já tem conta Google');
          }
          
          return;
        }
        // Se provider é 'email', pode continuar
      }
      
      // Autenticar via Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Buscar documento do usuário no Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get()
          .timeout(const Duration(seconds: 30));

      if (!userDoc.exists) {
        // Documento não existe - criar documento básico e redirecionar para onboarding
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'id': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'authProvider': 'email',
          'onboardingCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 30));
        
        // Navegar para onboarding com argumento skipWelcome
        Get.offAllNamed('/onboarding', arguments: {'skipWelcome': true});
        return;
      }

      final userData = userDoc.data()!;
      final onboardingCompleted = userData['onboardingCompleted'] ?? false;

      if (!onboardingCompleted) {
        // Onboarding incompleto - navegar com argumento skipWelcome
        Get.offAllNamed('/onboarding', arguments: {'skipWelcome': true});
      } else {
        // Onboarding completo - atualizar lastActiveAt e navegar para home
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
          'lastActiveAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 30));

        Get.offAllNamed('/home');
      }
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseLoginError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível fazer login. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos de autenticação social

  /// Placeholder para login com Facebook
  void onFacebookTap() {
    Get.snackbar(
      'Em breve',
      'O login com Facebook estará disponível em breve.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Realiza login com Google
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    showLoginButton.value = false; // Resetar estado

    try {
      // Forçar seleção de conta (não usar conta em cache)
      // Isso garante que o usuário sempre veja a tela de seleção de contas
      await _googleSignIn.signOut();
      
      if (kDebugMode) {
        debugPrint('🔐 Iniciando login com Google');
      }
      
      // Iniciar fluxo de autenticação do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Se o usuário cancelou o login, retornar silenciosamente
      if (googleUser == null) {
        if (kDebugMode) {
          debugPrint('❌ Login com Google cancelado pelo usuário');
        }
        isLoading.value = false;
        return;
      }
      
      if (kDebugMode) {
        debugPrint('✅ Usuário Google selecionado: ${googleUser.email}');
      }

      // VERIFICAR ANTES DE AUTENTICAR: Se email já existe no Firestore com outro provider
      if (kDebugMode) {
        debugPrint('🔍 Verificando se email ${googleUser.email} já existe no Firestore');
      }
      
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: googleUser.email)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 30));
      
      if (emailQuery.docs.isNotEmpty) {
        // Email já existe - verificar provider
        final existingUserData = emailQuery.docs.first.data();
        final existingProvider = existingUserData['authProvider'] as String?;
        
        if (kDebugMode) {
          debugPrint('⚠️ Email já existe com provider: $existingProvider');
        }
        
        if (existingProvider == 'email') {
          // Email já existe com login por email/senha - BLOQUEAR
          errorMessage.value = 'Já existe uma conta com este e-mail usando login por email/senha. Por favor, faça login com email e senha.';
          showLoginButton.value = true;
          
          if (kDebugMode) {
            debugPrint('🚫 Login com Google bloqueado - email já tem conta email/senha');
          }
          
          return;
        }
        // Se provider é 'google', pode continuar (é o mesmo usuário)
      }

      // Obter credenciais de autenticação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Criar credencial do Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autenticar com Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Verificar se documento do usuário existe no Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get()
          .timeout(const Duration(seconds: 30));

      if (!userDoc.exists) {
        // Criar novo documento de usuário (email não existia antes)
        
        // Criar novo documento de usuário
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

        // Navegar para onboarding com argumento skipWelcome
        Get.offAllNamed('/onboarding', arguments: {'skipWelcome': true});
      } else {
        // Usuário existente - verificar onboarding
        final userData = userDoc.data()!;
        final onboardingCompleted = userData['onboardingCompleted'] ?? false;

        if (!onboardingCompleted) {
          // Navegar para onboarding com argumento skipWelcome
          Get.offAllNamed('/onboarding', arguments: {'skipWelcome': true});
        } else {
          // Onboarding completo - atualizar lastActiveAt e navegar para home
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

  // Métodos privados

  /// Gera código OTP de 5 dígitos
  /// 
  /// ⚠️ ATENÇÃO: Este código é gerado mas NÃO é enviado por email automaticamente
  /// Para testar em desenvolvimento: acessar Firestore Console e copiar o código
  /// Para produção: implementar envio de email (ver comentários em sendPasswordResetCode)
  String _generateOTP() {
    final random = Random();
    final code = (10000 + random.nextInt(90000)).toString();
    return code;
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

  // Métodos de recuperação de senha

  /// Cancela o processo de recuperação de senha
  /// Limpa dados temporários e volta para tela de login
  void cancelPasswordReset() {
    // Limpar dados temporários
    _tempEmail = null;
    
    // Cancelar timer de reenvio
    _resendCountdownTimer?.cancel();
    resendTimer.value = 0;
    
    // Limpar estados de erro
    errorMessage.value = '';
    
    // Voltar para tela de login
    backToSignin();
  }

  /// Envia código OTP para recuperação de senha
  /// 
  /// ⚠️ ATENÇÃO: Este código é gerado mas NÃO é enviado por email automaticamente
  /// Para testar em desenvolvimento: acessar Firestore Console e copiar o código
  /// Para produção: implementar envio de email via Cloud Function ou serviço de email
  Future<void> sendPasswordResetCode(String email) async {
    // Sanitizar e validar email
    final sanitizedEmail = email.trim().toLowerCase();
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

      // Armazenar código no Firestore com expiração
      await _firestore.collection('passwordResets').doc(sanitizedEmail).set({
        'code': code,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 30));

      // Armazenar email temporário para uso posterior
      _tempEmail = sanitizedEmail;

      // TODO: [PRODUÇÃO] Implementar envio de email
      // Opções:
      // 1. Cloud Function que escuta a collection passwordResets e envia email
      // 2. Serviço de email (SendGrid, AWS SES, etc)
      // 3. Firebase Extensions (Trigger Email)

      // Iniciar timer de reenvio (60 segundos)
      _startResendTimer();

      // Navegar para tela de verificação
      goToVerifyCode();
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível enviar o código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Envia link de recuperação de senha por email (método alternativo)
  /// 
  /// Este método usa o sistema nativo do Firebase Auth para enviar um link
  /// de reset de senha por email. O usuário clica no link e é redirecionado
  /// para uma página web do Firebase onde pode redefinir a senha.
  Future<void> sendPasswordResetLink(String email) async {
    // Sanitizar e validar email
    final sanitizedEmail = email.trim().toLowerCase();
    final emailError = validateEmail(sanitizedEmail);
    if (emailError != null) {
      errorMessage.value = emailError;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Enviar link de reset via Firebase Auth
      await _auth.sendPasswordResetEmail(email: sanitizedEmail);

      // Mostrar mensagem de sucesso
      Get.snackbar(
        'Link Enviado',
        'Um link para redefinir sua senha foi enviado para $sanitizedEmail',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      // Voltar para tela de login
      backToSignin();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseResetPasswordError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível enviar o link. Tente novamente.';
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

      // Armazenar código no Firestore com expiração
      await _firestore.collection('passwordResets').doc(_tempEmail!).set({
        'code': code,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 30));

      // TODO: [PRODUÇÃO] Implementar envio de email (ver sendPasswordResetCode)

      // Reiniciar timer de reenvio (60 segundos)
      _startResendTimer();

      // Feedback de sucesso
      Get.snackbar(
        'Código reenviado',
        'Um novo código foi enviado para seu e-mail.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseResetPasswordError(e);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível reenviar o código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifica código OTP
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
    // Sanitizar código (remover espaços)
    final sanitizedCode = code.trim();

    // Validar que o código tem exatamente 5 dígitos
    if (sanitizedCode.length != 5) {
      errorMessage.value = 'O código deve ter 5 dígitos.';
      return;
    }

    // Validar que o código contém apenas números
    final digitRegex = RegExp(r'^\d{5}$$');
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

      // Recuperar código do Firestore
      final doc = await _firestore.collection('passwordResets').doc(_tempEmail!).get()
          .timeout(const Duration(seconds: 30));

      if (!doc.exists) {
        errorMessage.value = 'Código não encontrado. Solicite um novo código.';
        return;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      // Verificar se o código expirou (> 10 minutos)
      if (DateTime.now().isAfter(expiresAt)) {
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
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao verificar código. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Redefine senha do usuário após verificação do código OTP
  /// 
  /// ⚠️ LIMITAÇÃO ATUAL: Este método envia um link de reset por email
  /// ao invés de redefinir a senha diretamente. Isso ocorre porque o Firebase Auth
  /// não permite reset direto de senha sem reautenticação ou Admin SDK.
  /// 
  /// TODO: [MELHORIA] Implementar reset direto via Cloud Function com Admin SDK
  /// Isso permitiria redefinir a senha diretamente após validação do OTP,
  /// sem necessidade de enviar outro email.
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
      if (_tempEmail == null) {
        errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
        return;
      }

      // TODO: [MELHORIA] Implementar reset direto via Cloud Function com Admin SDK
      // Atualmente usa sendPasswordResetEmail (usuário precisa clicar no link)

      // Enviar link de reset via Firebase Auth
      await _auth.sendPasswordResetEmail(email: _tempEmail!);

      // Limpar documento do Firestore
      await _firestore.collection('passwordResets').doc(_tempEmail!).delete()
          .timeout(const Duration(seconds: 30));

      // Limpar email temporário
      _tempEmail = null;

      // Navegar para login com mensagem de sucesso
      Get.snackbar(
        'Link Enviado',
        'Um link para redefinir sua senha foi enviado para seu e-mail.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      backToSignin();
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseResetPasswordError(e);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível redefinir a senha. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Handlers

  /// Handler de erros de login do Firebase Auth
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

  /// Handler de erros do Firestore
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
        return 'Recurso não encontrado.';
      case 'already-exists':
        return 'Recurso já existe.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }

  /// Handler de erros do Google Sign-In
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
          // Mostrar botão de login para este erro específico
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

  // Navegação

  void goToForgotPassword() => Get.to(() => const ForgotPasswordView());
  void goToVerifyCode() => Get.to(() => const VerifyCodeView());
  void goToNewPassword() => Get.to(() => const NewPasswordView());
  void backToSignin() => Get.offAllNamed('/auth');

  // Logout

  /// Realiza logout do usuário e reseta flag de primeiro acesso
  Future<void> logout() async {
    try {
      // Limpar dados sensíveis do FlutterSecureStorage
      await _secureStorage.deleteAll();

      // Logout do Firebase Auth
      await _auth.signOut();

      // Resetar isFirstAccess para true para que o usuário volte ao welcome
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', true);

      // Navegar para onboarding (welcome)
      Get.offAllNamed('/onboarding');
    } catch (e) {
      errorMessage.value = 'Erro ao fazer logout. Tente novamente.';
    }
  }
}
