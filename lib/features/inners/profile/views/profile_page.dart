import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../friends/views/friends_view.dart';
import '../widgets/change_avatar_modal.dart';
import '../widgets/complete_profile_card.dart';
import '../widgets/overview_section.dart';
import '../widgets/profile_header.dart';
import 'settings_page.dart';

/// Página de perfil do usuário (próprio perfil)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header com card azul
          ProfileHeader(
            title: 'Perfil',
            avatarAsset: AppAssets.charMara,
            name: 'Sam',
            username: 'sam1201',
            following: 30,
            followers: 22,
            flagAsset: AppAssets.flagFrance,
            coursesCount: 2,
            isOwnProfile: true,
            showFollowButton: false,
            onSettingsTap: () {
              Get.to(() => const SettingsPage());
            },
            onFollowingTap: () {
              Get.to(() => const FriendsView(), arguments: {'tab': 'following'});
            },
            onFollowersTap: () {
              Get.to(() => const FriendsView(), arguments: {'tab': 'followers'});
            },
            onAvatarTap: () {
              ChangeAvatarModal.show(
                context,
                currentAvatar: AppAssets.charMara,
                onAvatarSelected: (avatar) {
                  // TODO: Atualizar avatar
                },
              );
            },
          ),

          // Card "Finish your profile"
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                CompleteProfileCard(
                  stepsLeft: 2,
                  onTap: () {
                    // TODO: Navegar para completar perfil
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Overview
          SliverToBoxAdapter(
            child: OverviewSection(
              xp: 9120,
              streak: 6,
              level: 12,
              flagAsset: AppAssets.flagFrance,
            ),
          ),

          // Espaço para bottom bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}
