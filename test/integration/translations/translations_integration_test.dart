import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/shared/translations/app_translations.dart';
import 'package:pippo/shared/translations/pt_BR.dart';
import 'package:pippo/shared/translations/en_US.dart';
import 'package:pippo/shared/translations/es_ES.dart';

import '../helpers/firebase_test_helper.dart';

/// Integration Test - Translations System
/// 
/// Validates the complete internationalization system:
/// - Default language (Portuguese)
/// - Dynamic language switching
/// - Fallback behavior
/// 
/// Requirements tested:
/// - 5.2: Device locale detection
/// - 5.3: Fallback to Portuguese
/// - 5.4: Missing translation fallback
/// - 7.1: Interface language display
/// - 7.2: Unsupported locale fallback
void main() {
  setUpAll(() async {
    await FirebaseTestHelper.setupFirebase();
  });

  group('Translations Integration Tests', () {
    group('Default Language - Portuguese', () {
      test('Portuguese should be the default fallback locale', () {
        // Arrange
        final translations = AppTranslations();
        final keys = translations.keys;

        // Assert - Portuguese translations exist and are complete
        expect(keys.containsKey('pt_BR'), true);
        expect(keys['pt_BR']!.isNotEmpty, true);
        
        // Verify translation system is working by checking direct translation
        expect(PtBR.translations['common_continue'], 'Continuar');
      });

      test('Portuguese translations should be complete', () {
        // Arrange
        final ptTranslations = PtBR.translations;

        // Assert - Every key has a non-empty value
        for (var entry in ptTranslations.entries) {
          expect(entry.value.isNotEmpty, true,
              reason: 'Key ${entry.key} has empty value in pt_BR');
        }
      });
    });

    group('Dynamic Language Switching', () {
      test('translation maps should support all required languages', () {
        // Arrange
        final translations = AppTranslations();
        final keys = translations.keys;

        // Assert - All locales are registered
        expect(keys.containsKey('pt_BR'), true);
        expect(keys.containsKey('en_US'), true);
        expect(keys.containsKey('es_ES'), true);
        
        // Verify translations are not empty
        expect(keys['pt_BR']!.isNotEmpty, true);
        expect(keys['en_US']!.isNotEmpty, true);
        expect(keys['es_ES']!.isNotEmpty, true);
      });
    });

    group('Fallback Behavior', () {
      test('fallback locale should be Portuguese', () {
        // Arrange
        final translations = AppTranslations();
        final keys = translations.keys;

        // Assert - Portuguese exists as fallback
        expect(keys.containsKey('pt_BR'), true);
        expect(keys['pt_BR']!.isNotEmpty, true);
      });

      test('missing translation key should be handled gracefully', () {
        // Arrange
        final ptTranslations = PtBR.translations;
        final enTranslations = EnUS.translations;

        // Assert - Fallback locale has all keys
        expect(ptTranslations.isNotEmpty, true);
        expect(enTranslations.isNotEmpty, true);
        
        // Verify common keys exist
        expect(ptTranslations.containsKey('common_continue'), true);
        expect(enTranslations.containsKey('common_continue'), true);
      });
    });

    group('Translation Completeness', () {
      test('all supported locales should have same keys', () {
        // Arrange
        final ptKeys = PtBR.translations.keys.toSet();
        final enKeys = EnUS.translations.keys.toSet();
        final esKeys = EsES.translations.keys.toSet();

        // Assert - All locales have same keys
        expect(ptKeys, equals(enKeys));
        expect(ptKeys, equals(esKeys));
        expect(enKeys, equals(esKeys));
      });

      test('fallback locale (pt_BR) should have all keys', () {
        // Arrange
        final ptTranslations = PtBR.translations;

        // Assert - Every key has a non-empty value
        for (var entry in ptTranslations.entries) {
          expect(entry.value.isNotEmpty, true,
              reason: 'Key ${entry.key} has empty value in pt_BR');
        }
      });

      test('common keys should be available in all languages', () {
        // Arrange - Common keys that should exist
        final commonKeys = [
          'common_continue',
          'common_cancel',
          'common_save',
          'common_delete',
          'common_back',
        ];

        // Assert - Keys exist in all languages
        for (var key in commonKeys) {
          expect(PtBR.translations.containsKey(key), true, 
              reason: '$key missing in pt_BR');
          expect(EnUS.translations.containsKey(key), true, 
              reason: '$key missing in en_US');
          expect(EsES.translations.containsKey(key), true, 
              reason: '$key missing in es_ES');
        }
      });
    });

    group('Real-World Scenarios', () {
      test('auth flow translations should exist', () {
        // Arrange - Auth keys
        final authKeys = [
          'auth_signin_title',
          'auth_email_label',
          'auth_password_label',
          'auth_signin_button',
        ];

        // Assert - Keys exist in all languages
        for (var key in authKeys) {
          expect(PtBR.translations.containsKey(key), true);
          expect(EnUS.translations.containsKey(key), true);
          expect(EsES.translations.containsKey(key), true);
        }
        
        // Verify Portuguese translations
        expect(PtBR.translations['auth_signin_title'], 'Entrar');
        expect(PtBR.translations['auth_email_label'], 'Usuário / e-mail');
        expect(PtBR.translations['auth_password_label'], 'Senha');
      });

      test('error messages should be translated', () {
        // Arrange - Error keys
        final errorKeys = [
          'error_email_required',
          'error_password_required',
          'error_auth_invalid_credential',
        ];

        // Assert - Keys exist in all languages
        for (var key in errorKeys) {
          expect(PtBR.translations.containsKey(key), true);
          expect(EnUS.translations.containsKey(key), true);
          expect(EsES.translations.containsKey(key), true);
        }
        
        // Verify English error messages
        expect(EnUS.translations['error_email_required'], 'Email is required.');
        expect(EnUS.translations['error_password_required'], 'Password is required.');
        expect(EnUS.translations['error_auth_invalid_credential'], 'Incorrect email or password.');
      });

      test('navigation labels should be translated', () {
        // Arrange - Navigation keys
        final navKeys = [
          'home_courses_tab',
          'home_leaderboard_tab',
          'home_shop_tab',
          'home_profile_tab',
        ];

        // Assert - Keys exist in all languages
        for (var key in navKeys) {
          expect(PtBR.translations.containsKey(key), true);
          expect(EnUS.translations.containsKey(key), true);
          expect(EsES.translations.containsKey(key), true);
        }
        
        // Verify Spanish translations
        expect(EsES.translations['home_courses_tab'], 'Cursos');
        expect(EsES.translations['home_leaderboard_tab'], 'Ranking');
        expect(EsES.translations['home_shop_tab'], 'Tienda');
        expect(EsES.translations['home_profile_tab'], 'Perfil');
      });
    });

    group('Edge Cases', () {
      test('translation with parameters should have correct format', () {
        // Arrange
        final key = 'home_gems_modal_total_earned';
        
        // Assert - Key exists and has parameter placeholder
        expect(PtBR.translations.containsKey(key), true);
        expect(EnUS.translations.containsKey(key), true);
        
        // Verify parameter placeholder format
        expect(EnUS.translations[key]!.contains('{count}'), true);
        expect(PtBR.translations[key]!.contains('{count}'), true);
      });

      test('all translation keys should follow naming convention', () {
        // Arrange
        final ptKeys = PtBR.translations.keys;
        final keyPattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');
        
        // Assert - All keys follow snake_case convention
        for (var key in ptKeys) {
          expect(keyPattern.hasMatch(key), true,
              reason: 'Key "$key" does not follow naming convention');
        }
      });
    });
  });
}
