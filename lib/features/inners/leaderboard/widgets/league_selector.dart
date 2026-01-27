import 'package:flutter/material.dart';

/// Exibição do nível atual da liga (escudo central maior, laterais menores)
/// 
/// Este widget exibe os escudos das ligas com o escudo atual em destaque.
/// Os escudos laterais (anterior e próximo) são exibidos com menor opacidade.
/// 
/// Propriedades:
/// - shieldAssets: Lista de assets dos escudos das ligas
/// - currentLevel: Índice da liga atual (0-based)
/// - onLeagueSelected: Callback opcional quando um escudo é clicado
class LeagueSelector extends StatelessWidget {
  final List<String> shieldAssets;
  final int currentLevel;
  final Function(int)? onLeagueSelected;

  const LeagueSelector({
    super.key,
    required this.shieldAssets,
    required this.currentLevel,
    this.onLeagueSelected,
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
            _buildShield(
              shieldAssets[prevIndex],
              isActive: false,
              onTap: onLeagueSelected != null
                  ? () => onLeagueSelected!(prevIndex)
                  : null,
            )
          else
            const SizedBox(width: 80),

          const SizedBox(width: 8),

          // Escudo atual (maior, ativo)
          _buildShield(
            shieldAssets[currentLevel],
            isActive: true,
            onTap: null, // Escudo atual não é clicável
          ),

          const SizedBox(width: 8),

          // Próximo escudo (menor, desativado)
          if (nextIndex != null)
            _buildShield(
              shieldAssets[nextIndex],
              isActive: false,
              onTap: onLeagueSelected != null
                  ? () => onLeagueSelected!(nextIndex)
                  : null,
            )
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildShield(String asset, {required bool isActive, VoidCallback? onTap}) {
    final size = isActive ? 100.0 : 70.0;
    final opacity = isActive ? 1.0 : 0.4;

    final shield = AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 200),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );

    // Se tem callback e não é o escudo ativo, tornar clicável
    if (onTap != null && !isActive) {
      return GestureDetector(
        onTap: onTap,
        child: shield,
      );
    }

    return shield;
  }
}
