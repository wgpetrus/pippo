import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/utils/validation_helper.dart';
import '../navigation/onboarding_navigation.dart';

/// Controller do fluxo de onboarding
class OnboardingController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Estados adicionais
  final isAddingCourse = false.obs;
  
  // Flag para pular WelcomeView (quando vem de login social)
  final skipWelcome = false.obs;
  
  // Provider de autenticação ('email' ou 'google')
  final authProvider = ''.obs;

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

  // Dados OTP
  final resendTimer = 0.obs;

  // Estado privado
  String? _tempEmail;
  Timer? _resendCountdownTimer;

  // Lifecycle
  @override
  void onClose() {
    _resendCountdownTimer?.cancel();
    super.onClose();
  }

  // Validadores

  /// Valida nome do usuário
  String? validateName(String? value) {
    return ValidationHelper.validateName(value);
  }

  /// Valida e-mail do usuário
  String? validateEmail(String? value) {
    return ValidationHelper.validateEmail(value);
  }

  /// Valida senha do usuário
  String? validatePassword(String? value) {
    return ValidationHelper.validatePassword(value);
  }
  
  // Métodos de verificação de fluxo
  
  /// Verifica se deve pular tela de email (login social)
  bool shouldSkipEmail() => authProvider.value == 'google';
  
  /// Verifica se deve pular tela de senha (login social)
  bool shouldSkipPassword() => authProvider.value == 'google';
  
  /// Verifica se deve pular verificação OTP (login social)
  bool shouldSkipVerifyCode() => authProvider.value == 'google';

  // Métodos públicos

  /// Cria conta no Firebase Auth e envia código OTP
  Future<void> createAccount() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Sanitize and validate name
      final sanitizedName = ValidationHelper.sanitizeName(userName.value);
      final nameError = validateName(sanitizedName);
      if (nameError != null) {
        errorMessage.value = nameError;
        return;
      }

      // Sanitize and validate email
      final sanitizedEmail = ValidationHelper.sanitizeEmail(userEmail.value);
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

      // Update with sanitized values
      userName.value = sanitizedName;
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
      // Gerar código OTP
      final code = _generateOTP();

      // Salvar código no Firestore com expiração
      await _firestore.collection('emailVerifications').doc(userEmail.value).set({
        'code': code,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ⚠️ IMPLEMENTAÇÃO INCOMPLETA - ENVIO DE EMAIL ⚠️
      // TODO: [PRODUÇÃO] Implementar envio de email
      // 
      // PROBLEMA ATUAL:
      // - Código gerado e salvo no Firestore ✅
      // - MAS usuário NÃO recebe email com código ❌
      // - Para testes: acessar Firestore Console e copiar código manualmente
      // 
      // SOLUÇÃO PARA PRODUÇÃO:
      // Opção 1 (Recomendada): Cloud Function
      //   - Criar Cloud Function que escuta novos docs em 'emailVerifications'
      //   - Function envia email via SendGrid/Mailgun/AWS SES
      //   - Mais seguro (código nunca exposto no cliente)
      // 
      // Opção 2: Serviço de Email Direto
      //   - Integrar package de email (emailjs, sendgrid_mailer)
      //   - Enviar email direto do app
      //   - Menos seguro (API key no cliente)
      // 
      // ⚠️ NÃO FAZER DEPLOY EM PRODUÇÃO SEM IMPLEMENTAR ENVIO DE EMAIL ⚠️

      // Armazenar email temporariamente para reenvio
      _tempEmail = userEmail.value;

      // Iniciar timer de 60 segundos
      _startResendTimer();

      // Log em modo debug
      if (kDebugMode) {
        debugPrint('🔓 DEBUG MODE: Código OTP salvo no Firestore');
        debugPrint('📧 Email: ${userEmail.value}');
        debugPrint('🔑 Código: $code (copie do Firestore Console)');
      }

      // Navegar para tela de verificação
      nav.goToVerifyCode();
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
    if (_tempEmail == null) {
      errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Gerar novo código OTP
      final code = _generateOTP();

      // Salvar código no Firestore com expiração
      await _firestore.collection('emailVerifications').doc(_tempEmail!).set({
        'code': code,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ⚠️ MESMO PROBLEMA DO sendVerificationCode ⚠️
      // TODO: [PRODUÇÃO] Implementar envio de email
      // Ver comentários detalhados em sendVerificationCode()

      // Reiniciar timer de 60 segundos
      _startResendTimer();

      // Log em modo debug
      if (kDebugMode) {
        debugPrint('🔓 DEBUG MODE: Novo código OTP salvo no Firestore');
        debugPrint('📧 Email: $_tempEmail');
        debugPrint('🔑 Código: $code (copie do Firestore Console)');
      }

      // Feedback de sucesso
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

  /// Verifica código OTP com bypass em debug mode
  Future<void> verifyCode(String code) async {
    // Sanitizar código (remover espaços)
    final sanitizedCode = code.trim();

    // BYPASS EM DEBUG MODE
    if (kDebugMode && sanitizedCode == '00000') {
      debugPrint('🔓 DEBUG MODE: Bypass OTP com código $sanitizedCode');
      await finalizeAccount();
      return;
    }

    // Validar código tem exatamente 5 dígitos
    if (sanitizedCode.length != 5) {
      errorMessage.value = 'O código deve ter 5 dígitos.';
      return;
    }

    // Validar código contém apenas números
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

      // Buscar código no Firestore
      final doc = await _firestore.collection('emailVerifications').doc(_tempEmail!).get();

      if (!doc.exists) {
        errorMessage.value = 'Código não encontrado. Solicite um novo código.';
        return;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      // Verificar se código expirou (> 10 minutos)
      if (DateTime.now().isAfter(expiresAt)) {
        errorMessage.value = 'Código expirado. Solicite um novo código.';
        return;
      }

      // Verificar se código corresponde
      if (sanitizedCode != storedCode) {
        errorMessage.value = 'Código inválido. Verifique e tente novamente.';
        return;
      }

      // Código válido - deletar documento OTP
      await _firestore.collection('emailVerifications').doc(_tempEmail!).delete();

      // Cancelar timer de reenvio
      _resendCountdownTimer?.cancel();
      resendTimer.value = 0;

      // Prosseguir para finalização da conta
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
  Future<String> generateUniqueUsername(String name) async {
    try {
      // Sanitizar nome: lowercase, remover espaços e caracteres especiais
      String baseUsername = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
      
      // Garantir que username não está vazio após sanitização
      if (baseUsername.isEmpty) {
        baseUsername = 'user';
      }
      
      String username = baseUsername;
      int attempts = 0;
      const maxAttempts = 100;

      while (attempts < maxAttempts) {
        // Buscar username existente no Firestore
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        // Se username não existe, retornar
        if (querySnapshot.docs.isEmpty) {
          return username;
        }

        // Username existe, adicionar número aleatório (1-9999)
        final random = Random().nextInt(9999) + 1;
        username = '$baseUsername$random';
        attempts++;
      }

      // Máximo de tentativas atingido
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
      final sanitizedEmail = ValidationHelper.sanitizeEmail(userEmail.value);
      final sanitizedName = ValidationHelper.sanitizeName(userName.value);
      
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
      // Validar studyTime é um inteiro válido
      final studyTimeValue = int.tryParse(studyTime.value);
      if (studyTimeValue == null || studyTimeValue <= 0) {
        throw Exception('Tempo de estudo inválido.');
      }
      
      // Gerar ID do curso usando Firestore auto-generated ID
      final courseRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc();
      
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
      // Obter usuário autenticado do Firebase Auth
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      // Sanitizar dados antes de validar
      userName.value = ValidationHelper.sanitizeName(userName.value);
      
      // Sanitizar email apenas se não for login social
      if (authProvider.value != 'google') {
        userEmail.value = ValidationHelper.sanitizeEmail(userEmail.value);
      }

      // Validar todos os dados antes de salvar
      final nameError = validateName(userName.value);
      if (nameError != null) {
        errorMessage.value = nameError;
        return;
      }

      // Validar email e senha apenas se não for login social
      if (authProvider.value != 'google') {
        final emailError = validateEmail(userEmail.value);
        if (emailError != null) {
          errorMessage.value = emailError;
          return;
        }

        final passwordError = validatePassword(userPassword.value);
        if (passwordError != null) {
          errorMessage.value = passwordError;
          return;
        }
      }

      // Validar outros campos
      if (selectedLanguage.value.isEmpty) {
        errorMessage.value = 'Selecione um idioma.';
        return;
      }
      if (languageLevel.value.isEmpty) {
        errorMessage.value = 'Selecione um nível.';
        return;
      }
      if (studyTime.value.isEmpty) {
        errorMessage.value = 'Selecione o tempo de estudo.';
        return;
      }

      // Gerar username único a partir do userName (já sanitizado)
      final username = await generateUniqueUsername(userName.value);

      // Criar documento do usuário
      await createUserDocument(user.uid, username);

      // Criar primeiro curso
      await createFirstCourse(user.uid);

      // Inicializar estatísticas de gamificação
      await initializeGamificationStats(user.uid);

      // Salvar isFirstAccess = false no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);

      // Navegar para tela de conclusão
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
  Future<void> addNewCourse() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Verificar se usuário está autenticado
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      final userId = user.uid;

      // Validar studyTime é um inteiro válido
      final studyTimeValue = int.tryParse(studyTime.value);
      if (studyTimeValue == null || studyTimeValue <= 0) {
        errorMessage.value = 'Tempo de estudo inválido.';
        return;
      }

      // Gerar ID do curso usando Firestore auto-generated ID
      final courseRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc();
      
      final courseId = courseRef.id;

      // Criar documento do curso em users/{userId}/courses/{courseId}
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

      // NÃO modificar documento do usuário
      // NÃO modificar estatísticas de gamificação
      // NÃO atualizar SharedPreferences

      // Navegar para tela de conclusão
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
  Future<void> completeOnboarding() async {
    // Verificar modo (add course ou novo usuário)
    if (isAddingCourse.value) {
      // Modo add course: apenas criar novo curso
      await addNewCourse();
    } else {
      // Modo novo usuário: criar documento do usuário, primeiro curso e stats
      await finalizeAccount();
    }

    // Navegar para /home usando Get.offAllNamed em ambos os casos
    nav.finishOnboarding();
  }

  /// Calcula o progresso atual do onboarding
  Map<String, int> calculateProgress(String currentScreen) {
    // Definir ordem das telas para onboarding completo (9 telas - exclui transições)
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

    // Definir ordem das telas para modo add course (4 telas)
    final addCourseScreens = [
      'select_language',
      'language_level',
      'learning_reason',
      'study_time',
    ];

    // Selecionar lista apropriada baseado no modo
    final screens = isAddingCourse.value ? addCourseScreens : fullOnboardingScreens;
    final total = screens.length;

    // Encontrar posição atual (1-indexed)
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

  /// Gera código OTP de 5 dígitos
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
