# Design Document

## Overview

Este documento descreve a arquitetura e implementação das correções de responsividade para o app Pippo. A solução centraliza cálculos responsivos em um utilitário (`ResponsiveUtils`) e aplica mudanças incrementais nos widgets existentes.

### Princípios de Design

1. **Centralização**: Todos os cálculos responsivos em um único lugar
2. **Proporcionalidade**: Tamanhos baseados em proporção da tela, não valores fixos
3. **Limites seguros**: Valores mínimos e máximos para garantir usabilidade
4. **Retrocompatibilidade**: Mudanças não quebram funcionalidades existentes

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        App                                   │
├─────────────────────────────────────────────────────────────┤
│  shared/utils/responsive_utils.dart                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ResponsiveUtils                                     │   │
│  │  - init(context)                                     │   │
│  │  - width(value, {min, max})                          │   │
│  │  - height(value, {min, max})                         │   │
│  │  - fontSize(value, {min})                            │   │
│  │  - isSmallScreen                                     │   │
│  │  - isLandscape                                       │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│  Widgets que usam ResponsiveUtils:                          │
│  - AppButton (height responsivo)                            │
│  - AppPinput (width/height responsivo)                      │
│  - HomeAppbar (Flexible nos stats)                          │
│  - EnergyModal (bolts responsivos)                          │
│  - ProfileCard (overflow handling)                          │
│  - CompletePage (mascot/cards responsivos)                  │
│  - Headers (expandedHeight responsivo)                      │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### ResponsiveUtils

Utilitário singleton para cálculos responsivos.

```dart
/// Utilitário de responsividade
class ResponsiveUtils {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _textScaleFactor;
  
  // Base design: iPhone SE (375 x 667)
  static const double _baseWidth = 375.0;
  static const double _baseHeight = 667.0;
  static const double _maxTextScale = 1.3;
  
  /// Inicializa com o contexto (chamar no main ou wrapper)
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _textScaleFactor = mediaQuery.textScaleFactor.clamp(1.0, _maxTextScale);
  }
  
  /// Largura responsiva
  static double width(double value, {double? min, double? max}) {
    final scaled = value * (_screenWidth / _baseWidth);
    return scaled.clamp(min ?? 0, max ?? double.infinity);
  }
  
  /// Altura responsiva
  static double height(double value, {double? min, double? max}) {
    final scaled = value * (_screenHeight / _baseHeight);
    return scaled.clamp(min ?? 0, max ?? double.infinity);
  }
  
  /// Font size responsivo (com limite de acessibilidade)
  static double fontSize(double value, {double? min}) {
    final scaled = value * _textScaleFactor;
    return scaled.clamp(min ?? 10, double.infinity);
  }
  
  /// Tela pequena (< 360px largura)
  static bool get isSmallScreen => _screenWidth < 360;
  
  /// Tela muito pequena (< 600px altura)
  static bool get isShortScreen => _screenHeight < 600;
  
  /// Modo landscape
  static bool get isLandscape => _screenWidth > _screenHeight;
  
  /// Getters para dimensões
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
}
```

### Mudanças nos Widgets

#### AppButton

```dart
// ANTES
height: 62,

// DEPOIS
height: ResponsiveUtils.height(62, min: 48, max: 72),
```

#### AppPinput

```dart
// ANTES
width: 65,
height: 65,

// DEPOIS
final size = ResponsiveUtils.width(65, min: 48, max: 75);
width: size,
height: size,
```

#### HomeAppbar Stats

```dart
// ANTES
Row(
  children: [
    _buildStatChip(...),
    _buildStatChip(...),
  ],
)

// DEPOIS
Row(
  children: [
    Flexible(child: _buildStatChip(...)),
    Flexible(child: _buildStatChip(...)),
  ],
)
```

#### EnergyModal Bolts

```dart
// ANTES
width: 40,
height: 40,

// DEPOIS
final boltSize = ResponsiveUtils.width(40, min: 28, max: 48);
width: boltSize,
height: boltSize,
```

#### ProfileCard Name

```dart
// ANTES
Text(name, style: ...)

// DEPOIS
Text(
  name,
  style: ...,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

#### CompletePage Mascot

```dart
// ANTES
width: 300,
height: 300,

// DEPOIS
final mascotSize = ResponsiveUtils.width(300, min: 200, max: 350);
width: mascotSize,
height: mascotSize,
```

#### Headers (Profile, Leaderboard, Treasure)

```dart
// ANTES (ProfileHeader)
expandedHeight: 260,

// DEPOIS
expandedHeight: ResponsiveUtils.height(260, min: 220, max: 300),
```

## Data Models

Não há novos data models. As mudanças são apenas em cálculos de UI.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Scaling Proporcional

*For any* screen dimension and base value, the responsive value returned by `ResponsiveUtils.width()` or `ResponsiveUtils.height()` should be proportional to the screen size relative to the base design (375x667).

**Validates: Requirements 1.1, 2.1, 2.2, 2.3, 5.1, 5.2, 5.3, 5.4, 6.1, 6.3, 7.1, 7.4**

### Property 2: Clamp Bounds

*For any* value and min/max bounds passed to ResponsiveUtils methods, the returned value should always be within [min, max] inclusive.

**Validates: Requirements 1.3, 2.4, 6.4, 7.3, 8.2**

### Property 3: Minimum Touch Targets

*For any* screen size, interactive elements (buttons, inputs) should have dimensions >= 44px to comply with accessibility guidelines.

**Validates: Requirements 2.4**

### Property 4: TextScaleFactor Clamping

*For any* device textScaleFactor, the effective scale applied should be min(deviceFactor, 1.3) to prevent layout breaks while respecting accessibility.

**Validates: Requirements 8.1, 8.3**

### Property 5: Aspect Ratio Preservation

*For any* image or avatar, when scaled responsively, the aspect ratio (width/height) should remain constant.

**Validates: Requirements 7.2**

## Error Handling

### Inicialização

```dart
// ResponsiveUtils deve ser inicializado antes do uso
// Se não inicializado, usar valores padrão seguros

static double width(double value, {double? min, double? max}) {
  if (_screenWidth == 0) {
    // Fallback para base design se não inicializado
    return value.clamp(min ?? 0, max ?? double.infinity);
  }
  final scaled = value * (_screenWidth / _baseWidth);
  return scaled.clamp(min ?? 0, max ?? double.infinity);
}
```

### Valores Inválidos

```dart
// Garantir que min <= max
static double _clamp(double value, double? min, double? max) {
  final effectiveMin = min ?? 0;
  final effectiveMax = max ?? double.infinity;
  
  // Se min > max, usar min como valor
  if (effectiveMin > effectiveMax) {
    return effectiveMin;
  }
  
  return value.clamp(effectiveMin, effectiveMax);
}
```

## Testing Strategy

### Abordagem Dual

A estratégia de testes combina:
- **Unit tests**: Exemplos específicos e edge cases
- **Property tests**: Propriedades universais validadas com múltiplos inputs

### Unit Tests

1. **ResponsiveUtils.init()**: Verifica inicialização correta
2. **ResponsiveUtils.width()**: Testa valores específicos
3. **ResponsiveUtils.height()**: Testa valores específicos
4. **ResponsiveUtils.fontSize()**: Testa com diferentes textScaleFactors
5. **Edge cases**: Telas muito pequenas, muito grandes, landscape

### Property-Based Tests

Usar `fast_check` ou `glados` para Dart:

```dart
// Property 1: Scaling Proporcional
property('width scales proportionally', () {
  forAll(
    combine2(
      integer(min: 100, max: 1000), // screenWidth
      integer(min: 10, max: 200),   // value
    ),
    (screenWidth, value) {
      ResponsiveUtils._screenWidth = screenWidth.toDouble();
      final result = ResponsiveUtils.width(value.toDouble());
      final expected = value * (screenWidth / 375);
      expect(result, closeTo(expected, 0.01));
    },
  );
});

// Property 2: Clamp Bounds
property('clamp respects bounds', () {
  forAll(
    combine3(
      integer(min: 0, max: 100),   // value
      integer(min: 0, max: 50),    // min
      integer(min: 50, max: 100),  // max
    ),
    (value, min, max) {
      final result = ResponsiveUtils.width(
        value.toDouble(),
        min: min.toDouble(),
        max: max.toDouble(),
      );
      expect(result, greaterThanOrEqualTo(min));
      expect(result, lessThanOrEqualTo(max));
    },
  );
});

// Property 4: TextScaleFactor Clamping
property('textScaleFactor clamped to 1.3', () {
  forAll(
    doubleInRange(0.5, 3.0), // deviceFactor
    (factor) {
      ResponsiveUtils._textScaleFactor = factor.clamp(1.0, 1.3);
      expect(ResponsiveUtils._textScaleFactor, lessThanOrEqualTo(1.3));
    },
  );
});
```

### Configuração de Testes

- **Framework**: `flutter_test` + `glados` (property-based testing)
- **Mínimo 100 iterações** por property test
- **Tag format**: `Feature: responsive-fixes, Property N: description`

### Cobertura

| Componente | Unit Tests | Property Tests |
|------------|------------|----------------|
| ResponsiveUtils | ✅ | ✅ |
| AppButton | ✅ | - |
| AppPinput | ✅ | - |
| Modals | ✅ | - |
| Headers | ✅ | - |
