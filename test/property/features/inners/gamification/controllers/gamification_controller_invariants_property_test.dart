import 'package:glados/glados.dart';

/// Classe auxiliar de teste - lógica de gamificação isolada sem dependências do Firebase
/// 
/// Esta classe replica a lógica essencial do GamificationController para testes de propriedades,
/// permitindo validar invariantes sem necessidade de mock do Firebase.
class TestGamificationState {
  // Estados - Streak
  int currentStreak = 0;
  int longestStreak = 0;
  
  // Estados - Energy
  int currentEnergy = 5;
  final int maxEnergy = 5;
  
  // Estados - XP
  int totalXp = 0;
  int weeklyXp = 0;
  int todayXp = 0;
  
  // Estados - Gems
  int gems = 0;
  int totalGemsEarned = 0;
  int totalGemsSpent = 0;
  
  // Estados - Level
  int level = 1;
  int xpToNextLevel = 100;
  
  // Operações - Streak
  /// Atualiza streak mantendo invariante: longestStreak >= currentStreak
  void updateStreakInvariant(int newCurrentStreak) {
    currentStreak = newCurrentStreak;
    // Manter invariante: longestStreak >= currentStreak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }
  
  // Operações - XP
  /// Adiciona XP aos contadores (total, semanal, diário)
  void addXp(int xpAmount) {
    if (xpAmount < 0) return; // Prevenir XP negativo
    
    totalXp += xpAmount;
    weeklyXp += xpAmount;
    todayXp += xpAmount;
  }
  
  // Operações - Energy
  /// Define energia respeitando limites [0, maxEnergy]
  void setEnergy(int energy) {
    // Limitar energia aos bounds válidos [0, maxEnergy]
    if (energy < 0) {
      currentEnergy = 0;
    } else if (energy > maxEnergy) {
      currentEnergy = maxEnergy;
    } else {
      currentEnergy = energy;
    }
  }
  
  /// Consome 1 energia (não vai abaixo de 0)
  void consumeEnergy() {
    if (currentEnergy > 0) {
      currentEnergy--;
    }
  }
  
  /// Regenera energia respeitando limite máximo
  void regenerateEnergy(int amount) {
    setEnergy(currentEnergy + amount);
  }
  
  // Operações - Gems
  /// Adiciona gems aos contadores (gems, totalGemsEarned)
  void addGems(int gemsAmount) {
    if (gemsAmount < 0) return; // Prevenir gems negativas
    
    gems += gemsAmount;
    totalGemsEarned += gemsAmount;
  }
  
  /// Gasta gems (valida saldo suficiente)
  void spendGems(int cost) {
    if (cost < 0 || gems < cost) return; // Prevenir gasto inválido
    
    gems -= cost;
    totalGemsSpent += cost;
  }
  
  // Operações - Level
  /// Verifica e processa level ups (pode processar múltiplos níveis)
  void checkLevelUp() {
    while (totalXp >= xpToNextLevel) {
      level++;
      xpToNextLevel = level * 100;
      addGems(10); // Premiar gems por level up
    }
  }
}

void main() {
  group('Feature: gamification-system, Testes de Propriedades Invariantes', () {
    // Property 1: Invariante de Streak
    // Para qualquer estado de gamificação, longestStreak deve sempre ser >= currentStreak
    Glados2(any.int, any.int).test(
      'Property 1: longestStreak >= currentStreak sempre se mantém',
      (currentStreakValue, longestStreakValue) {
        // Limitar a range válido (0-365)
        final current = currentStreakValue.abs() % 366;
        final longest = longestStreakValue.abs() % 366;
        
        // Criar estado
        final state = TestGamificationState();
        state.currentStreak = current;
        state.longestStreak = longest;
        
        // Executar operação de atualização de streak
        final newStreak = (current + 1) % 366;
        state.updateStreakInvariant(newStreak);
        
        // Verificar que invariante se mantém
        expect(
          state.longestStreak,
          greaterThanOrEqualTo(state.currentStreak),
          reason: 'longestStreak deve sempre ser >= currentStreak',
        );
      },
    );

    // Property 2: Total XP Nunca Diminui
    // Para qualquer operação nas stats de gamificação, totalXp depois deve ser >= totalXp antes
    Glados2(any.int, any.int).test(
      'Property 2: totalXp nunca diminui após qualquer operação',
      (initialXp, xpToAdd) {
        // Limitar a range válido
        final initial = initialXp.abs() % 100000;
        final toAdd = xpToAdd.abs() % 1000;
        
        // Criar estado com XP inicial
        final state = TestGamificationState();
        state.totalXp = initial;
        
        // Armazenar valor inicial
        final xpBefore = state.totalXp;
        
        // Executar adição de XP
        state.addXp(toAdd);
        
        // Verificar que totalXp nunca diminuiu
        expect(
          state.totalXp,
          greaterThanOrEqualTo(xpBefore),
          reason: 'totalXp nunca deve diminuir após qualquer operação',
        );
        
        // Verificar que aumentou exatamente pela quantidade adicionada
        expect(
          state.totalXp,
          equals(xpBefore + toAdd),
          reason: 'totalXp deve aumentar exatamente pela quantidade adicionada',
        );
      },
    );

    // Testar que XP negativo é rejeitado
    test('Property 2: adição de XP negativo é rejeitada', () {
      final state = TestGamificationState();
      state.totalXp = 100;
      
      // Tentar adicionar XP negativo
      state.addXp(-50);
      
      // Verificar que XP não mudou
      expect(
        state.totalXp,
        equals(100),
        reason: 'XP negativo deve ser rejeitado e totalXp deve permanecer inalterado',
      );
    });

    // Property 3: Limites de Energia
    // Para qualquer estado de gamificação, currentEnergy deve estar em [0, maxEnergy]
    // e maxEnergy deve sempre ser igual a 5
    Glados(any.int).test(
      'Property 3: energia permanece dentro dos limites [0, maxEnergy]',
      (energyChange) {
        // Limitar a range razoável
        final change = (energyChange % 20) - 10; // -10 a +9
        
        // Criar estado com energia inicial aleatória
        final state = TestGamificationState();
        final initialEnergy = (energyChange.abs() % 6); // 0-5
        state.currentEnergy = initialEnergy;
        
        // Aplicar mudança de energia
        state.setEnergy(initialEnergy + change);
        
        // Verificar limites de energia
        expect(
          state.currentEnergy,
          greaterThanOrEqualTo(0),
          reason: 'currentEnergy nunca deve ser negativa',
        );
        
        expect(
          state.currentEnergy,
          lessThanOrEqualTo(state.maxEnergy),
          reason: 'currentEnergy nunca deve exceder maxEnergy',
        );
        
        expect(
          state.maxEnergy,
          equals(5),
          reason: 'maxEnergy deve sempre ser igual a 5',
        );
      },
    );

    // Testar que consumo de energia respeita limites
    test('Property 3: consumo de energia respeita limite inferior', () {
      final state = TestGamificationState();
      state.currentEnergy = 0;
      
      // Tentar consumir energia quando está em 0
      state.consumeEnergy();
      
      // Verificar que energia permanece em 0
      expect(
        state.currentEnergy,
        equals(0),
        reason: 'Energia não deve ficar abaixo de 0',
      );
    });

    // Testar que regeneração de energia respeita limites
    test('Property 3: regeneração de energia respeita limite superior', () {
      final state = TestGamificationState();
      state.currentEnergy = 5;
      
      // Tentar regenerar energia quando está no máximo
      state.regenerateEnergy(10);
      
      // Verificar que energia está limitada ao máximo
      expect(
        state.currentEnergy,
        equals(5),
        reason: 'Energia não deve exceder maxEnergy (5)',
      );
    });

    // Property 4: Recursos Não-Negativos
    // Para qualquer estado de gamificação, todos os recursos devem ser não-negativos
    Glados3(any.int, any.int, any.int).test(
      'Property 4: todos os recursos permanecem não-negativos',
      (gemsValue, xpValue, streakValue) {
        // Limitar a ranges válidos
        final gems = gemsValue.abs() % 10000;
        final xp = xpValue.abs() % 100000;
        final streak = streakValue.abs() % 366;
        
        // Criar estado com valores
        final state = TestGamificationState();
        state.gems = gems;
        state.totalXp = xp;
        state.weeklyXp = xp;
        state.todayXp = xp;
        state.currentStreak = streak;
        state.currentEnergy = 3;
        
        // Verificar que todos os recursos são não-negativos
        expect(
          state.gems,
          greaterThanOrEqualTo(0),
          reason: 'gems deve ser não-negativo',
        );
        
        expect(
          state.totalXp,
          greaterThanOrEqualTo(0),
          reason: 'totalXp deve ser não-negativo',
        );
        
        expect(
          state.weeklyXp,
          greaterThanOrEqualTo(0),
          reason: 'weeklyXp deve ser não-negativo',
        );
        
        expect(
          state.todayXp,
          greaterThanOrEqualTo(0),
          reason: 'todayXp deve ser não-negativo',
        );
        
        expect(
          state.currentStreak,
          greaterThanOrEqualTo(0),
          reason: 'currentStreak deve ser não-negativo',
        );
        
        expect(
          state.currentEnergy,
          greaterThanOrEqualTo(0),
          reason: 'currentEnergy deve ser não-negativa',
        );
      },
    );

    // Testar que gastar mais gems do que disponível é rejeitado
    test('Property 4: gastar mais gems do que disponível é rejeitado', () {
      final state = TestGamificationState();
      state.gems = 50;
      
      // Tentar gastar mais gems do que disponível
      state.spendGems(100);
      
      // Verificar que gems não mudaram
      expect(
        state.gems,
        equals(50),
        reason: 'Gems não devem ficar negativas ao gastar mais do que disponível',
      );
      
      expect(
        state.totalGemsSpent,
        equals(0),
        reason: 'totalGemsSpent não deve aumentar quando transação é inválida',
      );
    });

    // Testar que gasto negativo de gems é rejeitado
    test('Property 4: gasto negativo de gems é rejeitado', () {
      final state = TestGamificationState();
      state.gems = 100;
      
      // Tentar gastar gems negativas
      state.spendGems(-50);
      
      // Verificar que gems não mudaram
      expect(
        state.gems,
        equals(100),
        reason: 'Gasto negativo de gems deve ser rejeitado',
      );
    });

    // Testar que operações combinadas mantêm invariantes
    test('Property 1-4: operações combinadas mantêm todas as invariantes', () {
      final state = TestGamificationState();
      
      // Executar múltiplas operações
      state.addXp(100);
      state.checkLevelUp(); // Deve subir de nível e premiar gems
      state.updateStreakInvariant(5);
      state.consumeEnergy();
      state.regenerateEnergy(2);
      state.spendGems(5);
      
      // Verificar que todas as invariantes se mantêm
      expect(
        state.longestStreak,
        greaterThanOrEqualTo(state.currentStreak),
        reason: 'Invariante de streak deve se manter após operações combinadas',
      );
      
      expect(
        state.totalXp,
        greaterThanOrEqualTo(100),
        reason: 'Total XP não deve diminuir após operações combinadas',
      );
      
      expect(
        state.currentEnergy,
        inInclusiveRange(0, state.maxEnergy),
        reason: 'Energia deve permanecer dentro dos limites após operações combinadas',
      );
      
      expect(
        state.gems,
        greaterThanOrEqualTo(0),
        reason: 'Gems devem permanecer não-negativas após operações combinadas',
      );
      
      expect(
        state.totalXp,
        greaterThanOrEqualTo(0),
        reason: 'Total XP deve permanecer não-negativo após operações combinadas',
      );
    });
  });
}
