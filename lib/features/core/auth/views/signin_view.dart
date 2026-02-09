import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_credentials_controller.dart';
import '../controllers/auth_providers_controller.dart';
import '../widgets/social_button.dart';

/// Tela de login
class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Estados
  bool _obscurePassword = true;
  late final AuthCredentialsController _credentialsController;
  late final AuthProvidersController _providersController;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _credentialsController = Get.find<AuthCredentialsController>();
    _providersController = Get.find<AuthProvidersController>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'auth_signin_title'.tr,
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: r.spacing24,
            right: r.spacing24,
            top: r.spacing24,
            bottom: r.spacing24 + r.keyboardHeight,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.spacing8),
                AppTextField(
                  label: 'auth_email_label'.tr,
                  hint: 'auth_email_hint'.tr,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _credentialsController.validateEmail,
                ),
                SizedBox(height: r.spacing16),
                AppTextField(
                  label: 'auth_password_label'.tr,
                  hint: 'auth_password_hint'.tr,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _credentialsController.validatePassword,
                  suffixIcon: IconButton(
                    icon: FaIcon(
                      _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                      color: AppTheme.gray400,
                      size: r.fontSize16,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                SizedBox(height: r.spacing12),
                _buildForgotPassword(r),
                SizedBox(height: r.spacing32),
                Obx(() {
                  // Mostrar erro de credentials ou providers (o que tiver conteúdo)
                  final errorMsg = _credentialsController.errorMessage.value.isNotEmpty
                      ? _credentialsController.errorMessage.value
                      : _providersController.errorMessage.value;
                  
                  if (errorMsg.isEmpty) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: r.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          errorMsg,
                          style: AppTheme.textSmMedium.copyWith(color: AppTheme.error),
                        ),
                        // Botão "Fazer login" quando erro de conta existente com credencial diferente
                        if (_providersController.showLoginButton.value) ...[
                          SizedBox(height: r.spacing12),
                          AppButton(
                            text: 'auth_login_with_email_button'.tr,
                            isPrimary: false,
                            onPressed: () {
                              // Limpar erro e focar no formulário
                              _credentialsController.errorMessage.value = '';
                              _providersController.errorMessage.value = '';
                              _providersController.showLoginButton.value = false;
                              _emailController.clear();
                              _passwordController.clear();
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                Obx(() {
                  final isLoading = _credentialsController.isLoading.value || 
                                   _providersController.isLoading.value;
                  return AppButton(
                    text: 'auth_signin_button'.tr,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _credentialsController.login(
                                _emailController.text.trim(),
                                _passwordController.text,
                              );
                            }
                          },
                  );
                }),
                SizedBox(height: r.spacing16),
                _buildSocialButtons(r),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widgets
  Widget _buildForgotPassword(ResponsiveUtils r) {
    return Obx(() {
      final isLoading = _credentialsController.isLoading.value || 
                       _providersController.isLoading.value;
      return GestureDetector(
        onTap: isLoading ? null : _providersController.goToForgotPassword,
        child: Opacity(
          opacity: isLoading ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'auth_forgot_password'.tr,
                style: AppTheme.textMdSemibold.copyWith(
                  color: AppTheme.primary,
                  fontSize: r.fontSize14,
                ),
              ),
              SizedBox(height: r.spacing4 / 2),
              Container(
                height: 1.5,
                width: r.value(mobile: 165, tablet: 180, desktop: 200),
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSocialButtons(ResponsiveUtils r) {
    return Obx(() {
      final isLoading = _credentialsController.isLoading.value || 
                       _providersController.isLoading.value;
      return Row(
        children: [
          Expanded(
            child: SocialButton(
              text: 'auth_facebook_button'.tr,
              iconPath: AppAssets.logoFacebook,
              onPressed: isLoading ? null : _providersController.onFacebookTap,
            ),
          ),
          SizedBox(width: r.spacing12),
          Expanded(
            child: SocialButton(
              text: 'auth_gmail_button'.tr,
              iconPath: AppAssets.logoGoogle,
              onPressed: isLoading ? null : _providersController.signInWithGoogle,
            ),
          ),
        ],
      );
    });
  }
}
