import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_controller.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/mascot_bubble.dart';
import '../widgets/word_chip.dart';
import '../widgets/word_zone.dart';
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

  // Dados mockados
  final _sentence = "J'apprends une.";
  final _correctAnswer = ['Eu', 'estou', 'aprendendo', 'uma'];
  final _availableWords = ['língua', 'velho', 'estudar', 'novo', 'Eu', 'estou', 'aprendendo', 'uma'];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LessonController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header
            Obx(() => ExerciseHeader(
                  progress: _controller.progress,
                  energy: Get.find<GamificationController>().currentEnergy.value,
                  onBack: () => Get.back(),
                )),

            const SizedBox(height: 24),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Selecione a tradução correta',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
            ),

            const SizedBox(height: 20),

            // Mascote com balão de áudio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MascotBubble(
                mascotAsset: AppAssets.lessonMascotFire,
                text: _sentence,
                onAudioTap: () {
                  // TODO: Tocar áudio
                },
              ),
            ),

            const SizedBox(height: 24),

            // Zona de resposta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: WordZone(
                words: _selectedWords,
                onWordTap: _onRemoveWord,
              ),
            ),

            const SizedBox(height: 24),

            // Palavras disponíveis
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildAvailableWords(),
              ),
            ),

            // Botão Check
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppButton(
                text: 'Verificar',
                onPressed: _selectedWords.isNotEmpty ? _onCheck : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets

  Widget _buildAvailableWords() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableWords.map((word) {
        final isSelected = _selectedWords.contains(word);
        return WordChip(
          text: word,
          isSelected: isSelected,
          onTap: isSelected ? null : () => _onSelectWord(word),
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

  void _onCheck() {
    if (_selectedWords.isEmpty) return;

    final isCorrect = listEquals(_selectedWords, _correctAnswer);

    // Registra a resposta no controller
    _controller.recordAnswer(isCorrect: isCorrect);

    FeedbackBottomSheet.show(
      context,
      type: isCorrect ? FeedbackType.correct : FeedbackType.wrong,
      correctAnswer: _correctAnswer.join(' '),
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    // Avança para o próximo exercício
    _controller.nextExercise();
    Get.off(() => const MatchExercisePage());
  }
}
