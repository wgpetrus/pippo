import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import 'word_chip.dart';

/// Zona de palavras selecionadas (resposta)
class WordZone extends StatelessWidget {
  final List<String> words;
  final Function(int) onWordTap;
  final int maxSlots;

  const WordZone({
    super.key,
    required this.words,
    required this.onWordTap,
    this.maxSlots = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.gray600, width: 1),
          bottom: BorderSide(color: AppTheme.gray600, width: 1),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (int i = 0; i < words.length; i++)
            WordChip(
              text: words[i],
              onTap: () => onWordTap(i),
            ),
        ],
      ),
    );
  }
}
