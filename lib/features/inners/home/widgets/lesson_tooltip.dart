import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';

/// Tooltip de lição (Start/Continue)
class LessonTooltip extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const LessonTooltip({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Balão
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.white, width: 2),
            ),
            child: Text(
              text,
              style: AppTheme.textMdBold.copyWith(color: AppTheme.white),
            ),
          ),

          // Setinha
          CustomPaint(
            size: const Size(16, 8),
            painter: _TooltipArrowPainter(),
          ),
        ],
      ),
    );
  }
}

/// Painter da setinha do tooltip
class _TooltipArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppTheme.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Borda nos lados
    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
