import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';
import '../../../../shared/theme/theme.dart';
import '../../gamification/controllers/energy_controller.dart';
import '../../gamification/controllers/gems_controller.dart';
import '../../gamification/controllers/streak_controller.dart';
import '../../gamification/controllers/xp_level_controller.dart';
import '../widgets/iap_notice_dialog.dart';
import '../widgets/purchase_confirmation_dialog.dart';

/// Controller da loja
class ShopController extends GetxController {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final ownedPacks = <String, int>{}.obs; // {packId: quantity}
  
  final claimedRewards = <String>[].obs; // Lista de IDs de recompensas já reivindicadas

  late final EnergyController _energyController;
  late final XpLevelController _xpLevelController;
  late final GemsController _gemsController;
  late final StreakController _streakController;

  /// Constructor com DI opcional (backward compatible)
  ShopController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _energyController = Get.find<EnergyController>();
    _xpLevelController = Get.find<XpLevelController>();
    _gemsController = Get.find<GemsController>();
    _streakController = Get.find<StreakController>();
    loadOwnedPacks();
    loadClaimedRewards();
  }

  @override
  void onClose() {
    // Limpar listas
    ownedPacks.clear();
    claimedRewards.clear();

    // Resetar estados
    isLoading.value = false;
    errorMessage.value = '';

    super.onClose();
  }

  int get gems => _gemsController.gems.value;
  bool get isGamificationLoading => _gemsController.isLoading.value;

  Future<void> loadOwnedPacks() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shop')
          .doc('packs')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        ownedPacks.value = Map<String, int>.from(data);
      }
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    }
  }

  Future<void> loadClaimedRewards() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shop')
          .doc('claimed_rewards')
          .get();

      if (doc.exists) {
        claimedRewards.value = List<String>.from(doc.data()?['rewards'] ?? []);
      }
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    }
  }

  int getPackQuantity(String packId) {
    return ownedPacks[packId] ?? 0;
  }

  bool isRewardClaimedReactive(String rewardId) {
    return claimedRewards.contains(rewardId);
  }

  Future<void> purchaseEnergyRefill() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (_gemsController.gems.value < 100) {
        errorMessage.value = 'error_insufficient_gems'.tr;
        _showErrorSnackbar(errorMessage.value);
        return;
      }

      await _gemsController.spendGems(100);

      await _energyController.refillEnergy();
      
      // CORREÇÃO: Recarregar energia para atualizar UI
      await _energyController.loadEnergy();

      if (_energyController.errorMessage.value.isNotEmpty) {
        errorMessage.value = _energyController.errorMessage.value;
        _showErrorSnackbar(_energyController.errorMessage.value);
      } else {
        _showSuccessSnackbar(
          'Energia recarregada! Você agora tem ${_energyController.currentEnergy.value} energias.',
        );
      }
    } catch (e) {
      errorMessage.value = 'error_purchase_energy'.tr;
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchaseXpBooster() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (_gemsController.gems.value < 150) {
        errorMessage.value = 'error_insufficient_gems'.tr;
        _showErrorSnackbar(errorMessage.value);
        return;
      }

      await _gemsController.spendGems(150);

      await _xpLevelController.activateXpBooster(60);

      if (_xpLevelController.errorMessage.value.isNotEmpty) {
        errorMessage.value = _xpLevelController.errorMessage.value;
        _showErrorSnackbar(_xpLevelController.errorMessage.value);
      } else {
        _showSuccessSnackbar('XP Booster ativado! Ganhe 2× XP por 1 hora.');
      }
    } catch (e) {
      errorMessage.value = 'error_purchase_xp_booster'.tr;
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchaseGemMultiplier(BuildContext context) async {
    PurchaseConfirmationDialog.show(
      context,
      itemName: 'Multiplicador de Gemas',
      cost: 200,
      description: 'Ganhe 2× gemas nas lições por 1 hora!',
      onConfirm: () async {
        isLoading.value = true;
        errorMessage.value = '';

        try {
          if (_gemsController.gems.value < 200) {
            errorMessage.value = 'error_insufficient_gems'.tr;
            _showErrorSnackbar(errorMessage.value);
            return;
          }

          await _gemsController.spendGems(200);

          await _gemsController.activateGemMultiplier(60);

          if (_gemsController.errorMessage.value.isNotEmpty) {
            errorMessage.value = _gemsController.errorMessage.value;
            _showErrorSnackbar(_gemsController.errorMessage.value);
          } else {
            _showSuccessSnackbar(
              'Multiplicador de Gemas ativado! Ganhe 2× gemas por 1 hora.',
            );
          }
        } catch (e) {
          errorMessage.value = 'error_purchase_gem_multiplier'.tr;
          _showErrorSnackbar(errorMessage.value);
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> purchaseStreakFreeze(BuildContext context) async {
    PurchaseConfirmationDialog.show(
      context,
      itemName: 'Proteção de Streak',
      cost: 200,
      description: 'Proteja seu streak por 1 dia!',
      onConfirm: () async {
        isLoading.value = true;
        errorMessage.value = '';

        try {
          if (_gemsController.gems.value < 200) {
            errorMessage.value = 'error_insufficient_gems'.tr;
            _showErrorSnackbar(errorMessage.value);
            return;
          }

          await _gemsController.spendGems(200);

          await _streakController.useStreakFreeze();

          if (_streakController.errorMessage.value.isNotEmpty) {
            errorMessage.value = _streakController.errorMessage.value;
            _showErrorSnackbar(_streakController.errorMessage.value);
          } else {
            _showSuccessSnackbar(
              'Proteção de Streak ativada! Seu streak está protegido por 1 dia.',
            );
          }
        } catch (e) {
          errorMessage.value = 'error_purchase_streak_protection'.tr;
          _showErrorSnackbar(errorMessage.value);
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> claimFreeReward(BuildContext context, String rewardId, int gemsAmount) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'error_user_not_authenticated'.tr;
        return;
      }

      if (claimedRewards.contains(rewardId)) {
        errorMessage.value = 'error_reward_already_claimed'.tr;
        _showErrorSnackbar(errorMessage.value);
        return;
      }

      // Buscar curso ativo
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (coursesSnapshot.docs.isEmpty) {
        errorMessage.value = 'error_no_active_course'.tr;
        _showErrorSnackbar(errorMessage.value);
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;

      final originalGems = _gemsController.gems.value;
      final originalTotalGems = _gemsController.totalGemsEarned.value;

      _gemsController.gems.value += gemsAmount;
      _gemsController.totalGemsEarned.value += gemsAmount;

      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(courseId)
            .collection('stats')
            .doc('gamification')
            .update({
          'gems.gems': FieldValue.increment(gemsAmount),
          'gems.totalGemsEarned': FieldValue.increment(gemsAmount),
        });

        claimedRewards.add(rewardId);
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('shop')
            .doc('claimed_rewards')
            .set({'rewards': claimedRewards});

        _showSuccessSnackbar('Você ganhou $gemsAmount gemas!');
      } catch (e) {
        _gemsController.gems.value = originalGems;
        _gemsController.totalGemsEarned.value = originalTotalGems;
        claimedRewards.remove(rewardId);

        errorMessage.value = 'error_claim_free_reward'.tr;
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'error_claim_free_reward'.tr;
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchaseGemPack(BuildContext context, String packId, int gemsAmount, String price) async {
    IapNoticeDialog.show(
      context,
      onContinue: () {
        // TODO: [future] Implementar compra in-app real
        _showErrorSnackbar('Compras in-app serão implementadas em breve!');
      },
    );
  }

  Future<void> purchaseCollectible(BuildContext context, String itemId, String price) async {
    IapNoticeDialog.show(
      context,
      onContinue: () {
        // TODO: [future] Implementar compra in-app real
        _showErrorSnackbar('Compras in-app serão implementadas em breve!');
      },
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'common_success'.tr,
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
      'common_error'.tr,
      message,
      backgroundColor: AppTheme.red,
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
