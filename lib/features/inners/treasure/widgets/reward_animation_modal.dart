import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';

/// Modal de animação de recompensa usando Wolt Modal Sheet
/// 
/// Exibe uma animação celebratória quando o usuário coleta uma recompensa.
/// Auto-fecha após 2 segundos.
class RewardAnimationModal extends StatefulWidget {
  final String rewardType; // 'gems' ou 'xp'
  final int rewardAmount;

  const RewardAnimationModal({
    super.key,
    required this.rewardType,
    required this.rewardAmount,
  });

  @override
  State<RewardAnimationModal> createState() => _RewardAnimationModalState();
}

class _RewardAnimationModalState extends State<RewardAnimationModal>
    with SingleTickerProviderStateMixin {
  // Animações
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Lifecycle
  @override
  void initState() {
    super.initState();

    // Configurar animação
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // Iniciar animação
    _controller.forward();

    // Auto-fechar após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Padding(
            padding: EdgeInsets.all(r.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone da recompensa
                _buildRewardIcon(r),
                
                SizedBox(height: r.spacing16),
                
                // Texto "Recompensa!"
                Text(
                  'treasure_reward_animation_title',
                  style: AppTheme.displayXsBold.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
                
                SizedBox(height: r.spacing8),
                
                // Quantidade
                Text(
                  '+${widget.rewardAmount}',
                  style: AppTheme.displayMdExtrabold.copyWith(
                    color: widget.rewardType == 'gems'
                        ? AppTheme.gold
                        : AppTheme.purple,
                  ),
                ),
                
                SizedBox(height: r.spacing4),
                
                // Tipo
                Text(
                  widget.rewardType == 'gems' 
                      ? 'treasure_reward_animation_gems' 
                      : 'treasure_reward_animation_xp',
                  style: AppTheme.textLgMedium.copyWith(
                    color: AppTheme.gray300,
                  ),
                ),
                
                SizedBox(height: r.spacing24),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widgets
  Widget _buildRewardIcon(ResponsiveUtils r) {
    final iconPath = widget.rewardType == 'gems'
        ? AppAssets.appbarGem
        : AppAssets.treasureXpCoin;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Efeito de brilho
        Container(
          width: r.wp(30),
          height: r.wp(30),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.rewardType == 'gems'
                    ? AppTheme.gold100
                    : AppTheme.purple100,
                Colors.transparent,
              ],
            ),
          ),
        ),
        
        // Ícone
        Image.asset(
          iconPath,
          width: r.wp(20),
          height: r.wp(20),
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

/// Função helper para mostrar o modal usando Wolt Modal Sheet
void showRewardAnimationModal(
  BuildContext context, {
  required String rewardType,
  required int rewardAmount,
}) {
  WoltModalSheet.show(
    context: context,
    barrierDismissible: false,
    enableDrag: false,
    pageListBuilder: (context) => [
      WoltModalSheetPage(
        backgroundColor: AppTheme.white,
        hasSabGradient: false,
        isTopBarLayerAlwaysVisible: false,
        child: RewardAnimationModal(
          rewardType: rewardType,
          rewardAmount: rewardAmount,
        ),
      ),
    ],
  );
}
