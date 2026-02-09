import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal de seleção de horário do lembrete
class ReminderTimeModal {
  static void show(
    BuildContext context, {
    required DateTime initialTime,
    required Function(DateTime) onSave,
  }) {
    DateTime selectedTime = initialTime;

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      'reminder_time_title'.tr,
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    ),

                    const SizedBox(height: 24),

                    // Time Picker
                    SizedBox(
                      height: 200,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: selectedTime,
                        use24hFormat: false,
                        onDateTimeChanged: (DateTime newTime) {
                          selectedTime = newTime;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botão Save
                    AppButton(
                      text: 'reminder_time_save'.tr,
                      onPressed: () {
                        Get.back();
                        onSave(selectedTime);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
