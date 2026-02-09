import 'package:flutter_test/flutter_test.dart';
import 'package:pippo/shared/translations/pt_BR.dart';
import 'package:pippo/shared/translations/en_US.dart';
import 'package:pippo/shared/translations/es_ES.dart';

void main() {
  group('Common Keys', () {
    // List of required common keys based on requirements
    final requiredCommonKeys = [
      'common_continue',
      'common_cancel',
      'common_save',
      'common_delete',
      'common_back',
      'common_next',
      'common_done',
      'common_confirm',
    ];

    test('all required common keys should exist in pt_BR', () {
      final ptTranslations = PtBR.translations;

      for (var key in requiredCommonKeys) {
        expect(ptTranslations.containsKey(key), true,
            reason: 'Required common key "$key" missing in pt_BR');
      }
    });

    test('all required common keys should exist in en_US', () {
      final enTranslations = EnUS.translations;

      for (var key in requiredCommonKeys) {
        expect(enTranslations.containsKey(key), true,
            reason: 'Required common key "$key" missing in en_US');
      }
    });

    test('all required common keys should exist in es_ES', () {
      final esTranslations = EsES.translations;

      for (var key in requiredCommonKeys) {
        expect(esTranslations.containsKey(key), true,
            reason: 'Required common key "$key" missing in es_ES');
      }
    });

    test('all common_ prefixed keys should exist in all languages', () {
      final ptCommonKeys = PtBR.translations.keys
          .where((key) => key.startsWith('common_'))
          .toSet();
      final enCommonKeys = EnUS.translations.keys
          .where((key) => key.startsWith('common_'))
          .toSet();
      final esCommonKeys = EsES.translations.keys
          .where((key) => key.startsWith('common_'))
          .toSet();

      // All languages should have the same common keys
      expect(ptCommonKeys, equals(enCommonKeys),
          reason: 'pt_BR and en_US have different common keys');
      expect(ptCommonKeys, equals(esCommonKeys),
          reason: 'pt_BR and es_ES have different common keys');
      expect(enCommonKeys, equals(esCommonKeys),
          reason: 'en_US and es_ES have different common keys');
    });

    test('common keys should have non-empty values in pt_BR', () {
      final ptTranslations = PtBR.translations;
      final commonKeys =
          ptTranslations.keys.where((key) => key.startsWith('common_'));

      for (var key in commonKeys) {
        expect(ptTranslations[key]!.isNotEmpty, true,
            reason: 'Common key "$key" has empty value in pt_BR');
      }
    });

    test('common keys should have non-empty values in en_US', () {
      final enTranslations = EnUS.translations;
      final commonKeys =
          enTranslations.keys.where((key) => key.startsWith('common_'));

      for (var key in commonKeys) {
        expect(enTranslations[key]!.isNotEmpty, true,
            reason: 'Common key "$key" has empty value in en_US');
      }
    });

    test('common keys should have non-empty values in es_ES', () {
      final esTranslations = EsES.translations;
      final commonKeys =
          esTranslations.keys.where((key) => key.startsWith('common_'));

      for (var key in commonKeys) {
        expect(esTranslations[key]!.isNotEmpty, true,
            reason: 'Common key "$key" has empty value in es_ES');
      }
    });

    test('should have at least 9 common keys', () {
      final ptCommonKeys = PtBR.translations.keys
          .where((key) => key.startsWith('common_'))
          .length;

      expect(ptCommonKeys, greaterThanOrEqualTo(9),
          reason:
              'Should have at least 9 common keys (continue, cancel, save, delete, back, next, done, confirm, and others)');
    });

    test('common keys should be reused across features', () {
      // This test verifies that common keys follow the pattern
      // and are properly prefixed
      final ptTranslations = PtBR.translations;
      final commonKeys =
          ptTranslations.keys.where((key) => key.startsWith('common_')).toList();

      // All common keys should follow the pattern common_[action]
      final validPattern = RegExp(r'^common_[a-z_]+$');

      for (var key in commonKeys) {
        expect(validPattern.hasMatch(key), true,
            reason: 'Common key "$key" does not follow the pattern common_[action]');
      }
    });

    test('common_continue should exist in all languages', () {
      expect(PtBR.translations.containsKey('common_continue'), true);
      expect(EnUS.translations.containsKey('common_continue'), true);
      expect(EsES.translations.containsKey('common_continue'), true);
    });

    test('common_cancel should exist in all languages', () {
      expect(PtBR.translations.containsKey('common_cancel'), true);
      expect(EnUS.translations.containsKey('common_cancel'), true);
      expect(EsES.translations.containsKey('common_cancel'), true);
    });

    test('common_save should exist in all languages', () {
      expect(PtBR.translations.containsKey('common_save'), true);
      expect(EnUS.translations.containsKey('common_save'), true);
      expect(EsES.translations.containsKey('common_save'), true);
    });

    test('common_delete should exist in all languages', () {
      expect(PtBR.translations.containsKey('common_delete'), true);
      expect(EnUS.translations.containsKey('common_delete'), true);
      expect(EsES.translations.containsKey('common_delete'), true);
    });

    test('common_back should exist in all languages', () {
      expect(PtBR.translations.containsKey('common_back'), true);
      expect(EnUS.translations.containsKey('common_back'), true);
      expect(EsES.translations.containsKey('common_back'), true);
    });

    test('common_next should exist in all languages', () {
      expect(PtBR.translations.containsKey('common_next'), true);
      expect(EnUS.translations.containsKey('common_next'), true);
      expect(EsES.translations.containsKey('common_next'), true);
    });

    test('common_done should exist in all languages', () {
      expect(PtBR.translations.containsKey('common_done'), true);
      expect(EnUS.translations.containsKey('common_done'), true);
      expect(EsES.translations.containsKey('common_done'), true);
    });
  });
}
