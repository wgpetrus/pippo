import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../controllers/profile_controller.dart';
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
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    
    // Carregar perfil do usuário ao iniciar
    _controller.loadUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Perfil'),
      body: Obx(() {
        // Mostrar loading
        if (_controller.isLoadingProfile.value) {
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
              const SizedBox(height: 8),

              // Card azul do perfil
              ProfileCard(
                avatarAsset: _getAvatarAsset(userData['avatarId'] ?? 'avatar_01'),
                name: userData['name'] ?? '',
                username: userData['username'] ?? '',
                following: userData['followingCount'] ?? 0,
                followers: userData['followersCount'] ?? 0,
                flagAsset: _getCountryFlag(userData['country'] ?? 'BR'),
                coursesCount: userData['coursesCount'] ?? 0,
                isOwnProfile: false,
                showFollowButton: true,
                isFollowing: _controller.isFollowingViewedUser.value,
                onFollowTap: () {
                  if (_controller.isFollowingViewedUser.value) {
                    _controller.unfollowUser(widget.userId);
                  } else {
                    _controller.followUser(widget.userId);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Gráfico de progresso semanal
              // TODO: [future] Implementar dados reais do gráfico
              WeeklyProgressChart(
                userProgress: [
                  ChartData('Mon', 50),
                  ChartData('Tue', 100),
                  ChartData('Wed', 150),
                  ChartData('Thu', 200),
                  ChartData('Fri', 250),
                  ChartData('Sat', 500),
                  ChartData('Sun', 1200),
                ],
                otherProgress: [
                  ChartData('Mon', 30),
                  ChartData('Tue', 80),
                  ChartData('Wed', 50),
                  ChartData('Thu', 200),
                  ChartData('Fri', 250),
                  ChartData('Sat', 300),
                  ChartData('Sun', 350),
                ],
                showOther: true,
              ),
              const SizedBox(height: 24),

              // Overview - passar dados do usuário específico
              OverviewSection(
                flagAsset: _getCountryFlag(userData['country'] ?? 'BR'),
                totalXp: userData['totalXp'] ?? 0,
                currentStreak: userData['currentStreak'] ?? 0,
                longestStreak: userData['longestStreak'] ?? 0,
                level: userData['level'] ?? 1,
                useOwnStats: false, // Não usar stats do GamificationController
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
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
