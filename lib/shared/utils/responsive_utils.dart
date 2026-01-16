import 'package:flutter/material.dart';

/// Utilitário de responsividade centralizado
///
/// Suporta dois modos de uso:
/// 1. Estático: ResponsiveUtils.width(100) - para widgets que não têm context
/// 2. Instanciado: final r = ResponsiveUtils(context); r.wp(50) - para views
///
/// Base design: iPhone SE (375 x 667)
class ResponsiveUtils {
  // Contexto para modo instanciado
  final BuildContext? _context;

  // Dimensões estáticas da tela
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _textScaleFactor = 1.0;

  // Base design: iPhone SE (375 x 667)
  static const double _baseWidth = 375.0;
  static const double _baseHeight = 667.0;
  static const double _maxTextScale = 1.3;

  /// Construtor para modo instanciado
  ResponsiveUtils(BuildContext context) : _context = context {
    // Inicializa valores estáticos também
    init(context);
  }

  /// Construtor privado para uso estático
  ResponsiveUtils._() : _context = null;

  // MediaQuery do contexto
  MediaQueryData get _mq => MediaQuery.of(_context!);

  // Dimensões da tela (instanciado)
  double get widthScreen => _context != null ? _mq.size.width : _screenWidth;
  double get heightScreen => _context != null ? _mq.size.height : _screenHeight;

  // Breakpoints
  bool get isMobile => widthScreen < 600;
  bool get isTablet => widthScreen >= 600 && widthScreen < 1024;
  bool get isDesktop => widthScreen >= 1024;

  // Orientação
  bool get isLandscape =>
      _context != null ? _mq.orientation == Orientation.landscape : isLandscapeStatic;
  bool get isPortrait =>
      _context != null ? _mq.orientation == Orientation.portrait : !isLandscapeStatic;

  // SafeArea paddings
  EdgeInsets get safeAreaPadding =>
      _context != null ? _mq.padding : EdgeInsets.zero;
  double get topSafeArea => _context != null ? _mq.padding.top : 0;
  double get bottomSafeArea => _context != null ? _mq.padding.bottom : 0;
  double get leftSafeArea => _context != null ? _mq.padding.left : 0;
  double get rightSafeArea => _context != null ? _mq.padding.right : 0;

  // Keyboard
  double get keyboardHeight =>
      _context != null ? _mq.viewInsets.bottom : 0;
  bool get isKeyboardOpen => keyboardHeight > 0;

  // Text scaling
  double get textScaleFactor =>
      _context != null ? _mq.textScaleFactor : _textScaleFactor;

  // Valores responsivos baseados em porcentagem
  double wp(double percentage) => widthScreen * percentage / 100;
  double hp(double percentage) => heightScreen * percentage / 100;

  // Altura disponível (descontando SafeArea)
  double get availableHeight => heightScreen - topSafeArea - bottomSafeArea;
  double get availableWidth => widthScreen - leftSafeArea - rightSafeArea;

  // Espaçamentos responsivos
  double get spacing4 => isMobile ? 4 : 6;
  double get spacing8 => isMobile ? 8 : 12;
  double get spacing12 => isMobile ? 12 : 16;
  double get spacing16 => isMobile ? 16 : 20;
  double get spacing24 => isMobile ? 24 : 32;
  double get spacing32 => isMobile ? 32 : 40;
  double get spacing48 => isMobile ? 48 : 64;

  // Tamanhos de fonte responsivos
  double get fontSize10 => _limitFontSize(isMobile ? 10 : 12);
  double get fontSize12 => _limitFontSize(isMobile ? 12 : 14);
  double get fontSize14 => _limitFontSize(isMobile ? 14 : 16);
  double get fontSize16 => _limitFontSize(isMobile ? 16 : 18);
  double get fontSize18 => _limitFontSize(isMobile ? 18 : 20);
  double get fontSize20 => _limitFontSize(isMobile ? 20 : 24);
  double get fontSize24 => _limitFontSize(isMobile ? 24 : 28);
  double get fontSize32 => _limitFontSize(isMobile ? 32 : 40);

  // Limita font size para acessibilidade
  double _limitFontSize(double size) {
    final scaled = size * textScaleFactor;
    return scaled > size * 1.3 ? size * 1.3 : scaled;
  }

  // MaxWidth para desktop
  double get maxContentWidth => isDesktop ? 1200 : widthScreen;

  // Valor baseado no tipo de dispositivo
  T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Aspect ratio
  double aspectRatio(double w, double h) => w / h;

  // ============================================================
  // MÉTODOS ESTÁTICOS (compatibilidade com código existente)
  // ============================================================

  /// Inicializa com o contexto (chamar no main ou wrapper)
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _textScaleFactor = mediaQuery.textScaleFactor.clamp(1.0, _maxTextScale);
  }

  /// Largura responsiva (estático)
  static double width(double value, {double? min, double? max}) {
    if (_screenWidth == 0) {
      return value.clamp(min ?? 0, max ?? double.infinity);
    }
    final scaled = value * (_screenWidth / _baseWidth);
    return scaled.clamp(min ?? 0, max ?? double.infinity);
  }

  /// Altura responsiva (estático)
  static double height(double value, {double? min, double? max}) {
    if (_screenHeight == 0) {
      return value.clamp(min ?? 0, max ?? double.infinity);
    }
    final scaled = value * (_screenHeight / _baseHeight);
    return scaled.clamp(min ?? 0, max ?? double.infinity);
  }

  /// Font size responsivo (estático)
  static double fontSizeStatic(double value, {double? min}) {
    final scaled = value * _textScaleFactor;
    return scaled.clamp(min ?? 10, double.infinity);
  }

  /// Tela pequena (< 360px largura)
  static bool get isSmallScreen => _screenWidth < 360;

  /// Tela muito pequena (< 600px altura)
  static bool get isShortScreen => _screenHeight < 600;

  /// Modo landscape (estático)
  static bool get isLandscapeStatic => _screenWidth > _screenHeight;

  /// Getters para dimensões (estático)
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
}
