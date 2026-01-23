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
import 'complete_page.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LessonController>();
  }

  Map<String, dynamic> get _currentExercise {
    if (_controller.currentExerciseIndex.value >= _controller.currentExercises.length) {
      return {};
    }
    return _controller.currentExercises[_controller.currentExerciseIndex.value];
  }

  List<dynamic> get _options => _currentExercise['options'] as List? ?? [];

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    // Validação de exercício
    if (_currentExercise.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Exercício não encontrado')),
      );
    }

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
              padding: EdgeInsets.symmetric(horizontal: r.spacing16),
              child: Text(
                _currentExercise['prompt'] as String? ?? 'Selecione a imagem correta',
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.spacing16),
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
                    final option = _options[index];
                    return LessonOptionCard(
                      imageAsset: option['image'] as String? ?? '',
                      label: option['label'] as String? ?? '',
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
              padding: EdgeInsets.all(r.spacing16),
              child: Obx(() => AppButton(
                    text: 'Verificar',
                    isLoading: _controller.isLoading.value,
                    onPressed: _selectedIndex != null && !_controller.isLoading.value
                        ? _onCheck
                        : null,
                  )),
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

  void _onCheck() async {
    if (_selectedIndex == null) return;

    final selectedOption = _options[_selectedIndex!];
    final selectedImageId = selectedOption['id'] as String;

    // Submete a resposta ao controller
    await _controller.submitAnswer(selectedImageId, 'image');
  }

  void _onContinue() {
    // Avança para o próximo exercício
    _controller.nextExercise();
    
    // Verifica se há mais exercícios
    if (_controller.currentExerciseIndex.value < _controller.currentExercises.length) {
      // Continua na mesma tela (próximo exercício)
      setState(() {
        _selectedIndex = null;
      });
    } else {
      // Último exercício - navega para tela de conclusão
      Get.off(() => const CompletePage());
    }
  }
}
