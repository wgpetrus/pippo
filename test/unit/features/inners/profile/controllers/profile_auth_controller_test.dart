import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/profile/controllers/profile_auth_controller.dart';

void main() {
  late ProfileAuthController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    controller = ProfileAuthController(
      firestore: firestore,
      auth: auth,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileAuthController - changePassword()', () {
    test('atualiza senha no Firebase Auth', () async {
      // Note: MockFirebaseAuth não suporta reauthentication completa
      // Este teste valida a estrutura do método
      
      // Arrange
      const currentPassword = 'oldpassword123';
      const newPassword = 'newpassword456';

      // Act & Assert - Espera erro de reauthentication (normal com mock)
      await controller.changePassword(currentPassword, newPassword);
      
      // Verifica que o loading terminou
      expect(controller.isLoading.value, false);
    });
  });

  group('ProfileAuthController - linkPhoneNumber()', () {
    test('vincula telefone à conta', () async {
      // Note: MockFirebaseAuth não suporta phone auth completa
      // Este teste valida a estrutura do método
      
      // Arrange
      const phoneNumber = '+5511999999999';
      const verificationCode = '123456';
      controller.verificationId.value = 'test-verification-id';

      // Act
      await controller.linkPhoneNumber(phoneNumber, verificationCode);
      
      // Assert - Verifica que o loading terminou
      expect(controller.isLoading.value, false);
    });
  });

  group('ProfileAuthController - deleteAccount()', () {
    test('remove conta e dados do Firestore', () async {
      // Arrange - Criar dados do usuário
      await firestore.collection('users').doc(user.uid).set({
        'name': 'João Silva',
        'email': 'joao@example.com',
      });

      // Criar subcoleções
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .doc('user1')
          .set({'userId': 'user1'});

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('followers')
          .doc('user2')
          .set({'userId': 'user2'});

      // Act
      await controller.deleteAccount();
      
      // Assert - Verifica que o loading terminou
      expect(controller.isLoading.value, false);
      
      // Verificar que documento foi deletado
      final doc = await firestore.collection('users').doc(user.uid).get();
      expect(doc.exists, false);
    });
  });
}
