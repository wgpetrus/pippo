import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../gamification/controllers/energy_controller.dart';
import '../../gamification/controllers/gems_controller.dart';

/// Modal de Energy Sparks
class EnergyModal extends StatelessWidget {
  final VoidCallback? onUnlimitedTap;

  const EnergyModal({
    super.key,
    this.onUnlimitedTap,
  });

  // Getters
  bool _isFull(int currentEnergy, int maxEnergy) => currentEnergy >= maxEnergy;
  bool _isEmpty(int currentEnergy) => currentEnergy == 0;

  String _getMessageText(int currentEnergy, int maxEnergy) {
    if (_isFull(currentEnergy, maxEnergy)) {
      return 'home_energy_modal_full_message'.tr;
    } else if (_isEmpty(currentEnergy)) {
      return 'home_energy_modal_empty_message'.tr;
    } else {
      return 'home_energy_modal_low_message'.tr;
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final energyController = Get.find<EnergyController>();
    final gemsController = Get.find<GemsController>();
    
    // Padding responsivo para telas pequenas
    final verticalPadding = r.isTablet || r.isDesktop ? 24.0 : 16.0;
    final spacing = r.isTablet || r.isDesktop ? 24.0 : 16.0;
    final smallSpacing = r.isTablet || r.isDesktop ? 12.0 : 8.0;

    return Obx(() {
      final currentEnergy = energyController.currentEnergy.value;
      final maxEnergy = 5;
      final nextEnergyTime = energyController.getNextEnergyTime();
      final isFull = _isFull(currentEnergy, maxEnergy);
      final messageText = _getMessageText(currentEnergy, maxEnergy);
      
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
              Text(
                'home_energy_modal_title'.tr,
                style: AppTheme.displayXsBold,
              ),
              SizedBox(height: spacing),

              // Raios de energia
              _buildEnergyBolts(currentEnergy, maxEnergy),
              SizedBox(height: spacing),

              // Mensagem
              Text(
                messageText,
                textAlign: TextAlign.center,
                style: AppTheme.textMdMedium.copyWith(color: AppTheme.gray300),
              ),

              // Next Flash (se não estiver cheio)
              if (!isFull && nextEnergyTime.isNotEmpty) ...[
                SizedBox(height: smallSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'home_energy_modal_next_energy'.tr,
                      style: AppTheme.textMdMedium.copyWith(color: AppTheme.gray300),
                    ),
                    Text(
                      nextEnergyTime,
                      style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
                    ),
                  ],
                ),
              ],
              SizedBox(height: spacing),

              // Botão Unlimited Flashes
              AppButton(
                text: 'home_energy_modal_unlimited_button'.tr,
                isPrimary: true,
                onPressed: onUnlimitedTap,
                prefixIcon: const FaIcon(
                  FontAwesomeIcons.infinity,
                  color: AppTheme.white,
                  size: 18,
                ),
                suffixIcon: Text(
                  'home_energy_modal_free_trial'.tr,
                  style: AppTheme.textMdBold.copyWith(color: AppTheme.white),
                ),
              ),
              SizedBox(height: smallSpacing),

              // Botão Refill Flashes
              Obx(() => AppButton(
                text: 'home_energy_modal_refill_button'.tr,
                isPrimary: false,
                isLoading: energyController.isLoading.value,
                onPressed: energyController.isLoading.value || gemsController.gems.value < 100
                    ? null
                    : () async {
                        // CORREÇÃO: Ordem correta - gastar gems ANTES de recarregar
                        // 1. Verificar se tem gems suficientes
                        if (gemsController.gems.value < 100) {
                          Get.snackbar(
                            'home_energy_modal_insufficient_gems'.tr,
                            'home_energy_modal_insufficient_gems_message'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                            margin: const EdgeInsets.all(16),
                          );
                          return;
                        }
                        
                        // 2. Gastar gems primeiro
                        await gemsController.spendGems(100);
                        
                        // 3. Recarregar energia
                        await energyController.refillEnergy();
                        
                        // 4. Recarregar energia do controller para atualizar UI
                        await energyController.loadEnergy();
                        
                        // 5. Feedback visual
                        if (energyController.errorMessage.value.isNotEmpty) {
                          Get.snackbar(
                            'home_energy_modal_error_title'.tr,
                            energyController.errorMessage.value,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                            margin: const EdgeInsets.all(16),
                          );
                        } else {
                          Get.snackbar(
                            'home_energy_modal_success_title'.tr,
                            'home_energy_modal_success_message'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.primary,
                            colorText: AppTheme.white,
                            margin: const EdgeInsets.all(16),
                          );
                          
                          // Fechar modal após sucesso
                          Navigator.of(context).pop();
                        }
                      },
                prefixIcon: Image.asset(AppAssets.appbarRay, width: 24, height: 24),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppAssets.appbarGem, width: 20, height: 20),
                    const SizedBox(width: 4),
                    Text(
                      '100',
                      style: AppTheme.textLgBold.copyWith(
                        color: gemsController.gems.value < 100 
                            ? AppTheme.gray400 
                            : AppTheme.red,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      );
    });
  }

  // Widgets
  Widget _buildEnergyBolts(int currentEnergy, int maxEnergy) {
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
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onUnlimitedTap,
  }) async {
    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: EnergyModal(
            onUnlimitedTap: () {
              Navigator.of(context).pop();
              onUnlimitedTap?.call();
            },
          ),
        ),
      ],
    );
  }
}
