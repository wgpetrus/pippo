import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal de confirmação de exclusão genérico
class ConfirmDeleteModal {
  static void show(
    BuildContext context, {
    required String title,
    required String description,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.red100,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  title,
                  style: AppTheme.displayXsBold.copyWith(color: AppTheme.red),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Descrição
                Text(
                  description,
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Botão Cancel
                _CancelButton(onPressed: () => Get.back()),

                const SizedBox(height: 12),

                // Botão Confirmar
                AppButton(
                  text: confirmText,
                  color: AppTheme.red,
                  onPressed: () {
                    Get.back();
                    onConfirm();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Botão Cancel com borda azul
class _CancelButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CancelButton({required this.onPressed});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppTheme.primary,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: _isPressed ? 0 : 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AppTheme.white,
            border: Border.all(color: AppTheme.primary, width: 2),
          ),
          child: Center(
            child: Text(
              'Cancelar',
              style: AppTheme.textLgBold.copyWith(color: AppTheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}
