import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/shared/translations/app_translations.dart';
import 'package:pippo/shared/translations/pt_BR.dart';
import 'package:pippo/shared/translations/en_US.dart';
import 'package:pippo/shared/translations/es_ES.dart';

/// Helper class para setup de traduções em testes
class TranslationTestHelper {
  /// Inicializa GetX com traduções para testes
  /// 
  /// Deve ser chamado no setUp() de cada arquivo de teste que usa traduções
  static void setupTranslations({Locale locale = const Locale('pt', 'BR')}) {
    // Ensure GetX is in test mode
    Get.testMode = true;
    
    // Reset GetX to clean state
    Get.reset();
    
    // Initialize translations
    Get.put(AppTranslations());
    
    // Set locale
    Get.updateLocale(locale);
    
    // Force load translations into GetX
    final translations = AppTranslations().keys;
    final localeKey = '${locale.languageCode}_${locale.countryCode}';
    
    if (translations.containsKey(localeKey)) {
      // Manually add translations to GetX
      Get.addTranslations(translations);
    }
  }

  /// Limpa GetX após testes
  static void teardownTranslations() {
    Get.reset();
  }

  /// Obtém tradução diretamente do mapa (fallback para quando .tr não funciona)
  /// 
  /// Este método acessa diretamente os mapas de tradução, ignorando o sistema GetX
  /// que não funciona corretamente em ambiente de teste.
  static String translate(String key, {Locale locale = const Locale('pt', 'BR')}) {
    final localeKey = '${locale.languageCode}_${locale.countryCode}';
    
    Map<String, String> translations;
    switch (localeKey) {
      case 'pt_BR':
        translations = PtBR.translations;
        break;
      case 'en_US':
        translations = EnUS.translations;
        break;
      case 'es_ES':
        translations = EsES.translations;
        break;
      default:
        translations = PtBR.translations;
    }
    
    // Return the translated value or the key if not found
    return translations[key] ?? key;
  }

  /// Verifica se uma string é uma chave de tradução (não foi traduzida)
  static bool isTranslationKey(String text) {
    return text.startsWith('error_') || 
           text.startsWith('validation_') ||
           text.startsWith('auth_') ||
           text.startsWith('onboarding_') ||
           text.startsWith('home_') ||
           text.startsWith('profile_') ||
           text.startsWith('lesson_') ||
           text.startsWith('shop_') ||
           text.startsWith('leaderboard_') ||
           text.startsWith('treasure_') ||
           text.startsWith('common_');
  }

  /// Obtém mensagem de erro traduzida
  static String getErrorMessage(String key) {
    return translate(key);
  }

  /// Obtém mensagem de validação traduzida
  static String getValidationMessage(String key) {
    return translate(key);
  }
}
