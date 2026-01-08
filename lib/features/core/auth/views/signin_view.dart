import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
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
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: AppTheme.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('Sign in', style: AppTheme.textXlBold.copyWith(color: AppTheme.black)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                AppTextField(
                  label: 'User name / email',
                  hint: 'enter your user name / email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Password',
                  hint: 'enter your Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: FaIcon(
                      _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                      color: AppTheme.gray400,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 12),
                _buildForgotPassword(),
                const SizedBox(height: 32),
                AppButton(
                  text: 'Sign in',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: implementar login
                    }
                  },
                ),
                const SizedBox(height: 20),
                _buildSocialButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widgets
  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: _controller.goToForgotPassword,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Forget your password', style: AppTheme.textMdSemibold.copyWith(color: AppTheme.primary)),
          const SizedBox(height: 2),
          Container(height: 1.5, width: 165, color: AppTheme.primary),
        ],
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: SocialButton(text: 'Facebook', iconPath: AppAssets.logoFacebook, onPressed: () {}),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SocialButton(text: 'Gmail', iconPath: AppAssets.logoGoogle, onPressed: () {}),
        ),
      ],
    );
  }
}
