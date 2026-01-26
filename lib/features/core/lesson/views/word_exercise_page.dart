import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_controller.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/mascot_bubble.dart';
import '../widgets/word_chip.dart';
import '../widgets/word_zone.dart';
import 'complete_page.dart';
import 'image_exercise_page.dart';
import 'translation_exercise_page.dart';
import 'match_exercise_page.dart';

/// Página de exercício de ordenação de palavras
class WordExercisePage extends StatefulWidget {
  const WordExercisePage({super.key});

  @override
  State<WordExercisePage> createState() => _WordExercisePageState();
}

class _WordExercisePageState extends State<WordExercisePage> {
  late final LessonController _controller;
  
  // Palavras selecionadas (resposta)
  final List<String> _selectedWords = [];
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LessonController>();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Obx(() {
      // Tratamento de erro
      if (_controller.errorMessage.value.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Erro',
            _controller.errorMessage.value,
            backgroundColor: AppTheme.red,
            colorText: AppTheme.white,
          );
        });
      }

      // Obter exercício atual do controller
      if (_controller.currentExerciseIndex.value >= _controller.currentExercises.length) {
        return const Scaffold(
          body: Center(child: Text('Exercício não encontrado')),
        );
      }
      
      final currentExercise = _controller.currentExercises[_controller.currentExerciseIndex.value];
      final words = (currentExercise['words'] as List?)?.cast<String>() ?? [];
      
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
                  ExerciseHeader(
                    progress: _controller.progress,
                    energy: Get.find<GamificationController>().currentEnergy.value,
                    onBack: _hasChecked ? null : () => _onBackPressed(context),
                  ),

                  SizedBox(height: r.spacing24),

                  // Título
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                    child: Text(
                      currentExercise['question'] as String? ?? 'Organize as palavras',
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    ),
                  ),

                  SizedBox(height: r.spacing16),

                  // Mascote com balão de áudio
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                    child: MascotBubble(
                      mascotAsset: AppAssets.lessonMascotFire,
                      text: currentExercise['question'] as String? ?? '',
                      onAudioTap: () {
                        // TODO: [etapa 8] conectar com TTS para tocar áudio
                      },
                    ),
                  ),

                  SizedBox(height: r.spacing24),

                  // Zona de resposta
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                    child: WordZone(
                      words: _selectedWords,
                      onWordTap: _hasChecked ? (_) {} : _onRemoveWord,
                    ),
                  ),

                  SizedBox(height: r.spacing24),

                  // Palavras disponíveis
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                    child: _buildAvailableWords(words),
                  ),

                  SizedBox(height: r.spacing16),

                  // Botão Check
                  Padding(
                    padding: EdgeInsets.all(r.spacing16),
                    child: AppButton(
                      text: 'Verificar',
                      isLoading: _controller.isLoading.value,
                      onPressed: _selectedWords.isNotEmpty && !_controller.isLoading.value && !_hasChecked
                          ? _onCheck
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // Widgets

  Widget _buildAvailableWords(List<String> availableWords) {
    final r = ResponsiveUtils(context);
    return Wrap(
      spacing: r.spacing8,
      runSpacing: r.spacing8,
      children: availableWords.map((word) {
        final isSelected = _selectedWords.contains(word);
        return WordChip(
          text: word,
          isSelected: isSelected,
          onTap: (isSelected || _hasChecked) ? null : () => _onSelectWord(word),
        );
      }).toList(),
    );
  }

  // Métodos

  void _onSelectWord(String word) {
    setState(() {
      _selectedWords.add(word);
    });
  }

  void _onRemoveWord(int index) {
    setState(() {
      _selectedWords.removeAt(index);
    });
  }

  void _onCheck() async {
    if (_selectedWords.isEmpty) return;

    setState(() {
      _hasChecked = true;
    });

    // TODO: [etapa 8] submeter resposta ao controller
    await _controller.submitAnswer(_selectedWords, 'word_order');

    // Mostra feedback
    if (!mounted) return;
    FeedbackBottomSheet.show(
      context,
      type: _controller.isCorrectAnswer.value ? FeedbackType.correct : FeedbackType.wrong,
      correctAnswer: _controller.correctAnswerText.value,
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    // Fechar o modal primeiro
    Navigator.of(context).pop();
    
    // Depois avançar o índice do exercício
    _controller.nextExercise();
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

