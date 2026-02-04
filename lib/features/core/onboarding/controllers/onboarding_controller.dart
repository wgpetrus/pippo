// Dart SDK
import 'dart:async';
import 'dart:math';

// Flutter
import 'package:flutter/foundation.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports locais
import '../../../../shared/utils/language_helper.dart';
import '../../../../shared/utils/validation_helper.dart';
import '../navigation/onboarding_navigation.dart';

/// Controller do fluxo de onboarding
class OnboardingController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Estados adicionais
  final isAddingCourse = false.obs;
  final skipWelcome = false.obs;
  final authProvider = ''.obs;
  final showLoginOption = false.obs;
  
  // Estados de retry (task 8.2)
  final retryAttempt = 0.obs;
  final retryMessage = ''.obs;

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

  // Dados OTP
  final resendTimer = 0.obs;

  // Estado privado
  String? _tempEmail;
  String? _tempPassword; // Armazenado temporariamente apenas para criação da conta
  Timer? _resendCountdownTimer;
  bool _retryCancelled = false; // Flag simples para cancelamento de retry

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
  bool shouldSkipEmail() => authProvider.value == 'google';
  
  /// Verifica se deve pular tela de senha (login social)
  bool shouldSkipPassword() => authProvider.value == 'google';
  
  /// Verifica se deve pular verificação OTP (login social)
  bool shouldSkipVerifyCode() => authProvider.value == 'google';

  /// Lida com skip welcome (usuário autenticado retornando ao onboarding)
  Future<void> handleSkipWelcome() async {
    await configureAuthenticatedUser();
    nav.goToSelectLanguage();
  }

  /// Configura dados do usuário autenticado (login com onboarding incompleto)
  Future<void> configureAuthenticatedUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    // Carregar dados básicos do Firebase Auth
    userEmail.value = user.email ?? '';
    userName.value = user.displayName ?? '';
    
    // Detectar provider
    final providers = user.providerData.map((p) => p.providerId).toList();
    if (providers.contains('google.com')) {
      authProvider.value = 'google';
    } else {
      authProvider.value = 'email';
    }
    
    // Carregar dados parciais do Firestore (se existirem)
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 30));
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        
        // Carregar dados do onboarding se existirem
        if (data['name'] != null) userName.value = data['name'];
        if (data['age'] != null) userAge.value = data['age'];
        
        if (kDebugMode) {
          debugPrint('✅ Dados parciais carregados do Firestore');
          debugPrint('   - name: ${userName.value}');
          debugPrint('   - age: ${userAge.value}');
        }
        
        // Verificar se há curso parcial (usuário pode ter saído no meio)
        final coursesSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('courses')
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 30));
        
        if (coursesSnapshot.docs.isNotEmpty) {
          final courseData = coursesSnapshot.docs.first.data();
          
          // Carregar dados do curso
          if (courseData['language'] != null) selectedLanguage.value = courseData['language'];
          if (courseData['level'] != null) languageLevel.value = courseData['level'];
          if (courseData['reason'] != null) learningReason.value = courseData['reason'];
          if (courseData['studyTime'] != null) {
            final studyTimeValue = courseData['studyTime'] as int;
            studyTime.value = '$studyTimeValue min / dia';
          }
          
          if (kDebugMode) {
            debugPrint('✅ Dados do curso carregados');
            debugPrint('   - language: ${selectedLanguage.value}');
            debugPrint('   - level: ${languageLevel.value}');
            debugPrint('   - reason: ${learningReason.value}');
            debugPrint('   - studyTime: ${studyTime.value}');
          }
        }
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('⚠️ Timeout ao carregar dados do Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erro ao carregar dados do Firestore: $e');
      }
    }
  }

  // Métodos públicos - Criação de conta

  /// Sai do fluxo de onboarding
  /// Deleta usuário do Firebase Auth e volta para tela de boas-vindas
  Future<void> exitOnboarding() async {
    try {
      // Obter usuário atual
      final user = _auth.currentUser;
      
      if (user != null) {
        if (kDebugMode) {
          debugPrint('🚪 Saindo do onboarding - deletando usuário: ${user.uid}');
        }
        
        // Deletar usuário do Firebase Auth
        await user.delete();
        
        if (kDebugMode) {
          debugPrint('✅ Usuário deletado com sucesso');
        }
      }
      
      // Limpar dados temporários (SEGURANÇA: limpar senha da memória)
      _tempEmail = null;
      _tempPassword = null;
      
      // Cancelar timer de reenvio
      _resendCountdownTimer?.cancel();
      resendTimer.value = 0;
      
      // Limpar todos os estados
      errorMessage.value = '';
      showLoginOption.value = false;
      retryMessage.value = '';
      retryAttempt.value = 0;
      
      // Limpar dados do onboarding
      selectedLanguage.value = '';
      languageLevel.value = '';
      learningReason.value = '';
      studyTime.value = '';
      userName.value = '';
      userAge.value = '';
      userEmail.value = '';
      
      // Voltar para tela de boas-vindas (limpa stack de navegação)
      Get.offAllNamed('/onboarding');
      
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro Firebase ao sair do onboarding: ${e.code}');
      }
      
      // Limpar dados mesmo com erro
      _tempEmail = null;
      _tempPassword = null;
      
      // Mesmo com erro, voltar para welcome
      // Usuário pode ter sido deletado ou não estar mais autenticado
      Get.offAllNamed('/onboarding');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao sair do onboarding: $e');
      }
      
      // Limpar dados mesmo com erro
      _tempEmail = null;
      _tempPassword = null;
      
      // Mesmo com erro, voltar para welcome
      Get.offAllNamed('/onboarding');
    }
  }

  /// Define a senha temporariamente (chamado pela view antes de createAccount)
  void setPassword(String password) {
    _tempPassword = password;
  }

  /// Cria conta no Firebase Auth e envia código OTP
  Future<void> createAccount() async {
    isLoading.value = true;
    errorMessage.value = '';
    showLoginOption.value = false; // Resetar estado

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

      // Validate password (recebida como parâmetro, não armazenada)
      // SEGURANÇA: Senha nunca é armazenada em memória após criação da conta
      if (_tempPassword == null || _tempPassword!.isEmpty) {
        errorMessage.value = 'Senha é obrigatória.';
        return;
      }

      final passwordError = validatePassword(_tempPassword);
      if (passwordError != null) {
        errorMessage.value = passwordError;
        return;
      }

      // Update with sanitized values
      userName.value = sanitizedName;
      userEmail.value = sanitizedEmail;

      // Verificar se email já existe no Firestore (outro método de auth)
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
          // Email já existe - verificar provider
          final existingUserData = emailQuery.docs.first.data();
          final existingProvider = existingUserData['authProvider'] as String?;
          
          if (existingProvider == 'google') {
            // Email já existe com login do Google
            errorMessage.value = 'Já existe uma conta com este e-mail usando login do Google. Por favor, faça login com Google.';
            showLoginOption.value = true;
          } else {
            // Email já existe com outro método de autenticação
            errorMessage.value = 'Este e-mail já está sendo usado por outra conta.';
            showLoginOption.value = true;
          }
          return;
        }
      } on TimeoutException {
        errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
        return;
      } on FirebaseException catch (e) {
        errorMessage.value = _handleFirestoreError(e);
        return;
      }

      // Criar usuário no Firebase Auth com retry
      await _retryWithBackoff(() async {
        if (kDebugMode) {
          debugPrint('📝 Tentando criar usuário');
        }
        
        await _auth.createUserWithEmailAndPassword(
          email: sanitizedEmail,
          password: _tempPassword!,
        );
        
        if (kDebugMode) {
          debugPrint('✅ Usuário criado com sucesso');
        }
      });

      // Limpar senha da memória imediatamente após uso
      _tempPassword = null;

      // Gerar e enviar código OTP
      await sendVerificationCode();
    } on FirebaseAuthException catch (e) {
      // Detectar erro de email já existente
      if (e.code == 'email-already-in-use') {
        errorMessage.value = 'Este e-mail já está sendo usado por outra conta.';
        showLoginOption.value = true; // Mostrar opção de ir para login
      } else {
        errorMessage.value = _handleFirebaseAuthError(e);
      }
      // Limpar senha em caso de erro também
      _tempPassword = null;
    } catch (e) {
      errorMessage.value = 'Não foi possível criar sua conta. Tente novamente.';
      // Limpar senha em caso de erro também
      _tempPassword = null;
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos públicos - Verificação OTP

  /// Cancela o processo de verificação
  /// Deleta o usuário criado no Firebase Auth e volta para tela anterior
  Future<void> cancelVerification() async {
    try {
      // Obter usuário atual
      final user = _auth.currentUser;
      
      if (user != null) {
        if (kDebugMode) {
          debugPrint('🗑️ Deletando usuário criado: ${user.uid}');
        }
        
        // Deletar usuário do Firebase Auth
        await user.delete();
        
        if (kDebugMode) {
          debugPrint('✅ Usuário deletado com sucesso');
        }
      }
      
      // Limpar dados temporários (SEGURANÇA: limpar senha da memória)
      _tempEmail = null;
      _tempPassword = null;
      
      // Cancelar timer de reenvio
      _resendCountdownTimer?.cancel();
      resendTimer.value = 0;
      
      // Limpar estados de erro
      errorMessage.value = '';
      showLoginOption.value = false;
      
      // Voltar para tela anterior (user_password)
      Get.back();
      
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro Firebase ao cancelar verificação: ${e.code}');
      }
      
      // Limpar dados mesmo com erro
      _tempEmail = null;
      _tempPassword = null;
      
      // Mesmo com erro, voltar para tela anterior
      // Usuário pode ter sido deletado ou não estar mais autenticado
      Get.back();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao cancelar verificação: $e');
      }
      
      // Limpar dados mesmo com erro
      _tempEmail = null;
      _tempPassword = null;
      
      // Mesmo com erro, voltar para tela anterior
      Get.back();
    }
  }

  /// Envia código de verificação OTP
  Future<void> sendVerificationCode() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Gerar código OTP
      final code = _generateOTP();

      // Salvar código no Firestore com expiração (com retry)
      await _retryWithBackoff(() async {
        await _firestore.collection('emailVerifications').doc(userEmail.value).set({
          'code': code,
          'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
          'attempts': 0,
          'createdAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 30));
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
      }).timeout(const Duration(seconds: 30));

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
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
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
      await completeOnboarding();
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
      final doc = await _firestore.collection('emailVerifications').doc(_tempEmail!).get()
          .timeout(const Duration(seconds: 30));

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
      await _firestore.collection('emailVerifications').doc(_tempEmail!).delete()
          .timeout(const Duration(seconds: 30));

      // Cancelar timer de reenvio
      _resendCountdownTimer?.cancel();
      resendTimer.value = 0;
      
      // Limpar email temporário (não mais necessário)
      _tempEmail = null;

      debugPrint('✅ verifyCode: Código verificado com sucesso. Chamando completeOnboarding...');
      
      // Prosseguir para finalização da conta e navegação
      await completeOnboarding();
      
      debugPrint('✅ verifyCode: completeOnboarding finalizado.');
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

  // Métodos privados - Helpers

  /// Gera username único a partir do nome do usuário
  Future<String> _generateUniqueUsername(String name) async {
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
            .get()
            .timeout(const Duration(seconds: 30));

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
    } on TimeoutException {
      throw Exception('Tempo de espera esgotado. Verifique sua conexão e tente novamente.');
    } on FirebaseException catch (e) {
      throw Exception(_handleFirestoreError(e));
    } catch (e) {
      throw Exception('Erro ao verificar nome de usuário. Tente novamente.');
    }
  }

  // Métodos públicos - Finalização de conta

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

        // Senha já foi validada e limpa após createAccount
        // Não precisa validar novamente aqui
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
      if (learningReason.value.isEmpty) {
        errorMessage.value = 'Selecione o motivo de aprendizado.';
        return;
      }
      if (studyTime.value.isEmpty) {
        errorMessage.value = 'Selecione o tempo de estudo.';
        return;
      }

      // Extrair número da string studyTime (ex: "10 min / dia" → 10)
      final studyTimeMatch = RegExp(r'(\d+)').firstMatch(studyTime.value);
      final studyTimeValue = studyTimeMatch != null ? int.tryParse(studyTimeMatch.group(1)!) : null;
      if (studyTimeValue == null || studyTimeValue <= 0) {
        errorMessage.value = 'Tempo de estudo inválido.';
        return;
      }
      
      // Validar userName e userAge apenas se não for login social
      if (authProvider.value != 'google') {
        if (userName.value.isEmpty) {
          errorMessage.value = 'Digite seu nome.';
          return;
        }
        if (userAge.value.isEmpty) {
          errorMessage.value = 'Selecione sua idade.';
          return;
        }
      }

      // Verificar se documento do usuário já existe no Firestore
      final userDocSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (userDocSnapshot.exists) {
        // Documento já existe (criado pelo AuthController no login social)
        // Verificar se onboarding já foi completado
        final existingData = userDocSnapshot.data()!;
        final alreadyCompleted = existingData['onboardingCompleted'] ?? false;
        
        if (alreadyCompleted) {
          // Onboarding já foi completado anteriormente - não criar duplicados
          debugPrint('⚠️ Onboarding já foi completado. Pulando criação.');
          
          // Salvar isFirstAccess = false no SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isFirstAccess', false);
          
          // Resetar isLoading antes de retornar para permitir navegação
          isLoading.value = false;
          
          // Não navega aqui - deixa completeOnboarding() navegar
          return;
        }
        
        // Documento existe mas onboarding não foi completado
        // Continuar para atualizar documento e criar curso/stats
        debugPrint('📝 Documento existe mas onboarding incompleto. Atualizando...');
      }

      // Gerar username único a partir do userName (já sanitizado)
      final username = await _generateUniqueUsername(userName.value);

      // BATCH WRITE - Operação atômica (tudo ou nada) com retry
      await _retryWithBackoff(() async {
        final batch = _firestore.batch();

        // 1. Documento do usuário
        final userRef = _firestore.collection('users').doc(user.uid);
        
        if (userDocSnapshot.exists) {
          // Atualizar documento existente (login social)
          batch.update(userRef, {
            'name': userName.value,
            'searchName': userName.value.toLowerCase(), // Para busca case-insensitive
            'username': username,
            'age': userAge.value,
            'onboardingCompleted': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Criar novo documento (email/senha)
          batch.set(userRef, {
            'id': user.uid,
            'email': userEmail.value,
            'name': userName.value,
            'searchName': userName.value.toLowerCase(), // Para busca case-insensitive
            'username': username,
            'age': userAge.value,
            'authProvider': authProvider.value.isEmpty ? 'email' : authProvider.value,
            'onboardingCompleted': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // 2. Documento do curso
        final courseRef = userRef.collection('courses').doc();
        batch.set(courseRef, {
          'id': courseRef.id,
          'language': selectedLanguage.value,
          'languageName': _getLanguageName(selectedLanguage.value),
          'level': languageLevel.value,
          'reason': learningReason.value,
          'studyTime': studyTimeValue,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. Estatísticas de gamificação
        final statsRef = userRef.collection('stats').doc('gamification');
        batch.set(statsRef, {
          'xp': 0,
          'level': 1,
          'streak': 0,
          'energy': 5,
          'gems': 0,
          'hearts': 5,
          'lastActiveAt': FieldValue.serverTimestamp(),
        });

        // Commit batch - se qualquer operação falhar, nenhuma é aplicada
        await batch.commit().timeout(const Duration(seconds: 30));
      });

      // Salvar isFirstAccess = false no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);

      // Sucesso - não navega aqui, deixa completeOnboarding() navegar
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
      // Dados permanecem em memória (userName, userEmail, etc.) para retry
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      // Dados permanecem em memória (userName, userEmail, etc.) para retry
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      // Dados permanecem em memória para retry
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

      // Extrair número da string studyTime (ex: "10 min / dia" → 10)
      final studyTimeMatch = RegExp(r'(\d+)').firstMatch(studyTime.value);
      final studyTimeValue = studyTimeMatch != null ? int.tryParse(studyTimeMatch.group(1)!) : null;
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
      }).timeout(const Duration(seconds: 30));

      // NÃO modificar documento do usuário
      // NÃO modificar estatísticas de gamificação
      // NÃO atualizar SharedPreferences

      // Sucesso - não navega aqui, deixa completeOnboarding() navegar
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
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
    debugPrint('🚀 completeOnboarding: Iniciando...');
    
    // Verificar modo (add course ou novo usuário)
    if (isAddingCourse.value) {
      debugPrint('📚 completeOnboarding: Modo add course');
      // Modo add course: apenas criar novo curso
      await addNewCourse();
    } else {
      debugPrint('👤 completeOnboarding: Modo novo usuário');
      // Modo novo usuário: criar documento do usuário, primeiro curso e stats
      await finalizeAccount();
    }

    debugPrint('✅ completeOnboarding: Finalizou. ErrorMessage: "${errorMessage.value}"');
    
    // Navegar para /home usando Get.offAllNamed apenas se não houver erro
    if (errorMessage.value.isEmpty) {
      debugPrint('🏠 completeOnboarding: Navegando para home...');
      nav.finishOnboarding();
    } else {
      debugPrint('❌ completeOnboarding: Não navegou devido a erro: ${errorMessage.value}');
    }
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

  /// Cancela o retry em andamento
  void cancelRetry() {
    _retryCancelled = true;
    retryMessage.value = 'Operação cancelada.';
    
    if (kDebugMode) {
      debugPrint('🚫 Retry cancelado pelo usuário');
    }
  }

  // Métodos privados

  /// Wrapper de retry com exponential backoff
  /// 
  /// Executa [operation] até 3 vezes com backoff exponencial:
  /// - Tentativa 1: imediata
  /// - Tentativa 2: após 2 segundos
  /// - Tentativa 3: após 4 segundos
  /// 
  /// Retorna o resultado da operação se bem-sucedida.
  /// Lança a última exceção se todas as tentativas falharem.
  Future<T> _retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
  }) async {
    int attempt = 0;
    Exception? lastException;
    
    // Resetar flag de cancelamento no início
    _retryCancelled = false;

    while (attempt < maxAttempts) {
      // Verificar se retry foi cancelado
      if (_retryCancelled) {
        if (kDebugMode) {
          debugPrint('🚫 Retry cancelado na tentativa $attempt');
        }
        
        // Limpar estado de retry
        retryAttempt.value = 0;
        retryMessage.value = '';
        
        throw Exception('Operação cancelada pelo usuário.');
      }
      
      try {
        attempt++;
        
        // Atualizar estado de retry para feedback visual
        retryAttempt.value = attempt;
        if (attempt > 1) {
          retryMessage.value = 'Tentativa $attempt de $maxAttempts...';
        }
        
        if (kDebugMode) {
          debugPrint('🔄 Tentativa $attempt de $maxAttempts');
        }

        // Executar operação
        final result = await operation();
        
        // Limpar estado de retry após sucesso
        retryAttempt.value = 0;
        retryMessage.value = '';
        _retryCancelled = false;
        
        if (kDebugMode && attempt > 1) {
          debugPrint('✅ Operação bem-sucedida na tentativa $attempt');
        }
        
        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        if (kDebugMode) {
          debugPrint('❌ Tentativa $attempt falhou: ${e.toString()}');
        }

        // Se não é a última tentativa, aguardar antes de tentar novamente
        if (attempt < maxAttempts) {
          // Exponential backoff: 2^(attempt-1) segundos
          // Tentativa 1 → 0s (imediata)
          // Tentativa 2 → 2s
          // Tentativa 3 → 4s
          final delaySeconds = attempt == 1 ? 0 : pow(2, attempt - 1).toInt();
          
          if (delaySeconds > 0) {
            retryMessage.value = 'Aguardando ${delaySeconds}s antes da próxima tentativa...';
            
            if (kDebugMode) {
              debugPrint('⏳ Aguardando ${delaySeconds}s antes da próxima tentativa...');
            }
            
            // Aguardar com verificação de cancelamento a cada 100ms
            for (int i = 0; i < delaySeconds * 10; i++) {
              if (_retryCancelled) {
                if (kDebugMode) {
                  debugPrint('🚫 Retry cancelado durante aguardo');
                }
                
                // Limpar estado de retry
                retryAttempt.value = 0;
                retryMessage.value = '';
                
                throw Exception('Operação cancelada pelo usuário.');
              }
              await Future.delayed(const Duration(milliseconds: 100));
            }
          }
        }
      }
    }

    // Todas as tentativas falharam - limpar estado de retry
    retryAttempt.value = 0;
    retryMessage.value = '';
    _retryCancelled = false;
    
    // Todas as tentativas falharam
    if (kDebugMode) {
      debugPrint('💥 Todas as $maxAttempts tentativas falharam');
    }
    
    throw lastException!;
  }

  /// Retorna o nome do idioma a partir do código
  String _getLanguageName(String code) {
    return LanguageHelper.getLanguageName(code);
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
