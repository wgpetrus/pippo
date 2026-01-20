import 'package:get/get.dart';

import '../../../inners/gamification/controllers/gamification_controller.dart';

/// Controller para gerenciar o fluxo de lições e exercícios
class LessonController extends GetxController {
  // Dependências
  late final GamificationController _gamificationController;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados da lição
  final currentExerciseIndex = 0.obs;
  final totalExercises = 0.obs;
  final correctAnswers = 0.obs;
  final totalAnswers = 0.obs;
  final lessonStartTime = DateTime.now().obs;

  // Getters
  double get progress => totalExercises.value > 0
      ? currentExerciseIndex.value / totalExercises.value
      : 0.0;

  double get accuracy => totalAnswers.value > 0
      ? correctAnswers.value / totalAnswers.value
      : 0.0;

  bool get isPerfect => totalAnswers.value > 0 && accuracy == 1.0;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _gamificationController = Get.find<GamificationController>();
  }

  // Métodos públicos
  /// Verifica se o usuário pode iniciar uma lição
  /// Retorna true se pode iniciar, false caso contrário
  bool canStartLesson() {
    return _gamificationController.canStartLesson();
  }

  /// Inicia uma nova lição
  /// Consome energia e inicializa os estados da lição
  Future<void> startLesson({required int totalExercises}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Verifica se pode iniciar
      if (!canStartLesson()) {
        errorMessage.value = 'Energia insuficiente para iniciar a lição.';
        return;
      }

      // Consome energia via gamification
      await _gamificationController.onLessonStart();

      // Inicializa estados da lição
      this.totalExercises.value = totalExercises;
      currentExerciseIndex.value = 0;
      correctAnswers.value = 0;
      totalAnswers.value = 0;
      lessonStartTime.value = DateTime.now();
    } catch (e) {
      errorMessage.value = 'Erro ao iniciar lição. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Registra uma resposta do usuário
  void recordAnswer({required bool isCorrect}) {
    totalAnswers.value++;
    if (isCorrect) {
      correctAnswers.value++;
    }
  }

  /// Avança para o próximo exercício
  void nextExercise() {
    if (currentExerciseIndex.value < totalExercises.value) {
      currentExerciseIndex.value++;
    }
  }

  /// Completa a lição e resgata recompensas
  Future<void> completeLesson() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Calcula XP base (10-15 baseado na performance)
      final baseXp = _calculateBaseXp();

      // Calcula gems base (1-3 baseado na performance)
      final baseGems = _calculateBaseGems();

      // Chama gamification para processar recompensas
      await _gamificationController.onLessonComplete(
        baseXp,
        baseGems,
        isPerfect,
      );

      // Reset dos estados da lição
      _resetLessonState();
    } catch (e) {
      errorMessage.value = 'Erro ao completar lição. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos privados
  /// Calcula XP base baseado na performance (10-15)
  int _calculateBaseXp() {
    if (accuracy >= 0.9) return 15; // 90%+ = 15 XP
    if (accuracy >= 0.7) return 13; // 70-89% = 13 XP
    if (accuracy >= 0.5) return 11; // 50-69% = 11 XP
    return 10; // <50% = 10 XP
  }

  /// Calcula gems base baseado na performance (1-3)
  int _calculateBaseGems() {
    if (accuracy >= 0.9) return 3; // 90%+ = 3 gems
    if (accuracy >= 0.7) return 2; // 70-89% = 2 gems
    return 1; // <70% = 1 gem
  }

  /// Reseta os estados da lição
  void _resetLessonState() {
    currentExerciseIndex.value = 0;
    totalExercises.value = 0;
    correctAnswers.value = 0;
    totalAnswers.value = 0;
  }
}
