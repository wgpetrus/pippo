import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../inners/gamification/controllers/energy_controller.dart';
import '../controllers/lesson_flow_controller.dart';
import '../controllers/lesson_exercise_controller.dart';
import '../controllers/lesson_progress_controller.dart';
import '../widgets/audio_word_button.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/lesson_option_card.dart';

/// Página de exercício de seleção de imagem
class ImageExercisePage extends StatefulWidget {
  const ImageExercisePage({super.key});

  @override
  State<ImageExercisePage> createState() => _ImageExercisePageState();
}

class _ImageExercisePageState extends State<ImageExercisePage> {
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

  Map<String, dynamic> get _currentExercise {
    if (_flowController.currentExerciseIndex.value >= _flowController.currentExercises.length) {
      return {};
    }
    return _flowController.currentExercises[_flowController.currentExerciseIndex.value];
  }

  List<dynamic> get _options => _currentExercise['options'] as List? ?? [];

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    // Validação de exercício
    if (_currentExercise.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        body: Center(
          child: Text(
            'Exercício não encontrado',
            style: AppTheme.textMdRegular,
          ),
        ),
      );
    }

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
                      energy: Get.find<EnergyController>().currentEnergy.value,
                      onBack: _hasChecked ? null : () => _onBackPressed(context),
                    )),

                SizedBox(height: r.spacing24),

                // Título
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                  child: Text(
                    _currentExercise['question'] as String? ?? 'Selecione a imagem correta',
                    style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                  ),
                ),

                SizedBox(height: r.spacing16),

                // Botão de áudio com palavra
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                  child: AudioWordButton(
                    word: _currentExercise['word'] as String? ?? '',
                    onTap: () {
                      // TODO: Tocar áudio
                    },
                  ),
                ),

                SizedBox(height: r.spacing24),

                // Grid de opções
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: r.isLandscape ? 4 : 2,
                      crossAxisSpacing: r.spacing12,
                      mainAxisSpacing: r.spacing12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _options.length,
                    itemBuilder: (context, index) {
                      final option = _options[index];
                      return LessonOptionCard(
                        imageAsset: option['image'] as String? ?? '',
                        label: option['label'] as String? ?? '',
                        showImage: true,
                        status: _selectedIndex == index
                            ? LessonOptionStatus.selected
                            : LessonOptionStatus.normal,
                        onTap: _hasChecked ? null : () => _onOptionTap(index),
                      );
                    },
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

  // Métodos de ação

  void _onOptionTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCheck() async {
    if (_selectedIndex == null) return;

    setState(() {
      _hasChecked = true;
    });

    final selectedOption = _options[_selectedIndex!];
    final selectedImageId = selectedOption['id'] as String;

    await _exerciseController.submitAnswer(selectedImageId, 'image');

    // Atualizar progresso
    if (_exerciseController.isCorrectAnswer.value) {
      _progressController.addCorrectAnswer();
    } else {
      _progressController.addWrongAnswer();
      _progressController.loseHeart();
      
      // Verificar se perdeu todos os corações
      if (_progressController.hearts.value <= 0) {
        _progressController.lessonFailed.value = true;
        return;
      }
    }

    // Mostrar feedback
    if (!mounted) return;
    
    FeedbackBottomSheet.show(
      context,
      type: _exerciseController.isCorrectAnswer.value 
          ? FeedbackType.correct 
          : FeedbackType.wrong,
      correctAnswer: _exerciseController.isCorrectAnswer.value 
          ? null 
          : _exerciseController.correctAnswerText.value,
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    // Fechar o modal primeiro
    Navigator.of(context).pop();
    
    // Fechar feedback do controller
    _exerciseController.closeFeedback();
    
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
