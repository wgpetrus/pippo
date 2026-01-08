import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';

/// Widget do mascote com animação de bounce e balão de fala
class BouncingMascot extends StatefulWidget {
  final String asset;
  final String? bubbleText;
  final double mascotSize;

  const BouncingMascot({
    super.key,
    required this.asset,
    this.bubbleText,
    this.mascotSize = 140,
  });

  @override
  State<BouncingMascot> createState() => _BouncingMascotState();
}

class _BouncingMascotState extends State<BouncingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnim;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: widget.bubbleText != null
              ? _buildWithBubble()
              : Image.asset(widget.asset, width: widget.mascotSize, fit: BoxFit.contain),
        );
      },
    );
  }

  // Widgets
  Widget _buildWithBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          widget.asset,
          width: widget.mascotSize,
          height: widget.mascotSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: CustomPaint(
                  size: const Size(10, 16),
                  painter: _LeftArrowPainter(),
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.bubbleText!,
                    style: AppTheme.textMdSemibold.copyWith(color: AppTheme.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Painter para seta do balão de fala
class _LeftArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
