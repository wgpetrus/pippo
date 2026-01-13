import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
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
      return 'Your learning energy is fully charged ⚡\nReady to go?';
    } else if (isEmpty) {
      return 'No flashes left; Take a short break, then\ncome back stronger.';
    } else {
      return 'Only one flash left... use it wisely!';
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              'Your Energy Sparks',
              style: AppTheme.displayXsBold,
            ),
            const SizedBox(height: 24),

            // Raios de energia
            _buildEnergyBolts(),
            const SizedBox(height: 24),

            // Mensagem
            Text(
              _messageText,
              textAlign: TextAlign.center,
              style: AppTheme.textMdMedium.copyWith(color: AppTheme.gray300),
            ),

            // Next Flash (se não estiver cheio)
            if (!isFull && nextEnergyTime != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next Flash in  ',
                    style: AppTheme.textMdMedium.copyWith(color: AppTheme.gray300),
                  ),
                  Text(
                    nextEnergyTime!,
                    style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Botão Unlimited Flashes
            AppButton(
              text: 'Unlimited',
              isPrimary: true,
              onPressed: onUnlimitedTap,
              prefixIcon: const FaIcon(
                FontAwesomeIcons.infinity,
                color: AppTheme.white,
                size: 18,
              ),
              suffixIcon: Text(
                'Free trial',
                style: AppTheme.textMdBold.copyWith(color: AppTheme.white),
              ),
            ),
            const SizedBox(height: 12),

            // Botão Refill Flashes
            AppButton(
              text: 'Refill Flashes',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxEnergy, (index) {
        final isFilled = index < currentEnergy;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Image.asset(
            isFilled ? AppAssets.bottomRay : AppAssets.bottomRayDisable,
            width: 40,
            height: 40,
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
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: EnergyModal(
              currentEnergy: currentEnergy,
              maxEnergy: maxEnergy,
              nextEnergyTime: nextEnergyTime,
              onUnlimitedTap: () {
                Navigator.of(ctx).pop();
                onUnlimitedTap?.call();
              },
              onRefillTap: () {
                Navigator.of(ctx).pop();
                onRefillTap?.call();
              },
            ),
          ),
        ),
      ),
    );
  }
}
