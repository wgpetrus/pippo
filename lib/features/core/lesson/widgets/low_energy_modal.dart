import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal de aviso de energia baixa durante lição
class LowEnergyModal extends StatelessWidget {
  final int currentEnergy;
  final int maxEnergy;

  const LowEnergyModal({
    super.key,
    required this.currentEnergy,
    this.maxEnergy = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Raios de energia
            _buildEnergyBolts(),
            const SizedBox(height: 24),

            // Mensagem
            Text(
              'lesson_low_energy_message'.trParams({'energy': currentEnergy.toString()}),
              textAlign: TextAlign.center,
              style: AppTheme.textMdMedium.copyWith(color: AppTheme.black),
            ),
            const SizedBox(height: 24),

            // Botão Entendi
            AppButton(
              text: 'lesson_low_energy_button'.tr,
              onPressed: () => Navigator.of(context).pop(),
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
            isFilled ? AppAssets.appbarRay : AppAssets.bottomRayDisable,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        );
      }),
    );
  }

  // Método estático para exibir
  static void show(
    BuildContext context, {
    required int currentEnergy,
    int maxEnergy = 5,
  }) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: LowEnergyModal(
            currentEnergy: currentEnergy,
            maxEnergy: maxEnergy,
          ),
        ),
      ],
    );
  }
}
