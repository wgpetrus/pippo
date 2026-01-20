import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_controller.dart';
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
  late final LessonController _controller;
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
  void initState() {
    super.initState();
    _controller = Get.find<LessonController>();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
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
                'Selecione a imagem correta',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
            ),

            SizedBox(height: r.spacing16),

            // Botão de áudio com palavra
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.spacing20),
              child: AudioWordButton(
                word: 'le garçon',
                onTap: () {
                  // TODO: Tocar áudio
                },
              ),
            ),

            SizedBox(height: r.spacing24),

            // Grid de opções
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.spacing20),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: r.isLandscape ? 4 : 2,
                    crossAxisSpacing: r.spacing12,
                    mainAxisSpacing: r.spacing12,
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
              padding: EdgeInsets.all(r.spacing20),
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

    // Registra a resposta no controller
    _controller.recordAnswer(isCorrect: isCorrect);

    FeedbackBottomSheet.show(
      context,
      type: isCorrect ? FeedbackType.correct : FeedbackType.wrong,
      correctAnswer: _options[_correctIndex]['label'],
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    // Avança para o próximo exercício
    _controller.nextExercise();
    Get.off(() => const TranslationExercisePage());
  }
}
