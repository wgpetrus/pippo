import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';

/// Tile de amigo na lista
class FriendTile extends StatelessWidget {
  final String name;
  final int xp;
  final String avatar;
  final bool isFollowed;
  final bool showFollowAction;
  final VoidCallback? onTap;

  const FriendTile({
    super.key,
    required this.name,
    required this.xp,
    required this.avatar,
    required this.isFollowed,
    this.showFollowAction = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.pink100,
              ),
              child: ClipOval(
                child: Image.asset(avatar, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),

            // Nome e XP
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.textMdBold),
                  const SizedBox(height: 4),
                  Text(
                    '$xp XP',
                    style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray400),
                  ),
                ],
              ),
            ),

            // Botão de ação
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _buildActionButton() {
    // Na aba Following: mostra seta para ir ao perfil
    if (!showFollowAction) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.gray600),
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.chevronRight, color: AppTheme.gray400, size: 16),
        ),
      );
    }

    // Followers - mostra estado de follow
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFollowed ? AppTheme.primary : AppTheme.white,
        border: Border.all(color: isFollowed ? AppTheme.primary : AppTheme.gray600),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.userGroup,
          color: isFollowed ? AppTheme.white : AppTheme.green,
          size: 14,
        ),
      ),
    );
  }
}
