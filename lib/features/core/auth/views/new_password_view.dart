import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Tela de redefinição de senha
class NewPasswordView extends StatefulWidget {
  const NewPasswordView({super.key});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estados
  late final AuthController _controller;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validadores
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória.';
    }
    if (value != _newPasswordController.text) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Nova senha'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
                // Texto explicativo
                Text(
                  'Crie uma nova senha para sua conta.',
                  style: AppTheme.textMd.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Campo de nova senha
                AppTextField(
                  label: 'Nova senha',
                  hint: 'Digite sua nova senha',
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  validator: _controller.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.gray400,
                    ),
                    onPressed: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo de confirmação de senha
                AppTextField(
                  label: 'Confirmar senha',
                  hint: 'Digite sua senha novamente',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.gray400,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Mensagem de erro
                Obx(() {
                  if (_controller.errorMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _controller.errorMessage.value,
                      style: AppTheme.textSm.copyWith(
                        color: AppTheme.error,
                      ),
                    ),
                  );
                }),
                
                // Botão redefinir senha
                Obx(() => AppButton(
                  text: 'Redefinir senha',
                  isLoading: _controller.isLoading.value,
                  onPressed: _controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _controller.resetPassword(
                              _newPasswordController.text.trim(),
                            );
                          }
                        },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
