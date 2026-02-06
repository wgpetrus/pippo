import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../inners/gamification/controllers/gems_controller.dart';
import '../../../inners/gamification/controllers/xp_level_controller.dart';
import '../../../inners/gamification/controllers/streak_controller.dart';
import '../../../inners/gamification/controllers/energy_controller.dart';
import '../controllers/lesson_flow_controller.dart';
import '../controllers/lesson_progress_controller.dart';
import '../controllers/lesson_rewards_controller.dart';

/// Página de conclusão da lição
class CompletePage extends StatefulWidget {
  const CompletePage({super.key});

  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
  late final LessonFlowController _flowController;
  late final LessonProgressController _progressController;
  late final LessonRewardsController _rewardsController;
  bool _rewardsClaimed = false;

  @override
  void initState() {
    super.initState();
    _flowController = Get.find<LessonFlowController>();
    _progressController = Get.find<LessonProgressController>();
    _rewardsController = Get.find<LessonRewardsController>();
    
    // CORREÇÃO 1: Pausar o timer imediatamente ao entrar na tela
    _progressController.pauseTimer();
    
    // CORREÇÃO 2: Calcular e armazenar XP e Gems imediatamente
    _calculateRewards();
  }
  
  /// Calcula as recompensas e armazena nos observáveis para exibição
  Future<void> _calculateRewards() async {
    await _rewardsController.calculateRewards();
  }

  Future<void> _claimRewards() async {
    if (_rewardsClaimed) return;

    setState(() {
      _rewardsClaimed = true;
    });

    // Completa a lição e resgata recompensas
    // O timer já foi pausado no initState
    await _rewardsController.applyRewards();

    if (_rewardsController.errorMessage.value.isEmpty) {
      // Recarregar stats dos controllers de gamificação para atualizar UI
      try {
        if (Get.isRegistered<GemsController>()) {
          await Get.find<GemsController>().loadGems();
        }
        if (Get.isRegistered<XpLevelController>()) {
          await Get.find<XpLevelController>().loadXpAndLevel();
        }
        if (Get.isRegistered<StreakController>()) {
          await Get.find<StreakController>().loadStreak();
        }
        if (Get.isRegistered<EnergyController>()) {
          await Get.find<EnergyController>().loadEnergy();
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao recarregar stats de gamificação: $e');
      }
      
      // Navega de volta para home (limpa stack de lições)
      Get.until((route) => route.settings.name == '/home');
    } else {
      // Mostra erro se houver
      Get.snackbar(
        'Erro',
        _rewardsController.errorMessage.value,
        backgroundColor: AppTheme.red,
        colorText: AppTheme.white,
      );
      setState(() {
        _rewardsClaimed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    // Calcula estatísticas
    final accuracy = (_progressController.accuracy).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: Column(
            children: [
              SizedBox(height: r.spacing32),

              // Título
              Text(
                'Lição Completa!',
                style: AppTheme.displayMdBold.copyWith(color: AppTheme.primary),
              ),

              const Spacer(),

              // Mascote com estrelas
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Mascote
                  Image.asset(
                    AppAssets.lessonMascotComplete,
                    width: r.wp(60),
                    height: r.wp(60),
                    fit: BoxFit.contain,
                  ),

                  // Estrela esquerda (rosa)
                  Positioned(
                    left: r.spacing16,
                    top: r.spacing16,
                    child: Image.asset(
                      AppAssets.starsPink,
                      width: r.spacing32,
                      height: r.spacing32,
                    ),
                  ),

                  // Estrela direita (azul)
                  Positioned(
                    right: r.spacing16,
                    top: r.spacing48,
                    child: Image.asset(
                      AppAssets.starsBlue,
                      width: r.spacing48,
                      height: r.spacing48,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Cards de estatísticas
              Obx(() {
                // Usa valores calculados pelo controller (incluem todos os bônus)
                final currentTotalXp = _rewardsController.calculatedXp.value;
                final currentTotalGems = _rewardsController.calculatedGems.value;
                final currentAccuracy = (_progressController.accuracy).toStringAsFixed(0);
                final currentTimeString = _progressController.getFormattedTime();
                
                return r.isLandscape
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            r: r,
                            icon: AppAssets.treasureXpCoin,
                            value: currentTotalXp.toString(),
                            label: 'XP Total',
                            color: AppTheme.gold,
                          ),
                        ),
                        SizedBox(width: r.spacing12),
                        Expanded(
                          child: _buildStatCard(
                            r: r,
                            icon: AppAssets.treasureTarget,
                            value: '$currentAccuracy%',
                            label: _progressController.getAccuracyLabel(),
                            color: AppTheme.pink,
                          ),
                        ),
                        SizedBox(width: r.spacing12),
                        Expanded(
                          child: _buildStatCard(
                            r: r,
                            icon: AppAssets.lessonClock,
                            value: currentTimeString,
                            label: 'Tempo',
                            color: AppTheme.orange,
                          ),
                        ),
                        SizedBox(width: r.spacing12),
                        Expanded(
                          child: _buildStatCard(
                            r: r,
                            icon: AppAssets.appbarGem,
                            value: currentTotalGems.toString(),
                            label: 'Gemas',
                            color: AppTheme.red,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                r: r,
                                icon: AppAssets.treasureXpCoin,
                                value: currentTotalXp.toString(),
                                label: 'XP Total',
                                color: AppTheme.gold,
                              ),
                            ),
                            SizedBox(width: r.spacing12),
                            Expanded(
                              child: _buildStatCard(
                                r: r,
                                icon: AppAssets.treasureTarget,
                                value: '$currentAccuracy%',
                                label: _progressController.getAccuracyLabel(),
                                color: AppTheme.pink,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: r.spacing12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                r: r,
                                icon: AppAssets.lessonClock,
                                value: currentTimeString,
                                label: 'Tempo',
                                color: AppTheme.orange,
                              ),
                            ),
                            SizedBox(width: r.spacing12),
                            Expanded(
                              child: _buildStatCard(
                                r: r,
                                icon: AppAssets.appbarGem,
                                value: currentTotalGems.toString(),
                                label: 'Gemas',
                                color: AppTheme.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
              }),

              SizedBox(height: r.spacing24),

              // Botão resgatar recompensa
              Obx(() => AppButton(
                    text: 'Resgatar Recompensa',
                    isLoading: _rewardsController.isLoading.value,
                    onPressed: _rewardsController.isLoading.value || _rewardsClaimed
                        ? null
                        : _claimRewards,
                  )),

              SizedBox(height: r.spacing16),
            ],
          ),
        ),
      ),
    );
  }

  // Widget de card de estatística
  Widget _buildStatCard({
    required ResponsiveUtils r,
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          // Parte superior (branca)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: r.spacing16,
              horizontal: r.spacing12,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Stack(
              children: [
                // Conteúdo centralizado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(icon, width: r.spacing24, height: r.spacing24),
                    SizedBox(width: r.spacing8),
                    Flexible(
                      child: Text(
                        value,
                        style: AppTheme.displayXsBold.copyWith(color: color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Estrela no canto superior direito
                Positioned(
                  right: 0,
                  top: 0,
                  child: SvgPicture.asset(
                    AppAssets.profileStar,
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      color,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Parte inferior (colorida)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: r.spacing12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.textMdBold.copyWith(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }
}
