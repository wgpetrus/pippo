import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../profile/views/user_profile_page.dart';
import '../widgets/friend_tile.dart';
import '../widgets/friend_toggle.dart';

/// Tela de Following/Followers
class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  late bool _isFollowing;

  // Mock data
  final _friends = [
    {'name': 'Haruto', 'xp': 45204, 'avatar': AppAssets.charMara, 'isFollowed': true},
    {'name': 'Sam', 'xp': 1204, 'avatar': AppAssets.charDiogo, 'isFollowed': false},
    {'name': 'Jack', 'xp': 72, 'avatar': AppAssets.charFrancilene, 'isFollowed': false},
    {'name': 'Samurai', 'xp': 49, 'avatar': AppAssets.charGlauciane, 'isFollowed': false},
    {'name': 'Miyuki', 'xp': 3005, 'avatar': AppAssets.charLindoedson, 'isFollowed': true},
    {'name': 'Riku', 'xp': 987, 'avatar': AppAssets.charRenner, 'isFollowed': false},
    {'name': 'Aiko', 'xp': 210, 'avatar': AppAssets.charDafny, 'isFollowed': false},
  ];

  // Lifecycle
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _isFollowing = args?['tab'] != 'followers';
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Amigos'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FriendToggle(
              isFollowing: _isFollowing,
              onToggle: (value) => setState(() => _isFollowing = value),
            ),
          ),
          const SizedBox(height: 24),

          // Contador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _isFollowing ? '2500 Seguindo' : '1500 Seguidores',
              style: AppTheme.textLgBold,
            ),
          ),
          const SizedBox(height: 16),

          // Lista
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return FriendTile(
                  name: friend['name'] as String,
                  xp: friend['xp'] as int,
                  avatar: friend['avatar'] as String,
                  isFollowed: friend['isFollowed'] as bool,
                  showFollowAction: !_isFollowing,
                  onTap: () => Get.to(() => UserProfilePage(
                        name: friend['name'] as String,
                        username: (friend['name'] as String).toLowerCase(),
                        avatarAsset: friend['avatar'] as String,
                        xp: friend['xp'] as int,
                      )),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
