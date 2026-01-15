import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';

/// Estados do card de opção de lição
enum LessonOptionStatus {
  normal,
  selected,
  correct,
  wrong,
}

/// Card genérico de opção selecionável para exercícios de lição
class LessonOptionCard extends StatelessWidget {
  final String? imageAsset;
  final String label;
  final LessonOptionStatus status;
  final VoidCallback? onTap;
  final bool showImage;

  const LessonOptionCard({
    super.key,
    this.imageAsset,
    required this.label,
    this.status = LessonOptionStatus.normal,
    this.onTap,
    this.showImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: showImage ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 2),
          boxShadow: _hasShadow
              ? [BoxShadow(color: _shadowColor, offset: const Offset(0, 4), blurRadius: 0)]
              : null,
        ),
        child: showImage ? _buildWithImage() : _buildTextOnly(),
      ),
    );
  }

  // Layout com imagem
  Widget _buildWithImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(imageAsset!, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.textMdSemibold.copyWith(color: _textColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Layout só texto
  Widget _buildTextOnly() {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              label,
              style: AppTheme.textLgSemibold.copyWith(color: _textColor),
            ),
          ),
        ),
        if (_showCheckIcon) _buildCheckIcon(),
      ],
    );
  }

  // Ícone de check/x
  Widget _buildCheckIcon() {
    final isCorrect = status == LessonOptionStatus.correct;
    final iconColor = isCorrect ? AppTheme.green : AppTheme.red;
    final iconDarkColor = isCorrect ? const Color(0xFF28A000) : const Color(0xFFCC0000);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconDarkColor,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconColor,
        ),
        child: Center(
          child: FaIcon(
            isCorrect ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
            color: AppTheme.white,
            size: 14,
          ),
        ),
      ),
    );
  }

  // Helpers

  bool get _hasShadow =>
      status == LessonOptionStatus.selected ||
      status == LessonOptionStatus.correct ||
      status == LessonOptionStatus.wrong;

  bool get _showCheckIcon =>
      status == LessonOptionStatus.correct ||
      status == LessonOptionStatus.wrong;

  Color get _backgroundColor {
    switch (status) {
      case LessonOptionStatus.selected:
        return AppTheme.primary100;
      case LessonOptionStatus.correct:
        return AppTheme.green100;
      case LessonOptionStatus.wrong:
        return AppTheme.red100;
      case LessonOptionStatus.normal:
        return AppTheme.white;
    }
  }

  Color get _borderColor {
    switch (status) {
      case LessonOptionStatus.selected:
        return AppTheme.primary;
      case LessonOptionStatus.correct:
        return AppTheme.green;
      case LessonOptionStatus.wrong:
        return AppTheme.red;
      case LessonOptionStatus.normal:
        return AppTheme.gray600;
    }
  }

  Color get _shadowColor {
    switch (status) {
      case LessonOptionStatus.selected:
        return AppTheme.primary;
      case LessonOptionStatus.correct:
        return AppTheme.green;
      case LessonOptionStatus.wrong:
        return AppTheme.red;
      case LessonOptionStatus.normal:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    switch (status) {
      case LessonOptionStatus.selected:
        return AppTheme.primary;
      case LessonOptionStatus.correct:
        return AppTheme.green;
      case LessonOptionStatus.wrong:
        return AppTheme.red;
      case LessonOptionStatus.normal:
        return AppTheme.black;
    }
  }
}
