import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../friends/views/friends_view.dart';
import '../../gamification/controllers/xp_level_controller.dart';
import '../../gamification/controllers/streak_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/profile_data_controller.dart';
import '../controllers/profile_social_controller.dart';
import '../controllers/profile_courses_controller.dart';
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
  late final ProfileDataController _dataController;
  late final ProfileSocialController _socialController;
  late final ProfileCoursesController _coursesController;
  late final XpLevelController _xpLevelController;
  late final StreakController _streakController;

  @override
  bool get wantKeepAlive => true; // Manter estado da página

  @override
  void initState() {
    super.initState();
    _dataController = Get.find<ProfileDataController>();
    _socialController = Get.find<ProfileSocialController>();
    _coursesController = Get.find<ProfileCoursesController>();
    _xpLevelController = Get.find<XpLevelController>();
    _streakController = Get.find<StreakController>();
    
    // Carregar perfil e progresso semanal ao iniciar
    _dataController.loadOwnProfile();
    _socialController.loadWeeklyProgress();
  }

  // Recarregar dados quando a página é exibida
  void _refreshData() {
    _dataController.loadOwnProfile();
    _socialController.loadWeeklyProgress();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Obx(() {
        // Mostrar loading
        if (_dataController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        // Mostrar erro
        if (_dataController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dataController.errorMessage.value,
                    style: AppTheme.textMd.copyWith(color: AppTheme.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _dataController.loadOwnProfile(),
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
            await _dataController.loadOwnProfile();
            await _socialController.loadWeeklyProgress();
          },
          color: AppTheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header com card azul (já é um Sliver, não precisa de SliverToBoxAdapter)
              Obx(() => ProfileHeader(
                title: 'Perfil',
                avatarAsset: _getAvatarAsset(_dataController.avatarId.value),
                name: _dataController.userName.value,
                username: _dataController.username.value,
                following: _socialController.followingCount.value,
                followers: _socialController.followersCount.value,
                flagAsset: _getActiveCourseFlag(),
                coursesCount: _coursesController.userCourses.length,
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
                    currentAvatar: _getAvatarAsset(_dataController.avatarId.value),
                    onAvatarSelected: (avatar) {
                      // Extrair avatarId do asset path
                      final avatarId = _getAvatarIdFromAsset(avatar);
                      _dataController.updateProfile({'avatarId': avatarId});
                    },
                  );
                },
              )),

            // Card "Finish your profile" (mostrar apenas se incompleto)
            if (_dataController.profileCompletionPercentage.value < 100)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    CompleteProfileCard(
                      stepsLeft: _dataController.missingFields.length,
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
                // Obter curso ativo do HomeController para chave única (força reconstrução ao trocar curso)
                final homeController = Get.find<HomeController>();
                final courseId = homeController.activeCourseId.value;
                
                // Converter dados do controller para ChartData
                final weeklyProgressData = _socialController.weeklyProgress
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
                      key: ValueKey('weekly-chart-$courseId'), // Chave única baseada no curso ativo
                      userProgress: hasData
                          ? weeklyProgressData
                          : [
                              ChartData('Dom', 0),
                              ChartData('Seg', 0),
                              ChartData('Ter', 0),
                              ChartData('Qua', 0),
                              ChartData('Qui', 0),
                              ChartData('Sex', 0),
                              ChartData('Sáb', 0),
                            ],
                      otherProgress: [], // Não mostrar comparação no próprio perfil
                      showOther: false,
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ),

            // Overview - Reactive stats from XpLevelController and StreakController
            SliverToBoxAdapter(
              child: Obx(() => OverviewSection(
                flagAsset: _getActiveCourseFlag(),
                useOwnStats: true, // Usar stats dos novos controllers
              )),
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

  String _getActiveCourseFlag() {
    if (kDebugMode) {
      debugPrint('🔍 _getActiveCourseFlag: Buscando curso ativo');
      debugPrint('   Total de cursos: ${_coursesController.userCourses.length}');
    }

    // Buscar curso ATIVO (não primário)
    final activeCourse = _coursesController.userCourses.firstWhere(
      (course) => course['isActive'] == true,
      orElse: () => <String, dynamic>{},
    );

    if (kDebugMode) {
      debugPrint('   Curso ativo encontrado: ${activeCourse.isNotEmpty}');
      if (activeCourse.isNotEmpty) {
        debugPrint('   - Idioma: ${activeCourse['languageName']}');
        debugPrint('   - Bandeira: ${activeCourse['flagAsset']}');
      }
    }

    // Se encontrou curso ativo, retornar sua bandeira
    if (activeCourse.isNotEmpty && activeCourse['flagAsset'] != null) {
      return activeCourse['flagAsset'] as String;
    }

    // Fallback: usar bandeira do país do usuário
    if (kDebugMode) {
      debugPrint('   ⚠️ Usando fallback: bandeira do país ${_dataController.country.value}');
    }
    return _getCountryFlag(_dataController.country.value);
  }
}
