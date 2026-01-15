import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/audio_word_button.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/lesson_option_card.dart';
import 'translation_exercise_page.dart';

/// Página de exercício de seleção de imagem
class ImageExercisePage extends StatefulWidget {
  const ImageExercisePage({super.key});

  @override
  State<ImageExercisePage> createState() => _ImageExercisePageState();
}

class _ImageExercisePageState extends State<ImageExercisePage> {
  int? _selectedIndex;

  // Dados mockados
  final _correctIndex = 0;
  final _options = [
    {'image': AppAssets.lessonBoy, 'label': 'Menino'},
    {'image': AppAssets.lessonWaiter, 'label': 'Garçom'},
    {'image': AppAssets.lessonGirl, 'label': 'Menina'},
    {'image': AppAssets.lessonDog, 'label': 'Cachorro'},
  ];

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
              progress: 0.1,
              energy: 5,
              onBack: () => Get.back(),
            ),

            const SizedBox(height: 24),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Selecione a imagem correta',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
            ),

            const SizedBox(height: 16),

            // Botão de áudio com palavra
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AudioWordButton(
                word: 'le garçon',
                onTap: () {
                  // TODO: Tocar áudio
                },
              ),
            ),

            const SizedBox(height: 24),

            // Grid de opções
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveUtils.isLandscape ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    return LessonOptionCard(
                      imageAsset: _options[index]['image']!,
                      label: _options[index]['label']!,
                      showImage: true,
                      status: _selectedIndex == index
                          ? LessonOptionStatus.selected
                          : LessonOptionStatus.normal,
                      onTap: () => _onOptionTap(index),
                    );
                  },
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
      correctAnswer: _options[_correctIndex]['label'],
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    Get.off(() => const TranslationExercisePage());
  }
}
