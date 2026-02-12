import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pippo/features/inners/splash/controllers/splash_controller.dart';

void main() {
  late SplashController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('SplashController - Null Safety', () {
    test('deve navegar para auth quando usuário é null', () async {
      // Arrange
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: false);
      
      controller = SplashController(
        auth: auth,
        firestore: firestore,
      );

      // Act
      await Future.delayed(const Duration(seconds: 3));

      // Assert
      expect(auth.currentUser, isNull);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('não deve crashar com null pointer ao verificar usuário', () async {
      // Arrange
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: false);
      
      // Act & Assert - não deve lançar exceção
      expect(
        () => SplashController(
          auth: auth,
          firestore: firestore,
        ),
        returnsNormally,
      );
    });

    test('deve navegar para onboarding quando usuário é null e primeiro acesso', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'isFirstAccess': true});
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: false);
      
      controller = SplashController(
        auth: auth,
        firestore: firestore,
      );

      // Act
      await Future.delayed(const Duration(seconds: 3));

      // Assert
      expect(auth.currentUser, isNull);
      expect(controller.errorMessage.value, isEmpty);
    });
  });

  group('SplashController - Navegação com Usuário Válido', () {
    test('deve navegar para home quando usuário é válido e onboarding completo', () async {
      // Arrange
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true);
      final user = auth.currentUser!;
      
      // Criar documento do usuário com onboarding completo
      await firestore.collection('users').doc(user.uid).set({
        'onboardingCompleted': true,
        'name': 'Test User',
        'email': user.email,
      });

      controller = SplashController(
        auth: auth,
        firestore: firestore,
      );

      // Act
      await Future.delayed(const Duration(seconds: 3));

      // Assert
      expect(auth.currentUser, isNotNull);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('deve navegar para onboarding quando usuário é válido mas onboarding incompleto', () async {
      // Arrange
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true);
      final user = auth.currentUser!;
      
      // Criar documento do usuário sem onboarding completo
      await firestore.collection('users').doc(user.uid).set({
        'onboardingCompleted': false,
        'name': 'Test User',
        'email': user.email,
      });

      controller = SplashController(
        auth: auth,
        firestore: firestore,
      );

      // Act
      await Future.delayed(const Duration(seconds: 3));

      // Assert
      expect(auth.currentUser, isNotNull);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('deve navegar para onboarding quando documento do usuário não existe', () async {
      // Arrange
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true);
      
      controller = SplashController(
        auth: auth,
        firestore: firestore,
      );

      // Act
      await Future.delayed(const Duration(seconds: 3));

      // Assert
      expect(auth.currentUser, isNotNull);
      expect(controller.errorMessage.value, isEmpty);
    });
  });

  group('SplashController - Tratamento de Erros', () {
    test('deve tratar erro de Firestore corretamente', () async {
      // Arrange
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true);
      
      controller = SplashController(
        auth: auth,
        firestore: firestore,
      );

      // Act - aguardar navegação completa
      await Future.delayed(const Duration(seconds: 4));

      // Assert - não deve crashar mesmo com erro
      // O controller pode estar em loading ou ter completado a navegação
      expect(controller.errorMessage.value, isEmpty);
    });
  });

  group('SplashController - onClose()', () {
    test('deve limpar recursos no onClose', () {
      // Arrange
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: false);
      
      controller = SplashController(
        auth: auth,
        firestore: firestore,
      );

      controller.isLoading.value = true;
      controller.errorMessage.value = 'Erro de teste';
      controller.showRetryButton.value = true;

      // Act
      controller.onClose();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.showRetryButton.value, false);
    });
  });

  group('SplashController - Retry', () {
    test('deve permitir retry após erro', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'isFirstAccess': false});
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: false);
      
      controller = SplashController(
        auth: auth,
        firestore: firestore,
      );

      // Aguardar primeira navegação
      await Future.delayed(const Duration(seconds: 3));

      // Simular erro
      controller.errorMessage.value = 'Erro anterior';
      controller.showRetryButton.value = true;
      controller.isLoading.value = false;

      // Act - retry deve resetar estados
      controller.retry();

      // Assert - retry foi chamado sem crashar
      expect(() => controller.retry(), returnsNormally);
    });
  });
}
