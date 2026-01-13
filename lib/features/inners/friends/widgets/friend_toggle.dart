import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../../shared/theme/theme.dart';

/// Toggle de Following/Followers
class FriendToggle extends StatelessWidget {
  final bool isFollowing;
  final ValueChanged<bool> onToggle;

  const FriendToggle({
    super.key,
    required this.isFollowing,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      initialLabelIndex: isFollowing ? 0 : 1,
      totalSwitches: 2,
      labels: const ['Following', 'Followers'],
      activeBgColor: const [AppTheme.primary],
      activeFgColor: AppTheme.white,
      inactiveBgColor: AppTheme.white,
      inactiveFgColor: AppTheme.gray400,
      borderColor: const [AppTheme.gray600],
      borderWidth: 1,
      minWidth: double.infinity,
      minHeight: 48,
      cornerRadius: 24,
      radiusStyle: true,
      customTextStyles: const [AppTheme.textMdBold, AppTheme.textMdBold],
      onToggle: (index) => onToggle(index == 0),
    );
  }
}
