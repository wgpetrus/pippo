import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';

/// Estados do card de áudio
enum AudioCardStatus {
  normal,
  selected,
  matched,
}

/// Card de áudio para exercício de matching
class AudioCard extends StatelessWidget {
  final AudioCardStatus status;
  final VoidCallback? onTap;

  const AudioCard({
    super.key,
    this.status = AudioCardStatus.normal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: 2),
          boxShadow: status == AudioCardStatus.selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de áudio
            FaIcon(
              FontAwesomeIcons.volumeHigh,
              color: _iconColor,
              size: 16,
            ),
            const SizedBox(width: 8),

            // Waveform
            _buildWaveform(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(12, (index) {
        final heights = [0.4, 0.6, 0.3, 0.8, 1.0, 0.7, 0.5, 0.9, 0.6, 0.4, 0.7, 0.5];
        return Container(
          width: 3,
          height: 24 * heights[index],
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: _iconColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  // Helpers

  Color get _backgroundColor {
    switch (status) {
      case AudioCardStatus.selected:
        return AppTheme.primary100;
      case AudioCardStatus.matched:
        return AppTheme.white;
      case AudioCardStatus.normal:
        return AppTheme.white;
    }
  }

  Color get _borderColor {
    switch (status) {
      case AudioCardStatus.selected:
        return AppTheme.primary;
      case AudioCardStatus.matched:
        return AppTheme.gray600;
      case AudioCardStatus.normal:
        return AppTheme.primary;
    }
  }

  Color get _iconColor {
    switch (status) {
      case AudioCardStatus.selected:
        return AppTheme.primary;
      case AudioCardStatus.matched:
        return AppTheme.gray500;
      case AudioCardStatus.normal:
        return AppTheme.primary;
    }
  }
}
