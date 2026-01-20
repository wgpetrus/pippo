import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../gamification/controllers/gamification_controller.dart';

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
    final gamification = Get.find<GamificationController>();
    
    return Obx(() {
      final streakDays = gamification.currentStreak.value;
      final longestStreak = gamification.longestStreak.value;
      final level = _getLevel(streakDays);
      final bgColor = _getBgColor(level);
      final borderColor = _getBorderColor(level);
      final titleColor = _getTitleColor(level);
      final textColor = _getTextColor(level);
      final numberColor = _getNumberColor(level);
      final mascotAsset = _getMascotAsset(level);
      
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 4),
        ),
        child: Stack(
          children: [
            // Decoração de fundo
            ..._buildDecoration(level),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    'Sequência de Fogo',
                    style: AppTheme.textXlBold.copyWith(color: titleColor),
                  ),
                  const SizedBox(height: 12),

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
                          gamification,
                        ),
                      ),
                      Image.asset(mascotAsset, width: 150, fit: BoxFit.contain),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
    GamificationController gamification,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Número grande
        Text(
          streakDays.toString(),
          style: AppTheme.displayLgBold.copyWith(
            fontSize: 72,
            color: numberColor,
          ),
        ),
        const SizedBox(height: 8),

        // Texto
        Text(
          'Dias de sequência',
          style: AppTheme.textMdMedium.copyWith(color: textColor),
        ),
        const SizedBox(height: 4),

        // Longest streak
        Text(
          'Recorde: $longestStreak dias',
          style: AppTheme.textSmMedium.copyWith(color: textColor),
        ),
        const SizedBox(height: 12),

        // Streak freeze purchase option
        if (gamification.gems.value >= 200 && !gamification.streakFreezeAvailable)
          GestureDetector(
            onTap: () async {
              await gamification.purchaseStreakFreeze();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: textColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Proteção 200',
                    style: AppTheme.textSmBold.copyWith(color: textColor),
                  ),
                  const SizedBox(width: 4),
                  Image.asset(AppAssets.appbarGem, width: 16, height: 16),
                ],
              ),
            ),
          ),
        
        if (gamification.streakFreezeAvailable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🛡️ Proteção ativa',
              style: AppTheme.textSmBold.copyWith(color: textColor),
            ),
          ),
        
        const SizedBox(height: 12),

        // See more
        GestureDetector(
          onTap: onSeeMore,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ver mais',
                style: AppTheme.textMdBold.copyWith(color: textColor),
              ),
              const SizedBox(height: 2),
              Container(height: 2, width: 72, color: textColor),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDecoration(StreakLevel level) {
    switch (level) {
      case StreakLevel.zero:
        return _buildCircleDecoration();
      case StreakLevel.one:
        return _buildStarLineDecoration();
      case StreakLevel.two:
      case StreakLevel.four:
        return _buildZebraDecoration();
      case StreakLevel.seven:
        return _buildStarSvgDecoration();
    }
  }

  // Decoração para streak zerado (círculos)
  List<Widget> _buildCircleDecoration() {
    return [
      Positioned(
        top: 20,
        right: 40,
        child: _buildCircle(40, AppTheme.gray400_50),
      ),
      Positioned(
        top: 50,
        right: 100,
        child: _buildCircle(24, AppTheme.gray400_40),
      ),
      Positioned(
        bottom: 60,
        left: 20,
        child: _buildCircle(50, AppTheme.gray400_50),
      ),
      Positioned(
        bottom: 40,
        left: 90,
        child: _buildCircle(28, AppTheme.gray400_40),
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
  List<Widget> _buildStarLineDecoration() {
    return [
      Positioned(
        top: 40,
        left: 100,
        child: CustomPaint(
          size: const Size(40, 40),
          painter: _StarPainter(color: AppTheme.primary30),
        ),
      ),
    ];
  }

  // Decoração zebra (2-6 dias)
  List<Widget> _buildZebraDecoration() {
    return [
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Opacity(
            opacity: 0.3,
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
  List<Widget> _buildStarSvgDecoration() {
    return [
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Opacity(
            opacity: 0.3,
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
  static void show(
    BuildContext context, {
    VoidCallback? onSeeMore,
  }) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StreakModal(
              onSeeMore: () {
                Navigator.of(context).pop();
                onSeeMore?.call();
              },
            ),
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
