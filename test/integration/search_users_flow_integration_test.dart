import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/inners/profile/controllers/profile_controller.dart';
import 'package:pippo/features/inners/profile/views/profile_page.dart';
import 'package:pippo/features/inners/profile/views/search_users_page.dart';
import 'package:pippo/main.dart';

void main() {
  group('Search Users Flow Integration Tests', () {
    testWidgets('Fluxo completo de busca de usuários', (WidgetTester tester) async {
      // 1. Inicializar app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 2. Navegar para ProfilePage (já está na home)
      // Assumindo que ProfilePage é acessível via tab
      expect(find.byType(ProfilePage), findsWidgets);

      // 3. Procurar pelo FindFriendsCard
      // O card deve estar visível na ProfilePage
      expect(find.byKey(const Key('find_friends_card')), findsOneWidget);

      // 4. Tap no FindFriendsCard
      await tester.tap(find.byKey(const Key('find_friends_card')));
      await tester.pumpAndSettle();

      // 5. Verificar que SearchUsersPage abriu
      expect(find.byType(SearchUsersPage), findsOneWidget);

      // 6. Verificar que o campo de busca está visível
      expect(find.byType(TextField), findsOneWidget);

      // 7. Digitar query no campo de busca
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      // 8. Aguardar debounce (500ms)
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // 9. Verificar que o controller foi chamado
      final controller = Get.find<ProfileController>();
      expect(controller.searchQuery.value, 'test');

      // 10. Limpar busca
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // 11. Verificar que a busca foi limpa
      expect(controller.searchQuery.value, '');
      expect(controller.searchResults.length, 0);
    });

    testWidgets('Estado inicial da SearchUsersPage', (WidgetTester tester) async {
      // 1. Inicializar app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 2. Navegar para SearchUsersPage
      Get.to(() => const SearchUsersPage());
      await tester.pumpAndSettle();

      // 3. Verificar que está mostrando mensagem inicial
      expect(find.text('Busque por username ou nome'), findsOneWidget);

      // 4. Verificar que não há resultados
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Campo de busca com debounce', (WidgetTester tester) async {
      // 1. Inicializar app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 2. Navegar para SearchUsersPage
      Get.to(() => const SearchUsersPage());
      await tester.pumpAndSettle();

      // 3. Digitar no campo de busca
      await tester.enterText(find.byType(TextField), 'j');
      await tester.pump(const Duration(milliseconds: 100));

      // 4. Verificar que searchQuery ainda está vazio (debounce)
      final controller = Get.find<ProfileController>();
      expect(controller.searchQuery.value, '');

      // 5. Aguardar debounce
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // 6. Verificar que searchQuery foi atualizado
      expect(controller.searchQuery.value, 'j');
    });

    testWidgets('Botão clear limpa a busca', (WidgetTester tester) async {
      // 1. Inicializar app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 2. Navegar para SearchUsersPage
      Get.to(() => const SearchUsersPage());
      await tester.pumpAndSettle();

      // 3. Digitar no campo de busca
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // 4. Verificar que há um botão clear
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // 5. Tap no botão clear
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // 6. Verificar que o campo foi limpo
      expect(find.byType(TextField), findsOneWidget);
      final textField = find.byType(TextField);
      expect((tester.widget(textField) as TextField).controller?.text, '');
    });
  });
}
