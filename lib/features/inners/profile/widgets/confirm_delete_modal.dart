import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/profile_controller.dart';

/// Modal de confirmação final de exclusão de conta
class ConfirmDeleteModal {
  static void show(BuildContext context) {
    final controller = Get.find<ProfileController>();

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
                  'Confirmação Final',
                  style: AppTheme.displayXsBold.copyWith(color: AppTheme.red),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Descrição
                Text(
                  'Esta é sua última chance!\n\nSua conta será excluída permanentemente e não poderá ser recuperada.',
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Aviso adicional
                Text(
                  'Você tem certeza absoluta?',
                  style: AppTheme.textMdBold.copyWith(color: AppTheme.red),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Mostrar mensagem de erro se houver
                Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.red),
                        ),
                        child: Text(
                          controller.errorMessage.value,
                          style: AppTheme.textSmRegular.copyWith(color: AppTheme.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Botão Cancel
                _CancelButton(onPressed: () => Get.back()),

                const SizedBox(height: 12),

                // Botão Confirmar Exclusão
                Obx(() => AppButton(
                  text: controller.isLoading.value ? 'Excluindo...' : 'Confirmar Exclusão',
                  color: AppTheme.red,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          // Chamar deleteAccount do controller
                          await controller.deleteAccount();
                          
                          // Se não houver erro, o modal será fechado automaticamente
                          // pela navegação para /auth no controller
                          // Se houver erro, a mensagem será exibida acima
                        },
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Botão Cancel com borda verde
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
