import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';

/// Tipo de feedback do exercício
enum FeedbackType { correct, wrong }

/// Modal de feedback para exercícios (correto/errado)
class FeedbackBottomSheet {
  /// Exibe o modal de feedback
  static void show(
    BuildContext context, {
    required FeedbackType type,
    String? correctAnswer,
    required VoidCallback onContinue,
  }) {
    final isCorrect = type == FeedbackType.correct;

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: isCorrect ? AppTheme.green100 : AppTheme.red100,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: _FeedbackContent(
            isCorrect: isCorrect,
            correctAnswer: correctAnswer,
            onContinue: onContinue,
          ),
        ),
      ],
      modalTypeBuilder: (context) => WoltModalType.bottomSheet(),
      barrierDismissible: false,
    );
  }
}

/// Conteúdo do modal de feedback
class _FeedbackContent extends StatelessWidget {
  final bool isCorrect;
  final String? correctAnswer;
  final VoidCallback onContinue;

  const _FeedbackContent({
    required this.isCorrect,
    this.correctAnswer,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: isCorrect ? AppTheme.green100 : AppTheme.red100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: isCorrect ? AppTheme.green : AppTheme.red,
          width: 2,
        ),
      ),
      child: isCorrect ? _buildCorrectContent() : _buildWrongContent(),
    );
  }

  // Conteúdo para resposta correta
  Widget _buildCorrectContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          'lesson_feedback_correct_title'.tr,
          style: AppTheme.displayXsBold.copyWith(color: AppTheme.green),
        ),
        const SizedBox(height: 8),

        // Subtítulo
        Text(
          'lesson_feedback_correct_subtitle'.tr,
          style: AppTheme.textLgRegular.copyWith(color: AppTheme.green),
        ),
        const SizedBox(height: 24),

        // Botão Continuar
        AppButton(
          text: 'lesson_feedback_correct_button'.tr,
          color: AppTheme.green,
          onPressed: onContinue,
        ),
      ],
    );
  }

  // Conteúdo para resposta errada
  Widget _buildWrongContent() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Mascote grande atrás (posicionado no canto direito)
        Positioned(
          right: 0,
          top: -20,
          bottom: 20,
          child: Image.asset(
            AppAssets.lessonMascotError,
            width: 140,
            fit: BoxFit.contain,
          ),
        ),

        // Conteúdo principal
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balão de fala
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 100),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'lesson_feedback_wrong_message'.tr,
                style: AppTheme.textMdSemibold.copyWith(color: AppTheme.red),
              ),
            ),
            const SizedBox(height: 16),

            // Resposta correta (se fornecida)
            if (correctAnswer != null) ...[
              Text(
                'lesson_feedback_wrong_correct_answer_label'.tr,
                style: AppTheme.textMdBold.copyWith(color: AppTheme.black),
              ),
              const SizedBox(height: 4),
              Text(
                correctAnswer!,
                style: AppTheme.textMdRegular.copyWith(
                  color: AppTheme.black,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Botão Entendi
            AppButton(
              text: 'lesson_feedback_wrong_button'.tr,
              color: AppTheme.red,
              onPressed: onContinue,
            ),
          ],
        ),
      ],
    );
  }
}
