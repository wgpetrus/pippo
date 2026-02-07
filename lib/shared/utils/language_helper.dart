import 'app_assets.dart';

/// Helper para mapeamento de idiomas
/// 
/// Centraliza o mapeamento de códigos de idioma para:
/// - Nomes traduzidos em português
/// - Assets de bandeiras
class LanguageHelper {
  // Mapeamento de código → nome em português
  static const Map<String, String> languageNames = {
    'en': 'Inglês',
    'es': 'Espanhol',
    'fr': 'Francês',
    'de': 'Alemão',
    'pt': 'Português',
    'zh': 'Chinês',
    'ja': 'Japonês',
    'ar': 'Árabe',
  };

  // Mapeamento de código → asset da bandeira
  static const Map<String, String> languageFlags = {
    'en': AppAssets.flagUsa,
    'es': AppAssets.flagSpain,
    'fr': AppAssets.flagFrance,
    'de': AppAssets.flagGermany,
    'pt': AppAssets.flagBrazil,
    'zh': AppAssets.flagChina,
    'ja': AppAssets.flagJapan,
    'ar': AppAssets.flagSaudi,
  };

  /// Retorna o nome do idioma em português
  /// 
  /// Se o código não for encontrado, retorna o próprio código
  static String getLanguageName(String code) {
    return languageNames[code] ?? code;
  }

  /// Retorna o asset da bandeira do idioma
  /// 
  /// Se o código não for encontrado, retorna bandeira dos EUA como fallback
  static String getLanguageFlag(String code) {
    return languageFlags[code] ?? AppAssets.flagUsa;
  }
}
