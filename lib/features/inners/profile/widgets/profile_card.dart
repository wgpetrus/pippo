import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
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
  final bool isFollowing;
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
    this.isFollowing = false,
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A5F), // Azul escuro mais rico
            Color(0xFF2C5282), // Azul médio
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blueDark.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Padrão decorativo de fundo
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.white.withOpacity(0.03),
              ),
            ),
          ),
          
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header: Avatar, nome e settings
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar com borda e sombra
                    GestureDetector(
                      onTap: isOwnProfile ? onAvatarTap : null,
                      child: Builder(
                        builder: (context) {
                          final avatarSize = ResponsiveUtils.width(72, min: 56, max: 80);
                          return Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.white.withOpacity(0.3),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.pink100,
                              ),
                              child: ClipOval(
                                child: Image.asset(avatarAsset, fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Nome e username
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: AppTheme.displayXsBold.copyWith(
                              color: AppTheme.white,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

                    // Botão de configurações com fundo
                    if (isOwnProfile)
                      GestureDetector(
                        onTap: onSettingsTap,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SvgPicture.asset(
                            AppAssets.profileSettings,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              AppTheme.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset(
                          AppAssets.profileFollow,
                          width: 20,
                          height: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Divisor sutil
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.white.withOpacity(0),
                        AppTheme.white.withOpacity(0.2),
                        AppTheme.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats: Following, Followers, Courses
                Row(
                  children: [
                    // Following
                    Expanded(
                      child: GestureDetector(
                        onTap: onFollowingTap,
                        child: _buildStat(
                          '$following',
                          'profile_card_following',
                          FontAwesomeIcons.userGroup,
                        ),
                      ),
                    ),

                    // Divisor vertical
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.white.withOpacity(0.2),
                    ),

                    // Followers
                    Expanded(
                      child: GestureDetector(
                        onTap: onFollowersTap,
                        child: _buildStat(
                          '$followers',
                          'profile_card_followers',
                          FontAwesomeIcons.users,
                        ),
                      ),
                    ),

                    // Divisor vertical
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.white.withOpacity(0.2),
                    ),

                    // Courses
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppTheme.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Image.asset(
                                    flagAsset,
                                    width: 28,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+$coursesCount',
                                style: AppTheme.displayXsBold.copyWith(
                                  color: AppTheme.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'profile_card_courses'.tr,
                            style: AppTheme.textSmRegular.copyWith(
                              color: AppTheme.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Botão Follow/Following (se não for próprio perfil)
                if (showFollowButton) ...[
                  const SizedBox(height: 20),
                  AppButton(
                    text: isFollowing ? 'profile_card_following'.tr : 'profile_card_follow'.tr,
                    isPrimary: !isFollowing,
                    onPressed: onFollowTap,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 14,
              color: AppTheme.white.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: AppTheme.displayXsBold.copyWith(
                color: AppTheme.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label.tr,
          style: AppTheme.textSmRegular.copyWith(
            color: AppTheme.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
