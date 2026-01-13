import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';

/// Card de desafio (estilo Your Packs da Shop)
class ChallengeCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final int current;
  final int total;
  final String rewardAsset;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? progressColor;

  const ChallengeCard({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.current,
    required this.total,
    required this.rewardAsset,
    this.backgroundColor,
    this.borderColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.white;
    final border = borderColor ?? AppTheme.gray600;
    final barColor = progressColor ?? AppTheme.primary;
    final progress = total > 0 ? (current / total * 100).toInt() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: border, width: 2),
          left: BorderSide(color: border, width: 2),
          right: BorderSide(color: border, width: 2),
          bottom: BorderSide(color: border, width: 4),
        ),
      ),
      child: Row(
        children: [
          // Ícone do desafio
          Image.asset(iconAsset, width: 48, height: 48),
          const SizedBox(width: 12),

          // Título e progresso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.textMdBold),
                const SizedBox(height: 8),

                // Barra de progresso com degradê
                _buildProgressBar(progress, barColor),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Recompensa (baú)
          Image.asset(rewardAsset, width: 48, height: 48),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildProgressBar(int progress, Color color) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Row(
              children: [
                if (progress > 0)
                  Expanded(
                    flex: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.5), AppTheme.white],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                if (progress < 100)
                  Expanded(flex: 100 - progress, child: const SizedBox()),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$current/$total',
          style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray300),
        ),
      ],
    );
  }
}
