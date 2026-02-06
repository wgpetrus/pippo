import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/language_helper.dart';
import '../../../../shared/widgets/app_lesson_button.dart';
import '../../../core/lesson/controllers/lesson_flow_controller.dart';
import '../../../core/lesson/controllers/lesson_exercise_controller.dart';
import '../../../core/lesson/controllers/lesson_progress_controller.dart';
import '../../../core/lesson/controllers/lesson_rewards_controller.dart';
import '../../../core/lesson/views/sections_page.dart';
import '../../../core/onboarding/controllers/onboarding_controller.dart';
import '../../gamification/controllers/gems_controller.dart';
import '../../gamification/controllers/xp_level_controller.dart';
import '../../gamification/controllers/streak_controller.dart';
import '../../gamification/controllers/energy_controller.dart';
import '../../profile/controllers/profile_data_controller.dart';
import '../../profile/controllers/profile_social_controller.dart';
import '../../treasure/controllers/treasure_controller.dart';
import '../widgets/home_appbar.dart';

/// Controller da home
class HomeController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados de UI
  final currentNavIndex = 0.obs;
  final selectedStat = Rxn<StatType>();
  final showContinue = false.obs;
  
  // Estados do curso ativo
  final activeCourseId = ''.obs;
  final activeCourseName = ''.obs;
  final activeCourseLanguage = ''.obs;
  final activeCourseFlag = ''.obs;
  final activeCourseLevel = 0.obs;
  final userCourses = <Map<String, dynamic>>[].obs;
  final isLoadingCourses = false.obs;

  // Estados de progresso das lições
  final completedLessons = <String>[].obs; // IDs das lições completadas
  final inProgressLessons = <String>[].obs; // IDs das lições em progresso
  final isLoadingProgress = false.obs;
  final currentUnitIndex = 0.obs; // Índice da unidade atual (0 = Unidade 1, 1 = Unidade 2, etc)

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _loadActiveCourse();
    _loadLessonProgress();
  }
  
  @override
  void onReady() {
    super.onReady();
    // Verificar se há lição em progresso para mostrar "Continuar"
    _checkInProgressLesson();
  }
  
  // Getters
  
  /// Retorna os dados da unidade atual
  Map<String, dynamic> get currentUnit {
    return _units[currentUnitIndex.value];
  }
  
  /// Retorna os botões de lição da unidade atual
  List<Map<String, dynamic>> get currentLessonButtons {
    return currentUnit['lessons'] as List<Map<String, dynamic>>;
  }
  
  // Dados das unidades
  final _units = [
    {
      'number': 'Unidade 1',
      'title': 'Use frases básicas',
      'lessons': [
        {
          'lessonId': 'lesson_1',
          'iconAsset': AppAssets.iconStars,
          'effectAsset': AppAssets.effectStars,
          'offsetX': -0.13,
          'offsetY': 0.40,        },
        {
          'lessonId': 'lesson_2',
          'iconAsset': AppAssets.iconHeadset,
          'effectAsset': AppAssets.effectZebra,
          'offsetX': -0.03,
          'offsetY': 0.54,
          'animDelay': 200,
        },
        {
          'lessonId': 'lesson_3',
          'iconAsset': AppAssets.iconMic,
          'effectAsset': AppAssets.effectZebra,
          'offsetX': -0.08,
          'offsetY': 0.67,
          'animDelay': 400,
        },
        {
          'lessonId': 'lesson_4',
          'iconAsset': AppAssets.iconFire,
          'effectAsset': AppAssets.effectZebra,
          'offsetX': 0.05,
          'offsetY': 0.77,
          'animDelay': 600,
        },
        {
          'lessonId': 'lesson_5',
          'iconAsset': AppAssets.iconStar,
          'effectAsset': AppAssets.effectZebra,
          'offsetX': -0.20,
          'offsetY': 0.85,
          'animDelay': 800,
        },
      ],
    },
    {
      'number': 'Unidade 2',
      'title': 'Cumprimente pessoas',
      'lessons': [
        {
          'lessonId': 'lesson_1',
          'iconAsset': AppAssets.iconStars,
          'effectAsset': AppAssets.effectStars,
          'offsetX': -0.13,
          'offsetY': 0.40,        },
        {
          'lessonId': 'lesson_2',
          'iconAsset': AppAssets.iconHeadset,
          'effectAsset': AppAssets.effectZebra,
          'offsetX': -0.03,
          'offsetY': 0.54,
          'animDelay': 200,
        },
        {
          'lessonId': 'lesson_3',
          'iconAsset': AppAssets.iconMic,
          'effectAsset': AppAssets.effectZebra,
          'offsetX': -0.08,
          'offsetY': 0.67,
          'animDelay': 400,
        },
        {
          'lessonId': 'lesson_4',
          'iconAsset': AppAssets.iconFire,
          'effectAsset': AppAssets.effectZebra,
          'offsetX': 0.05,
          'offsetY': 0.77,
          'animDelay': 600,
        },
        {
          'lessonId': 'lesson_5',
          'iconAsset': AppAssets.iconStar,
          'effectAsset': AppAssets.effectZebra,
          'offsetX': -0.20,
          'offsetY': 0.85,
          'animDelay': 800,
        },
      ],
    },
  ];

  // Métodos privados
  
  /// Converte string de nível para int (para exibição)
  int _levelStringToInt(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
        return 3;
      default:
        return 1;
    }
  }
  
  /// Carrega o curso ativo do usuário
  Future<void> _loadActiveCourse() async {
    debugPrint('🔄 _loadActiveCourse() INICIADO');
    isLoadingCourses.value = true;

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('  ❌ Usuário não autenticado');
        return;
      }
      
      debugPrint('  👤 UserId: $userId');

      // Buscar curso ativo
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (coursesSnapshot.docs.isEmpty) {
        debugPrint('  ⚠️ Nenhum curso ativo encontrado - usando valores padrão');
        // Definir valores padrão para evitar problemas na UI
        activeCourseId.value = '';
        activeCourseLanguage.value = 'fr';
        activeCourseName.value = 'Francês';
        activeCourseFlag.value = AppAssets.flagFrance;
        activeCourseLevel.value = 0;
        return;
      }

      final courseData = coursesSnapshot.docs.first.data();
      final languageCode = courseData['language'] as String;
      
      activeCourseId.value = coursesSnapshot.docs.first.id;
      activeCourseLanguage.value = languageCode;
      activeCourseName.value = LanguageHelper.getLanguageName(languageCode);
      activeCourseFlag.value = LanguageHelper.getLanguageFlag(languageCode);
      
      // Nível do curso é uma String no Firestore (beginner, intermediate, advanced)
      // Converter para int para exibição (1 = beginner, 2 = intermediate, 3 = advanced)
      final levelString = courseData['level'] as String? ?? 'beginner';
      activeCourseLevel.value = _levelStringToInt(levelString);
      
      debugPrint('  ✅ Curso ativo carregado:');
      debugPrint('    ID: ${activeCourseId.value}');
      debugPrint('    Idioma: ${activeCourseName.value} ($languageCode)');
      debugPrint('    Bandeira: ${activeCourseFlag.value}');
      debugPrint('    Nível: ${activeCourseLevel.value}');
    } catch (e) {
      debugPrint('  ❌ Erro ao carregar curso ativo: $e');
    } finally {
      isLoadingCourses.value = false;
      debugPrint('✅ _loadActiveCourse() CONCLUÍDO');
    }
  }
  
  /// Carrega todos os cursos do usuário
  Future<void> loadUserCourses() async {
    debugPrint('🔄 loadUserCourses() INICIADO');
    
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('  ❌ Usuário não autenticado');
        return;
      }
      
      debugPrint('  👤 UserId: $userId');
      debugPrint('  📡 Buscando cursos em: users/$userId/courses');
      
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();
      
      debugPrint('  📊 Snapshot recebido: ${coursesSnapshot.docs.length} documentos');
      
      if (coursesSnapshot.docs.isEmpty) {
        debugPrint('  ⚠️ Nenhum curso encontrado');
        userCourses.value = [];
        return;
      }
      
      // Log de cada curso encontrado
      for (var doc in coursesSnapshot.docs) {
        final data = doc.data();
        debugPrint('  📚 Curso encontrado:');
        debugPrint('    - ID: ${doc.id}');
        debugPrint('    - Idioma: ${data['language']}');
        debugPrint('    - Nome: ${data['languageName']}');
        debugPrint('    - Ativo: ${data['isActive']}');
        debugPrint('    - Nível: ${data['level']}');
      }
      
      userCourses.value = coursesSnapshot.docs.map((doc) {
        final data = doc.data();
        final languageCode = data['language'] as String;
        
        return {
          'id': doc.id,
          'language': languageCode,
          'languageName': LanguageHelper.getLanguageName(languageCode),
          'flagAsset': LanguageHelper.getLanguageFlag(languageCode),
          'isActive': data['isActive'] ?? false,
          'level': data['level'],
          'studyTime': data['studyTime'],
        };
      }).toList();
      
      debugPrint('  ✅ ${userCourses.length} cursos carregados e convertidos');
      debugPrint('  📋 Lista final de cursos:');
      for (var course in userCourses) {
        debugPrint('    - ${course['languageName']} (${course['language']}): isActive=${course['isActive']}');
      }
    } catch (e) {
      debugPrint('  ❌ Erro ao carregar cursos: $e');
      debugPrint('  📍 Stack trace: ${StackTrace.current}');
    } finally {
      debugPrint('✅ loadUserCourses() CONCLUÍDO');
    }
  }
  
  Future<void> _loadLessonProgress() async {
    debugPrint('🔄 _loadLessonProgress() INICIADO');
    isLoadingProgress.value = true;

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('  ❌ Usuário não autenticado');
        return;
      }
      
      debugPrint('  👤 UserId: $userId');

      // Buscar curso ativo
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (coursesSnapshot.docs.isEmpty) {
        debugPrint('  ⚠️ Nenhum curso ativo encontrado');
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;
      debugPrint('  📚 Curso ativo: $courseId');

      // Buscar lições completadas
      final completedSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .where('status', isEqualTo: 'completed')
          .get();

      completedLessons.value = completedSnapshot.docs
          .map((doc) => doc.data()['lessonId'] as String)
          .toList();
      
      debugPrint('  ✅ Lições completadas: ${completedLessons.length}');
      debugPrint('    IDs: ${completedLessons.join(", ")}');
      
      // Buscar lições em progresso
      final inProgressSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .where('status', isEqualTo: 'in_progress')
          .get();

      inProgressLessons.value = inProgressSnapshot.docs
          .map((doc) => doc.data()['lessonId'] as String)
          .toList();
      
      debugPrint('  ✅ Lições em progresso: ${inProgressLessons.length}');
      debugPrint('    IDs: ${inProgressLessons.join(", ")}');
      
      // Determinar unidade atual baseada no progresso
      _updateCurrentUnit();
      
      debugPrint('  ✅ Unidade atual: ${currentUnitIndex.value}');
      debugPrint('  ✅ Nível do curso: ${activeCourseLevel.value}');
    } catch (e) {
      // Silenciosamente falhar - não é crítico
      debugPrint('  ❌ Erro ao carregar progresso: $e');
    } finally {
      isLoadingProgress.value = false;
      debugPrint('✅ _loadLessonProgress() CONCLUÍDO');
    }
  }
  
  /// Verifica se há lição em progresso para mostrar "Continuar"
  void _checkInProgressLesson() {
    debugPrint('🔍 _checkInProgressLesson() INICIADO');
    debugPrint('  📊 inProgressLessons: ${inProgressLessons.length}');
    debugPrint('    IDs: ${inProgressLessons.join(", ")}');
    debugPrint('  📊 completedLessons: ${completedLessons.length}');
    debugPrint('    IDs: ${completedLessons.join(", ")}');
    
    // Mostrar "Continue" se:
    // 1. Há lições em progresso OU
    // 2. Há lições completadas (usuário já começou o curso)
    final hasProgress = inProgressLessons.isNotEmpty || completedLessons.isNotEmpty;
    showContinue.value = hasProgress;
    
    debugPrint('  ✅ showContinue: ${showContinue.value} (inProgress: ${inProgressLessons.isNotEmpty}, completed: ${completedLessons.isNotEmpty})');
    debugPrint('✅ _checkInProgressLesson() CONCLUÍDO');
  }
  
  /// Atualiza a unidade atual baseada nas lições completadas
  void _updateCurrentUnit() {
    // Contar quantas lições foram completadas
    final completedCount = completedLessons.length;
    
    // Cada BOTÃO representa uma unidade completa (9 lições)
    // 0-8 completadas = Botão 1 ativo (Unidade 1)
    // 9-17 completadas = Botão 2 ativo (Unidade 2)
    // 18-26 completadas = Botão 3 ativo (Unidade 3)
    const lessonsPerButton = 9;
    
    // Calcular qual botão está ativo (em qual unidade o usuário está trabalhando)
    // Se completou 0-8 lições, está na unidade 0 (index 0)
    // Se completou 9-17 lições, está na unidade 1 (index 1)
    // Se completou 18-26 lições, está na unidade 2 (index 2)
    final activeButtonIndex = completedCount ~/ lessonsPerButton;
    
    // O header da unidade deve mostrar a unidade em que o usuário está TRABALHANDO
    // Se o usuário completou todas as lições de uma unidade, avança para a próxima
    // Mas se está no meio de uma unidade, mostra essa unidade
    currentUnitIndex.value = activeButtonIndex.clamp(0, _units.length - 1);
    
    debugPrint('📊 _updateCurrentUnit:');
    debugPrint('  ✅ Lições completadas: $completedCount');
    debugPrint('  📐 Cálculo: $completedCount ~/ $lessonsPerButton = $activeButtonIndex');
    debugPrint('  🎯 Header da unidade: ${currentUnitIndex.value + 1} (index ${currentUnitIndex.value})');
  }

  // Métodos públicos
  void onNavTap(int index) {
    final previousIndex = currentNavIndex.value;
    currentNavIndex.value = index;
    
    // Se navegando para a tab Treasure (index 3), recarregar desafios
    if (index == 3 && previousIndex != 3) {
      _refreshTreasurePage();
    }
    
    // Se navegando para a tab Profile (index 4), recarregar perfil e progresso
    if (index == 4 && previousIndex != 4) {
      _refreshProfilePage();
    }
  }

  /// Recarrega dados da página Treasure quando usuário retorna à tab
  void _refreshTreasurePage() {
    try {
      if (Get.isRegistered<TreasureController>()) {
        final treasureController = Get.find<TreasureController>();
        treasureController.loadChallenges();
      }
    } catch (e) {
      // TreasureController não registrado - não é crítico
    }
  }

  /// Recarrega dados da página Profile quando usuário retorna à tab
  void _refreshProfilePage() {
    try {
      final profileDataController = Get.find<ProfileDataController>();
      final profileSocialController = Get.find<ProfileSocialController>();
      
      profileDataController.loadOwnProfile();
      profileSocialController.loadWeeklyProgress();
      
      debugPrint('🔄 Profile atualizado ao trocar de aba');
    } catch (e) {
      debugPrint('⚠️ Erro ao atualizar Profile: $e');
      // Controllers não registrados - não é crítico
    }
  }

  void onStatTap(StatType stat) {
    selectedStat.value = selectedStat.value == stat ? null : stat;
  }
  
  /// Limpa a seleção do stat (chamar quando modal fechar)
  void clearStatSelection() {
    selectedStat.value = null;
  }

  /// Inicia lição do botão especificado
  /// buttonIndex: índice do botão clicado (0-4)
  void onStartTap(int buttonIndex) {
    // Marcar que há lição em progresso IMEDIATAMENTE
    showContinue.value = true;
    
    // Garantir que os controllers de lição estão registrados antes de navegar
    if (!Get.isRegistered<LessonFlowController>()) {
      // Registrar na ordem de dependência
      Get.lazyPut(() => LessonProgressController());
      Get.lazyPut(() => LessonExerciseController());
      Get.lazyPut(() => LessonRewardsController());
      Get.lazyPut(() => LessonFlowController());
    }
    
    debugPrint('🎯 onStartTap: buttonIndex=$buttonIndex');
    
    // Navegar para as seções do botão clicado
    Get.to(() => SectionsPage(
      courseName: activeCourseName.value.isEmpty ? 'French' : activeCourseName.value,
      buttonIndex: buttonIndex,
    ));
  }

  void onAddCourse() {
    // Marca que está adicionando curso e navega para onboarding
    final onboardingController = Get.find<OnboardingController>();
    onboardingController.isAddingCourse.value = true;
    onboardingController.nav.goToSelectLanguage();
  }
  
  /// Troca o curso ativo
  Future<void> switchActiveCourse(String newCourseId) async {
    debugPrint('🔄 switchActiveCourse() INICIADO: $newCourseId');
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'Usuário não autenticado.';
        debugPrint('  ❌ Usuário não autenticado');
        return;
      }
      
      // Não trocar se já é o curso ativo
      if (activeCourseId.value == newCourseId) {
        debugPrint('  ⚠️ Curso já está ativo');
        return;
      }
      
      final batch = _firestore.batch();
      
      // Desativar curso atual
      if (activeCourseId.value.isNotEmpty) {
        final currentCourseRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(activeCourseId.value);
        
        batch.update(currentCourseRef, {'isActive': false});
        debugPrint('  📝 Desativando curso atual: ${activeCourseId.value}');
      }
      
      // Ativar novo curso
      final newCourseRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(newCourseId);
      
      batch.update(newCourseRef, {'isActive': true});
      debugPrint('  📝 Ativando novo curso: $newCourseId');
      
      await batch.commit();
      debugPrint('  ✅ Batch commit realizado');
      
      // Recarregar curso ativo e progresso
      await _loadActiveCourse();
      await _loadLessonProgress();
      
      // Recarregar stats do novo curso (gamificação)
      debugPrint('  🔄 Recarregando stats do novo curso...');
      try {
        // Recarregar todos os controllers de gamificação
        if (Get.isRegistered<GemsController>()) {
          await Get.find<GemsController>().loadGems();
        }
        if (Get.isRegistered<XpLevelController>()) {
          await Get.find<XpLevelController>().loadXpAndLevel();
        }
        if (Get.isRegistered<StreakController>()) {
          await Get.find<StreakController>().loadStreak();
        }
        if (Get.isRegistered<EnergyController>()) {
          await Get.find<EnergyController>().loadEnergy();
        }
        debugPrint('  ✅ Stats recarregados com sucesso');
      } catch (e) {
        debugPrint('  ⚠️ Erro ao recarregar stats: $e');
      }

      // ATUALIZAR GRÁFICO DO PERFIL após trocar curso
      debugPrint('  🔄 Atualizando gráfico do perfil...');
      try {
        if (Get.isRegistered<ProfileSocialController>()) {
          final profileSocialController = Get.find<ProfileSocialController>();
          await profileSocialController.loadWeeklyProgress();
          debugPrint('  ✅ Gráfico do perfil atualizado com sucesso');
        }
      } catch (e) {
        debugPrint('  ⚠️ ProfileSocialController não encontrado ou erro ao atualizar gráfico: $e');
      }
      
      Get.snackbar(
        'Sucesso',
        'Curso alterado para ${activeCourseName.value}!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      debugPrint('✅ switchActiveCourse() CONCLUÍDO');
    } catch (e) {
      errorMessage.value = 'Erro ao trocar curso. Tente novamente.';
      debugPrint('❌ Erro ao trocar curso: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToShop() {
    currentNavIndex.value = 2; // Tab 2 = Shop
  }

  /// Recarrega o progresso das lições (chamar após completar uma lição)
  Future<void> reloadProgress() async {
    debugPrint('🔄 reloadProgress() CHAMADO');
    debugPrint('  📊 currentUnitIndex ANTES: ${currentUnitIndex.value}');
    
    await _loadActiveCourse();
    await _loadLessonProgress();
    _checkInProgressLesson();
    
    debugPrint('  📊 currentUnitIndex DEPOIS: ${currentUnitIndex.value}');
    debugPrint('✅ reloadProgress() CONCLUÍDO');
  }
  
  /// Recarrega TUDO após adicionar novo curso
  /// Chamado pelo OnboardingController após addNewCourse()
  Future<void> reloadAfterAddCourse() async {
    debugPrint('🔄 reloadAfterAddCourse() INICIADO');
    
    try {
      // 1. Recarregar curso ativo
      await _loadActiveCourse();
      
      // 2. Recarregar progresso das lições
      await _loadLessonProgress();
      _checkInProgressLesson();
      
      // 3. Recarregar gamificação
      try {
        // Recarregar todos os controllers de gamificação
        if (Get.isRegistered<GemsController>()) {
          await Get.find<GemsController>().loadGems();
        }
        if (Get.isRegistered<XpLevelController>()) {
          await Get.find<XpLevelController>().loadXpAndLevel();
        }
        if (Get.isRegistered<StreakController>()) {
          await Get.find<StreakController>().loadStreak();
        }
        if (Get.isRegistered<EnergyController>()) {
          await Get.find<EnergyController>().loadEnergy();
        }
        debugPrint('  ✅ Gamificação recarregada');
      } catch (e) {
        debugPrint('  ⚠️ Erro ao recarregar gamificação: $e');
      }
      
      // 4. Recarregar profile (se estiver registrado)
      try {
        if (Get.isRegistered<ProfileDataController>()) {
          final profileDataController = Get.find<ProfileDataController>();
          await profileDataController.loadOwnProfile();
          debugPrint('  ✅ Profile recarregado');
        }
      } catch (e) {
        debugPrint('  ⚠️ Erro ao recarregar profile: $e');
      }
      
      // 5. Resetar para tab 0 (Courses)
      currentNavIndex.value = 0;
      
      debugPrint('✅ reloadAfterAddCourse() CONCLUÍDO');
    } catch (e) {
      debugPrint('❌ Erro em reloadAfterAddCourse: $e');
      errorMessage.value = 'Erro ao recarregar dados. Tente novamente.';
    }
  }
  
  /// Determina o status de um botão de lição baseado no progresso
  /// 
  /// ESTRUTURA CORRETA:
  /// - Cada BOTÃO = 1 UNIDADE COMPLETA = 9 lições (3 seções × 3 lições)
  /// - Botão 1 (lesson_1) = lições 1-9
  /// - Botão 2 (lesson_2) = lições 10-18
  /// - Botão 3 (lesson_3) = lições 19-27
  /// - Botões 4-5 = placeholders (não implementados ainda)
  /// 
  /// O currentUnitIndex apenas controla qual HEADER é exibido, NÃO quais botões são visíveis.
  /// Todos os 5 botões são SEMPRE visíveis, apenas habilitam/desabilitam baseado no progresso.
  LessonStatus getLessonStatus(String lessonId, int lessonIndex) {
    debugPrint('🔍 getLessonStatus: lessonId=$lessonId, lessonIndex=$lessonIndex');
    debugPrint('  📊 completedLessons: ${completedLessons.join(", ")}');
    
    // Cada botão representa 9 lições
    // Botão 0 (lesson_1) = lições 1-9
    // Botão 1 (lesson_2) = lições 10-18
    // Botão 2 (lesson_3) = lições 19-27
    // etc.
    const lessonsPerButton = 9;
    final firstLessonOfButton = (lessonIndex * lessonsPerButton) + 1;
    final lastLessonOfButton = firstLessonOfButton + lessonsPerButton - 1;
    
    debugPrint('  📋 Botão $lessonIndex ($lessonId): lições $firstLessonOfButton-$lastLessonOfButton');
    
    // Verificar se TODAS as 9 lições deste botão foram completadas
    int completedCount = 0;
    for (int i = firstLessonOfButton; i <= lastLessonOfButton; i++) {
      if (completedLessons.contains(i.toString())) {
        completedCount++;
      }
    }
    
    final allLessonsCompleted = completedCount == lessonsPerButton;
    
    debugPrint('  ✅ Lições completadas: $completedCount/$lessonsPerButton');
    debugPrint('  ✅ Todas lições completadas: $allLessonsCompleted');
    
    // Se todas as 9 lições foram completadas, botão está COMPLETED
    if (allLessonsCompleted) {
      debugPrint('  → Status: COMPLETED (todas $lessonsPerButton lições completadas)');
      return LessonStatus.completed;
    }
    
    // Primeiro botão (lesson_1) sempre disponível
    if (lessonIndex == 0) {
      debugPrint('  → Status: AVAILABLE (primeiro botão do curso)');
      return LessonStatus.available;
    }
    
    // Para outros botões, verificar se o botão anterior foi completado
    final previousButtonIndex = lessonIndex - 1;
    final prevFirstLesson = (previousButtonIndex * lessonsPerButton) + 1;
    final prevLastLesson = prevFirstLesson + lessonsPerButton - 1;
    
    debugPrint('  🔍 Verificando botão anterior (index $previousButtonIndex)');
    debugPrint('    📋 Botão anterior: lições $prevFirstLesson-$prevLastLesson');
    
    // Verificar se TODAS as 9 lições do botão anterior foram completadas
    int prevCompletedCount = 0;
    for (int i = prevFirstLesson; i <= prevLastLesson; i++) {
      if (completedLessons.contains(i.toString())) {
        prevCompletedCount++;
      }
    }
    
    final prevAllCompleted = prevCompletedCount == lessonsPerButton;
    
    debugPrint('    ✅ Lições completadas do botão anterior: $prevCompletedCount/$lessonsPerButton');
    debugPrint('    ✅ Botão anterior completado: $prevAllCompleted');
    
    // Se o botão anterior foi completado, este botão está AVAILABLE
    if (prevAllCompleted) {
      debugPrint('  → Status: AVAILABLE (botão anterior completado)');
      return LessonStatus.available;
    }
    
    // Caso contrário, está LOCKED
    debugPrint('  → Status: LOCKED (botão anterior não completado)');
    return LessonStatus.locked;
  }

  // Métodos de UI

  /// Determina se deve mostrar tooltip e qual texto usar
  /// Retorna "Começar" se o botão não tem progresso, "Continuar" se tem progresso
  /// Retorna null se não deve mostrar tooltip (botão completo ou não é o botão atual)
  String? getTooltipText(String lessonId, int lessonIndex) {
    // Calcular qual é o botão da unidade atual baseado no progresso
    final completedCount = completedLessons.length;
    const lessonsPerButton = 9;
    final currentButtonIndex = completedCount ~/ lessonsPerButton;
    
    debugPrint('🎯 getTooltipText: lessonIndex=$lessonIndex, completedCount=$completedCount, currentButtonIndex=$currentButtonIndex');
    
    // Apenas o botão da unidade atual pode ter tooltip
    if (lessonIndex != currentButtonIndex) {
      debugPrint('  ❌ Não é o botão atual');
      return null;
    }
    
    // Calcular quais lições pertencem a este botão
    final firstLessonOfButton = (lessonIndex * lessonsPerButton) + 1;
    final lastLessonOfButton = firstLessonOfButton + lessonsPerButton - 1;
    
    // Verificar quantas lições foram completadas deste botão
    int completedCountInButton = 0;
    for (int i = firstLessonOfButton; i <= lastLessonOfButton; i++) {
      if (completedLessons.contains(i.toString())) {
        completedCountInButton++;
      }
    }
    
    debugPrint('  📊 Lições $firstLessonOfButton-$lastLessonOfButton: $completedCountInButton/$lessonsPerButton completadas');
    
    // Se TODAS as lições foram completadas, não mostrar tooltip
    if (completedCountInButton == lessonsPerButton) {
      debugPrint('  ✅ Todas completadas, sem tooltip');
      return null;
    }
    
    // Se tem alguma lição completada, mostrar "Continuar"
    if (completedCountInButton > 0) {
      debugPrint('  ✅ Retornando: Continuar');
      return 'Continuar';
    }
    
    // Se não tem nenhuma lição completada, mostrar "Começar"
    debugPrint('  ✅ Retornando: Começar');
    return 'Começar';
  }
}
