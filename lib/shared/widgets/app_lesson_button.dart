import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';

/// Status do botão de lição
enum LessonStatus {
  locked,    // Bloqueado (cinza)
  available, // Disponível (azul)
  completed, // Completo (dourado)
}

/// Botão circular de lição no caminho
class AppLessonButton extends StatefulWidget {
  final String iconAsset;
  final LessonStatus status;
  final VoidCallback? onPressed;
  final double size;
  final String? effectAsset;
  final double? progress; // 0.0 a 1.0

  const AppLessonButton({
    super.key,
    required this.iconAsset,
    required this.status,
    this.onPressed,
    this.size = 64,
    this.effectAsset,
    this.progress,
  });

  @override
  State<AppLessonButton> createState() => _AppLessonButtonState();
}

class _AppLessonButtonState extends State<AppLessonButton> {
  bool _isPressed = false;

  bool get _isDisabled => widget.status == LessonStatus.locked;
  double get _shadowHeight => 8.0;
  double get _ringSize => widget.size + 12;

  @override
  Widget build(BuildContext context) {
    final hasProgress = widget.progress != null && widget.progress! > 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: _isDisabled ? null : (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: _isDisabled ? null : () => setState(() => _isPressed = false),
      child: SizedBox(
        width: _ringSize + 20,
        height: _ringSize + _shadowHeight + 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sombra (borda inferior)
            Positioned(
              top: _shadowHeight + 10,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getShadowColor(),
                ),
              ),
            ),

            // Anel de progresso
            if (hasProgress)
              Positioned(
                top: _isPressed ? _shadowHeight + 8 : 8,
                child: SizedBox(
                  width: _ringSize,
                  height: _ringSize,
                  child: CustomPaint(
                    painter: _ProgressRingPainter(
                      progress: widget.progress!,
                      color: AppTheme.primaryLight,
                      backgroundColor: AppTheme.white,
                    ),
                  ),
                ),
              ),

            // Círculo principal com efeito e ícone
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              top: _isPressed ? _shadowHeight + 10 : 10,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getBackgroundColor(),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Efeito SVG (estrelas, zebra, etc)
                    if (widget.effectAsset != null)
                      ClipOval(
                        child: SvgPicture.asset(
                          widget.effectAsset!,
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.cover,
                        ),
                      ),

                    // Ícone SVG
                    SvgPicture.asset(
                      widget.iconAsset,
                      width: widget.size * 0.5,
                      height: widget.size * 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos privados
  Color _getBackgroundColor() {
    switch (widget.status) {
      case LessonStatus.locked:
        return AppTheme.gray400;
      case LessonStatus.available:
        return AppTheme.primary;
      case LessonStatus.completed:
        return AppTheme.gold;
    }
  }

  Color _getShadowColor() {
    switch (widget.status) {
      case LessonStatus.locked:
        return AppTheme.gray300;
      case LessonStatus.available:
        return AppTheme.primaryDark;
      case LessonStatus.completed:
        return AppTheme.darkYellow;
    }
  }
}

/// Painter do anel de progresso
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 6.0;

    // Fundo do anel
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progresso
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -90 * (3.14159 / 180); // Começa do topo
    final sweepAngle = 360 * progress * (3.14159 / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
