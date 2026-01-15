import 'package:flutter/material.dart';

/// Utilitário de responsividade centralizado
///
/// Calcula tamanhos responsivos baseados em proporção da tela
/// Base design: iPhone SE (375 x 667)
class ResponsiveUtils {
  // Dimensões da tela
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _textScaleFactor = 1.0;

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
  ///
  /// Calcula largura proporcional à tela com limites opcionais
  static double width(double value, {double? min, double? max}) {
    // Fallback para base design se não inicializado
    if (_screenWidth == 0) {
      return value.clamp(min ?? 0, max ?? double.infinity);
    }

    final scaled = value * (_screenWidth / _baseWidth);
    return scaled.clamp(min ?? 0, max ?? double.infinity);
  }

  /// Altura responsiva
  ///
  /// Calcula altura proporcional à tela com limites opcionais
  static double height(double value, {double? min, double? max}) {
    // Fallback para base design se não inicializado
    if (_screenHeight == 0) {
      return value.clamp(min ?? 0, max ?? double.infinity);
    }

    final scaled = value * (_screenHeight / _baseHeight);
    return scaled.clamp(min ?? 0, max ?? double.infinity);
  }

  /// Font size responsivo (com limite de acessibilidade)
  ///
  /// Aplica textScaleFactor limitado a 1.3x
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
