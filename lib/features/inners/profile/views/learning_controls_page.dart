import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_list_item.dart';
import '../controllers/profile_settings_controller.dart';

/// Página de controles de aprendizado
class LearningControlsPage extends StatefulWidget {
  const LearningControlsPage({super.key});

  @override
  State<LearningControlsPage> createState() => _LearningControlsPageState();
}

class _LearningControlsPageState extends State<LearningControlsPage> {
  late final ProfileSettingsController _controller;

  // Modo de exibição de palavras (0 = all words highlighted, 1 = new words only)
  int _displayModeIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Garantir que controller está registrado
    if (!Get.isRegistered<ProfileSettingsController>()) {
      Get.lazyPut<ProfileSettingsController>(() => ProfileSettingsController());
    }
    
    _controller = Get.find<ProfileSettingsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'learning_controls_title'.tr,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Seção Learning Style
            Text(
              'learning_controls_learning_style'.tr,
              style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
            ),

            const SizedBox(height: 8),

            // Sound effect
            Obx(() => AppListItem(
              icon: FontAwesomeIcons.volumeHigh,
              label: 'learning_controls_sound_effects'.tr,
              trailing: Switch(
                value: _controller.soundEffects.value,
                onChanged: (value) => _controller.updateSetting('soundEffects', value),
                activeThumbColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            )),

            // Listening exercises
            Obx(() => AppListItem(
              icon: FontAwesomeIcons.solidComment,
              label: 'learning_controls_listening_exercises'.tr,
              trailing: Switch(
                value: _controller.listeningExercises.value,
                onChanged: (value) => _controller.updateSetting('listeningExercises', value),
                activeThumbColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            )),

            // Speaking exercises
            Obx(() => AppListItem(
              icon: FontAwesomeIcons.solidCommentDots,
              label: 'learning_controls_speaking_exercises'.tr,
              trailing: Switch(
                value: _controller.speakingExercises.value,
                onChanged: (value) => _controller.updateSetting('speakingExercises', value),
                activeThumbColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            )),

            const SizedBox(height: 24),

            // Seção Daily Goal
            Text(
              'learning_controls_daily_goal_section'.tr,
              style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
            ),

            const SizedBox(height: 8),

            // Daily goal selector
            Obx(() => AppListItem(
              icon: FontAwesomeIcons.bullseye,
              label: 'learning_controls_daily_goal'.tr,
              trailing: Text(
                '${_controller.dailyGoal.value} ${'learning_controls_daily_goal_minutes'.tr}',
                style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
              ),
              onTap: () => _showDailyGoalModal(),
            )),

            const SizedBox(height: 24),

            // Seção Language-Specific Settings
            Text(
              'learning_controls_language_settings'.tr,
              style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
            ),

            const SizedBox(height: 8),

            // Word Display Mode
            AppListItem(
              icon: FontAwesomeIcons.solidUser,
              label: 'learning_controls_display_mode'.tr,
              trailing: Switch(
                value: _displayModeIndex == 0,
                onChanged: (value) => setState(() => _displayModeIndex = value ? 0 : 1),
                activeThumbColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

            const SizedBox(height: 16),

            // Cards de seleção de modo
            Row(
              children: [
                Expanded(
                  child: _DisplayModeCard(
                    isSelected: _displayModeIndex == 0,
                    onTap: () => setState(() => _displayModeIndex = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DisplayModeCard(
                    isSelected: _displayModeIndex == 1,
                    highlightAll: false,
                    onTap: () => setState(() => _displayModeIndex = 1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'learning_controls_daily_goal_section'.tr,
                style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
              ),
              const SizedBox(height: 16),
              ...[5, 10, 15, 20, 30].map((minutes) {
                return Obx(() => ListTile(
                  title: Text('$minutes minutos'),
                  trailing: _controller.dailyGoal.value == minutes
                      ? const Icon(Icons.check, color: AppTheme.primary)
                      : null,
                  onTap: () {
                    _controller.updateSetting('dailyGoal', minutes);
                    Navigator.pop(context);
                  },
                ));
              }),
            ],
          ),
        );
      },
    );
  }
}

/// Card de modo de exibição de palavras
class _DisplayModeCard extends StatelessWidget {
  final bool isSelected;
  final bool highlightAll;
  final VoidCallback onTap;

  const _DisplayModeCard({
    required this.isSelected,
    this.highlightAll = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.gray600,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pronúncias
            Row(
              children: [
                Text(
                  'Kah-myel',
                  style: AppTheme.textXsMedium.copyWith(
                    color: highlightAll || isSelected ? AppTheme.primary : AppTheme.gray400,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Mo-hoob',
                  style: AppTheme.textXsMedium.copyWith(
                    color: highlightAll || isSelected ? AppTheme.primary : AppTheme.gray400,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Palavras em cirílico
            RichText(
              text: TextSpan(
                style: AppTheme.textMdBold.copyWith(color: AppTheme.black),
                children: [
                  TextSpan(
                    text: 'Камель ',
                    style: TextStyle(
                      color: highlightAll && isSelected ? AppTheme.primary : AppTheme.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Мохуб',
                    style: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.black,
                      fontWeight: !highlightAll ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Label
            Text(
              'learning_controls_all_words'.tr,
              style: AppTheme.textSmMedium.copyWith(
                color: isSelected ? AppTheme.primary : AppTheme.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
