import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../theme/theme.dart';

/// Botão voltar padrão do app
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: AppTheme.white, size: 18),
        onPressed: onPressed ?? () => Get.back(),
      ),
    );
  }
}
