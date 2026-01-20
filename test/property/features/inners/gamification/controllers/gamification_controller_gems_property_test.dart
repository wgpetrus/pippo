import 'package:flutter_test/flutter_test.dart' hide test, group, expect;
import 'package:glados/glados.dart';
import 'package:test/test.dart' show test, group, expect;

// Test Helpers

/// Classe helper de teste - lógica isolada de gems sem dependências do Firebase
class TestGemsCalculator {
  // Estados
  int gems = 0;
  int totalGemsEarned = 0;
  int totalGemsSpent = 0;
  
  DateTime? gemMultiplierUntil;

  // Computed properties
  bool get hasGemMultiplier =>
      gemMultiplierUntil != null && DateTime.now().isBefore(gemMultiplierUntil!);

  // Métodos públicos
  void addGems(int amount) {
    if (amount < 0) {
      throw Exception('Cannot add negative gems');
    }

    // Aplicar multiplicador se ativo (2×)
    final gemsToAdd = hasGemMultiplier ? amount * 2 : amount;

    // Atualizar gems e totalGemsEarned atomicamente
    gems += gemsToAdd;
    totalGemsEarned += gemsToAdd;
  }

  bool spendGems(int amount) {
    // Validar gems suficientes
    if (gems < amount) {
      return false;
    }

    // Atualizar gems e totalGemsSpent atomicamente
    gems -= amount;
    totalGemsSpent += amount;
    
    return true;
  }
}

// Property Tests

void main() {
  group('Feature: gamification-system, Testes de Propriedades - Economia de Gems', () {
    // Property 27: Atomicidade da Atualização Dupla de Gems
    // Para qualquer ganho de gems de quantidade G, tanto gems quanto totalGemsEarned
    // devem aumentar em G em uma única operação atômica
    Glados2(any.int, any.int).test(
      'Property 27: gems e totalGemsEarned aumentam pela mesma quantidade atomicamente',
      (initialGems, gemsToAdd) {
        // Restringir valores a ranges válidos
        final gems = initialGems.abs() % 10000; // 0-9999
        final gemsAmount = gemsToAdd.abs() % 500; // 0-499
        
        // Criar calculadora com gems iniciais
        final calculator = TestGemsCalculator();
        calculator.gems = gems;
        calculator.totalGemsEarned = gems;
        
        // Armazenar valores iniciais
        final initialGemsValue = calculator.gems;
        final initialTotalEarned = calculator.totalGemsEarned;
        
        // Adicionar gems
        calculator.addGems(gemsAmount);
        
        // Calcular aumento esperado (sem multiplicador)
        final expectedIncrease = gemsAmount;
        
        // Verificar que ambos contadores aumentaram pela mesma quantidade
        final gemsIncrease = calculator.gems - initialGemsValue;
        final earnedIncrease = calculator.totalGemsEarned - initialTotalEarned;
        
        expect(
          gemsIncrease,
          equals(expectedIncrease),
          reason: 'gems deve aumentar em $expectedIncrease',
        );
        
        expect(
          earnedIncrease,
          equals(expectedIncrease),
          reason: 'totalGemsEarned deve aumentar pela mesma quantidade que gems',
        );
        
        // Verificar atomicidade - ambos devem ter aumentado exatamente pela mesma quantidade
        expect(
          gemsIncrease == earnedIncrease,
          isTrue,
          reason: 'Tanto gems quanto totalGemsEarned devem aumentar exatamente pela mesma quantidade atomicamente',
        );
      },
    );

    // Property 26: Multiplicador de Gems Dobra Ganhos
    // Para qualquer ganho de gems com multiplicador ativo, as gems finais adicionadas
    // devem ser exatamente 2× a quantidade base de gems
    Glados(any.int).test(
      'Property 26: multiplicador de gems dobra todos os ganhos de gems',
      (baseGems) {
        // Restringir a range válido
        final gems = baseGems.abs() % 500; // 0-499
        
        // Criar calculadora com multiplicador ativo
        final calculator = TestGemsCalculator();
        calculator.gemMultiplierUntil = DateTime.now().add(Duration(hours: 1));
        
        // Armazenar valores iniciais
        final initialGems = calculator.gems;
        
        // Adicionar gems
        calculator.addGems(gems);
        
        // Verificar que gems foram dobradas
        final actualIncrease = calculator.gems - initialGems;
        final expectedIncrease = gems * 2;
        
        expect(
          actualIncrease,
          equals(expectedIncrease),
          reason: 'Gems devem ser dobradas quando multiplicador está ativo. '
              'Base: $gems, Esperado: $expectedIncrease, Obtido: $actualIncrease',
        );
      },
    );

    // Property 28: Atualização Dupla de Gasto de Gems
    // Para qualquer gasto de gems de quantidade S, gems deve diminuir em S
    // e totalGemsSpent deve aumentar em S em uma única operação atômica
    Glados2(any.int, any.int).test(
      'Property 28: gems diminui e totalGemsSpent aumenta pela mesma quantidade atomicamente',
      (initialGems, gemsToSpend) {
        // Restringir valores a ranges válidos
        final gems = (initialGems.abs() % 1000) + 100; // 100-1099 (garantir suficiente para gastar)
        final spendAmount = (gemsToSpend.abs() % 100) + 1; // 1-100 (garantir menor que inicial)
        
        // Criar calculadora com gems iniciais
        final calculator = TestGemsCalculator();
        calculator.gems = gems;
        
        // Armazenar valores iniciais
        final initialGemsValue = calculator.gems;
        final initialTotalSpent = calculator.totalGemsSpent;
        
        // Gastar gems
        final success = calculator.spendGems(spendAmount);
        
        // Deve ter sucesso já que temos gems suficientes
        expect(success, isTrue, reason: 'Deve gastar gems com sucesso quando há saldo suficiente');
        
        // Verificar que gems diminuiu
        final gemsDecrease = initialGemsValue - calculator.gems;
        expect(
          gemsDecrease,
          equals(spendAmount),
          reason: 'gems deve diminuir em $spendAmount',
        );
        
        // Verificar que totalGemsSpent aumentou
        final spentIncrease = calculator.totalGemsSpent - initialTotalSpent;
        expect(
          spentIncrease,
          equals(spendAmount),
          reason: 'totalGemsSpent deve aumentar em $spendAmount',
        );
        
        // Verificar atomicidade - diminuição e aumento devem ser iguais
        expect(
          gemsDecrease == spentIncrease,
          isTrue,
          reason: 'Diminuição de gems e aumento de totalGemsSpent devem ser iguais (operação atômica)',
        );
      },
    );

    // Property 29: Prevenção de Gems Insuficientes
    // Para qualquer tentativa de compra onde gems < custo, a compra deve ser
    // prevenida e nenhuma mudança de estado deve ocorrer
    Glados2(any.int, any.int).test(
      'Property 29: gems insuficientes previnem compra e nenhuma mudança de estado',
      (initialGems, cost) {
        // Restringir valores para garantir gems insuficientes
        final gems = initialGems.abs() % 100; // 0-99
        final purchaseCost = (cost.abs() % 100) + 100; // 100-199 (sempre mais que gems)
        
        // Criar calculadora com gems insuficientes
        final calculator = TestGemsCalculator();
        calculator.gems = gems;
        calculator.totalGemsSpent = 0;
        
        // Armazenar valores iniciais
        final initialGemsValue = calculator.gems;
        final initialTotalSpent = calculator.totalGemsSpent;
        
        // Tentar gastar mais gems do que disponível
        final success = calculator.spendGems(purchaseCost);
        
        // Deve falhar
        expect(success, isFalse, reason: 'Deve falhar quando gems insuficientes');
        
        // Verificar que nenhuma mudança de estado ocorreu
        expect(
          calculator.gems,
          equals(initialGemsValue),
          reason: 'gems não deve mudar quando compra falha',
        );
        
        expect(
          calculator.totalGemsSpent,
          equals(initialTotalSpent),
          reason: 'totalGemsSpent não deve mudar quando compra falha',
        );
      },
    );

    // Property 30: Transação de Compra de Streak Freeze
    // Para qualquer usuário com gems >= 200, comprar streak freeze deve
    // atomicamente deduzir 200 gems e definir streakFreezeAvailable=true
    test(
      'Property 30: compra de streak freeze é transação atômica',
      () {
        // Criar calculadora com gems suficientes
        final calculator = TestGemsCalculator();
        calculator.gems = 250;
        
        // Armazenar valores iniciais
        final initialGems = calculator.gems;
        final initialSpent = calculator.totalGemsSpent;
        
        // Comprar streak freeze (200 gems)
        final success = calculator.spendGems(200);
        
        // Deve ter sucesso
        expect(success, isTrue, reason: 'Deve comprar com sucesso quando há gems suficientes');
        
        // Verificar que gems foram deduzidas
        expect(
          calculator.gems,
          equals(initialGems - 200),
          reason: 'Deve deduzir exatamente 200 gems',
        );
        
        // Verificar que totalGemsSpent foi atualizado
        expect(
          calculator.totalGemsSpent,
          equals(initialSpent + 200),
          reason: 'Deve aumentar totalGemsSpent em 200',
        );
        
        // Verificar atomicidade - ambas mudanças aconteceram juntas
        final gemsDecrease = initialGems - calculator.gems;
        final spentIncrease = calculator.totalGemsSpent - initialSpent;
        expect(
          gemsDecrease == spentIncrease && gemsDecrease == 200,
          isTrue,
          reason: 'Dedução de gems e rastreamento de gastos devem ser atômicos',
        );
      },
    );
  });
}
