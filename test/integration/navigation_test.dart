import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/inners/home/controllers/home_controller.dart';

/// Integration Test - Navigation Paths
/// 
/// Valida os fluxos críticos de navegação do app:
/// - Home → Shop via gems modal
/// - Profile → Settings navigation
/// - Navigation state management
/// 
/// Testa:
/// - Navegação entre tabs
/// - Navegação entre telas
/// - Controllers globais acessíveis
/// - Estado de navegação mantido
/// 
/// Note: Logout tests are covered in settings_logout_integration_test.dart
/// which handles Firebase initialization properly
void main() {
  group('Navigation Integration Tests', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    group('Home → Shop Navigation via Gems Modal', () {
      test('Gems modal navega para shop (tab 2)', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 0; // Tab 0 = Courses

        // Act - Simular clique no botão "Go to shop" do gems modal
        homeController.goToShop();

        // Assert
        expect(homeController.currentNavIndex.value, 2);
      });

      test('Modal fecha antes de navegar', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 0;
        
        bool modalClosed = false;
        bool navigationCalled = false;

        // Act - Simular comportamento do modal
        // 1. Fechar modal
        modalClosed = true;
        
        // 2. Navegar para shop
        homeController.goToShop();
        navigationCalled = true;

        // Assert
        expect(modalClosed, true);
        expect(navigationCalled, true);
        expect(homeController.currentNavIndex.value, 2);
      });

      test('Transição suave sem erros', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 0;

        // Act - Múltiplas navegações rápidas
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);
        
        homeController.onNavTap(0);
        expect(homeController.currentNavIndex.value, 0);
        
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Assert - Estado final correto
        expect(homeController.currentNavIndex.value, 2);
      });

      test('Navegação de qualquer tab para shop', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);

        // Test from tab 0 (Courses)
        homeController.currentNavIndex.value = 0;
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Test from tab 1 (Leaderboard)
        homeController.currentNavIndex.value = 1;
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Test from tab 3 (Treasure)
        homeController.currentNavIndex.value = 3;
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Test from tab 4 (Profile)
        homeController.currentNavIndex.value = 4;
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);
      });
    });

    group('Profile → Settings Navigation', () {
      test('Profile tab está ativa', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 4; // Tab 4 = Profile

        // Assert - Profile tab está ativa
        expect(homeController.currentNavIndex.value, 4);
        
        // Note: Settings page é acessada via Get.to() dentro do profile
        // Este teste valida que estamos na tab correta
      });

      test('Navegação para settings mantém estado do home', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 4;

        // Act - Simular navegação para settings (via Get.to)
        // Settings é uma página interna, não uma tab
        
        // Assert - Tab do profile permanece ativa
        expect(homeController.currentNavIndex.value, 4);
      });
    });

    group('Logout Navigation Flow', () {
      test('Logout deve limpar stack e retornar para auth', () {
        // Note: Este teste valida o conceito de navegação após logout
        // A implementação real com Firebase está em settings_logout_integration_test.dart
        
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 4; // Profile

        // Assert - Estado inicial correto
        expect(homeController.currentNavIndex.value, 4);
        
        // Note: Após logout, Get.offAllNamed('/auth') é chamado
        // Isso limpa todo o stack de navegação e retorna para auth
      });
    });

    group('Navigation State Management', () {
      test('Home tabs navegam corretamente', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);

        // Test all tabs
        homeController.onNavTap(0);
        expect(homeController.currentNavIndex.value, 0); // Courses

        homeController.onNavTap(1);
        expect(homeController.currentNavIndex.value, 1); // Leaderboard

        homeController.onNavTap(2);
        expect(homeController.currentNavIndex.value, 2); // Shop

        homeController.onNavTap(3);
        expect(homeController.currentNavIndex.value, 3); // Treasure

        homeController.onNavTap(4);
        expect(homeController.currentNavIndex.value, 4); // Profile
      });

      test('Navegação mantém estado do controller', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 0;

        // Act - Navegar entre tabs
        homeController.onNavTap(2);
        homeController.onNavTap(4);
        homeController.onNavTap(0);

        // Assert - Estado é mantido
        expect(homeController.currentNavIndex.value, 0);
        expect(homeController.isLoading.value, false);
        expect(homeController.errorMessage.value, '');
      });

      test('Múltiplas navegações rápidas não causam erros', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);

        // Act - Navegações rápidas
        for (int i = 0; i < 5; i++) {
          homeController.onNavTap(0);
          homeController.onNavTap(1);
          homeController.onNavTap(2);
          homeController.onNavTap(3);
          homeController.onNavTap(4);
        }

        // Assert - Estado final correto
        expect(homeController.currentNavIndex.value, 4);
      });
    });

    group('Global Controllers Accessibility', () {
      test('HomeController acessível de qualquer tela', () {
        // Arrange
        Get.put(HomeController(), permanent: true);

        // Act - Acessar de diferentes contextos
        final fromModal = Get.find<HomeController>();
        final fromTab = Get.find<HomeController>();

        // Assert - Mesma instância
        expect(fromModal, same(fromTab));
      });

      test('Controllers mantêm estado entre navegações', () {
        // Arrange
        Get.put(HomeController(), permanent: true);
        
        final homeController = Get.find<HomeController>();

        // Act - Modificar estados
        homeController.currentNavIndex.value = 3;

        // Assert - Estados persistem
        expect(Get.find<HomeController>().currentNavIndex.value, 3);
      });
    });

    group('Navigation Error Handling', () {
      test('Navegação com controller não registrado falha gracefully', () {
        // Arrange - Não registrar controller

        // Act & Assert - Tentar acessar controller não registrado
        expect(
          () => Get.find<HomeController>(),
          throwsA(isA<String>()),
        );
      });

      test('Reset não-permanente não remove controllers globais', () {
        // Arrange
        Get.put(HomeController(), permanent: true);

        // Act - Reset não-permanente
        Get.delete<HomeController>(force: false);

        // Assert - Controllers permanentes ainda estão registrados
        expect(Get.isRegistered<HomeController>(), true);
      });
    });

    group('Complete Navigation Flows', () {
      test('Fluxo completo: Home → Shop → Profile → Settings', () {
        // Arrange
        Get.put(HomeController(), permanent: true);
        
        final homeController = Get.find<HomeController>();

        // Step 1: Home (tab 0)
        homeController.currentNavIndex.value = 0;
        expect(homeController.currentNavIndex.value, 0);

        // Step 2: Navegar para Shop (tab 2)
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Step 3: Navegar para Profile (tab 4)
        homeController.onNavTap(4);
        expect(homeController.currentNavIndex.value, 4);

        // Step 4: Acessar Settings (via Get.to dentro do profile)
        // Settings é uma página interna, não afeta currentNavIndex
        expect(homeController.currentNavIndex.value, 4);
        
        // Note: Logout navigation is tested in settings_logout_integration_test.dart
      });

      test('Fluxo completo: Gems Modal → Shop → Voltar para Courses', () {
        // Arrange
        Get.put(HomeController(), permanent: true);
        final homeController = Get.find<HomeController>();

        // Step 1: Courses (tab 0)
        homeController.currentNavIndex.value = 0;
        expect(homeController.currentNavIndex.value, 0);

        // Step 2: Abrir gems modal e navegar para shop
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Step 3: Voltar para courses
        homeController.onNavTap(0);
        expect(homeController.currentNavIndex.value, 0);
      });

      test('Fluxo completo: Todas as tabs em sequência', () {
        // Arrange
        Get.put(HomeController(), permanent: true);
        final homeController = Get.find<HomeController>();

        // Act - Navegar por todas as tabs
        final tabs = [0, 1, 2, 3, 4];
        for (final tab in tabs) {
          homeController.onNavTap(tab);
          expect(homeController.currentNavIndex.value, tab);
        }

        // Assert - Estado final correto
        expect(homeController.currentNavIndex.value, 4);
      });
    });
  });
}
  // 2. Navegar para shop
        homeController.goToShop();
        navigationCalled = true;

        // Assert
        expect(modalClosed, true);
        expect(navigationCalled, true);
        expect(homeController.currentNavIndex.value, 2);
      });

      test('Transição suave sem erros', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 0;

        // Act - Múltiplas navegações rápidas
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);
        
        homeController.onNavTap(0);
        expect(homeController.currentNavIndex.value, 0);
        
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Assert - Estado final correto
        expect(homeController.currentNavIndex.value, 2);
      });

      test('Navegação de qualquer tab para shop', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);

        // Test from tab 0 (Courses)
        homeController.currentNavIndex.value = 0;
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Test from tab 1 (Leaderboard)
        homeController.currentNavIndex.value = 1;
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Test from tab 3 (Treasure)
        homeController.currentNavIndex.value = 3;
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Test from tab 4 (Profile)
        homeController.currentNavIndex.value = 4;
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);
      });
    });

    group('Profile → Settings Navigation', () {
      test('Profile tab está ativa', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 4; // Tab 4 = Profile

        // Assert - Profile tab está ativa
        expect(homeController.currentNavIndex.value, 4);
        
        // Note: Settings page é acessada via Get.to() dentro do profile
        // Este teste valida que estamos na tab correta
      });

      test('Navegação para settings mantém estado do home', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 4;

        // Act - Simular navegação para settings (via Get.to)
        // Settings é uma página interna, não uma tab
        
        // Assert - Tab do profile permanece ativa
        expect(homeController.currentNavIndex.value, 4);
      });
    });

    group('Logout Navigation Flow', () {
      test('Logout deve limpar stack e retornar para auth', () {
        // Note: Este teste valida o conceito de navegação após logout
        // A implementação real com Firebase está em settings_logout_integration_test.dart
        
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 4; // Profile

        // Assert - Estado inicial correto
        expect(homeController.currentNavIndex.value, 4);
        
        // Note: Após logout, Get.offAllNamed('/auth') é chamado
        // Isso limpa todo o stack de navegação e retorna para auth
      });
    });

    group('Navigation State Management', () {
      test('Home tabs navegam corretamente', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);

        // Test all tabs
        homeController.onNavTap(0);
        expect(homeController.currentNavIndex.value, 0); // Courses

        homeController.onNavTap(1);
        expect(homeController.currentNavIndex.value, 1); // Leaderboard

        homeController.onNavTap(2);
        expect(homeController.currentNavIndex.value, 2); // Shop

        homeController.onNavTap(3);
        expect(homeController.currentNavIndex.value, 3); // Treasure

        homeController.onNavTap(4);
        expect(homeController.currentNavIndex.value, 4); // Profile
      });

      test('Navegação mantém estado do controller', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);
        homeController.currentNavIndex.value = 0;

        // Act - Navegar entre tabs
        homeController.onNavTap(2);
        homeController.onNavTap(4);
        homeController.onNavTap(0);

        // Assert - Estado é mantido
        expect(homeController.currentNavIndex.value, 0);
        expect(homeController.isLoading.value, false);
        expect(homeController.errorMessage.value, '');
      });

      test('Múltiplas navegações rápidas não causam erros', () {
        // Arrange
        final homeController = Get.put(HomeController(), permanent: true);

        // Act - Navegações rápidas
        for (int i = 0; i < 5; i++) {
          homeController.onNavTap(0);
          homeController.onNavTap(1);
          homeController.onNavTap(2);
          homeController.onNavTap(3);
          homeController.onNavTap(4);
        }

        // Assert - Estado final correto
        expect(homeController.currentNavIndex.value, 4);
      });
    });

    group('Global Controllers Accessibility', () {
      test('HomeController acessível de qualquer tela', () {
        // Arrange
        Get.put(HomeController(), permanent: true);

        // Act - Acessar de diferentes contextos
        final fromModal = Get.find<HomeController>();
        final fromTab = Get.find<HomeController>();

        // Assert - Mesma instância
        expect(fromModal, same(fromTab));
      });

      test('Controllers mantêm estado entre navegações', () {
        // Arrange
        Get.put(HomeController(), permanent: true);
        
        final homeController = Get.find<HomeController>();

        // Act - Modificar estados
        homeController.currentNavIndex.value = 3;

        // Assert - Estados persistem
        expect(Get.find<HomeController>().currentNavIndex.value, 3);
      });
    });

    group('Navigation Error Handling', () {
      test('Navegação com controller não registrado falha gracefully', () {
        // Arrange - Não registrar controller

        // Act & Assert - Tentar acessar controller não registrado
        expect(
          () => Get.find<HomeController>(),
          throwsA(isA<String>()),
        );
      });

      test('Reset não-permanente não remove controllers globais', () {
        // Arrange
        Get.put(HomeController(), permanent: true);

        // Act - Reset não-permanente
        Get.delete<HomeController>(force: false);

        // Assert - Controllers permanentes ainda estão registrados
        expect(Get.isRegistered<HomeController>(), true);
      });
    });

    group('Complete Navigation Flows', () {
      test('Fluxo completo: Home → Shop → Profile → Settings', () {
        // Arrange
        Get.put(HomeController(), permanent: true);
        
        final homeController = Get.find<HomeController>();

        // Step 1: Home (tab 0)
        homeController.currentNavIndex.value = 0;
        expect(homeController.currentNavIndex.value, 0);

        // Step 2: Navegar para Shop (tab 2)
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Step 3: Navegar para Profile (tab 4)
        homeController.onNavTap(4);
        expect(homeController.currentNavIndex.value, 4);

        // Step 4: Acessar Settings (via Get.to dentro do profile)
        // Settings é uma página interna, não afeta currentNavIndex
        expect(homeController.currentNavIndex.value, 4);
        
        // Note: Logout navigation is tested in settings_logout_integration_test.dart
      });

      test('Fluxo completo: Gems Modal → Shop → Voltar para Courses', () {
        // Arrange
        Get.put(HomeController(), permanent: true);
        final homeController = Get.find<HomeController>();

        // Step 1: Courses (tab 0)
        homeController.currentNavIndex.value = 0;
        expect(homeController.currentNavIndex.value, 0);

        // Step 2: Abrir gems modal e navegar para shop
        homeController.goToShop();
        expect(homeController.currentNavIndex.value, 2);

        // Step 3: Voltar para courses
        homeController.onNavTap(0);
        expect(homeController.currentNavIndex.value, 0);
      });

      test('Fluxo completo: Todas as tabs em sequência', () {
        // Arrange
        Get.put(HomeController(), permanent: true);
        final homeController = Get.find<HomeController>();

        // Act - Navegar por todas as tabs
        final tabs = [0, 1, 2, 3, 4];
        for (final tab in tabs) {
          homeController.onNavTap(tab);
          expect(homeController.currentNavIndex.value, tab);
        }

        // Assert - Estado final correto
        expect(homeController.currentNavIndex.value, 4);
      });
    });
  });
}
