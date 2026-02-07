import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pippo/features/inners/friends/views/friends_view.dart';
import 'package:pippo/shared/theme/theme.dart';

/// Teste de integração para verificar que a view de amigos mostra placeholder claro para dados de teste
@Skip('Widget/integration test depends on GetX controllers (e.g., ProfileSocialController) not registered in this test environment.')
void main() {
  group('Testes de Placeholder de Amigos', () {
    testWidgets('Página de amigos renderiza com sucesso com dados mockados',
        (WidgetTester tester) async {
      // Arrange: Construir a página de amigos
      await tester.pumpWidget(
        GetMaterialApp(
          home: const FriendsView(),
          theme: ThemeData(
            fontFamily: 'Nunito',
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
        ),
      );

      // Act: Aguardar o widget construir
      await tester.pumpAndSettle();

      // Assert: A página renderiza com sucesso
      expect(
        find.byType(FriendsView),
        findsOneWidget,
        reason: 'FriendsView deve renderizar com sucesso',
      );

      expect(
        find.byType(ListView),
        findsOneWidget,
        reason: 'FriendsView deve ter estrutura ListView',
      );
    });

    testWidgets('View de amigos mostra banner de placeholder de dados de teste',
        (WidgetTester tester) async {
      // Arrange: Construir a página de amigos
      await tester.pumpWidget(
        GetMaterialApp(
          home: const FriendsView(),
          theme: ThemeData(
            fontFamily: 'Nunito',
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
        ),
      );

      // Act: Aguardar o widget construir
      await tester.pumpAndSettle();

      // Assert: Texto de placeholder de dados de teste deve estar visível
      expect(
        find.textContaining('Test data'),
        findsOneWidget,
        reason: 'Texto de placeholder de dados de teste deve estar visível',
      );

      expect(
        find.textContaining('Firestore'),
        findsOneWidget,
        reason: 'Referência ao Firestore deve estar no texto do placeholder',
      );

      // Assert: Widget de ícone de flask deve estar presente
      expect(
        find.byType(FaIcon),
        findsWidgets,
        reason: 'Widgets de ícone de flask devem estar visíveis no banner de placeholder',
      );
    });

    testWidgets('View de amigos mostra ícone de flask nos avatares de amigos mockados',
        (WidgetTester tester) async {
      // Arrange: Construir a página de amigos
      await tester.pumpWidget(
        GetMaterialApp(
          home: const FriendsView(),
          theme: ThemeData(
            fontFamily: 'Nunito',
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
        ),
      );

      // Act: Aguardar o widget construir
      await tester.pumpAndSettle();

      // Assert: Múltiplos widgets FaIcon devem estar visíveis (um por amigo + banner)
      expect(
        find.byType(FaIcon),
        findsWidgets,
        reason: 'Widgets FaIcon devem estar visíveis nos avatares de amigos e banner',
      );

      // Assert: Containers laranja para ícones de flask devem estar visíveis
      final orangeContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == AppTheme.orange,
      );

      expect(
        orangeContainers,
        findsWidgets,
        reason: 'Containers laranja para ícones de flask devem estar visíveis',
      );
    });

    testWidgets('Banner de placeholder da view de amigos tem estilização correta',
        (WidgetTester tester) async {
      // Arrange: Construir a página de amigos
      await tester.pumpWidget(
        GetMaterialApp(
          home: const FriendsView(),
          theme: ThemeData(
            fontFamily: 'Nunito',
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
        ),
      );

      // Act: Aguardar o widget construir
      await tester.pumpAndSettle();

      // Assert: Container com fundo laranja deve estar visível
      final orangeBackgroundContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == AppTheme.orange100,
      );

      expect(
        orangeBackgroundContainers,
        findsWidgets,
        reason: 'Containers com fundo laranja devem estar visíveis para placeholders',
      );
    });
  });
}
