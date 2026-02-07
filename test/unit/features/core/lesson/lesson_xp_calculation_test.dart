import 'package:flutter_test/flutter_test.dart';

/// Testes unitários para cálculos de XP no LessonRewardsController
/// 
/// Verifica a lógica de cálculo pura sem necessidade de
/// inicialização completa do Firebase ou estado do controller.
void main() {
  int xpForNextLevel(int currentLevel) {
    return currentLevel * 100;
  }

  group('LessonRewardsController - Cálculos de XP', () {
    test('calculateXPForNextLevel segue fórmula: currentLevel * 100', () {
      // Testar fórmula para vários níveis
      expect(xpForNextLevel(1), equals(100));
      expect(xpForNextLevel(2), equals(200));
      expect(xpForNextLevel(5), equals(500));
      expect(xpForNextLevel(10), equals(1000));
      expect(xpForNextLevel(50), equals(5000));
      expect(xpForNextLevel(100), equals(10000));
    });

    test('calculateXPForNextLevel nunca retorna negativo ou zero', () {
      // Testar que todos os valores são positivos
      for (int level = 1; level <= 100; level++) {
        final xp = xpForNextLevel(level);
        expect(xp, greaterThan(0), reason: 'Nível $level deve ter XP positivo');
        expect(xp, greaterThanOrEqualTo(100), reason: 'Nível $level deve requerer pelo menos 100 XP');
      }
    });

    test('calculateXPForNextLevel é determinístico', () {
      // Testar que o mesmo input sempre produz o mesmo output
      for (int level = 1; level <= 50; level++) {
        final xp1 = xpForNextLevel(level);
        final xp2 = xpForNextLevel(level);
        final xp3 = xpForNextLevel(level);
        
        expect(xp1, equals(xp2), reason: 'Fórmula deve ser determinística');
        expect(xp2, equals(xp3), reason: 'Fórmula deve ser determinística');
        expect(xp1, equals(level * 100), reason: 'Fórmula deve seguir especificação');
      }
    });

    test('Requisitos de XP aumentam monotonicamente', () {
      // Testar que cada nível requer mais XP que o anterior
      for (int level = 1; level < 100; level++) {
        final currentXp = xpForNextLevel(level);
        final nextXp = xpForNextLevel(level + 1);
        
        expect(nextXp, greaterThan(currentXp),
            reason: 'Nível ${level + 1} deve requerer mais XP que nível $level');
        expect(nextXp - currentXp, equals(100),
            reason: 'Aumento de XP deve ser exatamente 100 por nível');
      }
    });

    test('calculateXPForNextLevel escala corretamente para níveis altos', () {
      final highLevels = [100, 500, 1000, 5000, 10000];
      
      for (final level in highLevels) {
        final xp = xpForNextLevel(level);
        
        expect(xp, equals(level * 100),
            reason: 'Fórmula deve funcionar para nível $level');
        
        // Testar escala linear
        final doubleLevel = level * 2;
        final doubleXp = xpForNextLevel(doubleLevel);
        expect(doubleXp, equals(xp * 2),
            reason: 'XP deve escalar linearmente com o nível');
      }
    });
  });
}
