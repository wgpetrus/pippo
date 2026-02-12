import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/shared/translations/pt_BR.dart';
import 'package:pippo/shared/translations/en_US.dart';
import 'package:pippo/shared/translations/es_ES.dart';

void main() {
  group('Controllers Translation Keys Tests', () {
    test('TreasureChallengesController - keys básicas existem em pt_BR', () {
      final translations = PtBR.translations;
      
      // Verificar que as mensagens de erro básicas existem
      expect(translations.containsKey('error_challenge_not_found'), isTrue);
      expect(translations.containsKey('error_check_challenge_completion'), isTrue);
      expect(translations.containsKey('error_update_challenge_progress'), isTrue);
      expect(translations.containsKey('error_progress_negative'), isTrue);
      expect(translations.containsKey('error_user_not_authenticated'), isTrue);
      expect(translations.containsKey('error_firestore_deadline_exceeded'), isTrue);
      expect(translations.containsKey('error_firestore_default'), isTrue);
    });

    test('ShopController - keys básicas existem em pt_BR', () {
      final translations = PtBR.translations;
      
      // Verificar que as mensagens de erro básicas existem
      expect(translations.containsKey('error_insufficient_gems'), isTrue);
      expect(translations.containsKey('error_purchase_xp_booster'), isTrue);
      expect(translations.containsKey('error_purchase_energy'), isTrue);
      expect(translations.containsKey('error_no_active_course'), isTrue);
      expect(translations.containsKey('error_purchase_streak_protection'), isTrue);
      expect(translations.containsKey('error_purchase_gem_multiplier'), isTrue);
      expect(translations.containsKey('error_user_not_authenticated'), isTrue);
      expect(translations.containsKey('error_reward_already_claimed'), isTrue);
      expect(translations.containsKey('error_claim_free_reward'), isTrue);
    });

    test('HomeStatsController - todas as keys existem em pt_BR', () {
      final translations = PtBR.translations;
      
      // Verificar que os botões existem
      expect(translations.containsKey('home_lesson_button_continue'), isTrue);
      expect(translations.containsKey('home_lesson_button_start'), isTrue);
      
      // Verificar que as traduções não são as strings hardcoded originais
      expect(translations['home_lesson_button_continue'], equals('Continuar'));
      expect(translations['home_lesson_button_start'], equals('Começar'));
    });

    test('XpLevelController - keys de tempo existem em pt_BR', () {
      final translations = PtBR.translations;
      
      // Verificar que os formatos de tempo existem
      expect(translations.containsKey('common_time_minutes_remaining'), isTrue);
      expect(translations.containsKey('common_time_hours_remaining'), isTrue);
      
      // Verificar que as traduções contêm placeholders
      expect(translations['common_time_minutes_remaining'], contains('{minutes}'));
      expect(translations['common_time_hours_remaining'], contains('{hours}'));
    });

    test('GemsController - keys de tempo existem em pt_BR', () {
      final translations = PtBR.translations;
      
      // Verificar que os formatos de tempo existem
      expect(translations.containsKey('common_time_minutes_remaining'), isTrue);
      expect(translations.containsKey('common_time_hours_remaining'), isTrue);
      
      // Verificar que as traduções contêm placeholders
      expect(translations['common_time_minutes_remaining'], contains('{minutes}'));
      expect(translations['common_time_hours_remaining'], contains('{hours}'));
    });

    test('Todas as keys básicas existem em en_US', () {
      final translations = EnUS.translations;
      
      final keysToCheck = [
        'error_challenge_not_found',
        'error_check_challenge_completion',
        'error_update_challenge_progress',
        'error_progress_negative',
        'error_user_not_authenticated',
        'error_firestore_deadline_exceeded',
        'error_firestore_default',
        'error_insufficient_gems',
        'error_purchase_xp_booster',
        'error_purchase_energy',
        'error_no_active_course',
        'error_purchase_streak_protection',
        'error_purchase_gem_multiplier',
        'error_reward_already_claimed',
        'error_claim_free_reward',
        'home_lesson_button_continue',
        'home_lesson_button_start',
        'common_time_minutes_remaining',
        'common_time_hours_remaining',
      ];

      for (final key in keysToCheck) {
        expect(translations.containsKey(key), isTrue, reason: 'Key "$key" should exist in en_US');
      }
    });

    test('Todas as keys básicas existem em es_ES', () {
      final translations = EsES.translations;
      
      final keysToCheck = [
        'error_challenge_not_found',
        'error_check_challenge_completion',
        'error_update_challenge_progress',
        'error_progress_negative',
        'error_user_not_authenticated',
        'error_firestore_deadline_exceeded',
        'error_firestore_default',
        'error_insufficient_gems',
        'error_purchase_xp_booster',
        'error_purchase_energy',
        'error_no_active_course',
        'error_purchase_streak_protection',
        'error_purchase_gem_multiplier',
        'error_reward_already_claimed',
        'error_claim_free_reward',
        'home_lesson_button_continue',
        'home_lesson_button_start',
        'common_time_minutes_remaining',
        'common_time_hours_remaining',
      ];

      for (final key in keysToCheck) {
        expect(translations.containsKey(key), isTrue, reason: 'Key "$key" should exist in es_ES');
      }
    });

    test('Nenhuma key está vazia', () {
      final ptBR = PtBR.translations;
      final enUS = EnUS.translations;
      final esES = EsES.translations;
      
      final keysToCheck = [
        'error_challenge_not_found',
        'error_insufficient_gems',
        'home_lesson_button_continue',
        'home_lesson_button_start',
        'common_time_minutes_remaining',
        'common_time_hours_remaining',
      ];

      for (final key in keysToCheck) {
        expect(ptBR[key], isNotEmpty, reason: 'pt_BR translation for "$key" should not be empty');
        expect(enUS[key], isNotEmpty, reason: 'en_US translation for "$key" should not be empty');
        expect(esES[key], isNotEmpty, reason: 'es_ES translation for "$key" should not be empty');
      }
    });
  });
}
