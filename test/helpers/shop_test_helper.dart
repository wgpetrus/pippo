import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Helper para popular dados de teste relacionados à Shop
/// 
/// Uso:
/// ```dart
/// await ShopTestHelper.populateShopItems(firestore, userId);
/// await ShopTestHelper.simulatePurchase(firestore, userId, 'energy_refill', 50);
/// ```
class ShopTestHelper {
  /// Popula Firestore com itens da loja e gems iniciais do usuário
  /// 
  /// Cria:
  /// - Gems iniciais (500) em users/{userId}/stats/gamification
  /// - 4 boosts na coleção shopItems:
  ///   - Energy Refill (50 gems)
  ///   - XP Booster (150 gems)
  ///   - Gem Multiplier (200 gems)
  ///   - Streak Freeze (100 gems)
  /// 
  /// Retorna Map com IDs dos documentos criados
  static Future<Map<String, String>> populateShopItems(
    FakeFirebaseFirestore firestore,
    String userId,
  ) async {
    // Popular gems iniciais do usuário
    await firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification')
        .set({
      'totalGems': 500,
      'totalGemsSpent': 0,
    });

    // Popular itens da loja
    final items = {
      'energy_refill': {
        'id': 'energy_refill',
        'name': 'Energy Refill',
        'cost': 50,
        'type': 'boost',
        'description': 'Restaura energia para o máximo',
      },
      'xp_booster': {
        'id': 'xp_booster',
        'name': 'XP Booster',
        'cost': 150,
        'type': 'boost',
        'description': 'Dobra XP ganho por 1 hora',
      },
      'gem_multiplier': {
        'id': 'gem_multiplier',
        'name': 'Gem Multiplier',
        'cost': 200,
        'type': 'boost',
        'description': 'Dobra gems ganhas por 1 hora',
      },
      'streak_freeze': {
        'id': 'streak_freeze',
        'name': 'Streak Freeze',
        'cost': 100,
        'type': 'boost',
        'description': 'Protege streak por 1 dia',
      },
    };

    final itemIds = <String, String>{};

    for (final entry in items.entries) {
      final docRef = await firestore.collection('shopItems').add(entry.value);
      itemIds[entry.key] = docRef.id;
    }

    return itemIds;
  }

  /// Simula compra de um item da loja
  /// 
  /// Realiza:
  /// - Deduz gems do usuário (users/{userId}/stats/gamification)
  /// - Cria documento de compra em users/{userId}/purchases/{purchaseId}
  /// - Ativa boost se aplicável
  /// 
  /// Retorna ID da compra criada
  static Future<String> simulatePurchase(
    FakeFirebaseFirestore firestore,
    String userId,
    String itemId,
    int cost,
  ) async {
    final statsDoc = firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification');

    // Obter gems atuais
    final snapshot = await statsDoc.get();
    final currentGems = snapshot.data()?['totalGems'] ?? 0;
    final totalSpent = snapshot.data()?['totalGemsSpent'] ?? 0;

    // Deduzir gems
    await statsDoc.update({
      'totalGems': currentGems - cost,
      'totalGemsSpent': totalSpent + cost,
    });

    // Criar documento de compra
    final purchaseRef = await firestore
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .add({
      'itemId': itemId,
      'cost': cost,
      'purchasedAt': FieldValue.serverTimestamp(),
    });

    // Ativar boost se aplicável
    if (itemId == 'xp_booster' ||
        itemId == 'gem_multiplier' ||
        itemId == 'energy_refill') {
      await statsDoc.update({
        'boosters.$itemId': {
          'active': true,
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 1)),
          ),
        },
      });
    }

    return purchaseRef.id;
  }
}
