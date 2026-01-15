import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import 'profile_card.dart';

/// Header colapsável do profile com card azul
class ProfileHeader extends StatelessWidget {
  final String title;
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

  const ProfileHeader({
    super.key,
    required this.title,
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
    // Altura maior se tiver botão Follow back
    final baseHeight = showFollowButton ? 340.0 : 260.0;
    final expandedHeight = ResponsiveUtils.height(
      baseHeight,
      min: showFollowButton ? 280.0 : 220.0,
      max: showFollowButton ? 380.0 : 300.0,
    );
    
    return SliverAppBar(
      backgroundColor: AppTheme.white,
      surfaceTintColor: AppTheme.white,
      elevation: 0,
      pinned: true,
      expandedHeight: expandedHeight,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      title: Text(title, style: AppTheme.displaySmBold),
      titleSpacing: 20,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Container(
            color: AppTheme.white,
            padding: const EdgeInsets.only(top: 70),
            child: ProfileCard(
              avatarAsset: avatarAsset,
              name: name,
              username: username,
              following: following,
              followers: followers,
              flagAsset: flagAsset,
              coursesCount: coursesCount,
              isOwnProfile: isOwnProfile,
              showFollowButton: showFollowButton,
              onSettingsTap: onSettingsTap,
              onFollowingTap: onFollowingTap,
              onFollowersTap: onFollowersTap,
              onFollowTap: onFollowTap,
              onAvatarTap: onAvatarTap,
            ),
          ),
        ),
      ),
    );
  }
}
