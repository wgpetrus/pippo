import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/profile_auth_controller.dart';

/// Página de alteração de senha
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estados de visibilidade
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late final ProfileAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileAuthController>();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Alterar senha'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.spacing16),
              child: Column(
                children: [
                  SizedBox(height: r.spacing24),

                  // Old Password
                  AppTextField(
                    label: 'Senha Atual',
                    hint: 'digite a senha atual',
                    controller: _oldPasswordController,
                    obscureText: _obscureOldPassword,
                    validator: _controller.validateCurrentPassword,
                    suffixIcon: IconButton(
                      icon: FaIcon(
                        _obscureOldPassword
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash,
                        size: r.fontSize16,
                        color: AppTheme.gray400,
                      ),
                      onPressed: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                    ),
                  ),

                  SizedBox(height: r.spacing16),

                  // New Password
                  AppTextField(
                    label: 'Nova Senha',
                    hint: 'digite a nova senha',
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    validator: _controller.validateNewPassword,
                    suffixIcon: IconButton(
                      icon: FaIcon(
                        _obscureNewPassword
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash,
                        size: r.fontSize16,
                        color: AppTheme.gray400,
                      ),
                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ),
                  ),

                  SizedBox(height: r.spacing16),

                  // Confirm Password
                  AppTextField(
                    label: 'Confirmar senha',
                    hint: 'repita sua senha',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => _controller.validateConfirmPassword(
                      value,
                      _newPasswordController.text,
                    ),
                    suffixIcon: IconButton(
                      icon: FaIcon(
                        _obscureConfirmPassword
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash,
                        size: r.fontSize16,
                        color: AppTheme.gray400,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),

                  SizedBox(height: r.spacing16),

                  // Error message
                  Obx(() {
                    if (_controller.errorMessage.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: r.spacing16),
                      child: Text(
                        _controller.errorMessage.value,
                        style: AppTheme.textSmMedium.copyWith(color: AppTheme.error),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),

                  SizedBox(height: r.spacing16),

                  // Save Button
                  Obx(() => AppButton(
                    text: 'Salvar',
                    isPrimary: false,
                    isLoading: _controller.isLoading.value,
                    onPressed: _controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _controller.changePassword(
                                _oldPasswordController.text,
                                _newPasswordController.text,
                              );
                            }
                          },
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
