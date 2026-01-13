import 'package:flutter/material.dart';

/// Widget com animação de flutuação suave
class AppFloatAnim extends StatefulWidget {
  final Widget child;
  final double distance;
  final int durationMs;
  final int delayMs;

  const AppFloatAnim({
    super.key,
    required this.child,
    this.distance = 6,
    this.durationMs = 1500,
    this.delayMs = 0,
  });

  @override
  State<AppFloatAnim> createState() => _AppFloatAnimState();
}

class _AppFloatAnimState extends State<AppFloatAnim>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.durationMs),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: -widget.distance).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Delay para iniciar a animação
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _started = true;
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _started ? _animation.value : 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
