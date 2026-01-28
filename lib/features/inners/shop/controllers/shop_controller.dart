import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../widgets/purchase_confirmation_dialog.dart';

/// Controller da loja
class ShopController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Dependências
  late final GamificationController _gamification;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _gamification = Get.find<GamificationController>();
  }

  // Getters para acesso aos dados de gamificação
  int get gems => _gamification.gems.value;
  bool get isGamificationLoading => _gamification.isLoading.value;

  // Métodos públicos - Compras
  /// Compra recarga de energia (100 gems)
  Future<void> purchaseEnergyRefill() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _gamification.purchaseEnergyRefill();

      if (_gamification.errorMessage.value.isNotEmpty) {
        errorMessage.value = _gamification.errorMessage.value;
        _showErrorSnackbar(_gamification.errorMessage.value);
      } else {
        _showSuccessSnackbar(
          'Energia recarregada! Você agora tem ${_gamification.currentEnergy.value} energias.',
        );
      }
    } catch (e) {
      errorMessage.value = 'Erro ao comprar recarga de energia. Tente novamente.';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Compra XP booster (150 gems, 1 hora)
  Future<void> purchaseXpBooster() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _gamification.purchaseXpBooster();

      if (_gamification.errorMessage.value.isNotEmpty) {
        errorMessage.value = _gamification.errorMessage.value;
        _showErrorSnackbar(_gamification.errorMessage.value);
      } else {
        _showSuccessSnackbar('XP Booster ativado! Ganhe 2× XP por 1 hora.');
      }
    } catch (e) {
      errorMessage.value = 'Erro ao comprar XP booster. Tente novamente.';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Compra gem multiplier (200 gems, 1 hora)
  Future<void> purchaseGemMultiplier(BuildContext context) async {
    // Mostrar diálogo de confirmação
    PurchaseConfirmationDialog.show(
      context,
      itemName: 'Multiplicador de Gemas',
      cost: 200,
      description: 'Ganhe 2× gemas nas lições por 1 hora!',
      onConfirm: () async {
        isLoading.value = true;
        errorMessage.value = '';

        try {
          await _gamification.purchaseGemMultiplier();

          if (_gamification.errorMessage.value.isNotEmpty) {
            errorMessage.value = _gamification.errorMessage.value;
            _showErrorSnackbar(_gamification.errorMessage.value);
          } else {
            _showSuccessSnackbar(
              'Multiplicador de Gemas ativado! Ganhe 2× gemas por 1 hora.',
            );
          }
        } catch (e) {
          errorMessage.value = 'Erro ao comprar multiplicador de gemas. Tente novamente.';
          _showErrorSnackbar(errorMessage.value);
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  /// Compra streak freeze (200 gems)
  Future<void> purchaseStreakFreeze(BuildContext context) async {
    // Mostrar diálogo de confirmação
    PurchaseConfirmationDialog.show(
      context,
      itemName: 'Proteção de Streak',
      cost: 200,
      description: 'Proteja seu streak por 1 dia!',
      onConfirm: () async {
        isLoading.value = true;
        errorMessage.value = '';

        try {
          await _gamification.purchaseStreakFreeze();

          if (_gamification.errorMessage.value.isNotEmpty) {
            errorMessage.value = _gamification.errorMessage.value;
            _showErrorSnackbar(_gamification.errorMessage.value);
          } else {
            _showSuccessSnackbar(
              'Proteção de Streak ativada! Seu streak está protegido por 1 dia.',
            );
          }
        } catch (e) {
          errorMessage.value = 'Erro ao comprar proteção de streak. Tente novamente.';
          _showErrorSnackbar(errorMessage.value);
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  // Métodos privados - Feedback
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Sucesso!',
      message,
      backgroundColor: AppTheme.green,
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Erro',
      message,
      backgroundColor: AppTheme.red,
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
