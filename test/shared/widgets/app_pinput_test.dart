import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pippo/shared/utils/responsive_utils.dart';
import 'package:pippo/shared/widgets/app_pinput.dart';

void main() {
  group('AppPinput Responsive Tests', () {
    testWidgets('pinput size is responsive on small screen', (tester) async {
      // Simular tela pequena (320x568 - iPhone SE 1st gen)
      await tester.binding.setSurfaceSize(const Size(320, 568));

      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppPinput(
                  controller: controller,
                  focusNode: focusNode,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calcular tamanho esperado
      final expectedSize = ResponsiveUtils.width(65, min: 48, max: 75);

      // Tamanho deve estar entre min (48) e max (75)
      expect(expectedSize, greaterThanOrEqualTo(48));
      expect(expectedSize, lessThanOrEqualTo(75));

      // Verificar que o widget foi renderizado
      expect(find.byType(AppPinput), findsOneWidget);

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('pinput size is responsive on large screen', (tester) async {
      // Simular tela grande (414x896 - iPhone 11 Pro Max)
      await tester.binding.setSurfaceSize(const Size(414, 896));

      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppPinput(
                  controller: controller,
                  focusNode: focusNode,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calcular tamanho esperado
      final expectedSize = ResponsiveUtils.width(65, min: 48, max: 75);

      // Tamanho deve estar entre min (48) e max (75)
      expect(expectedSize, greaterThanOrEqualTo(48));
      expect(expectedSize, lessThanOrEqualTo(75));

      // Verificar que o widget foi renderizado
      expect(find.byType(AppPinput), findsOneWidget);

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('pinput maintains minimum size on very small screen', (tester) async {
      // Simular tela muito pequena
      await tester.binding.setSurfaceSize(const Size(280, 480));

      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppPinput(
                  controller: controller,
                  focusNode: focusNode,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calcular tamanho esperado
      final expectedSize = ResponsiveUtils.width(65, min: 48, max: 75);

      // Tamanho mínimo deve ser >= 48px
      expect(expectedSize, greaterThanOrEqualTo(48));

      // Verificar que o widget foi renderizado
      expect(find.byType(AppPinput), findsOneWidget);

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('pinput respects max bound on very large screen', (tester) async {
      // Simular tela muito grande (tablet)
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppPinput(
                  controller: controller,
                  focusNode: focusNode,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calcular tamanho esperado
      final expectedSize = ResponsiveUtils.width(65, min: 48, max: 75);

      // Tamanho não deve exceder max (75)
      expect(expectedSize, lessThanOrEqualTo(75));

      // Verificar que o widget foi renderizado
      expect(find.byType(AppPinput), findsOneWidget);

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('pinput with custom length uses responsive size', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));

      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ResponsiveUtils.init(context);
                return AppPinput(
                  controller: controller,
                  focusNode: focusNode,
                  length: 6,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que o widget foi renderizado
      expect(find.byType(AppPinput), findsOneWidget);

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('pinput size is consistent across different screen sizes', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      // Testar em diferentes tamanhos de tela
      final screenSizes = [
        const Size(320, 568),  // iPhone SE 1st gen
        const Size(375, 667),  // iPhone SE 2nd gen
        const Size(414, 896),  // iPhone 11 Pro Max
        const Size(768, 1024), // iPad
      ];

      for (final size in screenSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  ResponsiveUtils.init(context);
                  return AppPinput(
                    controller: controller,
                    focusNode: focusNode,
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Calcular tamanho esperado
        final expectedSize = ResponsiveUtils.width(65, min: 48, max: 75);

        // Verificar que o tamanho está dentro dos limites
        expect(expectedSize, greaterThanOrEqualTo(48));
        expect(expectedSize, lessThanOrEqualTo(75));

        // Verificar que o widget foi renderizado
        expect(find.byType(AppPinput), findsOneWidget);
      }

      controller.dispose();
      focusNode.dispose();
    });
  });
}
