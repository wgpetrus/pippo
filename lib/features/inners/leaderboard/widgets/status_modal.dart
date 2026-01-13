import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal para selecionar status do usuário
class StatusModal {
  // Dados mockados de status disponíveis
  static const _statusOptions = [
    AppAssets.charDiogo,
    AppAssets.charMara,
    AppAssets.charDafny,
    AppAssets.charFrancilene,
    AppAssets.charGlauciane,
    AppAssets.charLindoedson,
    AppAssets.charRenner,
    AppAssets.charDiogo,
    AppAssets.charMara,
    AppAssets.charDafny,
  ];

  /// Exibe o modal de seleção de status
  static void show(BuildContext context, {
    required String currentAvatar,
    String? currentStatus,
    required Function(String?) onStatusSelected,
  }) {
    String? selectedStatus = currentStatus;

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: AppTheme.white,
          hasSabGradient: false,
          topBarTitle: Text('Set your status', style: AppTheme.textXlBold),
          trailingNavBarWidget: _buildGemCounter(),
          isTopBarLayerAlwaysVisible: true,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    // Avatar com status atual
                    _buildCurrentAvatar(currentAvatar, selectedStatus),
                    const SizedBox(height: 32),

                    // Grid de opções
                    _buildStatusGrid(
                      selectedStatus: selectedStatus,
                      onSelect: (status) {
                        setState(() => selectedStatus = status);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botões
                    AppButton(
                      text: 'Done',
                      onPressed: () {
                        onStatusSelected(selectedStatus);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Clear status',
                      isPrimary: false,
                      onPressed: () {
                        onStatusSelected(null);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widgets
  static Widget _buildGemCounter() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppAssets.appbarGem, width: 24, height: 24),
          const SizedBox(width: 6),
          Text(
            '650',
            style: AppTheme.textLgBold.copyWith(color: AppTheme.red),
          ),
        ],
      ),
    );
  }

  static Widget _buildCurrentAvatar(String avatar, String? status) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Borda tracejada
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary,
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
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
            decoration: BoxDecoration(
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
    required String? selectedStatus,
    required Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _statusOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final asset = entry.value;
        final isSelected = index == 0; // Primeiro selecionado por padrão

        return GestureDetector(
          onTap: () => onSelect('😊'), // Placeholder
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.gray600,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: ClipOval(
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
          ),
        );
      }).toList(),
    );
  }
}
