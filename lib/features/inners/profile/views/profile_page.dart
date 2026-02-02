import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../friends/views/friends_view.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/change_avatar_modal.dart';
import '../widgets/complete_profile_card.dart';
import '../widgets/find_friends_card.dart';
import '../widgets/overview_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/weekly_progress_chart.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';

/// Página de perfil do usuário (próprio perfil)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  late final ProfileController _controller;
  late final GamificationController _gamification;

  @override
  bool get wantKeepAlive => true; // Manter estado da página

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    _gamification = Get.find<GamificationController>();
    
    // Carregar perfil e progresso semanal ao iniciar
    _controller.loadOwnProfile();
    _controller.loadWeeklyProgress();
  }

  // Recarregar dados quando a página é exibida
  void _refreshData() {
    _controller.loadOwnProfile();
    _controller.loadWeeklyProgress();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: AppTheme.white,
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
                    onPressed: () => _controller.loadOwnProfile(),
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

        // Conteúdo do perfil
        return RefreshIndicator(
          onRefresh: () async {
            await _controller.loadOwnProfile();
            await _controller.loadWeeklyProgress();
          },
          color: AppTheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header com card azul (já é um Sliver, não precisa de SliverToBoxAdapter)
              ProfileHeader(
                title: 'Perfil',
                avatarAsset: _getAvatarAsset(_controller.avatarId.value),
                name: _controller.userName.value,
                username: _controller.username.value,
                following: _controller.followingCount.value,
                followers: _controller.followersCount.value,
                flagAsset: _getCountryFlag(_controller.country.value),
                coursesCount: _controller.userCourses.length,
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
                    currentAvatar: _getAvatarAsset(_controller.avatarId.value),
                    onAvatarSelected: (avatar) {
                      // Extrair avatarId do asset path
                      final avatarId = _getAvatarIdFromAsset(avatar);
                      _controller.updateProfile({'avatarId': avatarId});
                    },
                  );
                },
              ),

            // Card "Finish your profile" (mostrar apenas se incompleto)
            if (_controller.profileCompletionPercentage.value < 100)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    CompleteProfileCard(
                      stepsLeft: _controller.missingFields.length,
                      onTap: () {
                        Get.to(() => const EditProfilePage());
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

            // Card "Encontrar amigos"
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const FindFriendsCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Gráfico de progresso semanal
            SliverToBoxAdapter(
              child: Obx(() {
                // Converter dados do controller para ChartData
                final weeklyProgressData = _controller.weeklyProgress
                    .map((day) => ChartData(
                          day['day'] as String,
                          (day['xp'] as int).toDouble(),
                        ))
                    .toList();

                // Se não houver dados, mostrar valores zerados
                final hasData = weeklyProgressData.isNotEmpty;

                return Column(
                  children: [
                    WeeklyProgressChart(
                      userProgress: hasData
                          ? weeklyProgressData
                          : [
                              ChartData('Sun', 0),
                              ChartData('Mon', 0),
                              ChartData('Tue', 0),
                              ChartData('Wed', 0),
                              ChartData('Thu', 0),
                              ChartData('Fri', 0),
                              ChartData('Sat', 0),
                            ],
                      otherProgress: [], // Não mostrar comparação no próprio perfil
                      showOther: false,
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ),

            // Overview - Reactive stats from GamificationController
            SliverToBoxAdapter(
              child: OverviewSection(
                flagAsset: _getCountryFlag(_controller.country.value),
                useOwnStats: true, // Usar stats do GamificationController
              ),
            ),

            // Espaço para bottom bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
        );
      }),
    );
  }

  // Auxiliares

  String _getAvatarAsset(String avatarId) {
    // Mapear avatarId para asset path
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

  String _getAvatarIdFromAsset(String asset) {
    // Mapear asset path para avatarId
    if (asset == AppAssets.charMara) return 'avatar_01';
    if (asset == AppAssets.charDafny) return 'avatar_02';
    if (asset == AppAssets.charDiogo) return 'avatar_03';
    if (asset == AppAssets.charFrancilene) return 'avatar_04';
    if (asset == AppAssets.charGlauciane) return 'avatar_05';
    if (asset == AppAssets.charLindoedson) return 'avatar_06';
    if (asset == AppAssets.charRenner) return 'avatar_07';
    return 'avatar_01';
  }

  String _getCountryFlag(String countryCode) {
    // Mapear código do país para asset da bandeira
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
