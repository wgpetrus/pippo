import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_back_button.dart';

/// AppBar padrão do app para páginas internas
/// Mantém consistência visual em todas as telas
class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool centerTitle;

  const AppAppbar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.white,
      surfaceTintColor: AppTheme.white,
      elevation: 0,
      leading: showBack ? AppBackButton(onPressed: onBack) : null,
      title: Text(title, style: AppTheme.displaySmBold),
      titleSpacing: showBack ? 12 : 20,
      centerTitle: centerTitle,
      actions: actions,
    );
  }
}
