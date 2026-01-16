import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Tela de recuperação de senha
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Estados
  late final AuthController _controller;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Esqueci minha senha'),
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
                  'Digite seu e-mail para receber um código de verificação e redefinir sua senha.',
                  style: AppTheme.textMd.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Campo de e-mail
                AppTextField(
                  label: 'E-mail',
                  hint: 'Digite seu e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _controller.validateEmail,
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
                
                // Botão enviar código
                Obx(() => AppButton(
                  text: 'Enviar código',
                  isLoading: _controller.isLoading.value,
                  onPressed: _controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _controller.sendPasswordResetCode(
                              _emailController.text.trim(),
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
