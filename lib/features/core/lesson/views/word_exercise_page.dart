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
import 'complete_page.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LessonController>();
  }

  @override
  Widget build(BuildContext context) {
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
      final sentence = currentExercise['sentence'] as String? ?? '';
      final availableWords = (currentExercise['availableWords'] as List?)?.cast<String>() ?? [];
      
      return Scaffold(
        backgroundColor: AppTheme.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              ExerciseHeader(
                progress: _controller.progress,
                energy: Get.find<GamificationController>().currentEnergy.value,
                onBack: () => Get.back(),
              ),

              const SizedBox(height: 24),

              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  currentExercise['prompt'] as String? ?? 'Selecione a tradução correta',
                  style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                ),
              ),

              const SizedBox(height: 20),

              // Mascote com balão de áudio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MascotBubble(
                  mascotAsset: AppAssets.lessonMascotFire,
                  text: sentence,
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
                  child: _buildAvailableWords(availableWords),
                ),
              ),

              // Botão Check
              Padding(
                padding: const EdgeInsets.all(20),
                child: AppButton(
                  text: 'Verificar',
                  isLoading: _controller.isLoading.value,
                  onPressed: _selectedWords.isNotEmpty && !_controller.isLoading.value
                      ? _onCheck
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Widgets

  Widget _buildAvailableWords(List<String> availableWords) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableWords.map((word) {
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

  void _onCheck() async {
    if (_selectedWords.isEmpty) return;

    // Submete a resposta ao controller
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
    // Avança para o próximo exercício
    _controller.nextExercise();
    
    // Verifica se há mais exercícios
    if (_controller.currentExerciseIndex.value < _controller.currentExercises.length) {
      // Continua na mesma tela (próximo exercício)
      setState(() {
        _selectedWords.clear();
      });
    } else {
      // Último exercício - navega para tela de conclusão
      Get.off(() => const CompletePage());
    }
  }
}
