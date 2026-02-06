import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../friends/views/friends_view.dart';
import '../controllers/profile_social_controller.dart';
import '../widgets/overview_section.dart';
import '../widgets/profile_card.dart';
import '../widgets/weekly_progress_chart.dart';

/// Página de perfil de outro usuário
class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final ProfileSocialController _controller;

  // Ciclo de vida

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileSocialController>();
    
    // Limpar dados anteriores e carregar perfil do usuário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.viewedUserData.clear();
      _controller.errorMessage.value = '';
      _controller.loadUserProfile(widget.userId);
      _controller.loadUserWeeklyProgress(widget.userId);
      _controller.loadWeeklyProgress(); // Carregar progresso do usuário atual para comparação
    });
  }

  // Construção

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Perfil'),
      body: Obx(() {
        // Mostrar loading
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        // Mostrar erro
        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _controller.errorMessage.value,
                    style: AppTheme.textMd.copyWith(color: AppTheme.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _controller.loadUserProfile(widget.userId),
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

        // Verificar se há dados do usuário
        if (_controller.viewedUserData.isEmpty) {
          return const Center(
            child: Text('Usuário não encontrado'),
          );
        }

        final userData = _controller.viewedUserData;

        // Conteúdo do perfil
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.spacing8),

              // Card azul do perfil
              ProfileCard(
                avatarAsset: _getAvatarAsset(userData['avatarId'] ?? 'avatar_01'),
                name: userData['name'] ?? '',
                username: userData['username'] ?? '',
                following: userData['followingCount'] ?? 0,
                followers: userData['followersCount'] ?? 0,
                flagAsset: userData['primaryCourseFlag'] ?? _getCountryFlag(userData['country'] ?? 'BR'),
                coursesCount: userData['coursesCount'] ?? 0,
                isOwnProfile: false,
                showFollowButton: true,
                isFollowing: _controller.isFollowingViewedUser.value,
                onFollowingTap: () {
                  Get.to(
                    () => const FriendsView(),
                    arguments: {
                      'tab': 'following',
                      'userId': widget.userId,
                    },
                  );
                },
                onFollowersTap: () {
                  Get.to(
                    () => const FriendsView(),
                    arguments: {
                      'tab': 'followers',
                      'userId': widget.userId,
                    },
                  );
                },
                onFollowTap: () {
                  if (_controller.isFollowingViewedUser.value) {
                    _controller.unfollowUser(widget.userId);
                  } else {
                    _controller.followUser(widget.userId);
                  }
                },
              ),
              SizedBox(height: r.spacing24),

              // Gráfico de progresso semanal
              Obx(() {
                // Converter dados do controller para ChartData
                final currentUserProgress = _controller.weeklyProgress
                    .map((day) => ChartData(
                          day['day'] as String,
                          (day['xp'] as int).toDouble(),
                        ))
                    .toList();

                final viewedUserProgress = _controller.viewedUserWeeklyProgress
                    .map((day) => ChartData(
                          day['day'] as String,
                          (day['xp'] as int).toDouble(),
                        ))
                    .toList();

                // Se não houver dados, mostrar valores zerados
                final hasCurrentUserData = currentUserProgress.isNotEmpty;
                final hasViewedUserData = viewedUserProgress.isNotEmpty;

                return WeeklyProgressChart(
                  userProgress: hasCurrentUserData
                      ? currentUserProgress
                      : [
                          ChartData('Sun', 0),
                          ChartData('Mon', 0),
                          ChartData('Tue', 0),
                          ChartData('Wed', 0),
                          ChartData('Thu', 0),
                          ChartData('Fri', 0),
                          ChartData('Sat', 0),
                        ],
                  otherProgress: hasViewedUserData
                      ? viewedUserProgress
                      : [
                          ChartData('Sun', 0),
                          ChartData('Mon', 0),
                          ChartData('Tue', 0),
                          ChartData('Wed', 0),
                          ChartData('Thu', 0),
                          ChartData('Fri', 0),
                          ChartData('Sat', 0),
                        ],
                  showOther: true,
                );
              }),
              SizedBox(height: r.spacing24),

              // Overview
              OverviewSection(
                flagAsset: userData['primaryCourseFlag'] ?? _getCountryFlag(userData['country'] ?? 'BR'),
                totalXp: userData['totalXp'] ?? 0,
                currentStreak: userData['currentStreak'] ?? 0,
                longestStreak: userData['longestStreak'] ?? 0,
                level: userData['level'] ?? 1,
                useOwnStats: false,
              ),
            ],
          ),
        );
      }),
    );
  }

  // Auxiliares

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
        return AppAssets.charMara;
    }
  }

  String _getCountryFlag(String countryCode) {
    switch (countryCode) {
      case 'BR':
        return AppAssets.flagBrazil;
      case 'US':
        return AppAssets.flagUsa;
      case 'FR':
        return AppAssets.flagFrance;
      case 'ES':
        return AppAssets.flagSpain;
      case 'DE':
        return AppAssets.flagGermany;
      case 'CN':
        return AppAssets.flagChina;
      case 'JP':
        return AppAssets.flagJapan;
      case 'SA':
        return AppAssets.flagSaudit;
      default:
        return AppAssets.flagBrazil;
    }
  }
}
