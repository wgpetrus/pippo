import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import 'league_selector.dart';

/// Header colapsável do leaderboard com escudos
class LeaderboardHeader extends StatelessWidget {
  final String title;
  final List<String> shieldAssets;
  final int currentLevel;

  const LeaderboardHeader({
    super.key,
    required this.title,
    required this.shieldAssets,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.white,
      surfaceTintColor: AppTheme.white,
      elevation: 0,
      pinned: true,
      expandedHeight: 220,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      title: Text(title, style: AppTheme.displaySmBold),
      titleSpacing: 20,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Container(
            color: AppTheme.white,
            padding: const EdgeInsets.only(top: 70),
            child: LeagueSelector(
              shieldAssets: shieldAssets,
              currentLevel: currentLevel,
            ),
          ),
        ),
      ),
    );
  }
}
