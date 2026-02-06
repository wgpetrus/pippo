import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../profile/controllers/profile_social_controller.dart';
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
  late final ProfileSocialController _controller;
  late bool _isFollowing;
  late String? _userId;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileSocialController>();
    
    final args = Get.arguments as Map<String, dynamic>?;
    _isFollowing = args?['tab'] != 'followers';
    _userId = args?['userId'] as String?;

    // Carregar dados
    _loadData();
  }

  Future<void> _loadData() async {
    if (_userId != null && _userId!.isNotEmpty) {
      // Carregar following/followers de outro usuário
      if (_isFollowing) {
        await _controller.loadUserFollowing(_userId!);
      } else {
        await _controller.loadUserFollowers(_userId!);
      }
    } else {
      // Carregar following/followers do usuário atual
      if (_isFollowing) {
        await _controller.loadFollowing();
      } else {
        await _controller.loadFollowers();
      }
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Amigos'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: r.spacing16),

          // Toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.spacing16),
            child: FriendToggle(
              isFollowing: _isFollowing,
              onToggle: (value) {
                setState(() => _isFollowing = value);
                _loadData();
              },
            ),
          ),
          SizedBox(height: r.spacing16),

          // Contador
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.spacing16),
            child: Obx(() {
              final count = _isFollowing
                  ? _controller.following.length
                  : _controller.followers.length;
              final label = _isFollowing ? 'Seguindo' : 'Seguidores';
              return Text(
                '$count $label',
                style: AppTheme.textLgBold,
              );
            }),
          ),
          SizedBox(height: r.spacing16),

          // Lista
          Expanded(
            child: Obx(() {
              // Loading
              if (_controller.isLoadingSocial.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              // Erro
              if (_controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(r.spacing16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _controller.errorMessage.value,
                          style: AppTheme.textMd.copyWith(color: AppTheme.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: r.spacing16),
                        TextButton(
                          onPressed: _loadData,
                          child: Text(
                            'Tentar novamente',
                            style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final friends = _isFollowing
                  ? _controller.following
                  : _controller.followers;

              // Lista vazia
              if (friends.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(r.spacing16),
                    child: Text(
                      _isFollowing
                          ? 'Você ainda não está seguindo ninguém.'
                          : 'Você ainda não tem seguidores.',
                      style: AppTheme.textMd.copyWith(color: AppTheme.gray500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Lista de amigos
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return FriendTile(
                    name: friend['name'] ?? 'Usuário',
                    xp: friend['totalXp'] ?? 0,
                    avatar: friend['avatarId'] ?? 'avatar_01',
                    isFollowed: _controller.isUserFollowed(friend['userId'] as String),
                    showFollowAction: !_isFollowing,
                    isMockData: false,
                    onTap: () => Get.to(() => UserProfilePage(
                          userId: friend['userId'] as String,
                        )),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
