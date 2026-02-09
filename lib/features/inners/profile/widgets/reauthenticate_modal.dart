import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Modal de reautenticação para operações sensíveis
class ReauthenticateModal {
  static Future<String?> show(BuildContext context) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? result;

    await WoltModalSheet.show<String>(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  Text(
                    'reauthenticate_title'.tr,
                    style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Descrição
                  Text(
                    'reauthenticate_description'.tr,
                    style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Campo de senha
                  AppTextField(
                    controller: passwordController,
                    label: 'reauthenticate_password_label'.tr,
                    hint: 'reauthenticate_password_hint'.tr,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'reauthenticate_password_required'.tr;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Botão Cancelar
                  AppButton(
                    text: 'reauthenticate_cancel'.tr,
                    isPrimary: false,
                    onPressed: () {
                      result = null;
                      Get.back();
                    },
                  ),

                  const SizedBox(height: 12),

                  // Botão Confirmar
                  AppButton(
                    text: 'reauthenticate_confirm'.tr,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        result = passwordController.text;
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    passwordController.dispose();
    return result;
  }
}
