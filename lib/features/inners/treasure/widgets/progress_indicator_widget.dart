import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';

/// Widget de indicador de progresso customizado para desafios
/// 
/// Exibe uma barra de progresso animada com porcentagem ou fração.
class ProgressIndicatorWidget extends StatefulWidget {
  final int progress;
  final int goal;
  final bool showFraction; // true = "1/3", false = "33%"

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.goal,
    this.showFraction = true,
  });

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: _calculateProgress()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress ||
        oldWidget.goal != widget.goal) {
      _previousProgress = _calculateProgress(
        progress: oldWidget.progress,
        goal: oldWidget.goal,
      );
      _animation = Tween<double>(
        begin: _previousProgress,
        end: _calculateProgress(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateProgress({int? progress, int? goal}) {
    final p = progress ?? widget.progress;
    final g = goal ?? widget.goal;
    if (g == 0) return 0.0;
    return (p / g).clamp(0.0, 1.0);
  }

  String _getProgressText() {
    if (widget.showFraction) {
      return '${widget.progress}/${widget.goal}';
    } else {
      final percentage = (_calculateProgress() * 100).toInt();
      return '$percentage%';
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de progresso
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                // Background
                Container(
                  height: r.spacing8,
                  decoration: BoxDecoration(
                    color: AppTheme.gray700,
                    borderRadius: BorderRadius.circular(r.spacing8),
                  ),
                ),
                
                // Progresso
                FractionallySizedBox(
                  widthFactor: _animation.value,
                  child: Container(
                    height: r.spacing8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(r.spacing8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary30,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        
        SizedBox(height: r.spacing8),
        
        // Texto de progresso
        Text(
          _getProgressText(),
          style: AppTheme.textSmSemibold.copyWith(
            color: AppTheme.gray300,
          ),
        ),
      ],
    );
  }
}
