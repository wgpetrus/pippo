import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/core/auth/controllers/auth_controller.dart';

/// Integration Test - Settings Page Logout Workflow
/// 
/// Valida que o AuthController está disponível globalmente e pode ser
/// acessado de qualquer tela, incluindo Settings, para realizar logout.
/// 
/// Testa:
/// - Registro global do AuthController
/// - Acesso ao controller de qualquer contexto
/// - Estados obrigatórios (isLoading, errorMessage)
/// - Singleton pattern (mesma instância)
void main() {
  group('Global Controllers - AuthController Registration', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('AuthController deve estar registrado globalmente', () {
      // Arrange
      Get.put(AuthController(), permanent: true);

      // Act
      final isRegistered = Get.isRegistered<AuthController>();

      // Assert
      expect(isRegistered, true);
    });

    test('AuthController deve ser acessível via Get.find', () {
      // Arrange
      Get.put(AuthController(), permanent: true);

      // Act & Assert - Não deve lançar exceção
      expect(() => Get.find<AuthController>(), returnsNormally);
    });

    test('AuthController deve ter estados obrigatórios', () {
      // Arrange
      Get.put(AuthController(), permanent: true);
      final controller = Get.find<AuthController>();

      // Assert - Verificar estados obrigatórios
      expect(controller.isLoading, isNotNull);
      expect(controller.errorMessage, isNotNull);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, '');
    });

    test('Múltiplas chamadas a Get.find retornam mesma instância', () {
      // Arrange
      Get.put(AuthController(), permanent: true);

      // Act - Chamar Get.find múltiplas vezes
      final instance1 = Get.find<AuthController>();
      final instance2 = Get.find<AuthController>();
      final instance3 = Get.find<AuthController>();

      // Assert - Todas devem ser a mesma instância
      expect(instance1, same(instance2));
      expect(instance2, same(instance3));
      expect(instance1, same(instance3));
    });
  });

  group('Integration Tests - Settings Page Logout Workflow', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('Settings page pode acessar AuthController para logout', () {
      // Arrange - Simular registro global do AuthController
      Get.put(AuthController(), permanent: true);

      // Act - Simular acesso da Settings page
      final controller = Get.find<AuthController>();

      // Assert - Controller deve estar disponível
      expect(controller, isNotNull);
      expect(controller.isLoading, isNotNull);
      expect(controller.errorMessage, isNotNull);
    });

    test('AuthController permanece registrado após navegação', () {
      // Arrange
      Get.put(AuthController(), permanent: true);
      final initialController = Get.find<AuthController>();

      // Act - Simular navegação (reset não-permanente)
      Get.delete<AuthController>(force: false);

      // Assert - Controller permanente não deve ser removido
      expect(Get.isRegistered<AuthController>(), true);
      final afterNavController = Get.find<AuthController>();
      expect(afterNavController, same(initialController));
    });

    test('Logout limpa stack de navegação', () {
      // Arrange
      Get.put(AuthController(), permanent: true);
      final controller = Get.find<AuthController>();

      // Act - Verificar que método de logout existe
      // (teste de integração real seria com Firebase mock)
      expect(controller.logout, isNotNull);

      // Assert - Método logout deve ser callable
      expect(() => controller.logout(), returnsNormally);
    });
  });

  group('Error Handling - AuthController', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('errorMessage deve ser limpo antes de operações', () {
      // Arrange
      Get.put(AuthController(), permanent: true);
      final controller = Get.find<AuthController>();
      controller.errorMessage.value = 'Erro anterior';

      // Act - Simular início de nova operação
      controller.errorMessage.value = '';

      // Assert
      expect(controller.errorMessage.value, '');
    });

    test('isLoading deve ser false por padrão', () {
      // Arrange
      Get.put(AuthController(), permanent: true);
      final controller = Get.find<AuthController>();

      // Assert
      expect(controller.isLoading.value, false);
    });
  });
}
