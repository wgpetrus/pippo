import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/image_with_label.dart';
import '../widgets/lesson_option_card.dart';
import '../widgets/low_energy_modal.dart';
import 'word_exercise_page.dart';

/// Página de exercício de seleção de tradução
class TranslationExercisePage extends StatefulWidget {
  const TranslationExercisePage({super.key});

  @override
  State<TranslationExercisePage> createState() => _TranslationExercisePageState();
}

class _TranslationExercisePageState extends State<TranslationExercisePage> {
  int? _selectedIndex;
  bool _hasShownEnergyModal = false;

  // Dados mockados
  final _correctIndex = 1; // garçon
  final _options = ['femme', 'garçon', 'livre'];

  @override
  void initState() {
    super.initState();
    // Mostra o modal após o build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownEnergyModal) {
        _hasShownEnergyModal = true;
        LowEnergyModal.show(context, currentEnergy: 5);
      }
    });
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
            ExerciseHeader(
              progress: 0.5,
              energy: 5,
              onBack: () => Get.back(),
            ),

            const SizedBox(height: 24),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Selecione a tradução correta',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
            ),

            const SizedBox(height: 24),

            // Imagem com label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ImageWithLabel(
                imageAsset: AppAssets.lessonSpider,
                label: 'Menino',
              ),
            ),

            const SizedBox(height: 32),

            // Opções de tradução
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    for (int i = 0; i < _options.length; i++) ...[
                      LessonOptionCard(
                        label: _options[i],
                        status: _selectedIndex == i
                            ? LessonOptionStatus.selected
                            : LessonOptionStatus.normal,
                        onTap: () => _onOptionTap(i),
                      ),
                      if (i < _options.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),

            // Botão Check
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppButton(
                text: 'Verificar',
                onPressed: _selectedIndex != null ? _onCheck : null,
              ),
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

  void _onCheck() {
    if (_selectedIndex == null) return;

    final isCorrect = _selectedIndex == _correctIndex;

    FeedbackBottomSheet.show(
      context,
      type: isCorrect ? FeedbackType.correct : FeedbackType.wrong,
      correctAnswer: _options[_correctIndex],
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    Get.off(() => const WordExercisePage());
  }
}
