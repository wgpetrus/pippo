// Dart SDK
import 'dart:async';

// Flutter
import 'package:flutter/foundation.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports locais
import '../../../inners/home/controllers/home_controller.dart';
import '../navigation/onboarding_navigation.dart';
import 'onboarding_data_controller.dart';

/// Controller do fluxo de navegação do onboarding
class OnboardingFlowController extends GetxController {
  // Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados específicos
  final currentStep = ''.obs;

  // Navegação
  final nav = OnboardingNavigation();

  // Dependency
  late final OnboardingDataController _dataController;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _dataController = Get.find<OnboardingDataController>();
  }

  // Métodos públicos - Navegação

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
    _dataController.userEmail.value = user.email ?? '';
    _dataController.userName.value = user.displayName ?? '';

    // Detectar provider
    final providers = user.providerData.map((p) => p.providerId).toList();
    if (providers.contains('google.com')) {
      _dataController.authProvider.value = 'google';
    } else {
      _dataController.authProvider.value = 'email';
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
        if (data['name'] != null) _dataController.userName.value = data['name'];
        if (data['age'] != null) _dataController.userAge.value = data['age'];

        if (kDebugMode) {
          debugPrint('✅ Dados parciais carregados do Firestore');
          debugPrint('   - name: ${_dataController.userName.value}');
          debugPrint('   - age: ${_dataController.userAge.value}');
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
          if (courseData['language'] != null) {
            _dataController.selectedLanguage.value = courseData['language'];
          }
          if (courseData['level'] != null) {
            _dataController.languageLevel.value = courseData['level'];
          }
          if (courseData['reason'] != null) {
            _dataController.learningReason.value = courseData['reason'];
          }
          if (courseData['studyTime'] != null) {
            final studyTimeValue = courseData['studyTime'] as int;
            _dataController.studyTime.value = '$studyTimeValue min / dia';
          }

          if (kDebugMode) {
            debugPrint('✅ Dados do curso carregados');
            debugPrint('   - language: ${_dataController.selectedLanguage.value}');
            debugPrint('   - level: ${_dataController.languageLevel.value}');
            debugPrint('   - reason: ${_dataController.learningReason.value}');
            debugPrint('   - studyTime: ${_dataController.studyTime.value}');
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

      // Limpar dados temporários via DataController
      _dataController.clearAllData();

      // Limpar estados
      errorMessage.value = '';

      // Voltar para tela de boas-vindas (limpa stack de navegação)
      Get.offAllNamed('/onboarding');
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro Firebase ao sair do onboarding: ${e.code}');
      }

      // Limpar dados mesmo com erro
      _dataController.clearAllData();

      // Mesmo com erro, voltar para welcome
      Get.offAllNamed('/onboarding');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao sair do onboarding: $e');
      }

      // Limpar dados mesmo com erro
      _dataController.clearAllData();

      // Mesmo com erro, voltar para welcome
      Get.offAllNamed('/onboarding');
    }
  }

  /// Completa o onboarding
  Future<void> finishOnboarding() async {
    debugPrint('🚀 finishOnboarding: Iniciando...');

    // Verificar modo (add course ou novo usuário)
    if (_dataController.isAddingCourse.value) {
      debugPrint('📚 finishOnboarding: Modo add course');
      // Modo add course: apenas criar novo curso
      await _dataController.addNewCourse();

      // Recarregar dados do HomeController após adicionar curso
      if (errorMessage.value.isEmpty) {
        debugPrint('🔄 finishOnboarding: Recarregando HomeController...');
        try {
          final homeController = Get.find<HomeController>();
          await homeController.reloadAfterAddCourse();
          debugPrint('✅ finishOnboarding: HomeController recarregado');
        } catch (e) {
          debugPrint('⚠️ finishOnboarding: Erro ao recarregar HomeController: $e');
        }
      }
    } else {
      debugPrint('👤 finishOnboarding: Modo novo usuário');
      // Modo novo usuário: criar documento do usuário, primeiro curso e stats
      await _dataController.finalizeAccount();
    }

    debugPrint('✅ finishOnboarding: Finalizou. ErrorMessage: "${errorMessage.value}"');

    // Navegar para /home usando Get.offAllNamed apenas se não houver erro
    if (errorMessage.value.isEmpty) {
      debugPrint('🏠 finishOnboarding: Navegando para home...');
      nav.finishOnboarding();
    } else {
      debugPrint('❌ finishOnboarding: Não navegou devido a erro: ${errorMessage.value}');
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
    final screens = _dataController.isAddingCourse.value
        ? addCourseScreens
        : fullOnboardingScreens;
    final total = screens.length;

    // Encontrar posição atual (1-indexed)
    final index = screens.indexOf(currentScreen);
    final current = index >= 0 ? index + 1 : 1;

    return {'current': current, 'total': total};
  }
}
