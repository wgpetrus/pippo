import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popover/popover.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_float_anim.dart';
import '../../../../shared/widgets/app_lesson_button.dart';
import '../../leaderboard/views/leaderboard_page.dart';
import '../../profile/controllers/profile_data_controller.dart';
import '../../profile/views/profile_page.dart';
import '../../shop/views/shop_page.dart';
import '../../treasure/views/treasure_page.dart';
import '../controllers/home_navigation_controller.dart';
import '../controllers/home_stats_controller.dart';
import '../widgets/courses_modal.dart';
import '../widgets/energy_modal.dart';
import '../widgets/gems_modal.dart';
import '../widgets/home_appbar.dart';
import '../widgets/lesson_popover.dart';
import '../widgets/lesson_tooltip.dart';
import '../widgets/streak_modal.dart';
import '../widgets/unit_header.dart';

/// Tela principal do app
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // Build
  @override
  Widget build(BuildContext context) {
    final navController = Get.find<HomeNavigationController>();
    final statsController = Get.find<HomeStatsController>();
    final profileController = Get.find<ProfileDataController>();

    return Obx(() => Scaffold(
      body: IndexedStack(
        index: navController.currentNavIndex.value,
        children: [
          _buildCoursesPage(context, statsController, profileController),  // Tab 0
          const LeaderboardPage(),                 // Tab 1
          const ShopPage(),                        // Tab 2
          const TreasurePage(),                    // Tab 3
          const ProfilePage(),                     // Tab 4
        ],
      ),
      bottomNavigationBar: _buildBottomBar(navController, profileController),
    ));
  }

  // Bottom Navigation Bar
  Widget _buildBottomBar(HomeNavigationController navController, ProfileDataController profileController) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, AppAssets.bottomRay, navController),
              _buildNavItem(1, AppAssets.bottomCoroa, navController),
              _buildNavItem(2, AppAssets.bottomCoins, navController),
              _buildNavItem(3, AppAssets.bottomBox, navController),
              _buildAvatarNavItem(4, navController, profileController),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconAsset, HomeNavigationController navController) {
    final isSelected = navController.currentNavIndex.value == index;
    final containerSize = ResponsiveUtils.width(48, min: 44, max: 56);
    final iconSize = ResponsiveUtils.width(24, min: 24, max: 28);

    return GestureDetector(
      onTap: () => navController.onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppTheme.primary100 : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Image.asset(iconAsset, width: iconSize, height: iconSize),
        ),
      ),
    );
  }

  Widget _buildAvatarNavItem(int index, HomeNavigationController navController, ProfileDataController profileController) {
    final isSelected = navController.currentNavIndex.value == index;
    final containerSize = ResponsiveUtils.width(48, min: 44, max: 56);

    return GestureDetector(
      onTap: () => navController.onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: containerSize,
        height: containerSize,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppTheme.primary100 : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary,
          ),
          child: Obx(() => ClipOval(
            child: Image.asset(
              _getAvatarAsset(profileController.avatarId.value),
              fit: BoxFit.cover,
            ),
          )),
        ),
      ),
    );
  }

  // Widgets
  Widget _buildCoursesPage(BuildContext context, HomeStatsController statsController, ProfileDataController profileController) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.backgroundHome),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Conteúdo (mascote + botões)
        _buildContent(context, statsController),

        // AppBar
        Builder(
          builder: (appBarContext) => Obx(() => HomeAppbar(
            avatarAsset: _getAvatarAsset(profileController.avatarId.value),
            flagAsset: statsController.activeCourseFlag.value.isEmpty 
                ? AppAssets.flagFrance 
                : statsController.activeCourseFlag.value,
            selectedStat: statsController.selectedStat.value,
            onStatTap: (stat) => _onStatTap(appBarContext, statsController, stat),
            controller: statsController,
          )),
        ),

        // Unit Header
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Obx(() {
            // Acessar diretamente a variável observável para o GetX rastrear
            final _ = statsController.currentUnitIndex.value;
            final unit = statsController.currentUnit;
            
            return Builder(
              builder: (ctx) => UnitHeader(
                unitNumber: unit['number'] as String,
                title: unit['title'] as String,
                onListTap: () => _showLessonPopover(ctx, statsController),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, HomeStatsController statsController) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      // Acessar diretamente as variáveis observáveis para o GetX rastrear
      final _ = statsController.currentUnitIndex.value;
      final completedLessonsLen = statsController.completedLessons.length;
      final lessonButtons = statsController.currentLessonButtons;
      
      return Stack(
        children: [
          // Mascote
          Positioned(
            top: screenHeight * 0.40,
            left: 30,
            right: 0,
            child: Center(
              child: Transform.translate(
                offset: Offset(screenWidth * 0.18, 0),
                child: AppFloatAnim(
                  distance: 8,
                  durationMs: 1800,
                  child: Image.asset(
                    AppAssets.mascotExcited,
                    height: screenHeight * 0.14,
                  ),
                ),
              ),
            ),
          ),

          // Botões de lição (iterando sobre dados dinâmicos)
          ...lessonButtons.asMap().entries.map((entry) {
            final index = entry.key;
            final lessonData = entry.value;
            
            return _buildLessonButton(
              context: context,
              lessonData: lessonData,
              index: index,
              controller: statsController,
            );
          }),
        ],
      );
    });
  }

  Widget _buildLessonButton({
    required BuildContext context,
    required Map<String, dynamic> lessonData,
    required int index,
    required HomeStatsController controller,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final lessonId = lessonData['lessonId'] as String;
    final iconAsset = lessonData['iconAsset'] as String;
    final effectAsset = lessonData['effectAsset'] as String?;
    final offsetX = lessonData['offsetX'] as double;
    final offsetY = lessonData['offsetY'] as double;
    final animDelay = lessonData['animDelay'] as int? ?? 0;

    return Positioned(
      top: screenHeight * offsetY,
      left: 0,
      right: 0,
      child: Center(
        child: Transform.translate(
          offset: Offset(screenWidth * offsetX, 0),
          child: AppFloatAnim(
            distance: 4,
            durationMs: 2000,
            delayMs: animDelay,
            child: Obx(() {
              final status = controller.getLessonStatus(lessonId, index);
              final tooltipText = controller.getTooltipText(lessonId, index);
              
              if (tooltipText != null) {
                return _buildButtonWithTooltip(
                  lessonId: lessonId,
                  iconAsset: iconAsset,
                  effectAsset: effectAsset,
                  status: status,
                  controller: controller,
                  tooltipText: tooltipText,
                  buttonIndex: index,
                );
              }
              
              return AppLessonButton(
                iconAsset: iconAsset,
                status: status,
                effectAsset: effectAsset,
                onPressed: status == LessonStatus.locked ? null : () => controller.onStartTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonWithTooltip({
    required String lessonId,
    required String iconAsset,
    required String? effectAsset,
    required LessonStatus status,
    required HomeStatsController controller,
    required String tooltipText,
    required int buttonIndex,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AppLessonButton(
          iconAsset: iconAsset,
          status: status,
          effectAsset: effectAsset,
          onPressed: status == LessonStatus.locked ? null : () => controller.onStartTap(buttonIndex),
          progress: tooltipText == 'Continue' ? 0.3 : null,
        ),
        Positioned(
          bottom: 85,
          child: LessonTooltip(
            text: tooltipText,
            onTap: status == LessonStatus.locked ? null : () => controller.onStartTap(buttonIndex),
          ),
        ),
      ],
    );
  }

  // Métodos
  void _onStatTap(BuildContext context, HomeStatsController statsController, StatType stat) {
    // Marca como selecionada ANTES de abrir o modal
    statsController.onStatTap(stat);
    
    // Aguarda um frame para garantir que a UI atualizou
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Abre modal específico
      switch (stat) {
        case StatType.flag:
          _showCoursesModal(context, statsController);
          break;
        case StatType.fire:
          _showStreakModal(context, statsController);
          break;
        case StatType.gem:
          _showGemsModal(context, statsController);
          break;
        case StatType.ray:
          _showEnergyModal(context, statsController);
          break;
      }
    });
  }

  void _showCoursesModal(BuildContext context, HomeStatsController statsController) {
    // Carregar cursos antes de abrir modal
    statsController.loadUserCourses().then((_) {
      // Se não há cursos carregados, usar dados mockados como fallback
      final courses = statsController.userCourses.isEmpty
          ? [
              CourseData(
                flagAsset: statsController.activeCourseFlag.value.isEmpty 
                    ? AppAssets.flagFrance 
                    : statsController.activeCourseFlag.value,
                name: statsController.activeCourseName.value.isEmpty 
                    ? 'Francês' 
                    : statsController.activeCourseName.value,
                isSelected: true,
              ),
            ]
          : statsController.userCourses.map((course) {
              return CourseData(
                flagAsset: course['flagAsset'] as String,
                name: course['languageName'] as String,
                isSelected: course['isActive'] as bool,
              );
            }).toList();
      
      CoursesModal.show(
        context,
        courses: courses,
        selectedCourseName: statsController.activeCourseName.value.isEmpty 
            ? 'Francês' 
            : statsController.activeCourseName.value,
        currentLevel: statsController.activeCourseLevel.value,
        maxLevel: 15,
        onAddCourse: statsController.onAddCourse,
        onCourseSelected: (course) {
          // Encontrar ID do curso selecionado
          final selectedCourse = statsController.userCourses.firstWhereOrNull(
            (c) => c['languageName'] == course.name,
          );
          
          if (selectedCourse != null) {
            statsController.switchActiveCourse(selectedCourse['id'] as String);
          }
        },
      ).then((_) {
        // Limpar seleção quando modal fechar
        statsController.clearStatSelection();
      });
    });
  }

  void _showStreakModal(BuildContext context, HomeStatsController statsController) {
    StreakModal.show(
      context,
      onSeeMore: () {
        // TODO: Navegar para página de detalhes do streak
      },
    ).then((_) {
      // Limpar seleção quando modal fechar
      statsController.clearStatSelection();
    });
  }

  void _showGemsModal(BuildContext context, HomeStatsController statsController) {
    final navController = Get.find<HomeNavigationController>();
    
    GemsModal.show(
      context,
      onGoToShop: () {
        navController.goToShop();
      },
    ).then((_) {
      // Limpar seleção quando modal fechar
      statsController.clearStatSelection();
    });
  }

  void _showEnergyModal(BuildContext context, HomeStatsController statsController) {
    EnergyModal.show(
      context,
      onUnlimitedTap: () {
        // TODO: Ativar unlimited flashes (free trial)
      },
    ).then((_) {
      // Limpar seleção quando modal fechar
      statsController.clearStatSelection();
    });
  }

  void _showLessonPopover(BuildContext context, HomeStatsController statsController) {
    final unit = statsController.currentUnit;
    final lessonButtons = statsController.currentLessonButtons;
    final completedInUnit = lessonButtons.where((lesson) {
      final lessonId = lesson['lessonId'] as String;
      return statsController.completedLessons.contains(lessonId);
    }).length;
    
    showPopover(
      context: context,
      bodyBuilder: (ctx) => LessonPopoverContent(
        title: unit['title'] as String,
        currentLesson: completedInUnit + 1,
        totalLessons: lessonButtons.length,
        onStartTap: () {
          Navigator.of(ctx).pop();
          statsController.onStartTap(statsController.currentUnitIndex.value);
        },
      ),
      direction: PopoverDirection.bottom,
      width: 280,
      arrowHeight: 12,
      arrowWidth: 24,
      backgroundColor: AppTheme.primary,
      barrierColor: Colors.black26,
      radius: 20,
      shadow: const [],
    );
  }

  // Helper para converter avatarId em asset path
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
}
