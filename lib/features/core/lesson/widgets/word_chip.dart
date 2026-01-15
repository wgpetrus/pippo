import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';

/// Chip de palavra para exercício de ordenação
class WordChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isEmpty;
  final VoidCallback? onTap;

  const WordChip({
    super.key,
    required this.text,
    this.isSelected = false,
    this.isEmpty = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return _buildEmptySlot();
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.gray700 : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.gray600 : AppTheme.gray600,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? null
              : [
                  const BoxShadow(
                    color: AppTheme.gray500,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Text(
          text,
          style: AppTheme.textMdSemibold.copyWith(
            color: isSelected ? AppTheme.gray500 : AppTheme.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.gray700_50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.gray600,
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Text(
        text,
        style: AppTheme.textMdSemibold.copyWith(
          color: Colors.transparent,
        ),
      ),
    );
  }
}
