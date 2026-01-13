import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popover/popover.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_bottombar.dart';
import '../../../../shared/widgets/app_float_anim.dart';
import '../../../../shared/widgets/app_lesson_button.dart';
import '../../leaderboard/views/leaderboard_page.dart';
import '../../profile/views/profile_page.dart';
import '../../shop/views/shop_page.dart';
import '../../treasure/views/treasure_page.dart';
import '../controllers/home_controller.dart';
import '../widgets/courses_modal.dart';
import '../widgets/energy_modal.dart';
import '../widgets/gems_modal.dart';
import '../widgets/home_appbar.dart';
import '../widgets/lesson_popover.dart';
import '../widgets/lesson_tooltip.dart';
import '../widgets/streak_modal.dart';
import '../widgets/unit_header.dart';

/// Dados de cada botão de lição
class _LessonButtonData {
  final String iconAsset;
  final LessonStatus status;
  final String? effectAsset;
  final double offsetX;
  final double offsetY;
  final int animDelay;
  final bool hasTooltip;

  const _LessonButtonData({
    required this.iconAsset,
    required this.status,
    this.effectAsset,
    required this.offsetX,
    required this.offsetY,
    this.animDelay = 0,
    this.hasTooltip = false,
  });
}

/// Tela principal do app
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // Dados dos botões de lição
  static const _lessonButtons = [
    _LessonButtonData(
      iconAsset: AppAssets.iconStars,
      status: LessonStatus.completed,
      effectAsset: AppAssets.effectStars,
      offsetX: -0.13,
      offsetY: 0.40,
    ),
    _LessonButtonData(
      iconAsset: AppAssets.iconHeadset,
      status: LessonStatus.available,
      effectAsset: AppAssets.effectZebra,
      offsetX: -0.03,
      offsetY: 0.54,
      animDelay: 200,
      hasTooltip: true,
    ),
    _LessonButtonData(
      iconAsset: AppAssets.iconMic,
      status: LessonStatus.locked,
      effectAsset: AppAssets.effectZebra,
      offsetX: -0.08,
      offsetY: 0.67,
      animDelay: 400,
    ),
    _LessonButtonData(
      iconAsset: AppAssets.iconFire,
      status: LessonStatus.locked,
      effectAsset: AppAssets.effectZebra,
      offsetX: 0.05,
      offsetY: 0.77,
      animDelay: 600,
    ),
    _LessonButtonData(
      iconAsset: AppAssets.iconStar,
      status: LessonStatus.locked,
      effectAsset: AppAssets.effectZebra,
      offsetX: -0.20,
      offsetY: 0.85,
      animDelay: 800,
    ),
  ];

  // Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentNavIndex.value,
        children: [
          _buildCoursesPage(context, controller),
          const ShopPage(),
          const LeaderboardPage(),
          const TreasurePage(),
          const ProfilePage(),
        ],
      )),
    );
  }

  // Widgets
  Widget _buildCoursesPage(BuildContext context, HomeController controller) {
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
        _buildContent(context, controller),

        // AppBar
        Builder(
          builder: (appBarContext) => Obx(() => HomeAppbar(
            avatarAsset: AppAssets.charDiogo,
            flagAsset: AppAssets.flagFrance,
            flagCount: 5,
            fireCount: 6,
            gemCount: 8,
            rayCount: 5,
            selectedStat: controller.selectedStat.value,
            onStatTap: (stat) => _onStatTap(appBarContext, controller, stat),
          )),
        ),

        // Unit Header
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Builder(
            builder: (ctx) => UnitHeader(
              unitNumber: 'Unit 1',
              title: 'Use basic phrases',
              onListTap: () => _showLessonPopover(ctx, controller),
            ),
          ),
        ),

        // Bottom Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Obx(() => AppBottombar(
            currentIndex: controller.currentNavIndex.value,
            avatarAsset: AppAssets.charDiogo,
            onTap: controller.onNavTap,
          )),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, HomeController controller) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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

        // Botões de lição (iterando sobre dados)
        ..._lessonButtons.map((data) => _buildLessonButton(
          context: context,
          data: data,
          controller: data.hasTooltip ? controller : null,
        )),
      ],
    );
  }

  Widget _buildLessonButton({
    required BuildContext context,
    required _LessonButtonData data,
    HomeController? controller,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      top: screenHeight * data.offsetY,
      left: 0,
      right: 0,
      child: Center(
        child: Transform.translate(
          offset: Offset(screenWidth * data.offsetX, 0),
          child: AppFloatAnim(
            distance: 4,
            durationMs: 2000,
            delayMs: data.animDelay,
            child: controller != null
                ? Obx(() => _buildButtonWithTooltip(data: data, controller: controller))
                : AppLessonButton(
                    iconAsset: data.iconAsset,
                    status: data.status,
                    effectAsset: data.effectAsset,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonWithTooltip({
    required _LessonButtonData data,
    required HomeController controller,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AppLessonButton(
          iconAsset: data.iconAsset,
          status: data.status,
          effectAsset: data.effectAsset,
          onPressed: controller.onStartTap,
          progress: controller.showContinue.value ? 0.3 : null,
        ),
        Positioned(
          bottom: 85,
          child: LessonTooltip(
            text: controller.showContinue.value ? 'Continue' : 'Start!',
            onTap: controller.onStartTap,
          ),
        ),
      ],
    );
  }

  // Métodos
  void _onStatTap(BuildContext context, HomeController controller, StatType stat) {
    // Marca como selecionada
    controller.onStatTap(stat);
    
    // Abre modal específico
    switch (stat) {
      case StatType.flag:
        _showCoursesModal(context, controller);
        break;
      case StatType.fire:
        _showStreakModal(context);
        break;
      case StatType.gem:
        _showGemsModal(context, controller);
        break;
      case StatType.ray:
        _showEnergyModal(context);
        break;
    }
  }

  void _showCoursesModal(BuildContext context, HomeController controller) {
    CoursesModal.show(
      context,
      courses: const [
        CourseData(flagAsset: AppAssets.flagFrance, name: 'French', isSelected: true),
        CourseData(flagAsset: AppAssets.flagUsa, name: 'English'),
      ],
      selectedCourseName: 'French',
      currentLevel: 10,
      maxLevel: 15,
      onAddCourse: controller.onAddCourse,
      onCourseSelected: (course) {
        // TODO: Trocar curso ativo
      },
    );
  }

  void _showStreakModal(BuildContext context) {
    StreakModal.show(
      context,
      streakDays: 7,
      onSeeMore: () {
        // TODO: Navegar para página de detalhes do streak
      },
    );
  }

  void _showGemsModal(BuildContext context, HomeController controller) {
    GemsModal.show(
      context,
      currentGems: 650,
      packs: [
        GemPackData(
          iconAsset: AppAssets.shopGemPot,
          gems: 100,
          price: '\$ 4.99',
          iconSize: 67,
        ),
        GemPackData(
          iconAsset: AppAssets.shopChest,
          gems: 500,
          price: '\$ 8.99',
          oldPrice: '20',
          isHighlighted: true,
          badge: 'DISCOUNT',
          iconSize: 67,
        ),
        GemPackData(
          iconAsset: AppAssets.shopGemCar,
          gems: 1500,
          price: '\$ 24.99',
          iconSize: 56,
        ),
      ],
      onGoToShop: () => controller.onNavTap(1),
      onPackTap: (pack) {
        // TODO: Processar compra do pack
      },
    );
  }

  void _showEnergyModal(BuildContext context) {
    // Para testar os 3 estados, mude o currentEnergy:
    // 1 = "Only one flash left"
    // 0 = "No flashes left"
    // 5 = "Fully charged"
    EnergyModal.show(
      context,
      currentEnergy: 1,
      maxEnergy: 5,
      nextEnergyTime: '2h 25m',
      onUnlimitedTap: () {
        // TODO: Ativar unlimited flashes (free trial)
      },
      onRefillTap: () {
        // TODO: Comprar refill com gems
      },
    );
  }

  void _showLessonPopover(BuildContext context, HomeController controller) {
    showPopover(
      context: context,
      bodyBuilder: (ctx) => LessonPopoverContent(
        title: 'Use basic phrases',
        currentLesson: 2,
        totalLessons: 5,
        onStartTap: () {
          Navigator.of(ctx).pop();
          controller.onStartTap();
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
}
