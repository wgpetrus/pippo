import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_list_item.dart';

/// Página de controles de aprendizado
class LearningControlsPage extends StatefulWidget {
  const LearningControlsPage({super.key});

  @override
  State<LearningControlsPage> createState() => _LearningControlsPageState();
}

class _LearningControlsPageState extends State<LearningControlsPage> {
  // Estados dos switches
  bool _soundEffect = false;
  bool _feedbacks = true;
  bool _motivationalMessages = true;
  bool _listeningExperience = true;
  bool _hintVisibility = true;
  bool _wordDisplayMode = true;

  // Modo de exibição de palavras (0 = all words highlighted, 1 = new words only)
  int _displayModeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'Controles de Aprendizado',
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Salvar',
              style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
            ),
          ),
        ],
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
            AppListItem(
              icon: FontAwesomeIcons.volumeHigh,
              label: 'Efeitos sonoros',
              trailing: Switch(
                value: _soundEffect,
                onChanged: (value) => setState(() => _soundEffect = value),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

            // Feedbacks
            AppListItem(
              icon: FontAwesomeIcons.solidCommentDots,
              label: 'Feedbacks',
              trailing: Switch(
                value: _feedbacks,
                onChanged: (value) => setState(() => _feedbacks = value),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

            // Motivational messages
            AppListItem(
              icon: FontAwesomeIcons.solidBell,
              label: 'Mensagens motivacionais',
              trailing: Switch(
                value: _motivationalMessages,
                onChanged: (value) => setState(() => _motivationalMessages = value),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

            // Listening experience
            AppListItem(
              icon: FontAwesomeIcons.solidComment,
              label: 'Experiência de escuta',
              trailing: Switch(
                value: _listeningExperience,
                onChanged: (value) => setState(() => _listeningExperience = value),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

            // Hint Visibility
            AppListItem(
              icon: FontAwesomeIcons.solidImage,
              label: 'Visibilidade de Dicas',
              trailing: Switch(
                value: _hintVisibility,
                onChanged: (value) => setState(() => _hintVisibility = value),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

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
                value: _wordDisplayMode,
                onChanged: (value) => setState(() => _wordDisplayMode = value),
                activeColor: AppTheme.primary,
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
