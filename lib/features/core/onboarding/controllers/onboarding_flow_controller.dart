// Dart SDK
import 'dart:async';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Imports locais
import '../../../inners/home/controllers/home_stats_controller.dart';
import '../navigation/onboarding_navigation.dart';
import 'onboarding_data_controller.dart';

/// Controller do fluxo de navegação do onboarding
class OnboardingFlowController extends GetxController {
  // Firebase
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Constructor com DI
  OnboardingFlowController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados específicos
  final currentStep = ''.obs;
  final skipWelcome = false.obs;

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
        }
      }
    } on TimeoutException {
    } catch (e) {
    }
  }

  /// Sai do fluxo de onboarding
  /// Deleta usuário do Firebase Auth e volta para tela de boas-vindas
  Future<void> exitOnboarding() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Deletar usuário do Firebase Auth
        await user.delete();
      }

      // Limpar dados temporários via DataController
      _dataController.clearAllData();

      // Limpar estados
      errorMessage.value = '';

      // Voltar para tela de boas-vindas (limpa stack de navegação)
      Get.offAllNamed('/onboarding');
    } on FirebaseAuthException catch (_) {
      // Limpar dados mesmo com erro
      _dataController.clearAllData();

      // Mesmo com erro, voltar para welcome
      Get.offAllNamed('/onboarding');
    } catch (_) {
      // Limpar dados mesmo com erro
      _dataController.clearAllData();

      // Mesmo com erro, voltar para welcome
      Get.offAllNamed('/onboarding');
    }
  }

  /// Completa o onboarding
  Future<void> finishOnboarding() async {
    // Verificar modo (add course ou novo usuário)
    if (_dataController.isAddingCourse.value) {
      // Modo add course: apenas criar novo curso
      await _dataController.addNewCourse();

      // Recarregar dados do HomeStatsController após adicionar curso
      if (errorMessage.value.isEmpty) {
        try {
          final homeStatsController = Get.find<HomeStatsController>();
          await homeStatsController.reloadAfterAddCourse();
        } catch (e) {
        }
      }
    } else {
      // Modo novo usuário: criar documento do usuário, primeiro curso e stats
      await _dataController.finalizeAccount();
    }

    // Navegar para /home usando Get.offAllNamed apenas se não houver erro
    if (errorMessage.value.isEmpty) {
      nav.finishOnboarding();
    } else {
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
