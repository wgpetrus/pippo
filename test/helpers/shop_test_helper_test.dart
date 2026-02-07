import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_test_helper.dart';
import 'shop_test_helper.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  const testUserId = 'test-user-123';

  setUp(() async {
    await FirebaseTestHelper.setupFirebase();
    firestore = FirebaseTestHelper.createMockFirestore();
  });

  group('ShopTestHelper', () {
    test('populateShopItems cria gems iniciais e itens da loja', () async {
      // Act
      final itemIds = await ShopTestHelper.populateShopItems(
        firestore,
        testUserId,
      );

      // Assert - Verificar gems iniciais
      final statsDoc = await firestore
          .collection('users')
          .doc(testUserId)
          .collection('stats')
          .doc('gamification')
          .get();

      expect(statsDoc.exists, isTrue);
      expect(statsDoc.data()?['totalGems'], 500);
      expect(statsDoc.data()?['totalGemsSpent'], 0);

      // Assert - Verificar itens criados
      expect(itemIds.length, 4);
      expect(itemIds.containsKey('energy_refill'), isTrue);
      expect(itemIds.containsKey('xp_booster'), isTrue);
      expect(itemIds.containsKey('gem_multiplier'), isTrue);
      expect(itemIds.containsKey('streak_freeze'), isTrue);

      // Assert - Verificar dados dos itens
      final shopItems = await firestore.collection('shopItems').get();
      expect(shopItems.docs.length, 4);

      final energyRefill = shopItems.docs.firstWhere(
        (doc) => doc.data()['id'] == 'energy_refill',
      );
      expect(energyRefill.data()['cost'], 50);
      expect(energyRefill.data()['name'], 'Energy Refill');
    });

    test('simulatePurchase deduz gems e cria documento de compra', () async {
      // Arrange
      await ShopTestHelper.populateShopItems(firestore, testUserId);

      // Act
      final purchaseId = await ShopTestHelper.simulatePurchase(
        firestore,
        testUserId,
        'energy_refill',
        50,
      );

      // Assert - Verificar gems deduzidas
      final statsDoc = await firestore
          .collection('users')
          .doc(testUserId)
          .collection('stats')
          .doc('gamification')
          .get();

      expect(statsDoc.data()?['totalGems'], 450); // 500 - 50
      expect(statsDoc.data()?['totalGemsSpent'], 50);

      // Assert - Verificar documento de compra
      final purchaseDoc = await firestore
          .collection('users')
          .doc(testUserId)
          .collection('purchases')
          .doc(purchaseId)
          .get();

      expect(purchaseDoc.exists, isTrue);
      expect(purchaseDoc.data()?['itemId'], 'energy_refill');
      expect(purchaseDoc.data()?['cost'], 50);
      expect(purchaseDoc.data()?['purchasedAt'], isNotNull);

      // Assert - Verificar boost ativado
      expect(statsDoc.data()?['boosters'], isNotNull);
      expect(statsDoc.data()?['boosters']['energy_refill']['active'], isTrue);
    });

    test('simulatePurchase com múltiplas compras', () async {
      // Arrange
      await ShopTestHelper.populateShopItems(firestore, testUserId);

      // Act - Primeira compra
      await ShopTestHelper.simulatePurchase(
        firestore,
        testUserId,
        'energy_refill',
        50,
      );

      // Act - Segunda compra
      await ShopTestHelper.simulatePurchase(
        firestore,
        testUserId,
        'streak_freeze',
        100,
      );

      // Assert
      final statsDoc = await firestore
          .collection('users')
          .doc(testUserId)
          .collection('stats')
          .doc('gamification')
          .get();

      expect(statsDoc.data()?['totalGems'], 350); // 500 - 50 - 100
      expect(statsDoc.data()?['totalGemsSpent'], 150);

      // Assert - Verificar ambas compras
      final purchases = await firestore
          .collection('users')
          .doc(testUserId)
          .collection('purchases')
          .get();

      expect(purchases.docs.length, 2);
    });
  });
}
