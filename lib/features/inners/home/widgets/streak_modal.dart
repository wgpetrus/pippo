import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';

/// Níveis de streak
enum StreakLevel { zero, one, two, four, seven }

/// Modal de informações do Streak
class StreakModal extends StatelessWidget {
  final int streakDays;
  final VoidCallback? onSeeMore;

  const StreakModal({
    super.key,
    required this.streakDays,
    this.onSeeMore,
  });

  // Getters
  StreakLevel get _level {
    if (streakDays == 0) return StreakLevel.zero;
    if (streakDays == 1) return StreakLevel.one;
    if (streakDays <= 3) return StreakLevel.two;
    if (streakDays <= 6) return StreakLevel.four;
    return StreakLevel.seven;
  }

  Color get _bgColor {
    switch (_level) {
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

  Color get _borderColor {
    switch (_level) {
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

  Color get _textColor {
    switch (_level) {
      case StreakLevel.zero:
      case StreakLevel.two:
      case StreakLevel.four:
      case StreakLevel.seven:
        return AppTheme.white;
      case StreakLevel.one:
        return AppTheme.primary;
    }
  }

  Color get _titleColor {
    switch (_level) {
      case StreakLevel.zero:
      case StreakLevel.two:
      case StreakLevel.four:
      case StreakLevel.seven:
        return AppTheme.white;
      case StreakLevel.one:
        return AppTheme.black;
    }
  }

  Color get _numberColor {
    switch (_level) {
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

  String get _mascotAsset {
    switch (_level) {
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor, width: 4),
      ),
      child: Stack(
        children: [
          // Decoração de fundo
          ..._buildDecoration(),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Streak Flash',
                  style: AppTheme.textXlBold.copyWith(color: _titleColor),
                ),
                const SizedBox(height: 12),

                // Conteúdo principal
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildLeftContent()),
                    Image.asset(_mascotAsset, width: 150, fit: BoxFit.contain),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildLeftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Número grande
        Text(
          streakDays.toString(),
          style: AppTheme.displayLgBold.copyWith(
            fontSize: 72,
            color: _numberColor,
          ),
        ),
        const SizedBox(height: 8),

        // Texto
        Text(
          'Days of streak',
          style: AppTheme.textMdMedium.copyWith(color: _textColor),
        ),
        const SizedBox(height: 6),

        // See more
        GestureDetector(
          onTap: onSeeMore,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'See more',
                style: AppTheme.textMdBold.copyWith(color: _textColor),
              ),
              const SizedBox(height: 2),
              Container(height: 2, width: 72, color: _textColor),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDecoration() {
    switch (_level) {
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
        child: _buildCircle(40, AppTheme.gray400.withOpacity(0.5)),
      ),
      Positioned(
        top: 50,
        right: 100,
        child: _buildCircle(24, AppTheme.gray400.withOpacity(0.4)),
      ),
      Positioned(
        bottom: 60,
        left: 20,
        child: _buildCircle(50, AppTheme.gray400.withOpacity(0.5)),
      ),
      Positioned(
        bottom: 40,
        left: 90,
        child: _buildCircle(28, AppTheme.gray400.withOpacity(0.4)),
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
          painter: _StarPainter(color: AppTheme.primary.withOpacity(0.3)),
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
    required int streakDays,
    VoidCallback? onSeeMore,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StreakModal(
              streakDays: streakDays,
              onSeeMore: () {
                Navigator.of(ctx).pop();
                onSeeMore?.call();
              },
            ),
          ),
        ),
      ),
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
