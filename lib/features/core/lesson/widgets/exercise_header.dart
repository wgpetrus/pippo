import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';

/// Header de exercício com progresso e energia
class ExerciseHeader extends StatelessWidget {
  final double progress;
  final int energy;
  final VoidCallback? onBack;

  const ExerciseHeader({
    super.key,
    required this.progress,
    required this.energy,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Botão voltar (sem margem extra)
          // Se onBack é null, não mostra o botão (após verificar resposta)
          if (onBack != null)
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: AppTheme.white, size: 18),
                onPressed: onBack,
              ),
            ),

          if (onBack != null) const SizedBox(width: 12),

          // Barra de progresso
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.gray700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Energia
          Row(
            children: [
              Image.asset(
                AppAssets.appbarRay,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '$energy',
                style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
