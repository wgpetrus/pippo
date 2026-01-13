import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/app_assets.dart';

/// Header reutilizável para páginas internas (Shop, Leaderboard, Profile)
class AppPageHeader extends StatelessWidget {
  final String title;
  final int? gemCount;

  const AppPageHeader({
    super.key,
    required this.title,
    this.gemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.displaySmBold),

          // Contador de gems (opcional)
          if (gemCount != null)
            Row(
              children: [
                Image.asset(AppAssets.appbarGem, width: 24, height: 24),
                const SizedBox(width: 6),
                Text(
                  '$gemCount',
                  style: AppTheme.textLgBold.copyWith(color: AppTheme.red),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
