import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';

/// Mascote com balão de fala e botão de áudio
class MascotBubble extends StatelessWidget {
  final String mascotAsset;
  final String text;
  final VoidCallback? onAudioTap;

  const MascotBubble({
    super.key,
    required this.mascotAsset,
    required this.text,
    this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mascote
        Image.asset(
          mascotAsset,
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),

        const SizedBox(width: 8),

        // Balão de fala com áudio
        Expanded(
          child: GestureDetector(
            onTap: onAudioTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.gray600, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone de áudio
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary100,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.volumeHigh,
                        color: AppTheme.primary,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Texto
                  Flexible(
                    child: Text(
                      text,
                      style: AppTheme.textMdSemibold.copyWith(
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
