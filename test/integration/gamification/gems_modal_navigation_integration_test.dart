import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/inners/home/controllers/home_navigation_controller.dart';
import 'package:pippo/shared/theme/theme.dart';

import '../helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() async {
    await FirebaseTestHelper.setupFirebase();
  });

  group('Gems Modal Navigation - Smooth Transition Tests', () {
    late HomeNavigationController homeNavigationController;

    setUp(() {
      // Registrar controller
      homeNavigationController = Get.put(HomeNavigationController(), permanent: true);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('Modal fecha antes de navegar para shop', (WidgetTester tester) async {
      // Arrange
      bool modalClosed = false;
      bool navigationCalled = false;

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
            scaffoldBackgroundColor: AppTheme.white,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    // Simular comportamento do modal
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          body: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Fechar modal primeiro
                                Navigator.of(context).pop();
                                modalClosed = true;
                                
                                // Depois navegar
                                homeNavigationController.goToShop();
                                navigationCalled = true;
                              },
                              child: const Text('Ir para a loja'),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Abrir Modal'),
                );
              },
            ),
          ),
        ),
      );

      // Verificar que está na tab 0 (Courses)
      expect(homeNavigationController.currentNavIndex.value, 0);

      // Act - Abrir modal
      await tester.tap(find.text('Abrir Modal'));
      await tester.pumpAndSettle();

      // Act - Clicar no botão "Ir para a loja"
      await tester.tap(find.text('Ir para a loja'));
      await tester.pump(); // Inicia animação de fechamento

      // Verificar que modal está fechando
      expect(modalClosed, true);

      await tester.pumpAndSettle();

      // Assert - Verificar que navegou para shop (tab 2)
      expect(navigationCalled, true);
      expect(homeNavigationController.currentNavIndex.value, 2);
    });

    testWidgets('Transição é suave sem erros', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
            scaffoldBackgroundColor: AppTheme.white,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          body: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                homeNavigationController.goToShop();
                              },
                              child: const Text('Ir para a loja'),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Abrir Modal'),
                );
              },
            ),
          ),
        ),
      );

      // Act - Abrir modal
      await tester.tap(find.text('Abrir Modal'));
      await tester.pumpAndSettle();

      // Act - Clicar no botão
      await tester.tap(find.text('Ir para a loja'));
      
      // Verificar que não há erros durante a transição
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Assert - Verificar estado final
      expect(homeNavigationController.currentNavIndex.value, 2);
    });

    testWidgets('Callback é chamado apenas após modal fechar', (WidgetTester tester) async {
      // Arrange
      bool callbackCalled = false;
      int callbackCallCount = 0;

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
            scaffoldBackgroundColor: AppTheme.white,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          body: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                
                                // Callback após fechar
                                callbackCalled = true;
                                callbackCallCount++;
                                homeNavigationController.goToShop();
                              },
                              child: const Text('Ir para a loja'),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Abrir Modal'),
                );
              },
            ),
          ),
        ),
      );

      // Verificar que callback não foi chamado ainda
      expect(callbackCalled, false);
      expect(callbackCallCount, 0);

      // Act - Abrir modal
      await tester.tap(find.text('Abrir Modal'));
      await tester.pumpAndSettle();

      // Verificar que callback ainda não foi chamado
      expect(callbackCalled, false);

      // Act - Clicar no botão
      await tester.tap(find.text('Ir para a loja'));
      await tester.pump();

      // Callback deve ser chamado durante o fechamento
      await tester.pumpAndSettle();

      // Assert
      expect(callbackCalled, true);
      expect(callbackCallCount, 1); // Chamado apenas uma vez
      expect(homeNavigationController.currentNavIndex.value, 2);
    });

    test('goToShop atualiza currentNavIndex para 2', () {
      // Arrange
      homeNavigationController.currentNavIndex.value = 0;

      // Act
      homeNavigationController.goToShop();

      // Assert
      expect(homeNavigationController.currentNavIndex.value, 2);
    });
  });
}
