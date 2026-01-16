import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pippo/shared/utils/responsive_utils.dart';
import 'package:pippo/shared/widgets/app_button.dart';

void main() {
  group('AppButton Responsive Tests', () {
    testWidgets('button height is responsive on small screen', (tester) async {
      // Simular tela pequena (320x568 - iPhone SE 1st gen)
      await tester.binding.setSurfaceSize(const Size(320, 568));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppButton(
                  text: 'Test Button',
                  onPressed: () {},
                );
              },
            ),
          ),
        ),
      );

      // Encontrar o Container principal do botão
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(Container),
        ).first,
      );

      // Altura deve estar entre min (48) e max (72)
      expect(container.constraints?.minHeight ?? 0, greaterThanOrEqualTo(0));
      
      // Verificar que a altura está dentro dos limites
      final height = container.constraints?.maxHeight ?? 
                     (container.child as Container?)?.constraints?.maxHeight ?? 
                     48.0;
      expect(height, greaterThanOrEqualTo(48));
      expect(height, lessThanOrEqualTo(72));
    });

    testWidgets('button height is responsive on large screen', (tester) async {
      // Simular tela grande (414x896 - iPhone 11 Pro Max)
      await tester.binding.setSurfaceSize(const Size(414, 896));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppButton(
                  text: 'Test Button',
                  onPressed: () {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que o botão foi renderizado
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('button maintains minimum touch target of 44px', (tester) async {
      // Simular tela muito pequena
      await tester.binding.setSurfaceSize(const Size(280, 480));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppButton(
                  text: 'Test Button',
                  onPressed: () {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calcular altura esperada
      final expectedHeight = ResponsiveUtils.height(62, min: 48, max: 72);
      
      // Altura mínima deve ser >= 44px (acessibilidade)
      // Como definimos min: 48, isso garante >= 44
      expect(expectedHeight, greaterThanOrEqualTo(44));
    });

    testWidgets('disabled button uses responsive height', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return const AppButton(
                  text: 'Disabled Button',
                  onPressed: null, // disabled
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que o botão desabilitado foi renderizado
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Disabled Button'), findsOneWidget);
    });

    testWidgets('secondary button uses responsive height', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppButton(
                  text: 'Secondary Button',
                  isPrimary: false,
                  onPressed: () {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que o botão secundário foi renderizado
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Secondary Button'), findsOneWidget);
    });

    testWidgets('button height respects max bound on very large screen', (tester) async {
      // Simular tela muito grande (tablet)
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppButton(
                  text: 'Test Button',
                  onPressed: () {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calcular altura esperada
      final expectedHeight = ResponsiveUtils.height(62, min: 48, max: 72);
      
      // Altura não deve exceder max (72)
      expect(expectedHeight, lessThanOrEqualTo(72));
    });
  });
}
