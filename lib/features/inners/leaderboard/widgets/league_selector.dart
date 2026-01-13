import 'package:flutter/material.dart';

/// Exibição do nível atual da liga (escudo central maior, laterais menores)
class LeagueSelector extends StatelessWidget {
  final List<String> shieldAssets;
  final int currentLevel;

  const LeagueSelector({
    super.key,
    required this.shieldAssets,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    // Índices dos escudos visíveis (anterior, atual, próximo)
    final prevIndex = currentLevel > 0 ? currentLevel - 1 : null;
    final nextIndex = currentLevel < shieldAssets.length - 1 ? currentLevel + 1 : null;

    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Escudo anterior (menor, desativado)
          if (prevIndex != null)
            _buildShield(shieldAssets[prevIndex], isActive: false)
          else
            const SizedBox(width: 80),

          const SizedBox(width: 8),

          // Escudo atual (maior, ativo)
          _buildShield(shieldAssets[currentLevel], isActive: true),

          const SizedBox(width: 8),

          // Próximo escudo (menor, desativado)
          if (nextIndex != null)
            _buildShield(shieldAssets[nextIndex], isActive: false)
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildShield(String asset, {required bool isActive}) {
    final size = isActive ? 100.0 : 70.0;
    final opacity = isActive ? 1.0 : 0.4;

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 200),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
