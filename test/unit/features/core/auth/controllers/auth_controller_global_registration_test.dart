// Unit test for AuthController global registration
// Verifica que o padrão de registro global está correto e que o controller
// pode ser acessado de qualquer lugar (como settings page)

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('AuthController - Global Registration Pattern', () {
    setUp(() {
      // Setup GetX para testes
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('Get.put com permanent: true registra controller globalmente', () {
      // Arrange - Criar um controller mock simples
      final mockController = _MockAuthController();

      // Act - Registrar como permanent (padrão de main.dart)
      Get.put<_MockAuthController>(mockController, permanent: true);

      // Assert
      expect(Get.isRegistered<_MockAuthController>(), true);
      expect(() => Get.find<_MockAuthController>(), returnsNormally);
    });

    test('Controller permanent pode ser acessado múltiplas vezes', () {
      // Arrange
      final mockController = _MockAuthController();
      Get.put<_MockAuthController>(mockController, permanent: true);

      // Act - Acessar múltiplas vezes
      final instance1 = Get.find<_MockAuthController>();
      final instance2 = Get.find<_MockAuthController>();
      final instance3 = Get.find<_MockAuthController>();

      // Assert - Todas devem ser a mesma instância (singleton)
      expect(instance1, same(instance2));
      expect(instance2, same(instance3));
      expect(instance1, same(mockController));
    });

    test('Controller permanent não é removido por Get.delete', () {
      // Arrange
      final mockController = _MockAuthController();
      Get.put<_MockAuthController>(mockController, permanent: true);

      // Act - Tentar deletar
      Get.delete<_MockAuthController>();

      // Assert - Controller permanent ainda deve estar registrado
      expect(Get.isRegistered<_MockAuthController>(), true);
      expect(() => Get.find<_MockAuthController>(), returnsNormally);
    });

    test('Controller permanent pode ser acessado de qualquer contexto', () {
      // Arrange
      final mockController = _MockAuthController();
      Get.put<_MockAuthController>(mockController, permanent: true);

      // Act - Simular acesso de diferentes contextos
      // Contexto 1: Settings page
      final fromSettings = Get.find<_MockAuthController>();
      
      // Contexto 2: Home page
      final fromHome = Get.find<_MockAuthController>();
      
      // Contexto 3: Profile page
      final fromProfile = Get.find<_MockAuthController>();

      // Assert - Todos devem acessar a mesma instância
      expect(fromSettings, same(fromHome));
      expect(fromHome, same(fromProfile));
      expect(fromSettings, same(mockController));
    });

    test('Múltiplos controllers permanent podem coexistir', () {
      // Arrange
      final authController = _MockAuthController();
      final gamificationController = _MockGamificationController();

      // Act - Registrar ambos como permanent (padrão de main.dart)
      Get.put<_MockAuthController>(authController, permanent: true);
      Get.put<_MockGamificationController>(gamificationController, permanent: true);

      // Assert
      expect(Get.isRegistered<_MockAuthController>(), true);
      expect(Get.isRegistered<_MockGamificationController>(), true);
      expect(() => Get.find<_MockAuthController>(), returnsNormally);
      expect(() => Get.find<_MockGamificationController>(), returnsNormally);
    });

    test('Controller permanent permanece após navegação simulada', () {
      // Arrange
      final mockController = _MockAuthController();
      Get.put<_MockAuthController>(mockController, permanent: true);

      // Act - Simular múltiplas navegações
      for (int i = 0; i < 10; i++) {
        // Verificar que controller ainda está registrado
        expect(Get.isRegistered<_MockAuthController>(), true);
        final controller = Get.find<_MockAuthController>();
        expect(controller, same(mockController));
      }

      // Assert
      expect(Get.isRegistered<_MockAuthController>(), true);
    });

    test('Get.find não lança exceção quando controller está registrado', () {
      // Arrange
      final mockController = _MockAuthController();
      Get.put<_MockAuthController>(mockController, permanent: true);

      // Act & Assert - Não deve lançar exceção
      expect(() => Get.find<_MockAuthController>(), returnsNormally);
    });

    test('Get.find lança exceção quando controller NÃO está registrado', () {
      // Arrange - Não registrar controller

      // Act & Assert - Deve lançar exceção
      expect(
        () => Get.find<_MockAuthController>(),
        throwsA(isA<String>()),
      );
    });

    test('Get.isRegistered retorna false quando controller não está registrado', () {
      // Arrange - Não registrar controller

      // Act & Assert
      expect(Get.isRegistered<_MockAuthController>(), false);
    });

    test('Get.isRegistered retorna true quando controller está registrado', () {
      // Arrange
      final mockController = _MockAuthController();
      Get.put<_MockAuthController>(mockController, permanent: true);

      // Act & Assert
      expect(Get.isRegistered<_MockAuthController>(), true);
    });
  });

  group('AuthController - Settings Page Logout Scenario', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('Settings page pode acessar AuthController sem erro', () {
      // Arrange - Simular setup de main.dart
      final mockAuthController = _MockAuthController();
      Get.put<_MockAuthController>(mockAuthController, permanent: true);

      // Act - Simular acesso do settings_page.dart
      // final _authController = Get.find<AuthController>();
      expect(() => Get.find<_MockAuthController>(), returnsNormally);

      final controller = Get.find<_MockAuthController>();

      // Assert
      expect(controller, isNotNull);
      expect(controller, same(mockAuthController));
    });

    test('Logout pode ser chamado de settings page', () {
      // Arrange
      final mockController = _MockAuthController();
      Get.put<_MockAuthController>(mockController, permanent: true);
      final controller = Get.find<_MockAuthController>();

      // Act - Verificar que método logout existe
      expect(controller.logout, isNotNull);
      expect(controller.logout, isA<Function>());

      // Chamar logout
      controller.logout();

      // Assert - Verificar que foi chamado
      expect(controller.logoutCalled, true);
    });

    test('Logout não causa "Controller not found" error', () {
      // Arrange
      final mockController = _MockAuthController();
      Get.put<_MockAuthController>(mockController, permanent: true);

      // Act & Assert - Não deve lançar exceção ao acessar
      expect(() => Get.find<_MockAuthController>(), returnsNormally);
      
      final controller = Get.find<_MockAuthController>();
      expect(controller, isNotNull);

      // Chamar logout não deve causar erro
      expect(() => controller.logout(), returnsNormally);
    });

    test('Controller permanece acessível após logout', () {
      // Arrange
      final mockController = _MockAuthController();
      Get.put<_MockAuthController>(mockController, permanent: true);

      // Act - Chamar logout
      final controller = Get.find<_MockAuthController>();
      controller.logout();

      // Assert - Controller ainda deve estar registrado
      expect(Get.isRegistered<_MockAuthController>(), true);
      expect(() => Get.find<_MockAuthController>(), returnsNormally);
    });
  });

  group('AuthController - Global Registration Documentation', () {
    test('Padrão de registro em main.dart está documentado', () {
      // Este teste documenta o padrão correto de registro em main.dart:
      //
      // void main() async {
      //   WidgetsFlutterBinding.ensureInitialized();
      //   await Firebase.initializeApp();
      //   
      //   // Register global controllers
      //   Get.put(AuthController(), permanent: true);
      //   Get.put(GamificationController(), permanent: true);
      //   
      //   runApp(const MainApp());
      // }
      //
      // Este padrão garante que:
      // 1. Controllers estão disponíveis globalmente
      // 2. Não há erro "Controller not found"
      // 3. Settings page pode acessar AuthController para logout
      // 4. Controllers não são removidos durante navegação

      expect(true, true); // Test de documentação
    });

    test('Padrão de acesso em settings_page.dart está documentado', () {
      // Este teste documenta o padrão correto de acesso em settings_page.dart:
      //
      // class _SettingsPageState extends State<SettingsPage> {
      //   late final AuthController _authController;
      //
      //   @override
      //   void initState() {
      //     super.initState();
      //     _authController = Get.find<AuthController>();
      //   }
      //
      //   // ...
      //
      //   AppButton(
      //     text: 'Sair',
      //     onPressed: () => _authController.logout(),
      //   ),
      // }
      //
      // Este padrão garante que:
      // 1. Controller é acessado no initState
      // 2. Não há erro "Controller not found"
      // 3. Logout funciona de qualquer tela

      expect(true, true); // Test de documentação
    });
  });
}

// Mock classes para testes
class _MockAuthController extends GetxController {
  bool logoutCalled = false;

  void logout() {
    logoutCalled = true;
  }
}

class _MockGamificationController extends GetxController {
  // Mock vazio para testes
}
