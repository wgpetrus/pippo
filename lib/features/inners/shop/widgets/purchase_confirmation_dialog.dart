import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal de confirmação de compra na loja
class PurchaseConfirmationDialog {
  static void show(
    BuildContext context, {
    required String itemName,
    required int cost,
    required String description,
    required VoidCallback onConfirm,
  }) {
    final r = ResponsiveUtils(context);

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              r.spacing24,
              r.spacing16,
              r.spacing24,
              r.spacing24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'shop_confirmation_title'.tr,
                  style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.spacing16),

                // Nome do item
                Text(
                  itemName,
                  style: AppTheme.textXlBold.copyWith(color: AppTheme.primary),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.spacing8),

                // Custo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.appbarGem,
                      width: ResponsiveUtils.width(24, min: 20, max: 28),
                      height: ResponsiveUtils.height(24, min: 20, max: 28),
                    ),
                    SizedBox(width: r.spacing4),
                    Text(
                      '$cost',
                      style: AppTheme.textXlBold.copyWith(color: AppTheme.gold),
                    ),
                  ],
                ),

                SizedBox(height: r.spacing16),

                // Descrição
                Text(
                  description,
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.spacing24),

                // Botão Cancelar
                _CancelButton(onPressed: () => Get.back()),

                SizedBox(height: r.spacing12),

                // Botão Confirmar
                AppButton(
                  text: 'shop_confirmation_confirm'.tr,
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

/// Botão Cancelar com borda verde
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
    final r = ResponsiveUtils(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: double.infinity,
        height: ResponsiveUtils.height(62, min: 48, max: 72),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r.spacing32),
          color: AppTheme.green,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: _isPressed ? 0 : 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r.spacing32),
            color: AppTheme.white,
            border: Border.all(color: AppTheme.green, width: 2),
          ),
          child: Center(
            child: Text(
              'shop_confirmation_cancel'.tr,
              style: AppTheme.textLgBold.copyWith(color: AppTheme.green),
            ),
          ),
        ),
      ),
    );
  }
}
