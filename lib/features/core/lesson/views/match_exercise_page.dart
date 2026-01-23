import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_controller.dart';
import '../widgets/audio_card.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/lesson_option_card.dart';
import 'complete_page.dart';

/// Página de exercício de matching (combinar pares)
class MatchExercisePage extends StatefulWidget {
  const MatchExercisePage({super.key});

  @override
  State<MatchExercisePage> createState() => _MatchExercisePageState();
}

class _MatchExercisePageState extends State<MatchExercisePage> {
  late final LessonController _controller;
  int? _selectedAudioIndex;
  int? _selectedTextIndex;
  final Set<int> _matchedPairs = {};

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
    final pairs = (currentExercise['pairs'] as List?) ?? [];
    
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
              padding: EdgeInsets.symmetric(horizontal: r.spacing20),
              child: Text(
                currentExercise['prompt'] as String? ?? 'Toque nos pares correspondentes',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
            ),

            SizedBox(height: r.spacing32),

            // Pares
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.spacing20),
                child: Column(
                  children: [
                    for (int i = 0; i < pairs.length; i++) ...[
                      _buildPairRow(i, pairs, r),
                      if (i < pairs.length - 1) SizedBox(height: r.spacing16),
                    ],
                  ],
                ),
              ),
            ),

            // Link "Can't listen now"
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Implementar skip de exercício de áudio
                },
                child: Text(
                  "Não posso ouvir agora",
                  style: AppTheme.textMdSemibold.copyWith(
                    color: AppTheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            // Botão Check
            Padding(
              padding: EdgeInsets.all(r.spacing20),
              child: Obx(() => AppButton(
                    text: 'Verificar',
                    isLoading: _controller.isLoading.value,
                    onPressed: _matchedPairs.length == pairs.length && !_controller.isLoading.value
                        ? _onCheck
                        : null,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets

  Widget _buildPairRow(int index, List pairs, ResponsiveUtils r) {
    final isMatched = _matchedPairs.contains(index);
    final pair = pairs[index];

    return SizedBox(
      height: r.height(56, min: 48, max: 64),
      child: Row(
        children: [
          // Card de áudio
          Expanded(
            child: AudioCard(
              status: _getAudioStatus(index),
              onTap: isMatched ? null : () => _onAudioTap(index),
            ),
          ),

          SizedBox(width: r.spacing12),

          // Card de texto
          Expanded(
            child: LessonOptionCard(
              label: pair['text'] as String? ?? '',
              status: _getTextStatus(index),
              onTap: isMatched ? null : () => _onTextTap(index),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers

  AudioCardStatus _getAudioStatus(int index) {
    if (_matchedPairs.contains(index)) return AudioCardStatus.matched;
    if (_selectedAudioIndex == index) return AudioCardStatus.selected;
    return AudioCardStatus.normal;
  }

  LessonOptionStatus _getTextStatus(int index) {
    if (_matchedPairs.contains(index)) {
      return LessonOptionStatus.correct;
    }
    if (_selectedTextIndex == index) return LessonOptionStatus.selected;
    return LessonOptionStatus.normal;
  }

  // Métodos

  void _onAudioTap(int index) {
    setState(() {
      _selectedAudioIndex = index;
      _checkMatch();
    });
  }

  void _onTextTap(int index) {
    setState(() {
      _selectedTextIndex = index;
      _checkMatch();
    });
  }

  void _checkMatch() {
    if (_selectedAudioIndex != null && _selectedTextIndex != null) {
      // Verifica se os índices correspondem (match correto)
      if (_selectedAudioIndex == _selectedTextIndex) {
        _matchedPairs.add(_selectedAudioIndex!);
      }
      // Limpa seleção
      _selectedAudioIndex = null;
      _selectedTextIndex = null;
    }
  }

  void _onCheck() async {
    // Submete resposta ao controller
    // O controller valida se todos os pares estão corretos
    await _controller.submitAnswer(userAnswer: _matchedPairs.toList());

    // Mostra feedback
    FeedbackBottomSheet.show(
      context,
      type: _controller.isCorrectAnswer.value 
          ? FeedbackType.correct 
          : FeedbackType.incorrect,
      correctAnswer: _controller.correctAnswerText.value,
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    // Controller gerencia navegação para próximo exercício ou tela de conclusão
    _controller.nextExercise();
    
    // Reseta estado local para próximo exercício
    setState(() {
      _matchedPairs.clear();
      _selectedAudioIndex = null;
      _selectedTextIndex = null;
    });
  }
}
