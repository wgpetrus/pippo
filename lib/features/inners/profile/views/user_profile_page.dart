import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../widgets/overview_section.dart';
import '../widgets/profile_card.dart';
import '../widgets/weekly_progress_chart.dart';

/// Página de perfil de outro usuário
class UserProfilePage extends StatelessWidget {
  final String name;
  final String username;
  final String avatarAsset;
  final int xp;

  const UserProfilePage({
    super.key,
    required this.name,
    required this.username,
    required this.avatarAsset,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Perfil'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Card azul do perfil
            ProfileCard(
              avatarAsset: avatarAsset,
              name: name,
              username: username,
              following: 30,
              followers: 22,
              flagAsset: AppAssets.flagFrance,
              coursesCount: 2,
              isOwnProfile: false,
              showFollowButton: true,
              onFollowTap: () {
                // TODO: Seguir usuário
              },
            ),
            const SizedBox(height: 24),

            // Gráfico de progresso semanal
            WeeklyProgressChart(
              userProgress: [
                ChartData('Mon', 50),
                ChartData('Tue', 100),
                ChartData('Wed', 150),
                ChartData('Thu', 200),
                ChartData('Fri', 250),
                ChartData('Sat', 500),
                ChartData('Sun', 1200),
              ],
              otherProgress: [
                ChartData('Mon', 30),
                ChartData('Tue', 80),
                ChartData('Wed', 50),
                ChartData('Thu', 200),
                ChartData('Fri', 250),
                ChartData('Sat', 300),
                ChartData('Sun', 350),
              ],
              showOther: true,
            ),
            const SizedBox(height: 24),

            // Overview - passar dados do usuário específico
            OverviewSection(
              flagAsset: AppAssets.flagFrance,
              totalXp: xp, // XP do usuário específico
              currentStreak: 5, // TODO: [future] buscar do Firestore
              longestStreak: 12, // TODO: [future] buscar do Firestore
              level: 3, // TODO: [future] buscar do Firestore
              useOwnStats: false, // Não usar stats do GamificationController
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
