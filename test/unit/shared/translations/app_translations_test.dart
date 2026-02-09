import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/shared/translations/app_translations.dart';
import 'package:pippo/shared/translations/pt_BR.dart';
import 'package:pippo/shared/translations/en_US.dart';
import 'package:pippo/shared/translations/es_ES.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  group('AppTranslations', () {
    test('should contain all supported locales', () {
      final translations = AppTranslations();
      final keys = translations.keys;

      expect(keys.containsKey('pt_BR'), true);
      expect(keys.containsKey('en_US'), true);
      expect(keys.containsKey('es_ES'), true);
    });

    test('should have exactly 3 locales', () {
      final translations = AppTranslations();
      final keys = translations.keys;

      expect(keys.length, 3);
    });

    test('should return correct translation for pt_BR', () {
      final ptTranslations = PtBR.translations;

      expect(ptTranslations['auth_signin_title'], 'Entrar');
      expect(ptTranslations['common_continue'], 'Continuar');
      expect(ptTranslations['common_cancel'], 'Cancelar');
      expect(ptTranslations['common_save'], 'Salvar');
    });

    test('should return correct translation for en_US', () {
      final enTranslations = EnUS.translations;

      expect(enTranslations['auth_signin_title'], 'Sign in');
      expect(enTranslations['common_continue'], 'Continue');
      expect(enTranslations['common_cancel'], 'Cancel');
      expect(enTranslations['common_save'], 'Save');
    });

    test('should return correct translation for es_ES', () {
      final esTranslations = EsES.translations;

      expect(esTranslations['auth_signin_title'], 'Entrar');
      expect(esTranslations['common_continue'], 'Continuar');
      expect(esTranslations['common_cancel'], 'Cancelar');
      expect(esTranslations['common_save'], 'Guardar');
    });

    test('should handle missing key gracefully', () {
      Get.put(AppTranslations());
      Get.updateLocale(const Locale('pt', 'BR'));

      // Missing key returns the key itself
      expect('nonexistent_key'.tr, 'nonexistent_key');
    });

    test('should not have empty values in pt_BR', () {
      final ptTranslations = PtBR.translations;

      for (var entry in ptTranslations.entries) {
        expect(entry.value.isNotEmpty, true,
            reason: 'Key ${entry.key} has empty value in pt_BR');
      }
    });

    test('should not have empty values in en_US', () {
      final enTranslations = EnUS.translations;

      for (var entry in enTranslations.entries) {
        expect(entry.value.isNotEmpty, true,
            reason: 'Key ${entry.key} has empty value in en_US');
      }
    });

    test('should not have empty values in es_ES', () {
      final esTranslations = EsES.translations;

      for (var entry in esTranslations.entries) {
        expect(entry.value.isNotEmpty, true,
            reason: 'Key ${entry.key} has empty value in es_ES');
      }
    });
  });
}
