import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_controller.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/image_with_label.dart';
import '../widgets/lesson_option_card.dart';
import 'complete_page.dart';
import 'word_exercise_page.dart';

/// Página de exercício de seleção de tradução
class TranslationExercisePage extends StatefulWidget {
  const TranslationExercisePage({super.key});

  @override
  State<TranslationExercisePage> createState() => _TranslationExercisePageState();
}

class _TranslationExercisePageState extends State<TranslationExercisePage> {
  late final LessonController _controller;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LessonController>();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    // Obter exercício atual do controller
    if (_controller.currentExerciseIndex.value >= _controller.currentExercises.length) {
      return const Scaffold(
        body: Center(child: Text('Exercício não encontrado')),
      );
    }
    
    final currentExercise = _controller.currentExercises[_controller.currentExerciseIndex.value];
    final options = currentExercise['options'] as List;
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: r.spacing16),

            // Header
            Obx(() => ExerciseHeader(
                  progress: _controller.progress,
                  energy: Get.find<GamificationController>().currentEnergy.value,
                  onBack: () => Get.back(),
                )),

            SizedBox(height: r.spacing24),

            // Título
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.spacing16),
              child: Text(
                currentExercise['prompt'] as String? ?? 'Selecione a tradução correta',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
            ),

            SizedBox(height: r.spacing24),

            // Imagem com label
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.spacing16),
              child: ImageWithLabel(
                imageAsset: currentExercise['image'] as String? ?? AppAssets.lessonSpider,
                label: currentExercise['word'] as String? ?? '',
              ),
            ),

            SizedBox(height: r.spacing32),

            // Opções de tradução
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                child: Column(
                  children: [
                    for (int i = 0; i < options.length; i++) ...[
                      LessonOptionCard(
                        label: options[i]['text'] as String? ?? '',
                        status: _selectedIndex == i
                            ? LessonOptionStatus.selected
                            : LessonOptionStatus.normal,
                        onTap: () => _onOptionTap(i),
                      ),
                      if (i < options.length - 1) SizedBox(height: r.spacing12),
                    ],
                  ],
                ),
              ),
            ),

            // Botão Check
            Padding(
              padding: EdgeInsets.all(r.spacing16),
              child: Obx(() => AppButton(
                    text: 'Verificar',
                    isLoading: _controller.isLoading.value,
                    onPressed: _selectedIndex != null && !_controller.isLoading.value
                        ? _onCheck
                        : null,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos

  void _onOptionTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCheck() async {
    if (_selectedIndex == null || _controller.isLoading.value) return;

    final currentExercise = _controller.currentExercises[_controller.currentExerciseIndex.value];
    final options = currentExercise['options'] as List;
    final selectedOption = options[_selectedIndex!];
    final selectedTranslation = selectedOption['text'] as String;
    
    // Submete a resposta ao controller
    await _controller.submitAnswer(selectedTranslation, 'translation');
    
    // Mostra feedback após processamento
    _showFeedback(options);
  }

  void _showFeedback(List options) {
    // Encontrar resposta correta para exibir no feedback
    final correctOption = options.firstWhere((opt) => opt['isCorrect'] == true);
    final correctTranslation = correctOption['text'] as String;
    
    final isCorrect = _controller.lastAnswerCorrect.value;

    FeedbackBottomSheet.show(
      context,
      type: isCorrect ? FeedbackType.correct : FeedbackType.wrong,
      correctAnswer: correctTranslation,
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    // Avança para o próximo exercício via controller
    _controller.nextExercise();
    
    // Verifica se há mais exercícios
    if (_controller.currentExerciseIndex.value < _controller.currentExercises.length) {
      // Continua na mesma tela (próximo exercício)
      setState(() {
        _selectedIndex = null;
      });
    } else {
      // Último exercício - controller navega para conclusão
      _controller.completeLesson();
    }
  }
}
