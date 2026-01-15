import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_list_item.dart';
import '../widgets/reminder_time_modal.dart';

/// Página de configurações de notificações
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Estados dos switches
  bool _practiceReminders = false;
  bool _scheduling = true;
  bool _streakFreeze = true;
  bool _weeklyProgress = true;
  bool _hintVisibility = true;

  // Horário do lembrete
  DateTime _reminderTime = DateTime(2024, 1, 1, 6, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'Notificações',
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

            // Practice reminders
            AppListItem(
              label: 'Lembretes de prática',
              showChevron: false,
              trailing: Switch(
                value: _practiceReminders,
                onChanged: (value) => setState(() => _practiceReminders = value),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

            // Scheduling
            AppListItem(
              label: 'Agendamento',
              showChevron: false,
              trailing: Switch(
                value: _scheduling,
                onChanged: (value) => setState(() => _scheduling = value),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

            // Reminder time
            AppListItem(
              label: 'Horário do lembrete',
              enabled: _scheduling,
              onTap: () => _showReminderTimePicker(),
              trailing: Text(
                _formatTime(_reminderTime),
                style: AppTheme.textMdBold.copyWith(
                  color: _scheduling ? AppTheme.primary : AppTheme.gray400,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Streak Freeze
            AppListItem(
              label: 'Congelar Sequência',
              showChevron: false,
              trailing: Switch(
                value: _streakFreeze,
                onChanged: (value) => setState(() => _streakFreeze = value),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

            // Weekly Progress
            AppListItem(
              label: 'Progresso Semanal',
              showChevron: false,
              trailing: Switch(
                value: _weeklyProgress,
                onChanged: (value) => setState(() => _weeklyProgress = value),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            ),

            // Hint Visibility
            AppListItem(
              label: 'Visibilidade de Dicas',
              showChevron: false,
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

            // Botão Restore default
            AppButton(
              text: 'Restaurar padrão',
              isPrimary: false,
              onPressed: _restoreDefaults,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _restoreDefaults() {
    setState(() {
      _practiceReminders = false;
      _scheduling = true;
      _streakFreeze = true;
      _weeklyProgress = true;
      _hintVisibility = true;
      _reminderTime = DateTime(2024, 1, 1, 6, 0);
    });
  }

  void _showReminderTimePicker() {
    if (!_scheduling) return;
    ReminderTimeModal.show(
      context,
      initialTime: _reminderTime,
      onSave: (time) => setState(() => _reminderTime = time),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
