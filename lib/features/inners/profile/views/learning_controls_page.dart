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
    _controller = Get.find<ProfileSettingsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'Controles de Aprendizado',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Seção Learning Style
            Text(
              'Estilo de Aprendizado',
              style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
            ),

            const SizedBox(height: 8),

            // Sound effect
            Obx(() => AppListItem(
              icon: FontAwesomeIcons.volumeHigh,
              label: 'Efeitos sonoros',
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
              label: 'Exercícios de escuta',
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
              label: 'Exercícios de fala',
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
              'Meta Diária',
              style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
            ),

            const SizedBox(height: 8),

            // Daily goal selector
            Obx(() => AppListItem(
              icon: FontAwesomeIcons.bullseye,
              label: 'Meta diária',
              trailing: Text(
                '${_controller.dailyGoal.value} min',
                style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
              ),
              onTap: () => _showDailyGoalModal(),
            )),

            const SizedBox(height: 24),

            // Seção Language-Specific Settings
            Text(
              'Configurações de Idioma',
              style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
            ),

            const SizedBox(height: 8),

            // Word Display Mode
            AppListItem(
              icon: FontAwesomeIcons.solidUser,
              label: 'Modo de Exibição',
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
                'Meta Diária',
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
              'Todas as palavras',
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
