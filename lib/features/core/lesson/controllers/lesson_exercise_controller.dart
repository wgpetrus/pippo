import 'package:get/get.dart';

import 'lesson_flow_controller.dart';

/// Controller para gerenciar exercícios e validação de respostas
class LessonExerciseController extends GetxController {
  // Dependências
  late final LessonFlowController _flowController;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados de feedback (feedback states)
  final showFeedback = false.obs;
  final isCorrectAnswer = false.obs;
  final correctAnswerText = ''.obs;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    try {
      _flowController = Get.find<LessonFlowController>();
    } catch (e) {
      errorMessage.value = 'Erro ao inicializar controlador de fluxo.';
    }
  }

  @override
  void onClose() {
    // Resetar estados
    isLoading.value = false;
    errorMessage.value = '';
    showFeedback.value = false;
    isCorrectAnswer.value = false;
    correctAnswerText.value = '';

    super.onClose();
  }

  // Métodos públicos
  
  /// Submete uma resposta do usuário para o exercício atual
  /// 
  /// Valida resposta usando método apropriado e mostra feedback
  /// A view deve chamar LessonProgressController para atualizar contadores
  Future<void> submitAnswer(dynamic userAnswer, String exerciseType) async {
    try {
      // Obter exercício atual
      if (_flowController.currentExerciseIndex.value >= _flowController.currentExercises.length) {
        errorMessage.value = 'Exercício não encontrado.';
        return;
      }

      final currentExercise = _flowController.currentExercises[_flowController.currentExerciseIndex.value];
      
      // Validar resposta usando método apropriado
      bool isCorrect = false;
      String correctAnswer = '';

      switch (exerciseType) {
        case 'image':
          final selectedImageId = userAnswer as String;
          final options = currentExercise['options'] as List;
          final correctOption = options.firstWhere((opt) => opt['isCorrect'] == true);
          final correctImageId = correctOption['id'] as String;
          correctAnswer = correctImageId;
          isCorrect = validateImageExercise(selectedImageId, correctImageId);
          break;

        case 'translation':
          final selectedTranslation = userAnswer as String;
          final options = currentExercise['options'] as List;
          final correctOption = options.firstWhere((opt) => opt['isCorrect'] == true);
          final correctTranslationText = correctOption['text'] as String;
          correctAnswer = correctTranslationText;
          isCorrect = validateTranslationExercise(selectedTranslation, correctTranslationText);
          break;

        case 'word_order':
          final userOrder = userAnswer as List<String>;
          final correctOrder = currentExercise['correctOrder'] as List<String>;
          correctAnswer = correctOrder.join(' ');
          isCorrect = validateWordExercise(userOrder, correctOrder);
          break;

        case 'match':
          final userPairs = userAnswer as Map<String, String>;
          final pairs = currentExercise['pairs'] as List;
          final correctPairs = <String, String>{};
          for (final pair in pairs) {
            correctPairs[pair['audio'] as String] = pair['text'] as String;
          }
          correctAnswer = correctPairs.toString();
          isCorrect = validateMatchExercise(userPairs, correctPairs);
          break;

        default:
          errorMessage.value = 'Tipo de exercício desconhecido.';
          return;
      }

      // Mostra feedback (correto/incorreto)
      isCorrectAnswer.value = isCorrect;
      correctAnswerText.value = correctAnswer;
      showFeedback.value = true;
    } catch (e) {
      errorMessage.value = 'Erro ao processar resposta. Tente novamente.';
    }
  }

  /// Fecha o feedback e reseta estados
  void closeFeedback() {
    showFeedback.value = false;
    isCorrectAnswer.value = false;
    correctAnswerText.value = '';
  }

  // Métodos de validação
  
  /// Valida exercício de imagem comparando imageIds
  /// Retorna true se o imageId selecionado corresponde ao correto
  bool validateImageExercise(String selectedImageId, String correctImageId) {
    return selectedImageId == correctImageId;
  }

  /// Valida exercício de tradução comparando texto
  /// Comparação case-sensitive com whitespace trimmed
  bool validateTranslationExercise(String selectedTranslation, String correctTranslation) {
    return selectedTranslation.trim() == correctTranslation.trim();
  }

  /// Valida exercício de ordenação de palavras comparando arrays ordenados
  /// Retorna true se a ordem das palavras está correta
  bool validateWordExercise(List<String> userOrder, List<String> correctOrder) {
    if (userOrder.length != correctOrder.length) return false;
    
    for (int i = 0; i < userOrder.length; i++) {
      if (userOrder[i] != correctOrder[i]) return false;
    }
    
    return true;
  }

  /// Valida exercício de combinação verificando se todos os 4 pares estão corretos
  /// Retorna true se todos os pares correspondem
  bool validateMatchExercise(Map<String, String> userPairs, Map<String, String> correctPairs) {
    if (userPairs.length != 4 || correctPairs.length != 4) return false;
    
    for (final entry in correctPairs.entries) {
      if (userPairs[entry.key] != entry.value) return false;
    }
    
    return true;
  }
}
