import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Página de alteração de senha
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estados de visibilidade
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Alterar senha'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Old Password
            AppTextField(
              label: 'Senha Atual',
              hint: 'digite a senha atual',
              controller: _oldPasswordController,
              obscureText: _obscureOldPassword,
              suffixIcon: IconButton(
                icon: FaIcon(
                  _obscureOldPassword
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  size: 18,
                  color: AppTheme.gray400,
                ),
                onPressed: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
              ),
            ),

            const SizedBox(height: 20),

            // New Password
            AppTextField(
              label: 'Nova Senha',
              hint: 'digite a nova senha',
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              suffixIcon: IconButton(
                icon: FaIcon(
                  _obscureNewPassword
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  size: 18,
                  color: AppTheme.gray400,
                ),
                onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
            ),

            const SizedBox(height: 20),

            // Confirm Password
            AppTextField(
              label: 'Confirmar senha',
              hint: 'repita sua senha',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: FaIcon(
                  _obscureConfirmPassword
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  size: 18,
                  color: AppTheme.gray400,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            AppButton(
              text: 'Salvar',
              isPrimary: false,
              onPressed: () {
                // TODO: Salvar senha
              },
            ),
          ],
        ),
      ),
    );
  }
}
