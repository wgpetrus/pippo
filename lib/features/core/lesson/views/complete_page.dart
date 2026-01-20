import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/lesson_controller.dart';

/// Página de conclusão da lição
class CompletePage extends StatefulWidget {
  const CompletePage({super.key});

  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
  late final LessonController _controller;
  bool _rewardsClaimed = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LessonController>();
  }

  Future<void> _claimRewards() async {
    if (_rewardsClaimed) return;

    setState(() {
      _rewardsClaimed = true;
    });

    // Completa a lição e resgata recompensas
    await _controller.completeLesson();

    if (_controller.errorMessage.value.isEmpty) {
      // Navega de volta para home ou sections
      Get.back();
    } else {
      // Mostra erro se houver
      Get.snackbar(
        'Erro',
        _controller.errorMessage.value,
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
    final accuracy = (_controller.accuracy * 100).toStringAsFixed(0);
    final duration = DateTime.now().difference(_controller.lessonStartTime.value);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';

    // Calcula XP e gems que serão ganhos (preview)
    final baseXp = _controller.accuracy >= 0.9
        ? 15
        : _controller.accuracy >= 0.7
            ? 13
            : _controller.accuracy >= 0.5
                ? 11
                : 10;
    final baseGems = _controller.accuracy >= 0.9
        ? 3
        : _controller.accuracy >= 0.7
            ? 2
            : 1;

    // Adiciona bônus se perfeito ou primeira lição do dia
    var totalXp = baseXp;
    if (_controller.isPerfect) totalXp += 5;

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
              r.isLandscape
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: AppAssets.treasureXpCoin,
                            value: totalXp.toString(),
                            label: 'XP Total',
                            color: AppTheme.gold,
                          ),
                        ),
                        SizedBox(width: r.spacing12),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: AppAssets.treasureTarget,
                            value: '$accuracy%',
                            label: _controller.isPerfect ? 'Perfeito!' : 'Excelente',
                            color: AppTheme.pink,
                          ),
                        ),
                        SizedBox(width: r.spacing12),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: AppAssets.lessonClock,
                            value: timeString,
                            label: 'Tempo',
                            color: AppTheme.orange,
                          ),
                        ),
                        SizedBox(width: r.spacing12),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: AppAssets.appbarGem,
                            value: baseGems.toString(),
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
                                context: context,
                                icon: AppAssets.treasureXpCoin,
                                value: totalXp.toString(),
                                label: 'XP Total',
                                color: AppTheme.gold,
                              ),
                            ),
                            SizedBox(width: r.spacing12),
                            Expanded(
                              child: _buildStatCard(
                                context: context,
                                icon: AppAssets.treasureTarget,
                                value: '$accuracy%',
                                label: _controller.isPerfect ? 'Perfeito!' : 'Excelente',
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
                                context: context,
                                icon: AppAssets.lessonClock,
                                value: timeString,
                                label: 'Tempo',
                                color: AppTheme.orange,
                              ),
                            ),
                            SizedBox(width: r.spacing12),
                            Expanded(
                              child: _buildStatCard(
                                context: context,
                                icon: AppAssets.appbarGem,
                                value: baseGems.toString(),
                                label: 'Gemas',
                                color: AppTheme.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

              SizedBox(height: r.spacing24),

              // Botão resgatar recompensa
              Obx(() => AppButton(
                    text: 'Resgatar Recompensa',
                    isLoading: _controller.isLoading.value,
                    onPressed: _controller.isLoading.value || _rewardsClaimed
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
    required BuildContext context,
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final r = ResponsiveUtils(context);

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
