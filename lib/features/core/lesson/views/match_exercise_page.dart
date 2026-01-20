import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
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

  // Dados mockados (índices correspondem)
  final _pairs = [
    {'audio': 'audio_i', 'text': 'Eu'},
    {'audio': 'audio_cat', 'text': 'Gato'},
    {'audio': 'audio_and', 'text': 'e'},
    {'audio': 'audio_boy', 'text': 'menino'},
  ];

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
                'Toque nos pares correspondentes',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
            ),

            const SizedBox(height: 32),

            // Pares
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    for (int i = 0; i < _pairs.length; i++) ...[
                      _buildPairRow(i),
                      if (i < _pairs.length - 1) const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Link "Can't listen now"
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Pular exercício de áudio
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
              padding: const EdgeInsets.all(20),
              child: AppButton(
                text: 'Verificar',
                onPressed: _matchedPairs.length == _pairs.length ? _onCheck : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets

  Widget _buildPairRow(int index) {
    final isMatched = _matchedPairs.contains(index);

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          // Card de áudio
          Expanded(
            child: AudioCard(
              status: _getAudioStatus(index),
              onTap: isMatched ? null : () => _onAudioTap(index),
            ),
          ),

          const SizedBox(width: 12),

          // Card de texto
          Expanded(
            child: LessonOptionCard(
              label: _pairs[index]['text']!,
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

  void _onCheck() {
    // Todos os pares foram combinados corretamente
    // Registra como resposta correta
    _controller.recordAnswer(isCorrect: true);

    FeedbackBottomSheet.show(
      context,
      type: FeedbackType.correct,
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    // Avança para o próximo exercício (último da lição)
    _controller.nextExercise();
    Get.off(() => const CompletePage());
  }
}
