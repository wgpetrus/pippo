import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';

/// Título de seção com emoji
class SectionTitle extends StatelessWidget {
  final String emoji;
  final String title;

  const SectionTitle({
    super.key,
    required this.emoji,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(title, style: AppTheme.textXlBold),
      ],
    );
  }
}
