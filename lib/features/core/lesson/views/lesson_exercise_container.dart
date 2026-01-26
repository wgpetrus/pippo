import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/lesson_controller.dart';
import 'complete_page.dart';
import 'fail_page.dart';
import 'image_exercise_page.dart';
import 'translation_exercise_page.dart';
import 'word_exercise_page.dart';
import 'match_exercise_page.dart';

/// Container que renderiza o exercício correto baseado no índice atual
/// Esta é a ÚNICA página de exercícios que deve ser navegada
class LessonExerciseContainer extends StatelessWidget {
  const LessonExerciseContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LessonController>();
    
    return WillPopScope(
      // Bloquear voltar completamente durante os exercícios
      // O dialog de confirmação é mostrado pelos botões internos
      onWillPop: () async => false,
      child: Obx(() {
        // Se a lição falhou, navega para tela de falha
        if (controller.lessonFailed.value) {
          // Usar addPostFrameCallback para navegar após o build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.lessonFailed.value) {
              Get.off(() => const FailPage());
            }
          });
        }
        
        // Se não há exercícios ou índice inválido
        if (controller.currentExercises.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Nenhum exercício encontrado')),
          );
        }
        
        // Se completou todos os exercícios, mostra tela de conclusão
        if (controller.currentExerciseIndex.value >= controller.currentExercises.length) {
          return const CompletePage();
        }
        
        // Obter exercício atual
        final currentExercise = controller.currentExercises[controller.currentExerciseIndex.value];
        final exerciseType = currentExercise['type'] as String;
        
        // Renderizar o widget correto baseado no tipo com key única
        switch (exerciseType) {
          case 'image':
            return ImageExercisePage(key: ValueKey(controller.currentExerciseIndex.value));
          case 'translation':
            return TranslationExercisePage(key: ValueKey(controller.currentExerciseIndex.value));
          case 'word_order':
            return WordExercisePage(key: ValueKey(controller.currentExerciseIndex.value));
          case 'match':
            return MatchExercisePage(key: ValueKey(controller.currentExerciseIndex.value));
          default:
            return Scaffold(
              body: Center(child: Text('Tipo de exercício desconhecido: $exerciseType')),
            );
        }
      }),
    );
  }
}
