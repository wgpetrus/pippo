import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../gamification/controllers/streak_controller.dart';
import '../../gamification/controllers/gems_controller.dart';

/// Níveis de streak
enum StreakLevel { zero, one, two, four, seven }

/// Modal de informações do Streak
class StreakModal extends StatelessWidget {
  final VoidCallback? onSeeMore;

  const StreakModal({
    super.key,
    this.onSeeMore,
  });

  // Getters
  StreakLevel _getLevel(int streakDays) {
    if (streakDays == 0) return StreakLevel.zero;
    if (streakDays == 1) return StreakLevel.one;
    if (streakDays <= 3) return StreakLevel.two;
    if (streakDays <= 6) return StreakLevel.four;
    return StreakLevel.seven;
  }

  Color _getBgColor(StreakLevel level) {
    switch (level) {
      case StreakLevel.zero:
        return AppTheme.gray300;
      case StreakLevel.one:
        return AppTheme.primary100;
      case StreakLevel.two:
        return AppTheme.orange;
      case StreakLevel.four:
        return AppTheme.blue;
      case StreakLevel.seven:
        return AppTheme.orange;
    }
  }

  Color _getBorderColor(StreakLevel level) {
    switch (level) {
      case StreakLevel.zero:
        return AppTheme.white;
      case StreakLevel.one:
        return AppTheme.primary;
      case StreakLevel.two:
        return AppTheme.white;
      case StreakLevel.four:
        return AppTheme.primary;
      case StreakLevel.seven:
        return AppTheme.white;
    }
  }

  Color _getTextColor(StreakLevel level) {
    switch (level) {
      case StreakLevel.zero:
      case StreakLevel.two:
      case StreakLevel.four:
      case StreakLevel.seven:
        return AppTheme.white;
      case StreakLevel.one:
        return AppTheme.primary;
    }
  }

  Color _getTitleColor(StreakLevel level) {
    switch (level) {
      case StreakLevel.zero:
      case StreakLevel.two:
      case StreakLevel.four:
      case StreakLevel.seven:
        return AppTheme.white;
      case StreakLevel.one:
        return AppTheme.black;
    }
  }

  Color _getNumberColor(StreakLevel level) {
    switch (level) {
      case StreakLevel.zero:
      case StreakLevel.two:
      case StreakLevel.seven:
        return AppTheme.white;
      case StreakLevel.one:
        return AppTheme.primary;
      case StreakLevel.four:
        return AppTheme.white;
    }
  }

  String _getMascotAsset(StreakLevel level) {
    switch (level) {
      case StreakLevel.zero:
        return AppAssets.profileMascot0;
      case StreakLevel.one:
        return AppAssets.profileMascot1;
      case StreakLevel.two:
        return AppAssets.profileWarrior4;
      case StreakLevel.four:
        return AppAssets.profileWarrior2;
      case StreakLevel.seven:
        return AppAssets.profileWarrior5;
    }
  }


  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final streakController = Get.find<StreakController>();
    final gemsController = Get.find<GemsController>();
    
    return Obx(() {
      final streakDays = streakController.currentStreak.value;
      final longestStreak = streakController.longestStreak.value;
      final level = _getLevel(streakDays);
      final bgColor = _getBgColor(level);
      final borderColor = _getBorderColor(level);
      final titleColor = _getTitleColor(level);
      final textColor = _getTextColor(level);
      final numberColor = _getNumberColor(level);
      final mascotAsset = _getMascotAsset(level);
      
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(r.spacing24),
            border: Border.all(color: borderColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decoração de fundo
              ..._buildDecoration(level, r),

              // Conteúdo
              Padding(
                padding: EdgeInsets.fromLTRB(
                  r.spacing16,
                  r.spacing16,
                  r.spacing16,
                  r.spacing16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      'home_streak_modal_title'.tr,
                      style: AppTheme.displayXsBold.copyWith(color: titleColor),
                    ),
                    SizedBox(height: r.spacing16),

                    // Conteúdo principal
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _buildLeftContent(
                            streakDays,
                            longestStreak,
                            numberColor,
                            textColor,
                            streakController,
                            gemsController,
                            r,
                          ),
                        ),
                        SizedBox(width: r.spacing8),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: Image.asset(
                            mascotAsset,
                            width: ResponsiveUtils.width(140, min: 120, max: 160),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Widgets
  Widget _buildLeftContent(
    int streakDays,
    int longestStreak,
    Color numberColor,
    Color textColor,
    StreakController streakController,
    GemsController gemsController,
    ResponsiveUtils r,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Número grande com animação
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: streakDays.toDouble()),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              value.toInt().toString(),
              style: AppTheme.displayLgBold.copyWith(
                fontSize: r.value(mobile: 64, tablet: 72, desktop: 80),
                color: numberColor,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: numberColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: r.spacing8),

        // Texto
        Text(
          'home_streak_modal_days_label'.tr,
          style: AppTheme.textLgMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: r.spacing8),

        // Longest streak com ícone
        Row(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 16,
              color: textColor.withOpacity(0.8),
            ),
            SizedBox(width: r.spacing4),
            Text(
              'home_streak_modal_record_label'.tr.replaceAll('{count}', longestStreak.toString()),
              style: AppTheme.textSmMedium.copyWith(
                color: textColor.withOpacity(0.9),
              ),
            ),
          ],
        ),
        SizedBox(height: r.spacing16),

        // Streak freeze purchase option
        if (gemsController.gems.value >= 200 && !streakController.streakFreezeAvailable)
          _ProtectionButton(
            textColor: textColor,
            onTap: () async {
              // Purchase streak freeze via shop controller
              // This will be handled by ShopController
            },
          ),
        
        if (streakController.streakFreezeAvailable)
          _ProtectionBadge(textColor: textColor),
        
        SizedBox(height: r.spacing16),

        // See more
        if (onSeeMore != null)
          _SeeMoreButton(
            textColor: textColor,
            onTap: onSeeMore!,
          ),
      ],
    );
  }

  List<Widget> _buildDecoration(StreakLevel level, ResponsiveUtils r) {
    switch (level) {
      case StreakLevel.zero:
        return _buildCircleDecoration(r);
      case StreakLevel.one:
        return _buildStarLineDecoration(r);
      case StreakLevel.two:
      case StreakLevel.four:
        return _buildZebraDecoration(r);
      case StreakLevel.seven:
        return _buildStarSvgDecoration(r);
    }
  }

  // Decoração para streak zerado (círculos)
  List<Widget> _buildCircleDecoration(ResponsiveUtils r) {
    return [
      Positioned(
        top: r.spacing16,
        right: r.spacing32,
        child: _buildCircle(ResponsiveUtils.width(40, min: 32, max: 48), AppTheme.gray400_50),
      ),
      Positioned(
        top: r.spacing48,
        right: ResponsiveUtils.width(100, min: 80, max: 120),
        child: _buildCircle(ResponsiveUtils.width(24, min: 20, max: 28), AppTheme.gray400_40),
      ),
      Positioned(
        bottom: r.spacing48,
        left: r.spacing16,
        child: _buildCircle(ResponsiveUtils.width(50, min: 40, max: 60), AppTheme.gray400_50),
      ),
      Positioned(
        bottom: r.spacing32,
        left: ResponsiveUtils.width(90, min: 70, max: 110),
        child: _buildCircle(ResponsiveUtils.width(28, min: 24, max: 32), AppTheme.gray400_40),
      ),
    ];
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  // Decoração para 1 dia (estrela desenhada)
  List<Widget> _buildStarLineDecoration(ResponsiveUtils r) {
    return [
      Positioned(
        top: r.spacing32,
        left: ResponsiveUtils.width(100, min: 80, max: 120),
        child: CustomPaint(
          size: Size(
            ResponsiveUtils.width(40, min: 32, max: 48),
            ResponsiveUtils.height(40, min: 32, max: 48),
          ),
          painter: _StarPainter(color: AppTheme.primary30),
        ),
      ),
    ];
  }

  // Decoração zebra (2-6 dias)
  List<Widget> _buildZebraDecoration(ResponsiveUtils r) {
    return [
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r.spacing16),
          child: Opacity(
            opacity: 0.25,
            child: SvgPicture.asset(
              AppAssets.effectZebra,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    ];
  }

  // Decoração estrelas SVG (7+ dias)
  List<Widget> _buildStarSvgDecoration(ResponsiveUtils r) {
    return [
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r.spacing16),
          child: Opacity(
            opacity: 0.25,
            child: SvgPicture.asset(
              AppAssets.effectStars,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    ];
  }

  // Métodos estáticos
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSeeMore,
  }) async {
    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: StreakModal(
            onSeeMore: () {
              Navigator.of(context).pop();
              onSeeMore?.call();
            },
          ),
        ),
      ],
    );
  }
}

/// Painter para desenhar estrela de 4 pontas
class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Botão de proteção de streak
class _ProtectionButton extends StatefulWidget {
  final Color textColor;
  final VoidCallback onTap;

  const _ProtectionButton({
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_ProtectionButton> createState() => _ProtectionButtonState();
}

class _ProtectionButtonState extends State<_ProtectionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.spacing12,
            vertical: r.spacing8,
          ),
          decoration: BoxDecoration(
            color: widget.textColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(r.spacing12),
            border: Border.all(color: widget.textColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.textColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_rounded,
                size: 18,
                color: widget.textColor,
              ),
              SizedBox(width: r.spacing8),
              Text(
                'home_streak_modal_protection_button'.tr,
                style: AppTheme.textSmBold.copyWith(color: widget.textColor),
              ),
              SizedBox(width: r.spacing8),
              Image.asset(AppAssets.appbarGem, width: 18, height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge de proteção ativa
class _ProtectionBadge extends StatelessWidget {
  final Color textColor;

  const _ProtectionBadge({required this.textColor});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.spacing12,
        vertical: r.spacing8,
      ),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(r.spacing12),
        border: Border.all(color: textColor.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_rounded,
            size: 18,
            color: textColor,
          ),
          SizedBox(width: r.spacing8),
          Text(
            'home_streak_modal_protection_active'.tr,
            style: AppTheme.textSmBold.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

/// Botão "See More"
class _SeeMoreButton extends StatefulWidget {
  final Color textColor;
  final VoidCallback onTap;

  const _SeeMoreButton({
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_SeeMoreButton> createState() => _SeeMoreButtonState();
}

class _SeeMoreButtonState extends State<_SeeMoreButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'home_streak_modal_see_more'.tr,
                  style: AppTheme.textMdBold.copyWith(
                    color: widget.textColor,
                    decoration: _isHovered ? TextDecoration.underline : null,
                  ),
                ),
                SizedBox(width: r.spacing4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: widget.textColor,
                ),
              ],
            ),
            SizedBox(height: r.spacing4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: _isHovered ? 100 : 80,
              decoration: BoxDecoration(
                color: widget.textColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
