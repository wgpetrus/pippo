import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_list_item.dart';
import '../controllers/profile_settings_controller.dart';
import '../widgets/reminder_time_modal.dart';

/// Página de configurações de notificações
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final ProfileSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileSettingsController>();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'Notificações',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: r.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: r.spacing16),

            // Seção Learning Style
            Text(
              'Estilo de Aprendizado',
              style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
            ),

            SizedBox(height: r.spacing8),

            // Practice reminders
            Obx(() => AppListItem(
              label: 'Lembretes de prática',
              showChevron: false,
              trailing: Switch(
                value: _controller.practiceReminders.value,
                onChanged: (value) => _controller.updateSetting('practiceReminders', value),
                activeThumbColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            )),

            // Leaderboard updates
            Obx(() => AppListItem(
              label: 'Atualizações do ranking',
              showChevron: false,
              trailing: Switch(
                value: _controller.leaderboardUpdates.value,
                onChanged: (value) => _controller.updateSetting('leaderboardUpdates', value),
                activeThumbColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            )),

            // Reminder time
            Obx(() => AppListItem(
              label: 'Horário do lembrete',
              enabled: _controller.practiceReminders.value,
              onTap: () => _showReminderTimePicker(),
              trailing: Text(
                _controller.reminderTime.value,
                style: AppTheme.textMdBold.copyWith(
                  color: _controller.practiceReminders.value ? AppTheme.primary : AppTheme.gray400,
                ),
              ),
            )),

            SizedBox(height: r.spacing8),

            // Friend Activity
            Obx(() => AppListItem(
              label: 'Atividade de amigos',
              showChevron: false,
              trailing: Switch(
                value: _controller.friendActivity.value,
                onChanged: (value) => _controller.updateSetting('friendActivity', value),
                activeThumbColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary30,
                inactiveThumbColor: AppTheme.white,
                inactiveTrackColor: AppTheme.gray500,
              ),
            )),

            SizedBox(height: r.spacing32),
          ],
        ),
      ),
    );
  }

  void _showReminderTimePicker() {
    if (!_controller.practiceReminders.value) return;
    
    // Parse current time from string format "HH:mm"
    final timeParts = _controller.reminderTime.value.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 18;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final currentTime = DateTime(2024, 1, 1, hour, minute);
    
    ReminderTimeModal.show(
      context,
      initialTime: currentTime,
      onSave: (time) {
        // Format time as "HH:mm"
        final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        _controller.updateSetting('reminderTime', formattedTime);
      },
    );
  }
}
