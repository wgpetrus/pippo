import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';

/// Página de conclusão da lição
class CompletePage extends StatelessWidget {
  const CompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Título
              Text(
                'Lição Completa!',
                style: AppTheme.displayMdBold.copyWith(color: AppTheme.primary),
              ),

              const Spacer(),

              // Mascote com estrelas
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Mascote
                  Image.asset(
                    AppAssets.lessonMascotComplete,
                    width: ResponsiveUtils.width(300, min: 200, max: 350),
                    height: ResponsiveUtils.width(300, min: 200, max: 350),
                    fit: BoxFit.contain,
                  ),

                  // Estrela esquerda (rosa)
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Image.asset(
                      AppAssets.starsPink,
                      width: 40,
                      height: 40,
                    ),
                  ),

                  // Estrela direita (azul)
                  Positioned(
                    right: 20,
                    top: 60,
                    child: Image.asset(
                      AppAssets.starsBlue,
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Cards de estatísticas
              // Em landscape: exibir em uma única linha
              // Em portrait: exibir em duas linhas
              ResponsiveUtils.isLandscape
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: AppAssets.treasureXpCoin,
                            value: '25',
                            label: 'XP Total',
                            color: AppTheme.gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: AppAssets.treasureTarget,
                            value: '98%',
                            label: 'Excelente',
                            color: AppTheme.pink,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: AppAssets.lessonClock,
                            value: '2:40',
                            label: 'Tempo',
                            color: AppTheme.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: AppAssets.appbarGem,
                            value: '5',
                            label: 'Gemas',
                            color: AppTheme.red,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: AppAssets.treasureXpCoin,
                                value: '25',
                                label: 'XP Total',
                                color: AppTheme.gold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: AppAssets.treasureTarget,
                                value: '98%',
                                label: 'Excelente',
                                color: AppTheme.pink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: AppAssets.lessonClock,
                                value: '2:40',
                                label: 'Tempo',
                                color: AppTheme.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: AppAssets.appbarGem,
                                value: '5',
                                label: 'Gemas',
                                color: AppTheme.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

              const SizedBox(height: 32),

              // Botão resgatar recompensa
              AppButton(
                text: 'Resgatar Recompensa',
                onPressed: () => Get.back(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget de card de estatística
  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    // Padding responsivo
    final verticalPadding = ResponsiveUtils.height(20, min: 16, max: 24);
    final horizontalPadding = ResponsiveUtils.width(12, min: 8, max: 16);
    final iconSize = ResponsiveUtils.width(32, min: 24, max: 36);
    final bottomPadding = ResponsiveUtils.height(12, min: 10, max: 14);

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          // Parte superior (branca)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Stack(
              children: [
                // Conteúdo centralizado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(icon, width: iconSize, height: iconSize),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        value,
                        style: AppTheme.displayXsBold.copyWith(color: color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Estrela no canto superior direito
                Positioned(
                  right: 0,
                  top: 0,
                  child: SvgPicture.asset(
                    AppAssets.profileStar,
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      color,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Parte inferior (colorida)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: bottomPadding),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.textMdBold.copyWith(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }
}
