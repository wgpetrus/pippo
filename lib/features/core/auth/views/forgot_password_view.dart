import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_providers_controller.dart';

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
  late final AuthProvidersController _controller;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthProvidersController>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Validador de email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'error_email_required'.tr;
    if (!GetUtils.isEmail(value)) return 'error_email_invalid'.tr;
    return null;
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(title: 'auth_forgot_password_title'.tr),
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
                  'auth_forgot_password_description'.tr,
                  style: AppTheme.textMd.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Campo de e-mail
                AppTextField(
                  label: 'common_email_label'.tr,
                  hint: 'common_email_hint'.tr,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
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
                
                // Botão enviar link
                Obx(() => AppButton(
                  text: 'auth_send_link_button'.tr,
                  isLoading: _controller.isLoading.value,
                  onPressed: _controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _controller.sendPasswordResetLink(
                              _emailController.text.trim(),
                            );
                          }
                        },
                )),
                
                SizedBox(height: r.spacing16),
                
                // Link "Lembrei minha senha"
                Center(
                  child: Obx(() => GestureDetector(
                    onTap: _controller.isLoading.value ? null : _controller.backToSignin,
                    child: Opacity(
                      opacity: _controller.isLoading.value ? 0.5 : 1.0,
                      child: Text(
                        'auth_remembered_password'.tr,
                        style: AppTheme.textMdSemibold.copyWith(
                          color: AppTheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.primary,
                        ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
