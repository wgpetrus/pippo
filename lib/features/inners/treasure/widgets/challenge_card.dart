import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/treasure_challenges_controller.dart';
import '../controllers/treasure_rewards_controller.dart';

/// Card de desafio conectado aos TreasureControllers
/// 
/// Exibe informações do desafio e permite coletar recompensa quando completado.
/// Usa `Map<String, dynamic>` diretamente do Firestore (sem models).
/// 
/// **Requisitos Implementados:**
/// - 11.4: Exibe título, descrição, barra de progresso, texto de objetivo, ícone e valor da recompensa
/// - 11.5: Botão desabilitado (cinza) quando em progresso
/// - 11.6: Botão habilitado (verde) quando completado com animação de brilho
/// - 11.7: Loading spinner durante coleta de recompensa
/// - 13.1: Chama controller.claimReward() ao clicar
/// - 14.1, 14.2, 14.3: Usa ResponsiveUtils para todas as dimensões
/// - 10.5, 13.7: Exibe mensagens de erro amigáveis do controller
/// 
/// **Melhorias de UX:**
/// - Recompensa destacada com badge colorido (dourado para gems, azul para XP)
/// - Label clara do tipo de recompensa ("Gems" ou "XP")
/// - Ícone maior e mais visível
/// - Cores distintas para diferenciar tipos de recompensa instantaneamente
class ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challengeData;

  const ChallengeCard({
    super.key,
    required this.challengeData,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final challengesController = Get.find<TreasureChallengesController>();
    final rewardsController = Get.find<TreasureRewardsController>();

    // Extrair dados do map (Requirement 11.4)
    final title = challengeData['title'] as String? ?? 'treasure_challenge_default_title'.tr;
    final description = challengeData['description'] as String? ?? '';
    final progress = challengeData['progress'] as int? ?? 0;
    final goal = challengeData['goal'] as int? ?? 1;
    final iconPath = challengeData['iconPath'] as String? ?? '';
    final rewardType = challengeData['rewardType'] as String? ?? 'gems';
    final rewardAmount = challengeData['rewardAmount'] as int? ?? 0;
    final challengeId = challengeData['id'] as String? ?? '';

    // Calcular porcentagem de progresso usando helper do controller
    final progressPercentage = challengesController.getProgressPercentage(challengeData);
    final progressPercent = (progressPercentage * 100).toInt();

    // Determinar estado do desafio
    final isCompleted = challengesController.isCompletedState(challengeData);
    final barColor = isCompleted ? AppTheme.green : AppTheme.primary;

    // Determinar ícone de recompensa baseado no tipo
    final rewardIcon = rewardType == 'gems'
        ? 'assets/images/icons/icons-appbar-home/gem_appbar.png'
        : 'assets/images/icons/icons-treasure-page/xp-coin.png';
    
    // Determinar label de recompensa
    final rewardLabel = rewardType == 'gems' ? 'treasure_reward_gems'.tr : 'treasure_reward_xp'.tr;

    return Container(
      margin: EdgeInsets.only(bottom: r.spacing12),
      padding: EdgeInsets.all(r.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: const BorderSide(color: AppTheme.gray600, width: 2),
          left: const BorderSide(color: AppTheme.gray600, width: 2),
          right: const BorderSide(color: AppTheme.gray600, width: 2),
          bottom: const BorderSide(color: AppTheme.gray600, width: 4),
        ),
        // Glow animation quando completado (Requirement 11.6)
        boxShadow: rewardsController.shouldShowGlowAnimation(challengeData)
            ? [
                BoxShadow(
                  color: AppTheme.green.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ícone, título e recompensa (Requirement 11.4)
          Row(
            children: [
              // Ícone do desafio
              if (iconPath.isNotEmpty)
                Image.asset(
                  iconPath,
                  width: ResponsiveUtils.width(48, min: 40, max: 56),
                  height: ResponsiveUtils.width(48, min: 40, max: 56),
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.emoji_events,
                    size: ResponsiveUtils.width(48, min: 40, max: 56),
                    color: AppTheme.primary,
                  ),
                ),
              SizedBox(width: r.spacing12),

              // Título e descrição
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.textMdBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: r.spacing4),
                      Text(
                        description,
                        style: AppTheme.textSmRegular.copyWith(
                          color: AppTheme.gray300,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: r.spacing12),

              // Recompensa (ícone, valor e tipo) - MELHORADO para clareza
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.spacing8,
                  vertical: r.spacing8,
                ),
                decoration: BoxDecoration(
                  color: rewardType == 'gems' 
                      ? AppTheme.gold.withOpacity(0.1)
                      : AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: rewardType == 'gems' 
                        ? AppTheme.gold.withOpacity(0.3)
                        : AppTheme.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone da recompensa
                    Image.asset(
                      rewardIcon,
                      width: ResponsiveUtils.width(36, min: 32, max: 44),
                      height: ResponsiveUtils.width(36, min: 32, max: 44),
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.star,
                        size: ResponsiveUtils.width(36, min: 32, max: 44),
                        color: rewardType == 'gems' ? AppTheme.gold : AppTheme.primary,
                      ),
                    ),
                    SizedBox(height: r.spacing4),
                    // Valor da recompensa
                    Text(
                      '+$rewardAmount',
                      style: AppTheme.textMdBold.copyWith(
                        color: rewardType == 'gems' ? AppTheme.gold : AppTheme.primary,
                        fontSize: r.fontSize16,
                      ),
                    ),
                    // Label do tipo de recompensa
                    Text(
                      rewardLabel,
                      style: AppTheme.textXsBold.copyWith(
                        color: rewardType == 'gems' 
                            ? AppTheme.gold.withOpacity(0.8)
                            : AppTheme.primary.withOpacity(0.8),
                        fontSize: r.fontSize10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: r.spacing16),

          // Barra de progresso com texto de objetivo (Requirement 11.4)
          _buildProgressBar(
            progress: progress,
            goal: goal,
            progressPercent: progressPercent,
            barColor: barColor,
            r: r,
          ),

          SizedBox(height: r.spacing16),

          // Botão de coletar recompensa (Requirements 11.5, 11.6, 11.7, 13.1)
          Obx(() => _buildClaimButton(
                rewardsController: rewardsController,
                challengeId: challengeId,
                isCompleted: isCompleted,
              )),

          // Mensagem de erro (Requirements 10.5, 13.7)
          Obx(() {
            if (rewardsController.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: r.spacing8),
                child: Text(
                  rewardsController.errorMessage.value,
                  style: AppTheme.textSmRegular.copyWith(
                    color: AppTheme.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // Widgets

  /// Barra de progresso com degradê e texto de objetivo
  /// 
  /// Exibe:
  /// - Barra de progresso visual com gradiente
  /// - Texto de objetivo no formato "X/Y" (ex: "1/3 lessons")
  /// 
  /// Requirement 11.4: Display goal text (e.g., "1/3 lessons")
  Widget _buildProgressBar({
    required int progress,
    required int goal,
    required int progressPercent,
    required Color barColor,
    required ResponsiveUtils r,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: barColor, width: 1.5),
            ),
            child: Row(
              children: [
                if (progressPercent > 0)
                  Expanded(
                    flex: progressPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            barColor,
                            barColor.withOpacity(0.5),
                            AppTheme.white
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                if (progressPercent < 100)
                  Expanded(
                    flex: 100 - progressPercent,
                    child: const SizedBox(),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: r.spacing8),
        // Texto de objetivo (Requirement 11.4)
        Text(
          '$progress/$goal',
          style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray300),
        ),
      ],
    );
  }

  /// Botão de coletar recompensa com estados
  /// 
  /// Estados implementados:
  /// - **Em Progresso** (Requirement 11.5): Botão desabilitado com cor cinza
  /// - **Completado** (Requirement 11.6): Botão habilitado com cor verde primária
  /// - **Loading** (Requirement 11.7): Spinner durante coleta de recompensa
  /// 
  /// Ação (Requirement 13.1): Chama rewardsController.claimReward() ao clicar
  Widget _buildClaimButton({
    required TreasureRewardsController rewardsController,
    required String challengeId,
    required bool isCompleted,
  }) {
    // Verificar se botão está habilitado
    final isEnabled = rewardsController.isClaimButtonEnabled(challengeData);
    final isLoading = rewardsController.isClaimingReward.value;

    // Determinar cor do botão (Requirement 11.6: primary color when completed)
    final buttonColor = isCompleted ? AppTheme.green : null;

    return AppButton(
      text: isCompleted ? 'treasure_claim_button'.tr : 'treasure_in_progress_button'.tr,
      color: buttonColor,
      isLoading: isLoading, // Requirement 11.7: Show loading spinner
      onPressed: isEnabled
          ? () async {
              // Limpar mensagem de erro anterior
              rewardsController.errorMessage.value = '';
              
              // Coletar recompensa (Requirement 13.1)
              await rewardsController.claimReward(challengeId);
            }
          : null, // Requirement 11.5: Disable button when in progress
    );
  }
}
