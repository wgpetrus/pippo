import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';

/// Botão de áudio com palavra para exercícios
class AudioWordButton extends StatelessWidget {
  final String word;
  final VoidCallback? onTap;

  const AudioWordButton({
    super.key,
    required this.word,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão de áudio
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.volumeHigh,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Palavra
        Text(
          word,
          style: AppTheme.textXlBold.copyWith(color: AppTheme.primary),
        ),
      ],
    );
  }
}
