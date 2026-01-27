import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';

/// Estados possíveis do card de seção
enum SectionStatus {
  completed,   // Barra verde 5/5, sparkles, troféu dourado
  inProgress,  // Barra azul/cinza parcial, troféu cinza
  notStarted,  // Sem barra, texto "START NOW"
  locked,      // Fundo cinza, cadeado, mascote desbotado
}

/// Card de seção de lição
class SectionCard extends StatelessWidget {
  final String title;
  final SectionStatus status;
  final int currentProgress;
  final int totalProgress;
  final String? mascotAsset;
  final VoidCallback? onTap;
  final VoidCallback? onSeeDetails;

  const SectionCard({
    super.key,
    required this.title,
    required this.status,
    this.currentProgress = 0,
    this.totalProgress = 5,
    this.mascotAsset,
    this.onTap,
    this.onSeeDetails,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final isLocked = status == SectionStatus.locked;
    final isCompleted = status == SectionStatus.completed;
    final isClickable = !isLocked && !isCompleted && onTap != null;

    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: Container(
        height: r.hp(22),
        decoration: BoxDecoration(
          color: AppTheme.gray500,
          borderRadius: BorderRadius.circular(r.spacing16),
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: r.spacing4),
          decoration: BoxDecoration(
            color: isLocked ? AppTheme.gray700 : AppTheme.white,
            borderRadius: BorderRadius.circular(r.spacing16),
            border: Border.all(color: AppTheme.gray600, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Sparkles (só no completed)
                if (status == SectionStatus.completed) _buildSparkles(r),

                // Cadeado (só no locked)
                if (isLocked) _buildLockIcon(r),

                // Conteúdo principal
                Padding(
                  padding: EdgeInsets.all(r.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Título
                      Text(
                        title,
                        style: AppTheme.textXlBold.copyWith(
                          color: isLocked ? AppTheme.gray400 : AppTheme.black,
                        ),
                      ),

                      SizedBox(height: r.spacing4),

                      // Subtítulo baseado no estado
                      _buildSubtitle(r),

                      SizedBox(height: r.spacing12),

                      // Barra de progresso ou START NOW
                      // TODO: [etapa 8] mover lógica de exibição para controller (shouldShowProgress)
                      if (status == SectionStatus.completed ||
                          status == SectionStatus.inProgress ||
                          (status == SectionStatus.notStarted && currentProgress > 0))
                        _buildProgressBar(r),
                    ],
                  ),
                ),

                // Mascote
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildMascot(r),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widgets

  Widget _buildSparkles(ResponsiveUtils r) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.only(left: r.spacing16, top: r.spacing16),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 20,
                  child: _sparkle(12),
                ),
                Positioned(
                  left: 20,
                  top: 0,
                  child: _sparkle(8),
                ),
                Positioned(
                  left: 35,
                  top: 30,
                  child: _sparkle(6),
                ),
                Positioned(
                  left: 60,
                  top: 10,
                  child: _sparkle(10),
                ),
                Positioned(
                  left: 80,
                  top: 40,
                  child: _sparkle(8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sparkle(double size) {
    return FaIcon(
      FontAwesomeIcons.star,
      size: size,
      color: AppTheme.green60,
    );
  }

  Widget _buildLockIcon(ResponsiveUtils r) {
    return Positioned(
      left: r.spacing16,
      top: r.spacing16,
      child: FaIcon(
        FontAwesomeIcons.lock,
        size: 20,
        color: AppTheme.gray400,
      ),
    );
  }

  Widget _buildSubtitle(ResponsiveUtils r) {
    if (status == SectionStatus.locked) {
      return Text(
        'Complete o curso para\ndesbloquear.',
        style: AppTheme.textSmRegular.copyWith(
          color: AppTheme.gray400,
          height: 1.3,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onSeeDetails,
          child: Text(
            'Ver detalhes',
            style: AppTheme.textSmSemibold.copyWith(
              color: AppTheme.primary,
            ),
          ),
        ),

        // COMEÇAR AGORA (só no notStarted)
        if (status == SectionStatus.notStarted) ...[
          SizedBox(height: r.spacing8),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'COMEÇAR AGORA',
              style: AppTheme.textSmBold.copyWith(
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressBar(ResponsiveUtils r) {
    final isCompleted = status == SectionStatus.completed;
    final progress = totalProgress > 0 ? currentProgress / totalProgress : 0.0;

    return Row(
      children: [
        // Barra de progresso
        Expanded(
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.gray700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Preenchimento
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted ? AppTheme.green : AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Texto do progresso
                Center(
                  child: Text(
                    '$currentProgress/$totalProgress',
                    style: AppTheme.textSmBold.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: r.spacing8),

        // Troféu
        _buildTrophy(),
      ],
    );
  }

  Widget _buildTrophy() {
    final isCompleted = status == SectionStatus.completed;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FaIcon(
          FontAwesomeIcons.trophy,
          size: 24,
          color: isCompleted ? AppTheme.green : AppTheme.gray500,
        ),

        // Badge com número (só no completed)
        if (isCompleted)
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.gold,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '1',
                  style: AppTheme.textXsBold.copyWith(
                    color: AppTheme.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMascot(ResponsiveUtils r) {
    final isLocked = status == SectionStatus.locked;
    final asset = mascotAsset ?? AppAssets.mascotLesson;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(r.spacing16),
        bottomRight: Radius.circular(r.spacing16),
      ),
      child: ColorFiltered(
        colorFilter: isLocked
            ? const ColorFilter.mode(
                AppTheme.gray600_50,
                BlendMode.saturation,
              )
            : const ColorFilter.mode(
                Colors.transparent,
                BlendMode.multiply,
              ),
        child: Opacity(
          opacity: isLocked ? 0.6 : 1.0,
          child: Image.asset(
            asset,
            height: r.hp(22),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
