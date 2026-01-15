import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';

/// Imagem com balão de label para exercícios de tradução
class ImageWithLabel extends StatelessWidget {
  final String imageAsset;
  final String label;

  const ImageWithLabel({
    super.key,
    required this.imageAsset,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Imagem
        Image.asset(
          imageAsset,
          height: 120,
          fit: BoxFit.contain,
        ),

        const SizedBox(width: 8),

        // Balão com label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.gray600, width: 1),
          ),
          child: Text(
            label,
            style: AppTheme.textMdSemibold.copyWith(color: AppTheme.black),
          ),
        ),
      ],
    );
  }
}
