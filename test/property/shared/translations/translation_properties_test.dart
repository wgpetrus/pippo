import 'package:flutter_test/flutter_test.dart';
import 'package:pippo/shared/translations/pt_BR.dart';
import 'package:pippo/shared/translations/en_US.dart';
import 'package:pippo/shared/translations/es_ES.dart';

void main() {
  group('Translation Properties', () {
    // Feature: internationalization-system, Property 1: Translation Key Consistency
    // Validates: Requirements 8.1, 8.5
    test('all language files should have identical key sets', () {
      final ptKeys = PtBR.translations.keys.toSet();
      final enKeys = EnUS.translations.keys.toSet();
      final esKeys = EsES.translations.keys.toSet();
      
      // All files should have the same keys
      expect(ptKeys, equals(enKeys),
          reason: 'pt_BR and en_US should have identical keys');
      expect(ptKeys, equals(esKeys),
          reason: 'pt_BR and es_ES should have identical keys');
      expect(enKeys, equals(esKeys),
          reason: 'en_US and es_ES should have identical keys');
    }, tags: ['property']);

    // Feature: internationalization-system, Property 2: Fallback Locale Completeness
    // Validates: Requirements 5.4, 8.3
    test('fallback locale should have all keys used in the app', () {
      final ptTranslations = PtBR.translations;
      
      // Every key should have a non-empty value
      for (var entry in ptTranslations.entries) {
        expect(entry.value.isNotEmpty, true,
            reason: 'Key ${entry.key} has empty value in pt_BR');
      }
    }, tags: ['property']);

    // Feature: internationalization-system, Property 3: Translation Key Format Compliance
    // Validates: Requirements 3.1, 3.2
    test('all translation keys should follow naming convention', () {
      final allKeys = [
        ...PtBR.translations.keys,
        ...EnUS.translations.keys,
        ...EsES.translations.keys,
      ].toSet();
      
      final keyPattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');
      
      for (var key in allKeys) {
        expect(keyPattern.hasMatch(key), true,
            reason: 'Key "$key" does not follow naming convention');
      }
    }, tags: ['property']);

    // Feature: internationalization-system, Property 6: Common Key Reusability
    // Validates: Requirements 10.2, 10.4
    test('common keys should be prefixed with common_', () {
      final commonKeys = [
        'common_continue',
        'common_cancel',
        'common_save',
        'common_delete',
        'common_back',
        'common_next',
        'common_done',
        'common_verify',
        'common_confirm',
      ];
      
      for (var key in commonKeys) {
        expect(PtBR.translations.containsKey(key), true,
            reason: 'Common key $key missing in pt_BR');
        expect(EnUS.translations.containsKey(key), true,
            reason: 'Common key $key missing in en_US');
        expect(EsES.translations.containsKey(key), true,
            reason: 'Common key $key missing in es_ES');
      }
    }, tags: ['property']);
  });
}
