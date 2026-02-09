import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';

/// Tile de amigo na lista
class FriendTile extends StatelessWidget {
  final String name;
  final int xp;
  final String avatar;
  final bool isFollowed;
  final bool showFollowAction;
  final VoidCallback? onTap;
  final bool isMockData;

  const FriendTile({
    super.key,
    required this.name,
    required this.xp,
    required this.avatar,
    required this.isFollowed,
    this.showFollowAction = false,
    this.onTap,
    this.isMockData = false,
  });

  @override
  Widget build(BuildContext context) {
    final spacing12 = ResponsiveUtils.width(12, min: 8, max: 16);
    final spacing4 = ResponsiveUtils.width(4, min: 2, max: 6);
    final spacing16 = ResponsiveUtils.width(16, min: 12, max: 20);
    final borderWidth = ResponsiveUtils.width(2, min: 1.5, max: 2.5);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing16),
        child: Row(
          children: [
            // Avatar
            Builder(
              builder: (context) {
                final avatarSize = ResponsiveUtils.width(48, min: 40, max: 56);
                final avatarAsset = _getAvatarAsset(avatar);
                
                return Stack(
                  children: [
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.pink100,
                      ),
                      child: ClipOval(
                        child: Image.asset(avatarAsset, fit: BoxFit.cover),
                      ),
                    ),
                    // Placeholder icon for mock data
                    if (isMockData)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: avatarSize * 0.35,
                          height: avatarSize * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.orange,
                            border: Border.all(color: AppTheme.white, width: borderWidth),
                          ),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.flask,
                              color: AppTheme.white,
                              size: avatarSize * 0.18,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(width: spacing12),

            // Nome e XP
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.textMdBold),
                  SizedBox(height: spacing4),
                  Text(
                    'friends_xp_label'.tr.replaceAll('{xp}', xp.toString()),
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

  // Helpers
  String _getAvatarAsset(String avatarId) {
    switch (avatarId) {
      case 'avatar_01':
        return AppAssets.charMara;
      case 'avatar_02':
        return AppAssets.charDafny;
      case 'avatar_03':
        return AppAssets.charDiogo;
      case 'avatar_04':
        return AppAssets.charFrancilene;
      case 'avatar_05':
        return AppAssets.charGlauciane;
      case 'avatar_06':
        return AppAssets.charLindoedson;
      case 'avatar_07':
        return AppAssets.charRenner;
      default:
        // Se já for um asset path, retornar como está (para compatibilidade com mock data)
        if (avatarId.contains('AppAssets') || avatarId.contains('assets/')) {
          return avatarId;
        }
        return AppAssets.charMara;
    }
  }

  // Widgets
  Widget _buildActionButton() {
    final buttonSize = ResponsiveUtils.width(40, min: 36, max: 44);
    final iconSize = ResponsiveUtils.width(16, min: 14, max: 18);
    final iconSizeSmall = ResponsiveUtils.width(14, min: 12, max: 16);

    // Na aba Following: mostra seta para ir ao perfil
    if (!showFollowAction) {
      return Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.gray600),
        ),
        child: Center(
          child: FaIcon(FontAwesomeIcons.chevronRight, color: AppTheme.gray400, size: iconSize),
        ),
      );
    }

    // Followers - mostra estado de follow
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFollowed ? AppTheme.primary : AppTheme.white,
        border: Border.all(color: isFollowed ? AppTheme.primary : AppTheme.gray600),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.userGroup,
          color: isFollowed ? AppTheme.white : AppTheme.green,
          size: iconSizeSmall,
        ),
      ),
    );
  }
}
