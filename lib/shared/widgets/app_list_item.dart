import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/theme.dart';

/// Item de lista reutilizável para menus e configurações
/// Substitui SettingsItem e NotificationItem
class AppListItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showChevron;

  const AppListItem({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Ícone (opcional)
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.gray700_50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    size: 16,
                    color: enabled ? AppTheme.gray200 : AppTheme.gray400,
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],

            // Label
            Expanded(
              child: Text(
                label,
                style: icon != null
                    ? AppTheme.textMdSemibold.copyWith(
                        color: enabled ? AppTheme.black : AppTheme.gray400,
                      )
                    : AppTheme.textMdMedium.copyWith(
                        color: enabled ? AppTheme.black : AppTheme.gray400,
                      ),
              ),
            ),

            // Trailing (widget customizado ou seta)
            if (trailing != null)
              trailing!
            else if (onTap != null && showChevron)
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: AppTheme.gray400,
              ),
          ],
        ),
      ),
    );
  }
}
