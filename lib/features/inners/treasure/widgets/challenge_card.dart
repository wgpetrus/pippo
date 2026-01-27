import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/treasure_controller.dart';

/// Card de desafio conectado ao TreasureController
/// 
/// Exibe informações do desafio e permite coletar recompensa quando completado.
/// Usa Map<String, dynamic> diretamente do Firestore (sem models).
/// 
/// **Requisitos Implementados:**
/// - 11.4: Exibe título, descrição, barra de progresso, texto de objetivo, ícone e valor da recompensa
/// - 11.5: Botão desabilitado (cinza) quando em progresso
/// - 11.6: Botão habilitado (verde) quando completado com animação de brilho
/// - 11.7: Loading spinner durante coleta de recompensa
/// - 13.1: Chama controller.claimReward() ao clicar
/// - 14.1, 14.2, 14.3: Usa ResponsiveUtils para todas as dimensões
/// - 10.5, 13.7: Exibe mensagens de erro amigáveis do controller
class ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challengeData;

  const ChallengeCard({
    super.key,
    required this.challengeData,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final controller = Get.find<TreasureController>();

    // Extrair dados do map (Requirement 11.4)
    final title = challengeData['title'] as String? ?? 'Desafio';
    final description = challengeData['description'] as String? ?? '';
    final progress = challengeData['progress'] as int? ?? 0;
    final goal = challengeData['goal'] as int? ?? 1;
    final iconPath = challengeData['iconPath'] as String? ?? '';
    final rewardType = challengeData['rewardType'] as String? ?? 'gems';
    final rewardAmount = challengeData['rewardAmount'] as int? ?? 0;
    final challengeId = challengeData['id'] as String? ?? '';

    // Calcular porcentagem de progresso usando helper do controller
    final progressPercentage = controller.getProgressPercentage(challengeData);
    final progressPercent = (progressPercentage * 100).toInt();

    // Determinar estado do desafio
    final isCompleted = controller.isCompletedState(challengeData);
    final barColor = isCompleted ? AppTheme.green : AppTheme.primary;

    // Determinar ícone de recompensa baseado no tipo
    final rewardIcon = rewardType == 'gems'
        ? 'assets/images/icons/icons-appbar-home/gem_appbar.png'
        : 'assets/images/icons/icons-treasure-page/xp-coin.png';

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
        boxShadow: controller.shouldShowGlowAnimation(challengeData)
            ? [
                BoxShadow(
                  color: AppTheme.green.withValues(alpha: 0.3),
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

              // Recompensa (ícone e valor)
              Column(
                children: [
                  Image.asset(
                    rewardIcon,
                    width: ResponsiveUtils.width(32, min: 28, max: 40),
                    height: ResponsiveUtils.width(32, min: 28, max: 40),
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.star,
                      size: ResponsiveUtils.width(32, min: 28, max: 40),
                      color: AppTheme.gold,
                    ),
                  ),
                  SizedBox(height: r.spacing4),
                  Text(
                    '+$rewardAmount',
                    style: AppTheme.textSmBold.copyWith(
                      color: AppTheme.gold,
                    ),
                  ),
                ],
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
                controller: controller,
                challengeId: challengeId,
                isCompleted: isCompleted,
              )),

          // Mensagem de erro (Requirements 10.5, 13.7)
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: r.spacing8),
                child: Text(
                  controller.errorMessage.value,
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
                            barColor.withValues(alpha: 0.5),
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
  /// Ação (Requirement 13.1): Chama controller.claimReward() ao clicar
  Widget _buildClaimButton({
    required TreasureController controller,
    required String challengeId,
    required bool isCompleted,
  }) {
    // Verificar se botão está habilitado
    final isEnabled = controller.isClaimButtonEnabled(challengeData);
    final isLoading = controller.isClaimingReward.value;

    // Determinar cor do botão (Requirement 11.6: primary color when completed)
    final buttonColor = isCompleted ? AppTheme.green : null;

    return AppButton(
      text: isCompleted ? 'Coletar Recompensa' : 'Em Progresso',
      color: buttonColor,
      isLoading: isLoading, // Requirement 11.7: Show loading spinner
      onPressed: isEnabled
          ? () async {
              // Limpar mensagem de erro anterior
              controller.errorMessage.value = '';
              
              // Coletar recompensa (Requirement 13.1)
              await controller.claimReward(challengeId);
            }
          : null, // Requirement 11.5: Disable button when in progress
    );
  }
}
