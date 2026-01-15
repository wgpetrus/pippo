import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal de Energy Sparks
class EnergyModal extends StatelessWidget {
  final int currentEnergy;
  final int maxEnergy;
  final String? nextEnergyTime;
  final VoidCallback? onUnlimitedTap;
  final VoidCallback? onRefillTap;

  const EnergyModal({
    super.key,
    required this.currentEnergy,
    this.maxEnergy = 5,
    this.nextEnergyTime,
    this.onUnlimitedTap,
    this.onRefillTap,
  });

  // Getters
  bool get isFull => currentEnergy >= maxEnergy;
  bool get isEmpty => currentEnergy == 0;

  String get _messageText {
    if (isFull) {
      return 'Sua energia de aprendizado está totalmente carregada ⚡\nPronto para começar?';
    } else if (isEmpty) {
      return 'Sem energia restante. Faça uma pausa e\nvolte mais forte.';
    } else {
      return 'Apenas uma energia restante... use com sabedoria!';
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    // Padding responsivo para telas pequenas
    final verticalPadding = ResponsiveUtils.isShortScreen ? 16.0 : 24.0;
    final spacing = ResponsiveUtils.isShortScreen ? 16.0 : 24.0;
    final smallSpacing = ResponsiveUtils.isShortScreen ? 8.0 : 12.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.all(verticalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            const Text(
              'Sua Energia',
              style: AppTheme.displayXsBold,
            ),
            SizedBox(height: spacing),

            // Raios de energia
            _buildEnergyBolts(),
            SizedBox(height: spacing),

            // Mensagem
            Text(
              _messageText,
              textAlign: TextAlign.center,
              style: AppTheme.textMdMedium.copyWith(color: AppTheme.gray300),
            ),

            // Next Flash (se não estiver cheio)
            if (!isFull && nextEnergyTime != null) ...[
              SizedBox(height: smallSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Próxima energia em  ',
                    style: AppTheme.textMdMedium.copyWith(color: AppTheme.gray300),
                  ),
                  Text(
                    nextEnergyTime!,
                    style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
                  ),
                ],
              ),
            ],
            SizedBox(height: spacing),

            // Botão Unlimited Flashes
            AppButton(
              text: 'Ilimitado',
              isPrimary: true,
              onPressed: onUnlimitedTap,
              prefixIcon: const FaIcon(
                FontAwesomeIcons.infinity,
                color: AppTheme.white,
                size: 18,
              ),
              suffixIcon: Text(
                'Teste grátis',
                style: AppTheme.textMdBold.copyWith(color: AppTheme.white),
              ),
            ),
            SizedBox(height: smallSpacing),

            // Botão Refill Flashes
            AppButton(
              text: 'Recarregar',
              isPrimary: false,
              onPressed: onRefillTap,
              prefixIcon: Image.asset(AppAssets.appbarRay, width: 24, height: 24),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppAssets.appbarGem, width: 20, height: 20),
                  const SizedBox(width: 4),
                  Text(
                    '100',
                    style: AppTheme.textLgBold.copyWith(color: AppTheme.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _buildEnergyBolts() {
    final boltSize = ResponsiveUtils.width(40, min: 28, max: 48);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxEnergy, (index) {
        final isFilled = index < currentEnergy;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Image.asset(
            isFilled ? AppAssets.bottomRay : AppAssets.bottomRayDisable,
            width: boltSize,
            height: boltSize,
            fit: BoxFit.contain,
          ),
        );
      }),
    );
  }

  // Métodos estáticos
  static void show(
    BuildContext context, {
    required int currentEnergy,
    int maxEnergy = 5,
    String? nextEnergyTime,
    VoidCallback? onUnlimitedTap,
    VoidCallback? onRefillTap,
  }) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: EnergyModal(
              currentEnergy: currentEnergy,
              maxEnergy: maxEnergy,
              nextEnergyTime: nextEnergyTime,
              onUnlimitedTap: () {
                Navigator.of(context).pop();
                onUnlimitedTap?.call();
              },
              onRefillTap: () {
                Navigator.of(context).pop();
                onRefillTap?.call();
              },
            ),
          ),
        ),
      ],
    );
  }
}
