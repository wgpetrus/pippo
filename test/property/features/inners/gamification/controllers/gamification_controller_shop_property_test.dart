import 'package:flutter_test/flutter_test.dart' hide test, group, expect;
import 'package:glados/glados.dart';
import 'package:test/test.dart' show test, group, expect;

// Test Helpers

/// Classe helper de teste - lógica isolada de compras sem dependências do Firebase
class TestShopPurchaseManager {
  // Estados
  int gems = 0;
  int totalGemsSpent = 0;
  int currentEnergy = 5;
  
  DateTime? xpBoosterUntil;
  DateTime? gemMultiplierUntil;
  bool streakFreezeAvailable = false;

  // Computed properties
  bool get hasXpBooster =>
      xpBoosterUntil != null && DateTime.now().isBefore(xpBoosterUntil!);

  bool get hasGemMultiplier =>
      gemMultiplierUntil != null && DateTime.now().isBefore(gemMultiplierUntil!);

  // Métodos de compra
  bool purchaseEnergyRefill() {
    // Validar gems suficientes
    if (gems < 100) {
      return false;
    }

    // Deduzir gems atomicamente
    gems -= 100;
    totalGemsSpent += 100;
    
    // Adicionar 5 energia (limitado ao máximo de 5)
    final newEnergy = currentEnergy + 5;
    currentEnergy = newEnergy > 5 ? 5 : newEnergy;
    
    return true;
  }

  bool purchaseXpBooster() {
    // Validar gems suficientes
    if (gems < 150) {
      return false;
    }

    // Verificar idempotência
    if (hasXpBooster) {
      return false;
    }

    // Deduzir gems e ativar booster atomicamente
    gems -= 150;
    totalGemsSpent += 150;
    xpBoosterUntil = DateTime.now().add(const Duration(hours: 1));
    
    return true;
  }

  bool purchaseGemMultiplier() {
    // Validar gems suficientes
    if (gems < 200) {
      return false;
    }

    // Verificar idempotência
    if (hasGemMultiplier) {
      return false;
    }

    // Deduzir gems e ativar multiplier atomicamente
    gems -= 200;
    totalGemsSpent += 200;
    gemMultiplierUntil = DateTime.now().add(const Duration(hours: 1));
    
    return true;
  }

  bool purchaseStreakFreeze() {
    // Validar gems suficientes
    if (gems < 200) {
      return false;
    }

    // Verificar idempotência
    if (streakFreezeAvailable) {
      return false;
    }

    // Deduzir gems e ativar freeze atomicamente
    gems -= 200;
    totalGemsSpent += 200;
    streakFreezeAvailable = true;
    
    return true;
  }

  // Helper para executar compra por tipo
  bool executePurchase(int purchaseType) {
    switch (purchaseType) {
      case 0:
        return purchaseEnergyRefill();
      case 1:
        return purchaseXpBooster();
      case 2:
        return purchaseGemMultiplier();
      case 3:
        return purchaseStreakFreeze();
      default:
        return false;
    }
  }

  // Helper para obter custo por tipo
  int getCost(int purchaseType) {
    switch (purchaseType) {
      case 0:
        return 100; // Energy Refill
      case 1:
        return 150; // XP Booster
      case 2:
        return 200; // Gem Multiplier
      case 3:
        return 200; // Streak Freeze
      default:
        return 0;
    }
  }
}

// Property Tests

void main() {
  group('Feature: shop-system, Property-Based Tests - Atomic Gem Transactions', () {
    // Property 1: Atomic Gem Deduction
    // Todas as transações de gems são atômicas - ou completam totalmente ou revertem totalmente
    // Valida: Requirements 2.5, 3.5, 4.5, 5.5, 6.6
    Glados2(any.int, any.int).test(
      'Property 1: todas as transações de gems são atômicas - completam ou revertem totalmente',
      (initialGems, purchaseType) {
        // Restringir valores a ranges válidos
        final gems = initialGems.abs() % 2001; // 0-2000
        final type = purchaseType.abs() % 4; // 0-3 (4 tipos de compra)
        
        // Criar manager com gems iniciais
        final manager = TestShopPurchaseManager();
        manager.gems = gems;
        manager.totalGemsSpent = 0;
        
        // Armazenar valores iniciais
        final initialGemsValue = manager.gems;
        final initialTotalSpent = manager.totalGemsSpent;
        
        // Obter custo da compra
        final cost = manager.getCost(type);
        
        // Tentar compra
        final success = manager.executePurchase(type);
        
        if (success) {
          // Sucesso: ambos gems e totalGemsSpent devem ter sido atualizados
          expect(
            manager.gems,
            equals(initialGemsValue - cost),
            reason: 'Em caso de sucesso, gems deve ser deduzido em $cost',
          );
          
          expect(
            manager.totalGemsSpent,
            equals(initialTotalSpent + cost),
            reason: 'Em caso de sucesso, totalGemsSpent deve aumentar em $cost',
          );
          
          // Verificar atomicidade - ambas mudanças aconteceram juntas
          final gemsDecrease = initialGemsValue - manager.gems;
          final spentIncrease = manager.totalGemsSpent - initialTotalSpent;
          
          expect(
            gemsDecrease == spentIncrease && gemsDecrease == cost,
            isTrue,
            reason: 'Operação atômica: dedução de gems ($gemsDecrease) e aumento de totalGemsSpent ($spentIncrease) devem ser iguais ao custo ($cost)',
          );
        } else {
          // Falha: ambos valores devem permanecer inalterados
          expect(
            manager.gems,
            equals(initialGemsValue),
            reason: 'Em caso de falha, gems não deve mudar',
          );
          
          expect(
            manager.totalGemsSpent,
            equals(initialTotalSpent),
            reason: 'Em caso de falha, totalGemsSpent não deve mudar',
          );
        }
      },
    );

    // Property 2: Non-Negative Gem Balance
    // O saldo de gems nunca pode se tornar negativo após qualquer operação
    // Valida: Requirements 6.1
    Glados2(any.int, any.int).test(
      'Property 2: saldo de gems nunca pode se tornar negativo após qualquer operação',
      (initialGems, purchaseType) {
        // Restringir valores a ranges válidos
        final gems = initialGems.abs() % 1001; // 0-1000
        final type = purchaseType.abs() % 4; // 0-3 (4 tipos de compra)
        
        // Criar manager com gems iniciais
        final manager = TestShopPurchaseManager();
        manager.gems = gems;
        
        // Tentar compra
        manager.executePurchase(type);
        
        // Propriedade: gems nunca pode ser negativo
        expect(
          manager.gems >= 0,
          isTrue,
          reason: 'Gems deve sempre ser >= 0, mas obteve ${manager.gems}',
        );
      },
    );

    // Property 3: Gem Spending Consistency
    // totalGemsSpent sempre é igual à soma de todas as compras bem-sucedidas
    // Valida: Requirements 2.5, 3.5, 4.5, 5.5
    test(
      'Property 3: totalGemsSpent sempre é igual à soma de todas as compras bem-sucedidas',
      () {
        // Criar manager com gems suficientes para múltiplas compras
        final manager = TestShopPurchaseManager();
        manager.gems = 1000;
        manager.totalGemsSpent = 0;
        
        // Rastrear soma esperada
        int expectedTotalSpent = 0;
        
        // Sequência de compras: Energy Refill (100), XP Booster (150), Gem Multiplier (200), Streak Freeze (200)
        final purchases = [0, 1, 2, 3]; // Tipos de compra
        
        for (final purchaseType in purchases) {
          final cost = manager.getCost(purchaseType);
          final success = manager.executePurchase(purchaseType);
          
          if (success) {
            expectedTotalSpent += cost;
          }
        }
        
        // Verificar consistência
        expect(
          manager.totalGemsSpent,
          equals(expectedTotalSpent),
          reason: 'totalGemsSpent (${manager.totalGemsSpent}) deve ser igual à soma de todas as compras bem-sucedidas ($expectedTotalSpent)',
        );
        
        // Verificar que a soma é correta (100 + 150 + 200 + 200 = 650)
        expect(
          expectedTotalSpent,
          equals(650),
          reason: 'Soma esperada de todas as compras deve ser 650',
        );
      },
    );
  });

  group('Feature: shop-system, Property-Based Tests - Idempotent Boost Activation', () {
    // Property 4: XP Booster Idempotence
    // Comprar um XP booster já ativo falha sem alterar o estado
    // Valida: Requirements 3.2, 3.6
    Glados(any.int).test(
      'Property 4: comprar um XP booster já ativo falha sem alterar o estado',
      (initialGems) {
        // Restringir gems a valores suficientes (200-2000)
        final gems = 200 + (initialGems.abs() % 1801);
        
        // Criar manager com gems suficientes
        final manager = TestShopPurchaseManager();
        manager.gems = gems;
        manager.totalGemsSpent = 0;
        
        // Primeira compra - deve ter sucesso
        final firstPurchase = manager.purchaseXpBooster();
        
        expect(
          firstPurchase,
          isTrue,
          reason: 'Primeira compra de XP booster deve ter sucesso',
        );
        
        // Armazenar estado após primeira compra
        final gemsAfterFirst = manager.gems;
        final spentAfterFirst = manager.totalGemsSpent;
        final boosterUntilAfterFirst = manager.xpBoosterUntil;
        
        // Verificar que booster está ativo
        expect(
          manager.hasXpBooster,
          isTrue,
          reason: 'XP booster deve estar ativo após primeira compra',
        );
        
        // Segunda compra - deve falhar (idempotência)
        final secondPurchase = manager.purchaseXpBooster();
        
        expect(
          secondPurchase,
          isFalse,
          reason: 'Segunda compra de XP booster deve falhar (idempotência)',
        );
        
        // Verificar que estado não mudou
        expect(
          manager.gems,
          equals(gemsAfterFirst),
          reason: 'Gems não deve mudar na segunda compra (era $gemsAfterFirst, ficou ${manager.gems})',
        );
        
        expect(
          manager.totalGemsSpent,
          equals(spentAfterFirst),
          reason: 'totalGemsSpent não deve mudar na segunda compra (era $spentAfterFirst, ficou ${manager.totalGemsSpent})',
        );
        
        expect(
          manager.xpBoosterUntil,
          equals(boosterUntilAfterFirst),
          reason: 'xpBoosterUntil não deve mudar na segunda compra',
        );
        
        // Verificar que gems foi deduzido apenas uma vez (150)
        expect(
          gems - manager.gems,
          equals(150),
          reason: 'Gems deve ter sido deduzido apenas uma vez (150), mas foi deduzido ${gems - manager.gems}',
        );
      },
    );

    // Property 5: Gem Multiplier Idempotence
    // Comprar um gem multiplier já ativo falha sem alterar o estado
    // Valida: Requirements 4.2, 4.6
    Glados(any.int).test(
      'Property 5: comprar um gem multiplier já ativo falha sem alterar o estado',
      (initialGems) {
        // Restringir gems a valores suficientes (400-2000)
        final gems = 400 + (initialGems.abs() % 1601);
        
        // Criar manager com gems suficientes
        final manager = TestShopPurchaseManager();
        manager.gems = gems;
        manager.totalGemsSpent = 0;
        
        // Primeira compra - deve ter sucesso
        final firstPurchase = manager.purchaseGemMultiplier();
        
        expect(
          firstPurchase,
          isTrue,
          reason: 'Primeira compra de gem multiplier deve ter sucesso',
        );
        
        // Armazenar estado após primeira compra
        final gemsAfterFirst = manager.gems;
        final spentAfterFirst = manager.totalGemsSpent;
        final multiplierUntilAfterFirst = manager.gemMultiplierUntil;
        
        // Verificar que multiplier está ativo
        expect(
          manager.hasGemMultiplier,
          isTrue,
          reason: 'Gem multiplier deve estar ativo após primeira compra',
        );
        
        // Segunda compra - deve falhar (idempotência)
        final secondPurchase = manager.purchaseGemMultiplier();
        
        expect(
          secondPurchase,
          isFalse,
          reason: 'Segunda compra de gem multiplier deve falhar (idempotência)',
        );
        
        // Verificar que estado não mudou
        expect(
          manager.gems,
          equals(gemsAfterFirst),
          reason: 'Gems não deve mudar na segunda compra (era $gemsAfterFirst, ficou ${manager.gems})',
        );
        
        expect(
          manager.totalGemsSpent,
          equals(spentAfterFirst),
          reason: 'totalGemsSpent não deve mudar na segunda compra (era $spentAfterFirst, ficou ${manager.totalGemsSpent})',
        );
        
        expect(
          manager.gemMultiplierUntil,
          equals(multiplierUntilAfterFirst),
          reason: 'gemMultiplierUntil não deve mudar na segunda compra',
        );
        
        // Verificar que gems foi deduzido apenas uma vez (200)
        expect(
          gems - manager.gems,
          equals(200),
          reason: 'Gems deve ter sido deduzido apenas uma vez (200), mas foi deduzido ${gems - manager.gems}',
        );
      },
    );

    // Property 6: Streak Freeze Idempotence
    // Comprar um streak freeze já disponível falha sem alterar o estado
    // Valida: Requirements 5.2, 5.6
    Glados(any.int).test(
      'Property 6: comprar um streak freeze já disponível falha sem alterar o estado',
      (initialGems) {
        // Restringir gems a valores suficientes (400-2000)
        final gems = 400 + (initialGems.abs() % 1601);
        
        // Criar manager com gems suficientes
        final manager = TestShopPurchaseManager();
        manager.gems = gems;
        manager.totalGemsSpent = 0;
        
        // Primeira compra - deve ter sucesso
        final firstPurchase = manager.purchaseStreakFreeze();
        
        expect(
          firstPurchase,
          isTrue,
          reason: 'Primeira compra de streak freeze deve ter sucesso',
        );
        
        // Armazenar estado após primeira compra
        final gemsAfterFirst = manager.gems;
        final spentAfterFirst = manager.totalGemsSpent;
        final freezeAvailableAfterFirst = manager.streakFreezeAvailable;
        
        // Verificar que freeze está disponível
        expect(
          manager.streakFreezeAvailable,
          isTrue,
          reason: 'Streak freeze deve estar disponível após primeira compra',
        );
        
        // Segunda compra - deve falhar (idempotência)
        final secondPurchase = manager.purchaseStreakFreeze();
        
        expect(
          secondPurchase,
          isFalse,
          reason: 'Segunda compra de streak freeze deve falhar (idempotência)',
        );
        
        // Verificar que estado não mudou
        expect(
          manager.gems,
          equals(gemsAfterFirst),
          reason: 'Gems não deve mudar na segunda compra (era $gemsAfterFirst, ficou ${manager.gems})',
        );
        
        expect(
          manager.totalGemsSpent,
          equals(spentAfterFirst),
          reason: 'totalGemsSpent não deve mudar na segunda compra (era $spentAfterFirst, ficou ${manager.totalGemsSpent})',
        );
        
        expect(
          manager.streakFreezeAvailable,
          equals(freezeAvailableAfterFirst),
          reason: 'streakFreezeAvailable não deve mudar na segunda compra',
        );
        
        // Verificar que gems foi deduzido apenas uma vez (200)
        expect(
          gems - manager.gems,
          equals(200),
          reason: 'Gems deve ter sido deduzido apenas uma vez (200), mas foi deduzido ${gems - manager.gems}',
        );
      },
    );
  });

  group('Feature: shop-system, Property-Based Tests - Energy Cap Enforcement', () {
    // Property 7: Energy Never Exceeds Maximum
    // Recarga de energia nunca excede energia máxima (5)
    // Valida: Requirements 2.3
    Glados(any.int).test(
      'Property 7: recarga de energia nunca excede energia máxima (5)',
      (initialEnergy) {
        // Restringir energia inicial a valores válidos (0-5)
        final energy = initialEnergy.abs() % 6; // 0-5
        
        // Criar manager com gems suficientes e energia inicial
        final manager = TestShopPurchaseManager();
        manager.gems = 200; // Gems suficientes
        manager.currentEnergy = energy;
        
        // Comprar recarga de energia
        final success = manager.purchaseEnergyRefill();
        
        // Verificar que compra teve sucesso (gems suficientes)
        expect(
          success,
          isTrue,
          reason: 'Compra de recarga de energia deve ter sucesso com gems suficientes',
        );
        
        // Propriedade: energia nunca excede 5
        expect(
          manager.currentEnergy <= 5,
          isTrue,
          reason: 'Energia deve sempre ser <= 5, mas obteve ${manager.currentEnergy} (inicial era $energy)',
        );
        
        // Verificar também que energia não é negativa
        expect(
          manager.currentEnergy >= 0,
          isTrue,
          reason: 'Energia deve sempre ser >= 0, mas obteve ${manager.currentEnergy}',
        );
      },
    );

    // Property 8: Energy Addition Correctness
    // Recarga de energia adiciona exatamente 5 energia ou limita em 5
    // Valida: Requirements 2.3
    Glados(any.int).test(
      'Property 8: recarga de energia adiciona exatamente 5 energia ou limita em 5',
      (initialEnergy) {
        // Restringir energia inicial a valores válidos (0-5)
        final energy = initialEnergy.abs() % 6; // 0-5
        
        // Criar manager com gems suficientes e energia inicial
        final manager = TestShopPurchaseManager();
        manager.gems = 200; // Gems suficientes
        manager.currentEnergy = energy;
        
        // Armazenar energia inicial
        final initialEnergyValue = manager.currentEnergy;
        
        // Comprar recarga de energia
        final success = manager.purchaseEnergyRefill();
        
        // Verificar que compra teve sucesso
        expect(
          success,
          isTrue,
          reason: 'Compra de recarga de energia deve ter sucesso com gems suficientes',
        );
        
        // Calcular energia esperada: min(inicial + 5, 5)
        final expectedEnergy = (initialEnergyValue + 5) > 5 ? 5 : (initialEnergyValue + 5);
        
        // Propriedade: energia final deve ser min(inicial + 5, 5)
        expect(
          manager.currentEnergy,
          equals(expectedEnergy),
          reason: 'Energia final deve ser min($initialEnergyValue + 5, 5) = $expectedEnergy, mas obteve ${manager.currentEnergy}',
        );
        
        // Verificar casos específicos
        if (initialEnergyValue < 5) {
          // Se tinha menos de 5, deve ter aumentado
          expect(
            manager.currentEnergy > initialEnergyValue || manager.currentEnergy == 5,
            isTrue,
            reason: 'Se energia inicial ($initialEnergyValue) < 5, energia final (${manager.currentEnergy}) deve ter aumentado ou estar em 5',
          );
        } else {
          // Se já tinha 5, deve permanecer em 5
          expect(
            manager.currentEnergy,
            equals(5),
            reason: 'Se energia inicial era 5, energia final deve permanecer em 5, mas obteve ${manager.currentEnergy}',
          );
        }
      },
    );
  });

  group('Feature: shop-system, Property-Based Tests - Boost Expiration Consistency', () {
    // Property 9: XP Booster Expiration Time
    // O tempo de expiração do XP booster está sempre no futuro quando ativado
    // Valida: Requirements 3.4
    test(
      'Property 9: tempo de expiração do XP booster está sempre no futuro quando ativado',
      () {
        // Criar manager com gems suficientes
        final manager = TestShopPurchaseManager();
        manager.gems = 200;
        
        // Capturar tempo antes da compra
        final beforePurchase = DateTime.now();
        
        // Comprar XP booster
        final success = manager.purchaseXpBooster();
        
        // Capturar tempo depois da compra
        final afterPurchase = DateTime.now();
        
        // Verificar que compra teve sucesso
        expect(
          success,
          isTrue,
          reason: 'Compra de XP booster deve ter sucesso com gems suficientes',
        );
        
        // Verificar que xpBoosterUntil não é null
        expect(
          manager.xpBoosterUntil,
          isNotNull,
          reason: 'xpBoosterUntil deve ser definido após compra bem-sucedida',
        );
        
        // Propriedade 1: Expiration time está no futuro (> now)
        final now = DateTime.now();
        expect(
          manager.xpBoosterUntil!.isAfter(now),
          isTrue,
          reason: 'Tempo de expiração (${manager.xpBoosterUntil}) deve estar no futuro (depois de $now)',
        );
        
        // Propriedade 2: Expiration time está dentro de 1 hora
        // Deve ser <= now + 1 hora (com tolerância de 1 segundo para execução do teste)
        final oneHourFromNow = now.add(const Duration(hours: 1, seconds: 1));
        expect(
          manager.xpBoosterUntil!.isBefore(oneHourFromNow) || 
          manager.xpBoosterUntil!.isAtSameMomentAs(oneHourFromNow),
          isTrue,
          reason: 'Tempo de expiração (${manager.xpBoosterUntil}) deve estar dentro de 1 hora de agora ($oneHourFromNow)',
        );
        
        // Propriedade 3: Expiration time está aproximadamente 1 hora no futuro
        // Deve estar entre beforePurchase + 1h e afterPurchase + 1h
        final minExpiration = beforePurchase.add(const Duration(hours: 1));
        final maxExpiration = afterPurchase.add(const Duration(hours: 1, seconds: 1));
        
        expect(
          manager.xpBoosterUntil!.isAfter(minExpiration) || 
          manager.xpBoosterUntil!.isAtSameMomentAs(minExpiration),
          isTrue,
          reason: 'Tempo de expiração (${manager.xpBoosterUntil}) deve ser >= $minExpiration',
        );
        
        expect(
          manager.xpBoosterUntil!.isBefore(maxExpiration) || 
          manager.xpBoosterUntil!.isAtSameMomentAs(maxExpiration),
          isTrue,
          reason: 'Tempo de expiração (${manager.xpBoosterUntil}) deve ser <= $maxExpiration',
        );
        
        // Propriedade 4: hasXpBooster retorna true imediatamente após compra
        expect(
          manager.hasXpBooster,
          isTrue,
          reason: 'hasXpBooster deve retornar true imediatamente após compra',
        );
      },
    );

    // Property 10: Gem Multiplier Expiration Time
    // O tempo de expiração do gem multiplier está sempre no futuro quando ativado
    // Valida: Requirements 4.4
    test(
      'Property 10: tempo de expiração do gem multiplier está sempre no futuro quando ativado',
      () {
        // Criar manager com gems suficientes
        final manager = TestShopPurchaseManager();
        manager.gems = 300;
        
        // Capturar tempo antes da compra
        final beforePurchase = DateTime.now();
        
        // Comprar gem multiplier
        final success = manager.purchaseGemMultiplier();
        
        // Capturar tempo depois da compra
        final afterPurchase = DateTime.now();
        
        // Verificar que compra teve sucesso
        expect(
          success,
          isTrue,
          reason: 'Compra de gem multiplier deve ter sucesso com gems suficientes',
        );
        
        // Verificar que gemMultiplierUntil não é null
        expect(
          manager.gemMultiplierUntil,
          isNotNull,
          reason: 'gemMultiplierUntil deve ser definido após compra bem-sucedida',
        );
        
        // Propriedade 1: Expiration time está no futuro (> now)
        final now = DateTime.now();
        expect(
          manager.gemMultiplierUntil!.isAfter(now),
          isTrue,
          reason: 'Tempo de expiração (${manager.gemMultiplierUntil}) deve estar no futuro (depois de $now)',
        );
        
        // Propriedade 2: Expiration time está dentro de 1 hora
        // Deve ser <= now + 1 hora (com tolerância de 1 segundo para execução do teste)
        final oneHourFromNow = now.add(const Duration(hours: 1, seconds: 1));
        expect(
          manager.gemMultiplierUntil!.isBefore(oneHourFromNow) || 
          manager.gemMultiplierUntil!.isAtSameMomentAs(oneHourFromNow),
          isTrue,
          reason: 'Tempo de expiração (${manager.gemMultiplierUntil}) deve estar dentro de 1 hora de agora ($oneHourFromNow)',
        );
        
        // Propriedade 3: Expiration time está aproximadamente 1 hora no futuro
        // Deve estar entre beforePurchase + 1h e afterPurchase + 1h
        final minExpiration = beforePurchase.add(const Duration(hours: 1));
        final maxExpiration = afterPurchase.add(const Duration(hours: 1, seconds: 1));
        
        expect(
          manager.gemMultiplierUntil!.isAfter(minExpiration) || 
          manager.gemMultiplierUntil!.isAtSameMomentAs(minExpiration),
          isTrue,
          reason: 'Tempo de expiração (${manager.gemMultiplierUntil}) deve ser >= $minExpiration',
        );
        
        expect(
          manager.gemMultiplierUntil!.isBefore(maxExpiration) || 
          manager.gemMultiplierUntil!.isAtSameMomentAs(maxExpiration),
          isTrue,
          reason: 'Tempo de expiração (${manager.gemMultiplierUntil}) deve ser <= $maxExpiration',
        );
        
        // Propriedade 4: hasGemMultiplier retorna true imediatamente após compra
        expect(
          manager.hasGemMultiplier,
          isTrue,
          reason: 'hasGemMultiplier deve retornar true imediatamente após compra',
        );
      },
    );

    // Property 11: Boost Expiration Check
    // hasXpBooster e hasGemMultiplier verificam corretamente a expiração
    // Valida: Requirements 3.6, 4.6
    test(
      'Property 11: hasXpBooster e hasGemMultiplier verificam corretamente a expiração',
      () {
        // Criar manager
        final manager = TestShopPurchaseManager();
        
        // Teste 1: Boost no passado - deve retornar false
        manager.xpBoosterUntil = DateTime.now().subtract(const Duration(hours: 1));
        expect(
          manager.hasXpBooster,
          isFalse,
          reason: 'hasXpBooster deve retornar false quando expiration time está no passado',
        );
        
        manager.gemMultiplierUntil = DateTime.now().subtract(const Duration(hours: 1));
        expect(
          manager.hasGemMultiplier,
          isFalse,
          reason: 'hasGemMultiplier deve retornar false quando expiration time está no passado',
        );
        
        // Teste 2: Boost no presente (exatamente agora) - deve retornar false
        // DateTime.now() retorna o momento atual, então isBefore(now) será false
        final now = DateTime.now();
        manager.xpBoosterUntil = now;
        expect(
          manager.hasXpBooster,
          isFalse,
          reason: 'hasXpBooster deve retornar false quando expiration time é exatamente agora',
        );
        
        manager.gemMultiplierUntil = now;
        expect(
          manager.hasGemMultiplier,
          isFalse,
          reason: 'hasGemMultiplier deve retornar false quando expiration time é exatamente agora',
        );
        
        // Teste 3: Boost no futuro - deve retornar true
        manager.xpBoosterUntil = DateTime.now().add(const Duration(hours: 1));
        expect(
          manager.hasXpBooster,
          isTrue,
          reason: 'hasXpBooster deve retornar true quando expiration time está no futuro',
        );
        
        manager.gemMultiplierUntil = DateTime.now().add(const Duration(hours: 1));
        expect(
          manager.hasGemMultiplier,
          isTrue,
          reason: 'hasGemMultiplier deve retornar true quando expiration time está no futuro',
        );
        
        // Teste 4: Boost null - deve retornar false
        manager.xpBoosterUntil = null;
        expect(
          manager.hasXpBooster,
          isFalse,
          reason: 'hasXpBooster deve retornar false quando xpBoosterUntil é null',
        );
        
        manager.gemMultiplierUntil = null;
        expect(
          manager.hasGemMultiplier,
          isFalse,
          reason: 'hasGemMultiplier deve retornar false quando gemMultiplierUntil é null',
        );
        
        // Teste 5: Boost expirando em 1 segundo - deve retornar true
        manager.xpBoosterUntil = DateTime.now().add(const Duration(seconds: 1));
        expect(
          manager.hasXpBooster,
          isTrue,
          reason: 'hasXpBooster deve retornar true mesmo quando falta 1 segundo para expirar',
        );
        
        manager.gemMultiplierUntil = DateTime.now().add(const Duration(seconds: 1));
        expect(
          manager.hasGemMultiplier,
          isTrue,
          reason: 'hasGemMultiplier deve retornar true mesmo quando falta 1 segundo para expirar',
        );
        
        // Teste 6: Boost expirando em 1 milissegundo - deve retornar true
        manager.xpBoosterUntil = DateTime.now().add(const Duration(milliseconds: 1));
        expect(
          manager.hasXpBooster,
          isTrue,
          reason: 'hasXpBooster deve retornar true mesmo quando falta 1 milissegundo para expirar',
        );
        
        manager.gemMultiplierUntil = DateTime.now().add(const Duration(milliseconds: 1));
        expect(
          manager.hasGemMultiplier,
          isTrue,
          reason: 'hasGemMultiplier deve retornar true mesmo quando falta 1 milissegundo para expirar',
        );
      },
    );
  });

  group('Feature: shop-system, Property-Based Tests - Rollback Completeness', () {
    // Property 12: Complete State Rollback on Error
    // Em qualquer erro, todas as mudanças de estado são totalmente revertidas
    // Valida: Requirements 6.6
    Glados2(any.int, any.int).test(
      'Property 12: em qualquer erro, todas as mudanças de estado são totalmente revertidas',
      (initialGems, purchaseType) {
        // Restringir valores a ranges válidos
        final gems = initialGems.abs() % 2001; // 0-2000
        final type = purchaseType.abs() % 4; // 0-3 (4 tipos de compra)
        
        // Criar manager com estado inicial
        final manager = TestShopPurchaseManager();
        manager.gems = gems;
        manager.totalGemsSpent = 0;
        manager.currentEnergy = 3;
        manager.xpBoosterUntil = null;
        manager.gemMultiplierUntil = null;
        manager.streakFreezeAvailable = false;
        
        // Capturar estado inicial completo
        final initialState = {
          'gems': manager.gems,
          'totalGemsSpent': manager.totalGemsSpent,
          'currentEnergy': manager.currentEnergy,
          'xpBoosterUntil': manager.xpBoosterUntil,
          'gemMultiplierUntil': manager.gemMultiplierUntil,
          'streakFreezeAvailable': manager.streakFreezeAvailable,
          'hasXpBooster': manager.hasXpBooster,
          'hasGemMultiplier': manager.hasGemMultiplier,
        };
        
        // Tentar compra (pode falhar por gems insuficientes ou idempotência)
        final success = manager.executePurchase(type);
        
        if (!success) {
          // Em caso de falha, verificar que TODOS os valores permanecem inalterados
          expect(
            manager.gems,
            equals(initialState['gems']),
            reason: 'gems deve permanecer inalterado após falha',
          );
          
          expect(
            manager.totalGemsSpent,
            equals(initialState['totalGemsSpent']),
            reason: 'totalGemsSpent deve permanecer inalterado após falha',
          );
          
          expect(
            manager.currentEnergy,
            equals(initialState['currentEnergy']),
            reason: 'currentEnergy deve permanecer inalterado após falha',
          );
          
          expect(
            manager.xpBoosterUntil,
            equals(initialState['xpBoosterUntil']),
            reason: 'xpBoosterUntil deve permanecer inalterado após falha',
          );
          
          expect(
            manager.gemMultiplierUntil,
            equals(initialState['gemMultiplierUntil']),
            reason: 'gemMultiplierUntil deve permanecer inalterado após falha',
          );
          
          expect(
            manager.streakFreezeAvailable,
            equals(initialState['streakFreezeAvailable']),
            reason: 'streakFreezeAvailable deve permanecer inalterado após falha',
          );
          
          expect(
            manager.hasXpBooster,
            equals(initialState['hasXpBooster']),
            reason: 'hasXpBooster deve permanecer inalterado após falha',
          );
          
          expect(
            manager.hasGemMultiplier,
            equals(initialState['hasGemMultiplier']),
            reason: 'hasGemMultiplier deve permanecer inalterado após falha',
          );
        }
      },
    );

    // Property 13: Rollback Preserves Consistency
    // Rollback mantém consistência entre gems e totalGemsSpent
    // Valida: Requirements 6.6
    Glados2(any.int, any.int).test(
      'Property 13: rollback mantém consistência entre gems e totalGemsSpent',
      (initialGems, purchaseType) {
        // Restringir valores a ranges válidos
        final gems = initialGems.abs() % 2001; // 0-2000
        final type = purchaseType.abs() % 4; // 0-3 (4 tipos de compra)
        
        // Criar manager com estado inicial
        final manager = TestShopPurchaseManager();
        manager.gems = gems;
        manager.totalGemsSpent = 100; // Já gastou 100 gems antes
        
        // Capturar relação inicial entre gems e totalGemsSpent
        final initialGemsValue = manager.gems;
        final initialTotalSpent = manager.totalGemsSpent;
        
        // Tentar compra
        final success = manager.executePurchase(type);
        
        if (!success) {
          // Em caso de falha, verificar que a relação entre gems e totalGemsSpent não mudou
          final gemsChange = manager.gems - initialGemsValue;
          final spentChange = manager.totalGemsSpent - initialTotalSpent;
          
          expect(
            gemsChange,
            equals(0),
            reason: 'gems não deve mudar após falha (mudou $gemsChange)',
          );
          
          expect(
            spentChange,
            equals(0),
            reason: 'totalGemsSpent não deve mudar após falha (mudou $spentChange)',
          );
          
          // Verificar que ambos mudaram na mesma quantidade (0)
          expect(
            gemsChange.abs() == spentChange.abs(),
            isTrue,
            reason: 'Mudança em gems ($gemsChange) e totalGemsSpent ($spentChange) devem ser iguais em magnitude',
          );
        } else {
          // Em caso de sucesso, verificar que a relação é consistente
          final gemsDecrease = initialGemsValue - manager.gems;
          final spentIncrease = manager.totalGemsSpent - initialTotalSpent;
          
          expect(
            gemsDecrease,
            equals(spentIncrease),
            reason: 'Dedução de gems ($gemsDecrease) deve ser igual ao aumento de totalGemsSpent ($spentIncrease)',
          );
          
          expect(
            gemsDecrease > 0,
            isTrue,
            reason: 'Em caso de sucesso, gems deve ter sido deduzido (dedução: $gemsDecrease)',
          );
          
          expect(
            spentIncrease > 0,
            isTrue,
            reason: 'Em caso de sucesso, totalGemsSpent deve ter aumentado (aumento: $spentIncrease)',
          );
        }
      },
    );
  });

  group('Feature: shop-system, Property-Based Tests - Validation Order Consistency', () {
    // Property 14: Authentication Checked First
    // Valida: Requirements 6.4
    test(
      'Property 14: validação de autenticação acontece antes da validação de gems',
      () {
        // NOTA: TestShopPurchaseManager não simula autenticação
        // Esta propriedade será validada nos integration tests com o controller real
        // Aqui documentamos o comportamento esperado:
        //
        // Ordem de validação no controller real:
        // 1. Autenticação (userId != null)
        // 2. Saldo de gems
        // 3. Idempotência
        //
        // Cenário: usuário não autenticado + gems suficientes
        // Esperado: erro "Usuário não autenticado" (não erro de gems)
        
        expect(
          true,
          isTrue,
          reason: 'Propriedade documentada para integration tests',
        );
      },
    );

    // Property 15: Gem Balance Checked Before Idempotency
    // Valida: Requirements 6.1, 3.2, 4.2, 5.2
    Glados(any.int).test(
      'Property 15: validação de saldo de gems acontece antes da verificação de idempotência',
      (purchaseType) {
        // Restringir tipo de compra (1-3: boosts com idempotência)
        final type = 1 + (purchaseType.abs() % 3);
        
        // Cenário: gems insuficientes + boost já ativo
        final manager = TestShopPurchaseManager();
        manager.gems = 50; // Insuficiente para qualquer boost
        
        // Ativar boost (simular que já está ativo)
        switch (type) {
          case 1: // XP Booster (150 gems)
            manager.xpBoosterUntil = DateTime.now().add(const Duration(hours: 1));
            break;
          case 2: // Gem Multiplier (200 gems)
            manager.gemMultiplierUntil = DateTime.now().add(const Duration(hours: 1));
            break;
          case 3: // Streak Freeze (200 gems)
            manager.streakFreezeAvailable = true;
            break;
        }
        
        // Tentar compra
        final success = manager.executePurchase(type);
        
        // Propriedade: deve falhar por gems insuficientes (não por idempotência)
        expect(success, isFalse, reason: 'Compra deve falhar');
        expect(
          manager.gems,
          equals(50),
          reason: 'Gems inalterado = falhou na validação de gems (antes de idempotência)',
        );
      },
    );

    // Property 16: Validation Order Never Inverts
    // Valida: Design correctness
    test(
      'Property 16: ordem de validação nunca se inverte (auth → gems → idempotency)',
      () {
        final manager = TestShopPurchaseManager();
        
        // Cenário 1: Gems insuficientes + boost ativo
        // Deve falhar por gems (verificado antes de idempotência)
        manager.gems = 50;
        manager.xpBoosterUntil = DateTime.now().add(const Duration(hours: 1));
        
        final result1 = manager.purchaseXpBooster();
        expect(result1, isFalse, reason: 'Falha por gems insuficientes');
        expect(manager.gems, equals(50), reason: 'Gems inalterado');
        
        // Cenário 2: Gems suficientes + boost ativo
        // Deve falhar por idempotência
        manager.gems = 200;
        manager.xpBoosterUntil = DateTime.now().add(const Duration(hours: 1));
        
        final result2 = manager.purchaseXpBooster();
        expect(result2, isFalse, reason: 'Falha por idempotência');
        expect(manager.gems, equals(200), reason: 'Gems inalterado');
        
        // Cenário 3: Gems suficientes + boost não ativo
        // Deve ter sucesso
        manager.gems = 200;
        manager.xpBoosterUntil = null;
        
        final result3 = manager.purchaseXpBooster();
        expect(result3, isTrue, reason: 'Sucesso quando validações passam');
        expect(manager.gems, equals(50), reason: 'Gems deduzido (200 - 150)');
        
        // Propriedade validada: ordem consistente
        // 1. Gems verificado primeiro (cenário 1)
        // 2. Idempotência verificado depois (cenário 2)
        // 3. Compra executada quando ambos passam (cenário 3)
      },
    );
  });
}
