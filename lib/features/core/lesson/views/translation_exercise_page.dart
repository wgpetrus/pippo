import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_flow_controller.dart';
import '../controllers/lesson_exercise_controller.dart';
import '../controllers/lesson_progress_controller.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/image_with_label.dart';
import '../widgets/lesson_option_card.dart';
import 'complete_page.dart';
import 'word_exercise_page.dart';
import 'match_exercise_page.dart';
import 'image_exercise_page.dart';

/// Página de exercício de seleção de tradução
class TranslationExercisePage extends StatefulWidget {
  const TranslationExercisePage({super.key});

  @override
  State<TranslationExercisePage> createState() => _TranslationExercisePageState();
}

class _TranslationExercisePageState extends State<TranslationExercisePage> {
  late final LessonFlowController _flowController;
  late final LessonExerciseController _exerciseController;
  late final LessonProgressController _progressController;
  int? _selectedIndex;
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    _flowController = Get.find<LessonFlowController>();
    _exerciseController = Get.find<LessonExerciseController>();
    _progressController = Get.find<LessonProgressController>();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    // Obter exercício atual do controller
    if (_flowController.currentExerciseIndex.value >= _flowController.currentExercises.length) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        body: Center(
          child: Text(
            'Exercício não encontrado',
            style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
          ),
        ),
      );
    }
    
    final currentExercise = _flowController.currentExercises[_flowController.currentExerciseIndex.value];
    final options = currentExercise['options'] as List? ?? [];
    
    return WillPopScope(
      onWillPop: () async {
        // Bloquear voltar após verificar resposta
        if (_hasChecked) return false;
        
        // Mostrar dialog de confirmação antes de sair
        return await _showExitConfirmation(context) ?? false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.spacing16),

                // Header - sem botão voltar após verificar
                Obx(() => ExerciseHeader(
                      progress: _flowController.currentExerciseIndex.value / _flowController.currentExercises.length,
                      energy: Get.find<GamificationController>().currentEnergy.value,
                      onBack: _hasChecked ? null : () => _onBackPressed(context),
                    )),

                SizedBox(height: r.spacing24),

                // Título
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                  child: Text(
                    currentExercise['question'] as String? ?? 'Qual é a tradução correta?',
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                  child: Column(
                    children: [
                      for (int i = 0; i < options.length; i++) ...[
                        LessonOptionCard(
                          label: options[i]['text'] as String? ?? '',
                          status: _selectedIndex == i
                              ? LessonOptionStatus.selected
                              : LessonOptionStatus.normal,
                          onTap: _hasChecked ? null : () => _onOptionTap(i),
                        ),
                        if (i < options.length - 1) SizedBox(height: r.spacing12),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: r.spacing16),

                // Botão Check
                Padding(
                  padding: EdgeInsets.all(r.spacing16),
                  child: Obx(() => AppButton(
                        text: 'Verificar',
                        isLoading: _exerciseController.isLoading.value,
                        onPressed: _selectedIndex != null && !_exerciseController.isLoading.value && !_hasChecked
                            ? _onCheck
                            : null,
                      )),
                ),
              ],
            ),
          ),
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
    if (_selectedIndex == null || _exerciseController.isLoading.value) return;

    setState(() {
      _hasChecked = true;
    });

    final currentExercise = _flowController.currentExercises[_flowController.currentExerciseIndex.value];
    final options = currentExercise['options'] as List;
    final selectedOption = options[_selectedIndex!];
    final selectedTranslation = selectedOption['text'] as String;
    
    // Submete a resposta ao controller
    await _exerciseController.submitAnswer(selectedTranslation, 'translation');
    
    // Mostra feedback após processamento
    _showFeedback(options);
  }

  void _showFeedback(List options) {
    if (options.isEmpty) return;
    
    // Encontrar resposta correta para exibir no feedback
    String correctTranslation = '';
    try {
      final correctOption = options.firstWhere(
        (opt) => opt['isCorrect'] == true,
      );
      correctTranslation = correctOption['text'] as String? ?? '';
    } catch (e) {
      // Se não encontrar, usar primeira opção
      if (options.isNotEmpty) {
        correctTranslation = options.first['text'] as String? ?? '';
      }
    }
    
    final isCorrect = _exerciseController.isCorrectAnswer.value;

    FeedbackBottomSheet.show(
      context,
      type: isCorrect ? FeedbackType.correct : FeedbackType.wrong,
      correctAnswer: isCorrect ? null : correctTranslation,
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    // Fechar o modal primeiro
    Navigator.of(context).pop();
    
    // Depois avançar o índice do exercício
    _flowController.nextExercise();
  }

  // Métodos auxiliares

  /// Mostra dialog de confirmação ao tentar sair da lição
  Future<bool?> _showExitConfirmation(BuildContext context) async {
    return await WoltModalSheet.show<bool>(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone de aviso
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppTheme.orange,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  'Sair da lição?',
                  style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Mensagem
                Text(
                  'Se você sair agora, perderá o progresso desta lição e a energia gasta não será devolvida.',
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Botões
                AppButton(
                  text: 'Continuar Lição',
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Sair',
                  isPrimary: false,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
        ),
      ],
      modalTypeBuilder: (context) => WoltModalType.dialog(),
      barrierDismissible: false,
    );
  }

  /// Callback para o botão voltar do header
  void _onBackPressed(BuildContext context) async {
    final shouldExit = await _showExitConfirmation(context);
    if (shouldExit == true) {
      Get.back();
    }
  }
}
