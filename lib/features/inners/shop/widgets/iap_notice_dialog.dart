import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal de aviso sobre compras in-app
class IapNoticeDialog {
  static void show(
    BuildContext context, {
    required VoidCallback onContinue,
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
                // Ícone
                Container(
                  width: ResponsiveUtils.width(80, min: 64, max: 96),
                  height: ResponsiveUtils.height(80, min: 64, max: 96),
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.circleInfo,
                      size: ResponsiveUtils.width(40, min: 32, max: 48),
                      color: AppTheme.orange,
                    ),
                  ),
                ),

                SizedBox(height: r.spacing16),

                // Título
                Text(
                  'Aviso Importante',
                  style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.spacing12),

                // Mensagem
                Text(
                  'Compras in-app com dinheiro real serão implementadas em uma versão futura do aplicativo.',
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.spacing8),

                Text(
                  'Por enquanto, você pode adquirir gemas completando lições e desafios!',
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.primary),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.spacing24),

                // Botão Entendi
                AppButton(
                  text: 'Entendi',
                  onPressed: () {
                    Get.back();
                    onContinue();
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
