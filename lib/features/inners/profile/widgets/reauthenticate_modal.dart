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
                    'Confirme sua Identidade',
                    style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Descrição
                  Text(
                    'Por segurança, precisamos confirmar sua senha antes de continuar.',
                    style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Campo de senha
                  AppTextField(
                    controller: passwordController,
                    label: 'Senha',
                    hint: 'Digite sua senha',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Senha é obrigatória.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Botão Cancelar
                  AppButton(
                    text: 'Cancelar',
                    isPrimary: false,
                    onPressed: () {
                      result = null;
                      Get.back();
                    },
                  ),

                  const SizedBox(height: 12),

                  // Botão Confirmar
                  AppButton(
                    text: 'Confirmar',
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
