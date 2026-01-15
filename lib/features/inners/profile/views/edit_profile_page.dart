import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../widgets/change_avatar_modal.dart';
import '../widgets/delete_account_modal.dart';
import 'change_password_page.dart';
import 'phone_number_page.dart';

/// Página de edição de perfil
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'Sam');
  final _usernameController = TextEditingController(text: 'sam1201');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _currentAvatar = AppAssets.charMara;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'Perfil',
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Salvar',
              style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Avatar e Change avatar
            Row(
              children: [
                // Avatar
                Builder(
                  builder: (context) {
                    final avatarSize = ResponsiveUtils.width(80, min: 60, max: 96);
                    return Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary, width: 3),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          _currentAvatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Change avatar
                GestureDetector(
                  onTap: _changeAvatar,
                  child: Text(
                    'Trocar avatar',
                    style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Name
            AppTextField(
              label: 'Nome',
              hint: 'digite seu nome',
              controller: _nameController,
            ),

            const SizedBox(height: 20),

            // User name
            AppTextField(
              label: 'Nome de usuário',
              hint: 'digite seu nome de usuário',
              controller: _usernameController,
            ),

            const SizedBox(height: 20),

            // Email
            AppTextField(
              label: 'E-mail',
              hint: 'digite seu e-mail',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // Phone number
            GestureDetector(
              onTap: () => Get.to(() => const PhoneNumberPage()),
              child: AbsorbPointer(
                child: AppTextField(
                  label: 'Telefone',
                  hint: 'adicione seu telefone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Change password
            AppButton(
              text: 'Alterar senha',
              isPrimary: false,
              onPressed: () {
                Get.to(() => const ChangePasswordPage());
              },
            ),

            const SizedBox(height: 16),

            // Delete profile
            AppButton(
              text: 'Excluir perfil',
              isPrimary: false,
              color: AppTheme.red,
              onPressed: () {
                DeleteAccountModal.show(
                  context,
                  onDelete: () {
                    // TODO: Deletar conta
                  },
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Métodos

  void _changeAvatar() {
    ChangeAvatarModal.show(
      context,
      currentAvatar: _currentAvatar,
      onAvatarSelected: (avatar) {
        setState(() => _currentAvatar = avatar);
      },
    );
  }

  void _saveProfile() {
    // TODO: Salvar perfil
    Get.back();
  }
}
