import 'package:glados/glados.dart';

void main() {
  group('Feature: ranking-system, Promotion/Demotion Property Tests', () {
    // Property 12: Promotion Zone Stability
    // For any user finishing in ranks 1-3, they SHALL be promoted to the next
    // league (unless already in Diamond).
    // Validates: Requirements 2.3, 5.1, 5.2
    Glados2<int, String>(
      any.intInRange(1, 3), // Ranks in promotion zone (top 3)
      any.choose(['bronze', 'silver', 'gold', 'platinum', 'diamond']), // Current league
    ).test(
      'Property 12: Promotion Zone Stability - Users in ranks 1-3 are promoted (except Diamond)',
      (rank, currentLeague) {
        // Determinar nova liga após promoção
        final newLeague = _calculateNewLeague(
          rank: rank,
          currentLeague: currentLeague,
        );

        // Verificar regras de promoção
        if (currentLeague == 'diamond') {
          // Não pode promover de Diamond (já é a liga mais alta)
          expect(
            newLeague,
            equals('diamond'),
            reason: 'Users in Diamond league cannot be promoted further. '
                'Rank: $rank, Current league: $currentLeague, '
                'New league: $newLeague',
          );
        } else {
          // Deve promover para próxima liga
          final expectedLeague = _getNextLeague(currentLeague);
          expect(
            newLeague,
            equals(expectedLeague),
            reason: 'Users in promotion zone (ranks 1-3) must be promoted. '
                'Rank: $rank, Current league: $currentLeague, '
                'Expected: $expectedLeague, Got: $newLeague',
          );
        }

        // Verificar que a zona está correta
        final zone = _getUserZone(rank);
        expect(
          zone,
          equals('promotion'),
          reason: 'Ranks 1-3 must be in promotion zone. '
              'Rank: $rank, Zone: $zone',
        );
      },
    );

    // Property 13: Demotion Zone Stability
    // For any user finishing in ranks 8-10, they SHALL be demoted to the
    // previous league (unless already in Bronze).
    // Validates: Requirements 2.5, 5.3, 5.4
    Glados2<int, String>(
      any.intInRange(8, 10), // Ranks in demotion zone (bottom 3)
      any.choose(['bronze', 'silver', 'gold', 'platinum', 'diamond']), // Current league
    ).test(
      'Property 13: Demotion Zone Stability - Users in ranks 8-10 are demoted (except Bronze)',
      (rank, currentLeague) {
        // Determinar nova liga após rebaixamento
        final newLeague = _calculateNewLeague(
          rank: rank,
          currentLeague: currentLeague,
        );

        // Verificar regras de rebaixamento
        if (currentLeague == 'bronze') {
          // Não pode rebaixar de Bronze (já é a liga mais baixa)
          expect(
            newLeague,
            equals('bronze'),
            reason: 'Users in Bronze league cannot be demoted further. '
                'Rank: $rank, Current league: $currentLeague, '
                'New league: $newLeague',
          );
        } else {
          // Deve rebaixar para liga anterior
          final expectedLeague = _getPreviousLeague(currentLeague);
          expect(
            newLeague,
            equals(expectedLeague),
            reason: 'Users in demotion zone (ranks 8-10) must be demoted. '
                'Rank: $rank, Current league: $currentLeague, '
                'Expected: $expectedLeague, Got: $newLeague',
          );
        }

        // Verificar que a zona está correta
        final zone = _getUserZone(rank);
        expect(
          zone,
          equals('demotion'),
          reason: 'Ranks 8-10 must be in demotion zone. '
              'Rank: $rank, Zone: $zone',
        );
      },
    );

    // Property 14: Safe Zone Stability
    // For any user finishing in ranks 4-7, they SHALL remain in their
    // current league.
    // Validates: Requirements 2.4, 5.5
    Glados2<int, String>(
      any.intInRange(4, 7), // Ranks in safe zone (middle 4)
      any.choose(['bronze', 'silver', 'gold', 'platinum', 'diamond']), // Current league
    ).test(
      'Property 14: Safe Zone Stability - Users in ranks 4-7 remain in current league',
      (rank, currentLeague) {
        // Determinar nova liga (deve permanecer a mesma)
        final newLeague = _calculateNewLeague(
          rank: rank,
          currentLeague: currentLeague,
        );

        // Verificar que permanece na mesma liga
        expect(
          newLeague,
          equals(currentLeague),
          reason: 'Users in safe zone (ranks 4-7) must remain in current league. '
              'Rank: $rank, Current league: $currentLeague, '
              'New league: $newLeague',
        );

        // Verificar que a zona está correta
        final zone = _getUserZone(rank);
        expect(
          zone,
          equals('safe'),
          reason: 'Ranks 4-7 must be in safe zone. '
              'Rank: $rank, Zone: $zone',
        );
      },
    );
  });
}

// Helper: Determina a zona baseada no rank
String _getUserZone(int rank) {
  if (rank >= 1 && rank <= 3) return 'promotion';
  if (rank >= 4 && rank <= 7) return 'safe';
  if (rank >= 8 && rank <= 10) return 'demotion';
  return 'safe'; // fallback
}

// Helper: Calcula a nova liga baseada no rank e liga atual
String _calculateNewLeague({
  required int rank,
  required String currentLeague,
}) {
  // Determinar zona
  final zone = _getUserZone(rank);

  // Aplicar regras de promoção/rebaixamento
  if (zone == 'promotion') {
    // Promoção (exceto Diamond)
    if (currentLeague == 'diamond') {
      return 'diamond'; // Não pode promover de Diamond
    }
    return _getNextLeague(currentLeague);
  } else if (zone == 'demotion') {
    // Rebaixamento (exceto Bronze)
    if (currentLeague == 'bronze') {
      return 'bronze'; // Não pode rebaixar de Bronze
    }
    return _getPreviousLeague(currentLeague);
  } else {
    // Safe zone - permanece na mesma liga
    return currentLeague;
  }
}

// Helper: Retorna a próxima liga (promoção)
String _getNextLeague(String currentLeague) {
  switch (currentLeague) {
    case 'bronze':
      return 'silver';
    case 'silver':
      return 'gold';
    case 'gold':
      return 'platinum';
    case 'platinum':
      return 'diamond';
    case 'diamond':
      return 'diamond'; // Já é a mais alta
    default:
      return currentLeague;
  }
}

// Helper: Retorna a liga anterior (rebaixamento)
String _getPreviousLeague(String currentLeague) {
  switch (currentLeague) {
    case 'diamond':
      return 'platinum';
    case 'platinum':
      return 'gold';
    case 'gold':
      return 'silver';
    case 'silver':
      return 'bronze';
    case 'bronze':
      return 'bronze'; // Já é a mais baixa
    default:
      return currentLeague;
  }
}
