import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal para trocar avatar
class ChangeAvatarModal {
  // Lista de avatares disponíveis (avatars + characters)
  static final List<String> _avatars = [
    // Avatars
    AppAssets.avatarMascot1,
    AppAssets.avatarMascot2,
    AppAssets.avatarMascot3,
    AppAssets.avatar4,
    AppAssets.avatar5,
    // Characters
    AppAssets.charDafny,
    AppAssets.charDiogo,
    AppAssets.charFrancilene,
    AppAssets.charGlauciane,
    AppAssets.charLindoedson,
    AppAssets.charMara,
    AppAssets.charRenner,
  ];

  static void show(
    BuildContext context, {
    required String currentAvatar,
    required Function(String) onAvatarSelected,
  }) {
    final selectedAvatar = ValueNotifier<String>(currentAvatar);

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: AppTheme.white,
          hasSabGradient: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                const Text('Trocar Avatar', style: AppTheme.displaySmBold),
                const SizedBox(height: 24),

                // Grid de avatares 5x2
                ValueListenableBuilder<String>(
                  valueListenable: selectedAvatar,
                  builder: (context, selected, _) {
                    return _buildAvatarGrid(selected, (avatar) {
                      selectedAvatar.value = avatar;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Botão Save
                AppButton(
                  text: 'Salvar',
                  onPressed: () {
                    onAvatarSelected(selectedAvatar.value);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widgets
  static Widget _buildAvatarGrid(String selected, Function(String) onSelect) {
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: _avatars.map((a) => _buildAvatarItem(a, selected == a, () => onSelect(a))).toList(),
    );
  }

  static Widget _buildAvatarItem(String avatar, bool isSelected, VoidCallback onTap) {
    final avatarSize = ResponsiveUtils.width(60, min: 44, max: 72);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.gray600,
            width: isSelected ? 3 : 2,
          ),
          color: AppTheme.gray700,
        ),
        child: ClipOval(
          child: Image.asset(avatar, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
