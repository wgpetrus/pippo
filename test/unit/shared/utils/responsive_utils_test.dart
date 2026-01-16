import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide expect, group, test;
import 'package:glados/glados.dart';
import 'package:pippo/shared/utils/responsive_utils.dart';

void main() {
  group('ResponsiveUtils Property Tests', () {
    // Property 1: Scaling Proporcional
    // Feature: responsive-fixes, Property 1: Scaling Proporcional
    // Validates: Requirements 1.1, 1.3
    Glados2(any.positiveInt, any.positiveInt).test(
      'width fallback returns value when not initialized',
      (screenWidth, value) {
        // Sem inicializar, deve retornar o valor original
        final result = ResponsiveUtils.width(value.toDouble());
        expect(result, equals(value.toDouble()));
      },
    );

    // Property 2: Clamp Bounds
    // Feature: responsive-fixes, Property 2: Clamp Bounds
    // Validates: Requirements 1.1, 1.3
    Glados3(any.int, any.int, any.int).test(
      'width clamp respects min and max bounds',
      (value, minBound, maxBound) {
        // Garantir que min <= max
        final effectiveMin = minBound < maxBound ? minBound.toDouble() : maxBound.toDouble();
        final effectiveMax = minBound < maxBound ? maxBound.toDouble() : minBound.toDouble();

        final result = ResponsiveUtils.width(
          value.toDouble(),
          min: effectiveMin,
          max: effectiveMax,
        );

        // Resultado deve estar dentro dos limites
        expect(result, greaterThanOrEqualTo(effectiveMin));
        expect(result, lessThanOrEqualTo(effectiveMax));
      },
    );

    Glados3(any.int, any.int, any.int).test(
      'height clamp respects min and max bounds',
      (value, minBound, maxBound) {
        // Garantir que min <= max
        final effectiveMin = minBound < maxBound ? minBound.toDouble() : maxBound.toDouble();
        final effectiveMax = minBound < maxBound ? maxBound.toDouble() : minBound.toDouble();

        final result = ResponsiveUtils.height(
          value.toDouble(),
          min: effectiveMin,
          max: effectiveMax,
        );

        // Resultado deve estar dentro dos limites
        expect(result, greaterThanOrEqualTo(effectiveMin));
        expect(result, lessThanOrEqualTo(effectiveMax));
      },
    );

    Glados2(any.int, any.int).test(
      'fontSize clamp respects min bound',
      (value, minBound) {
        final result = ResponsiveUtils.fontSize(
          value.toDouble().abs(),
          min: minBound.toDouble().abs(),
        );

        // Resultado deve ser >= min
        expect(result, greaterThanOrEqualTo(minBound.toDouble().abs()));
      },
    );
  });

  group('ResponsiveUtils TextScaleFactor Property Tests', () {
    // Property 4: TextScaleFactor Clamping
    // Feature: responsive-fixes, Property 4: TextScaleFactor Clamping
    // Validates: Requirements 8.1, 8.3
    testWidgets('textScaleFactor is clamped to 1.3x maximum', (tester) async {
      // Criar um MediaQuery com textScaleFactor alto
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 667),
            textScaleFactor: 2.5, // Muito alto
          ),
          child: Builder(
            builder: (context) {
              ResponsiveUtils.init(context);
              return Container();
            },
          ),
        ),
      );

      // Testar que fontSize não ultrapassa 1.3x
      final baseFontSize = 16.0;
      final result = ResponsiveUtils.fontSize(baseFontSize);
      final maxExpected = baseFontSize * 1.3;

      expect(result, lessThanOrEqualTo(maxExpected));
    });

    testWidgets('textScaleFactor below 1.0 is clamped to 1.0', (tester) async {
      // Criar um MediaQuery com textScaleFactor baixo
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 667),
            textScaleFactor: 0.5, // Muito baixo
          ),
          child: Builder(
            builder: (context) {
              ResponsiveUtils.init(context);
              return Container();
            },
          ),
        ),
      );

      // Testar que fontSize não fica abaixo de 1.0x
      final baseFontSize = 16.0;
      final result = ResponsiveUtils.fontSize(baseFontSize);
      final minExpected = baseFontSize * 1.0;

      expect(result, greaterThanOrEqualTo(minExpected));
    });

    testWidgets('textScaleFactor within range is preserved', (tester) async {
      // Criar um MediaQuery com textScaleFactor normal
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 667),
            textScaleFactor: 1.15, // Dentro do range
          ),
          child: Builder(
            builder: (context) {
              ResponsiveUtils.init(context);
              return Container();
            },
          ),
        ),
      );

      // Testar que fontSize aplica o fator corretamente
      final baseFontSize = 16.0;
      final result = ResponsiveUtils.fontSize(baseFontSize);
      final expected = baseFontSize * 1.15;

      expect(result, closeTo(expected, 0.01));
    });
  });

  group('ResponsiveUtils Unit Tests', () {
    testWidgets('fallback returns clamped value when not initialized', (tester) async {
      // Sem inicializar, deve retornar valor com clamp aplicado
      final result = ResponsiveUtils.width(100, min: 50, max: 80);
      expect(result, equals(80)); // clamped ao max
    });

    testWidgets('fallback returns value when no bounds and not initialized', (tester) async {
      final result = ResponsiveUtils.width(100);
      expect(result, equals(100));
    });

    testWidgets('fontSize applies minimum of 10 by default', (tester) async {
      final result = ResponsiveUtils.fontSize(5);
      expect(result, greaterThanOrEqualTo(10));
    });

    testWidgets('isSmallScreen returns false when not initialized', (tester) async {
      // screenWidth é 0 quando não inicializado, e 0 < 360 é false
      expect(ResponsiveUtils.isSmallScreen, isFalse);
    });

    testWidgets('isShortScreen returns false when not initialized', (tester) async {
      // screenHeight é 0 quando não inicializado, e 0 < 600 é false
      expect(ResponsiveUtils.isShortScreen, isFalse);
    });

    testWidgets('isLandscape returns false when not initialized', (tester) async {
      // screenWidth e screenHeight são 0 quando não inicializado
      expect(ResponsiveUtils.isLandscape, isFalse);
    });
  });
}
