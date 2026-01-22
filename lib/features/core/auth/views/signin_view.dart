import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
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
    _passwordController.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(
        title: 'Entrar',
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
                  label: 'Usuário / e-mail',
                  hint: 'digite seu usuário / e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _controller.validateEmail,
                ),
                SizedBox(height: r.spacing16),
                AppTextField(
                  label: 'Senha',
                  hint: 'digite sua senha',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _controller.validatePassword,
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
                Obx(() => _controller.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(bottom: r.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _controller.errorMessage.value,
                              style: AppTheme.textSmMedium.copyWith(color: AppTheme.error),
                            ),
                            // Botão "Fazer login" quando erro de conta existente com credencial diferente
                            if (_controller.showLoginButton.value) ...[
                              SizedBox(height: r.spacing12),
                              AppButton(
                                text: 'Fazer login com e-mail',
                                isPrimary: false,
                                onPressed: () {
                                  // Limpar erro e focar no formulário
                                  _controller.errorMessage.value = '';
                                  _controller.showLoginButton.value = false;
                                  _emailController.clear();
                                  _passwordController.clear();
                                },
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),
                Obx(() => AppButton(
                      text: 'Entrar',
                      isLoading: _controller.isLoading.value,
                      onPressed: _controller.isLoading.value
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _controller.login(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );
                              }
                            },
                    )),
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
    return Obx(() => GestureDetector(
          onTap: _controller.isLoading.value ? null : _controller.goToForgotPassword,
          child: Opacity(
            opacity: _controller.isLoading.value ? 0.5 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esqueceu sua senha',
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
        ));
  }

  Widget _buildSocialButtons(ResponsiveUtils r) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: SocialButton(
                text: 'Facebook',
                iconPath: AppAssets.logoFacebook,
                onPressed: _controller.isLoading.value ? null : _controller.onFacebookTap,
              ),
            ),
            SizedBox(width: r.spacing12),
            Expanded(
              child: SocialButton(
                text: 'Gmail',
                iconPath: AppAssets.logoGoogle,
                onPressed: _controller.isLoading.value ? null : _controller.signInWithGoogle,
              ),
            ),
          ],
        ));
  }
}
