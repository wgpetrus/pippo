import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/leaderboard_controller.dart';

/// Modal para selecionar status do usuário
class StatusModal {
  // Opções de emoji disponíveis
  static const _statusOptions = [
    '😊', '😎', '🔥', '💪', '🎯', '🎭', '🚀', '⭐', '💎', '👑',
    '🎉', '😴', '🤔', '😤', '🥳', '🤓', '😇', '🤩', '😈', '🥶'
  ];

  /// Exibe o modal de seleção de status
  static void show(
    BuildContext context, {
    required String currentAvatar,
    String? currentStatus,
    required LeaderboardController controller,
  }) {
    final r = ResponsiveUtils(context);
    String? selectedStatus = currentStatus;

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: AppTheme.white,
          hasSabGradient: false,
          topBarTitle: Text('leaderboard_status_modal_title'.tr, style: AppTheme.textXlBold),
          isTopBarLayerAlwaysVisible: true,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Obx(() {
                final isUpdating = controller.isUpdatingStatus.value;
                final errorMsg = controller.errorMessage.value;

                return Padding(
                  padding: EdgeInsets.fromLTRB(r.spacing24, r.spacing16, r.spacing24, r.spacing24),
                  child: Column(
                    children: [
                      // Avatar com status atual
                      _buildCurrentAvatar(r, currentAvatar, selectedStatus),
                      SizedBox(height: r.spacing32),

                      // Mensagem de erro (se houver)
                      if (errorMsg.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(r.spacing12),
                          decoration: BoxDecoration(
                            color: AppTheme.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: AppTheme.red, size: 20),
                              SizedBox(width: r.spacing8),
                              Expanded(
                                child: Text(
                                  errorMsg,
                                  style: AppTheme.textSmMedium.copyWith(color: AppTheme.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: r.spacing16),
                      ],

                      // Grid de opções
                      _buildStatusGrid(
                        r: r,
                        selectedStatus: selectedStatus,
                        onSelect: (status) {
                          setState(() => selectedStatus = status);
                        },
                        enabled: !isUpdating,
                      ),
                      SizedBox(height: r.spacing32),

                      // Botões
                      AppButton(
                        text: 'leaderboard_status_modal_done'.tr,
                        isLoading: isUpdating,
                        onPressed: isUpdating
                            ? null
                            : () async {
                                await controller.updateUserStatus(selectedStatus);
                                if (controller.errorMessage.value.isEmpty) {
                                  Navigator.pop(context);
                                }
                              },
                      ),
                      SizedBox(height: r.spacing12),
                      AppButton(
                        text: 'leaderboard_status_modal_clear'.tr,
                        isPrimary: false,
                        onPressed: isUpdating
                            ? null
                            : () async {
                                await controller.updateUserStatus(null);
                                if (controller.errorMessage.value.isEmpty) {
                                  Navigator.pop(context);
                                }
                              },
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  // Widgets
  static Widget _buildCurrentAvatar(ResponsiveUtils r, String avatar, String? status) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Borda tracejada
        Container(
          width: r.wp(25),
          height: r.wp(25),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary,
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(r.spacing8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gray700,
            ),
            child: ClipOval(
              child: Image.asset(avatar, fit: BoxFit.cover),
            ),
          ),
        ),

        // Balão de status
        Positioned(
          top: -5,
          right: -10,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: status != null
                  ? Text(status, style: const TextStyle(fontSize: 18))
                  : const Icon(Icons.mood, color: AppTheme.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildStatusGrid({
    required ResponsiveUtils r,
    required String? selectedStatus,
    required Function(String) onSelect,
    required bool enabled,
  }) {
    return Wrap(
      spacing: r.spacing12,
      runSpacing: r.spacing12,
      alignment: WrapAlignment.center,
      children: _statusOptions.map((emoji) {
        final isSelected = emoji == selectedStatus;

        return GestureDetector(
          onTap: enabled ? () => onSelect(emoji) : null,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled ? AppTheme.white : AppTheme.gray600.withOpacity(0.3),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.gray600,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 28,
                  color: enabled ? null : AppTheme.gray600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
