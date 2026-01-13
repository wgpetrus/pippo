import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';

/// Card azul do perfil do usuário
class ProfileCard extends StatelessWidget {
  final String avatarAsset;
  final String name;
  final String username;
  final int following;
  final int followers;
  final String flagAsset;
  final int coursesCount;
  final bool isOwnProfile;
  final bool showFollowButton;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onAvatarTap;

  const ProfileCard({
    super.key,
    required this.avatarAsset,
    required this.name,
    required this.username,
    required this.following,
    required this.followers,
    required this.flagAsset,
    required this.coursesCount,
    this.isOwnProfile = true,
    this.showFollowButton = false,
    this.onSettingsTap,
    this.onFollowingTap,
    this.onFollowersTap,
    this.onFollowTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.blueDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Header: Avatar, nome e settings
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              GestureDetector(
                onTap: isOwnProfile ? onAvatarTap : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.pink100,
                  ),
                  child: ClipOval(
                    child: Image.asset(avatarAsset, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Nome e username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$username',
                      style: AppTheme.textMdRegular.copyWith(
                        color: AppTheme.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Ícone de configurações (próprio perfil) ou follow (outro perfil)
              if (isOwnProfile)
                GestureDetector(
                  onTap: onSettingsTap,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SvgPicture.asset(
                      AppAssets.profileSettings,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SvgPicture.asset(
                    AppAssets.profileFollow,
                    width: 28,
                    height: 28,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),

          // Stats: Following, Followers, Courses
          Row(
            children: [
              // Following
              Expanded(
                child: GestureDetector(
                  onTap: onFollowingTap,
                  child: _buildStat('$following', 'Following'),
                ),
              ),

              // Followers
              Expanded(
                child: GestureDetector(
                  onTap: onFollowersTap,
                  child: _buildStat('$followers', 'Followers'),
                ),
              ),

              // Courses
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(flagAsset, width: 28, height: 20, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+$coursesCount',
                          style: AppTheme.displayXsBold.copyWith(color: AppTheme.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Courses',
                      style: AppTheme.textMdRegular.copyWith(
                        color: AppTheme.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Botão Follow back (se não for próprio perfil)
          if (showFollowButton) ...[
            const SizedBox(height: 16),
            AppButton(
              text: 'Follow back',
              isPrimary: false,
              onPressed: onFollowTap,
            ),
          ],
        ],
      ),
    );
  }

  // Widgets
  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.displayXsBold.copyWith(color: AppTheme.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTheme.textMdRegular.copyWith(
            color: AppTheme.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
