import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../widgets/iap_notice_dialog.dart';
import '../widgets/purchase_confirmation_dialog.dart';

/// Controller da loja
class ShopController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados reativos - Pacotes adquiridos
  final ownedPacks = <String, int>{}.obs; // {packId: quantity}
  
  // Estados reativos - Recompensas reivindicadas
  final claimedRewards = <String>[].obs; // Lista de IDs de recompensas já reivindicadas

  // Dependências
  late final GamificationController _gamification;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _gamification = Get.find<GamificationController>();
    loadOwnedPacks();
    loadClaimedRewards();
  }

  // Getters para acesso aos dados de gamificação
  int get gems => _gamification.gems.value;
  bool get isGamificationLoading => _gamification.isLoading.value;

  // Métodos públicos - Pacotes
  /// Carrega pacotes adquiridos do Firestore
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
      // Não propagar erro - pacotes são opcionais
      errorMessage.value = _handleFirestoreError(e);
    }
  }

  /// Carrega recompensas reivindicadas do Firestore
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
      // Não propagar erro - recompensas são opcionais
      errorMessage.value = _handleFirestoreError(e);
    }
  }

  // Métodos privados - Pacotes
  /// Salva pacotes adquiridos no Firestore
  Future<void> _saveOwnedPacks() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('shop')
          .doc('packs')
          .set(ownedPacks);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      rethrow;
    }
  }

  /// Adiciona pacote ao inventário
  Future<void> _addPack(String packId, int quantity) async {
    final current = ownedPacks[packId] ?? 0;
    ownedPacks[packId] = current + quantity;
    await _saveOwnedPacks();
  }

  /// Handler de erros do Firestore
  String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
      case 'unavailable':
        return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
      case 'deadline-exceeded':
        return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
      case 'resource-exhausted':
        return 'Muitas requisições. Aguarde alguns minutos e tente novamente.';
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'not-found':
        return 'Recurso não encontrado.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }

  /// Obtém quantidade de um pacote
  int getPackQuantity(String packId) {
    return ownedPacks[packId] ?? 0;
  }

  /// Verifica se recompensa já foi reivindicada (reativo)
  bool isRewardClaimedReactive(String rewardId) {
    return claimedRewards.contains(rewardId);
  }

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

  // Métodos públicos - Ofertas Especiais
  /// Reivindica recompensa gratuita
  Future<void> claimFreeReward(BuildContext context, String rewardId, int gemsAmount) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Verificar se já reivindicou
      if (claimedRewards.contains(rewardId)) {
        errorMessage.value = 'Você já reivindicou esta recompensa.';
        _showErrorSnackbar(errorMessage.value);
        return;
      }

      // Salvar valores originais para reversão
      final originalGems = _gamification.gems.value;
      final originalTotalGems = _gamification.totalGemsEarned.value;

      // Atualizar UI imediatamente (otimista)
      _gamification.gems.value += gemsAmount;
      _gamification.totalGemsEarned.value += gemsAmount;

      try {
        // Adicionar gems no Firestore
        await _gamification.firestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .update({
          'gems.gems': FieldValue.increment(gemsAmount),
          'gems.totalGemsEarned': FieldValue.increment(gemsAmount),
        });

        // Marcar como reivindicado
        claimedRewards.add(rewardId);
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('shop')
            .doc('claimed_rewards')
            .set({'rewards': claimedRewards});

        _showSuccessSnackbar('Você ganhou $gemsAmount gemas!');
      } catch (e) {
        // Reverter mudanças locais
        _gamification.gems.value = originalGems;
        _gamification.totalGemsEarned.value = originalTotalGems;
        claimedRewards.remove(rewardId);

        errorMessage.value = 'Erro ao reivindicar recompensa. Tente novamente.';
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Erro ao reivindicar recompensa. Tente novamente.';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos públicos - Compras com Dinheiro Real
  /// Mostra aviso de IAP e compra pacote de gems
  Future<void> purchaseGemPack(BuildContext context, String packId, int gemsAmount, String price) async {
    // Mostrar aviso de IAP
    IapNoticeDialog.show(
      context,
      onContinue: () {
        // TODO: [future] Implementar compra in-app real
        _showErrorSnackbar('Compras in-app serão implementadas em breve!');
      },
    );
  }

  /// Mostra aviso de IAP e compra colecionável
  Future<void> purchaseCollectible(BuildContext context, String itemId, String price) async {
    // Mostrar aviso de IAP
    IapNoticeDialog.show(
      context,
      onContinue: () {
        // TODO: [future] Implementar compra in-app real
        _showErrorSnackbar('Compras in-app serão implementadas em breve!');
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
