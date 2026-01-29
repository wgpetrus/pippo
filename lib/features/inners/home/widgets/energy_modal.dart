import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../gamification/controllers/gamification_controller.dart';

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
      return 'Sua energia de aprendizado está totalmente carregada ⚡\nPronto para começar?';
    } else if (_isEmpty(currentEnergy)) {
      return 'Sem energia restante. Faça uma pausa e\nvolte mais forte.';
    } else {
      return 'Apenas uma energia restante... use com sabedoria!';
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final gamification = Get.find<GamificationController>();
    
    // Padding responsivo para telas pequenas
    final verticalPadding = r.isTablet || r.isDesktop ? 24.0 : 16.0;
    final spacing = r.isTablet || r.isDesktop ? 24.0 : 16.0;
    final smallSpacing = r.isTablet || r.isDesktop ? 12.0 : 8.0;

    return Obx(() {
      final currentEnergy = gamification.currentEnergy.value;
      final maxEnergy = 5;
      final nextEnergyTime = gamification.getNextEnergyTime();
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
              const Text(
                'Sua Energia',
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
                      'Próxima energia em  ',
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
              Obx(() => AppButton(
                text: 'Recarregar',
                isPrimary: false,
                isLoading: gamification.isLoading.value,
                onPressed: gamification.isLoading.value || gamification.gems.value < 100
                    ? null
                    : () async {
                        await gamification.purchaseEnergyRefill();
                        
                        // Feedback visual
                        if (gamification.errorMessage.value.isNotEmpty) {
                          Get.snackbar(
                            'Erro',
                            gamification.errorMessage.value,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.red,
                            colorText: AppTheme.white,
                            margin: const EdgeInsets.all(16),
                          );
                        } else {
                          Get.snackbar(
                            'Sucesso',
                            'Energia recarregada!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.primary,
                            colorText: AppTheme.white,
                            margin: const EdgeInsets.all(16),
                          );
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
                        color: gamification.gems.value < 100 
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
