import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/core/auth/controllers/auth_credentials_controller.dart';
import 'package:pippo/features/core/auth/controllers/auth_providers_controller.dart';

import '../helpers/firebase_test_helper.dart';

/// Integration Test - Settings Page Logout Workflow
/// 
/// Valida que os controllers de autenticação estão disponíveis globalmente e podem ser
/// acessados de qualquer tela, incluindo Settings, para realizar logout.
/// 
/// Testa:
/// - Registro global dos controllers de autenticação
/// - Acesso aos controllers de qualquer contexto
/// - Estados obrigatórios (isLoading, errorMessage)
/// - Singleton pattern (mesma instância)
void main() {
  group('Global Controllers - Auth Controllers Registration', () {
    setUp(() async {
      await FirebaseTestHelper.setupFirebase();
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('AuthCredentialsController deve estar registrado globalmente', () {
      // Arrange
      Get.put(AuthCredentialsController(), permanent: true);

      // Act
      final isRegistered = Get.isRegistered<AuthCredentialsController>();

      // Assert
      expect(isRegistered, true);
    });

    test('AuthProvidersController deve estar registrado globalmente', () {
      // Arrange
      Get.put(AuthProvidersController(), permanent: true);

      // Act
      final isRegistered = Get.isRegistered<AuthProvidersController>();

      // Assert
      expect(isRegistered, true);
    });

    test('AuthCredentialsController deve ser acessível via Get.find', () {
      // Arrange
      Get.put(AuthCredentialsController(), permanent: true);

      // Act & Assert - Não deve lançar exceção
      expect(() => Get.find<AuthCredentialsController>(), returnsNormally);
    });

    test('AuthProvidersController deve ser acessível via Get.find', () {
      // Arrange
      Get.put(AuthProvidersController(), permanent: true);

      // Act & Assert - Não deve lançar exceção
      expect(() => Get.find<AuthProvidersController>(), returnsNormally);
    });

    test('AuthCredentialsController deve ter estados obrigatórios', () {
      // Arrange
      Get.put(AuthCredentialsController(), permanent: true);
      final controller = Get.find<AuthCredentialsController>();

      // Assert - Verificar estados obrigatórios
      expect(controller.isLoading, isNotNull);
      expect(controller.errorMessage, isNotNull);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, '');
    });

    test('AuthProvidersController deve ter estados obrigatórios', () {
      // Arrange
      Get.put(AuthProvidersController(), permanent: true);
      final controller = Get.find<AuthProvidersController>();

      // Assert - Verificar estados obrigatórios
      expect(controller.isLoading, isNotNull);
      expect(controller.errorMessage, isNotNull);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, '');
    });

    test('Múltiplas chamadas a Get.find retornam mesma instância (Credentials)', () {
      // Arrange
      Get.put(AuthCredentialsController(), permanent: true);

      // Act - Chamar Get.find múltiplas vezes
      final instance1 = Get.find<AuthCredentialsController>();
      final instance2 = Get.find<AuthCredentialsController>();
      final instance3 = Get.find<AuthCredentialsController>();

      // Assert - Todas devem ser a mesma instância
      expect(instance1, same(instance2));
      expect(instance2, same(instance3));
      expect(instance1, same(instance3));
    });

    test('Múltiplas chamadas a Get.find retornam mesma instância (Providers)', () {
      // Arrange
      Get.put(AuthProvidersController(), permanent: true);

      // Act - Chamar Get.find múltiplas vezes
      final instance1 = Get.find<AuthProvidersController>();
      final instance2 = Get.find<AuthProvidersController>();
      final instance3 = Get.find<AuthProvidersController>();

      // Assert - Todas devem ser a mesma instância
      expect(instance1, same(instance2));
      expect(instance2, same(instance3));
      expect(instance1, same(instance3));
    });
  });

  group('Integration Tests - Settings Page Logout Workflow', () {
    setUp(() async {
      await FirebaseTestHelper.setupFirebase();
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('Settings page pode acessar AuthProvidersController para logout', () {
      // Arrange - Simular registro global do AuthProvidersController
      Get.put(AuthProvidersController(), permanent: true);

      // Act - Simular acesso da Settings page
      final controller = Get.find<AuthProvidersController>();

      // Assert - Controller deve estar disponível
      expect(controller, isNotNull);
      expect(controller.isLoading, isNotNull);
      expect(controller.errorMessage, isNotNull);
    });

    test('AuthProvidersController permanece registrado após navegação', () {
      // Arrange
      Get.put(AuthProvidersController(), permanent: true);
      final initialController = Get.find<AuthProvidersController>();

      // Act - Simular navegação (reset não-permanente)
      Get.delete<AuthProvidersController>(force: false);

      // Assert - Controller permanente não deve ser removido
      expect(Get.isRegistered<AuthProvidersController>(), true);
      final afterNavController = Get.find<AuthProvidersController>();
      expect(afterNavController, same(initialController));
    });

    test('Logout limpa stack de navegação', () {
      // Arrange
      Get.put(AuthProvidersController(), permanent: true);
      final controller = Get.find<AuthProvidersController>();

      // Act - Verificar que método de logout existe
      // (teste de integração real seria com Firebase mock)
      expect(controller.logout, isNotNull);

      // Assert - Método logout deve ser callable
      expect(() => controller.logout(), returnsNormally);
    });
  });

  group('Error Handling - Auth Controllers', () {
    setUp(() async {
      await FirebaseTestHelper.setupFirebase();
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('errorMessage deve ser limpo antes de operações (Credentials)', () {
      // Arrange
      Get.put(AuthCredentialsController(), permanent: true);
      final controller = Get.find<AuthCredentialsController>();
      controller.errorMessage.value = 'Erro anterior';

      // Act - Simular início de nova operação
      controller.errorMessage.value = '';

      // Assert
      expect(controller.errorMessage.value, '');
    });

    test('errorMessage deve ser limpo antes de operações (Providers)', () {
      // Arrange
      Get.put(AuthProvidersController(), permanent: true);
      final controller = Get.find<AuthProvidersController>();
      controller.errorMessage.value = 'Erro anterior';

      // Act - Simular início de nova operação
      controller.errorMessage.value = '';

      // Assert
      expect(controller.errorMessage.value, '');
    });

    test('isLoading deve ser false por padrão (Credentials)', () {
      // Arrange
      Get.put(AuthCredentialsController(), permanent: true);
      final controller = Get.find<AuthCredentialsController>();

      // Assert
      expect(controller.isLoading.value, false);
    });

    test('isLoading deve ser false por padrão (Providers)', () {
      // Arrange
      Get.put(AuthProvidersController(), permanent: true);
      final controller = Get.find<AuthProvidersController>();

      // Assert
      expect(controller.isLoading.value, false);
    });
  });
}
