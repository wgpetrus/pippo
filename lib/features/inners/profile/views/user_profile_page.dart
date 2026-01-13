import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
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
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: AppTheme.gray400, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Profile', style: AppTheme.displaySmBold),
      ),
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
                debugPrint('Follow tapped');
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

            // Overview
            OverviewSection(
              xp: xp,
              streak: 6,
              level: 12,
              flagAsset: AppAssets.flagFrance,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
