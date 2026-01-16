import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_list_item.dart';
import '../../../core/auth/controllers/auth_controller.dart';
import 'courses_page.dart';
import 'edit_profile_page.dart';
import 'learning_controls_page.dart';
import 'notifications_page.dart';

/// Página de configurações
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Estados
  bool _notificationsEnabled = true;
  late final AuthController _authController;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'Configurações',
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Salvar configurações
            },
            child: Text(
              'Salvar',
              style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: r.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: r.spacing16),

            // Account Section
            _buildSection(
              r: r,
              title: 'Conta',
              children: [
                AppListItem(
                  icon: FontAwesomeIcons.solidUser,
                  label: 'Perfil',
                  onTap: () => Get.to(() => const EditProfilePage()),
                ),
                AppListItem(
                  icon: FontAwesomeIcons.solidBell,
                  label: 'Notificações',
                  onTap: () => Get.to(() => const NotificationsPage()),
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        if (value) {
                          Get.to(() => const NotificationsPage());
                        }
                      },
                      activeColor: AppTheme.white,
                      activeTrackColor: AppTheme.primary,
                      inactiveThumbColor: AppTheme.white,
                      inactiveTrackColor: AppTheme.gray500,
                    ),
                  ),
                ),
                AppListItem(
                  icon: FontAwesomeIcons.graduationCap,
                  label: 'Cursos',
                  onTap: () => Get.to(() => const CoursesPage()),
                ),
                AppListItem(
                  icon: FontAwesomeIcons.sliders,
                  label: 'Controles de Aprendizado',
                  onTap: () => Get.to(() => const LearningControlsPage()),
                ),
              ],
            ),

            SizedBox(height: r.spacing24),

            // Subscription Section
            _buildSection(
              r: r,
              title: 'Assinatura',
              children: [
                AppListItem(
                  icon: FontAwesomeIcons.solidCreditCard,
                  label: 'Planos',
                  onTap: () {
                    // TODO: Navegar para Plans
                  },
                ),
              ],
            ),

            SizedBox(height: r.spacing24),

            // Support Section
            _buildSection(
              r: r,
              title: 'Suporte',
              children: [
                AppListItem(
                  icon: FontAwesomeIcons.shieldHalved,
                  label: 'Política de Privacidade',
                  onTap: () {
                    // TODO: Navegar para Privacy Policy
                  },
                ),
                AppListItem(
                  icon: FontAwesomeIcons.fileLines,
                  label: 'Termos de Uso',
                  onTap: () {
                    // TODO: Navegar para Terms of Use
                  },
                ),
                AppListItem(
                  icon: FontAwesomeIcons.solidCircleQuestion,
                  label: 'Ajuda e Suporte',
                  onTap: () {
                    // TODO: Navegar para Help & Support
                  },
                ),
              ],
            ),

            SizedBox(height: r.spacing32),

            // Logout Button
            AppButton(
              text: 'Sair',
              isPrimary: false,
              suffixIcon: FaIcon(
                FontAwesomeIcons.rightFromBracket,
                size: 16,
                color: AppTheme.primary,
              ),
              onPressed: () => _authController.logout(),
            ),

            SizedBox(height: r.spacing32),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _buildSection({
    required ResponsiveUtils r,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.textSmBold.copyWith(color: AppTheme.gray300),
        ),
        SizedBox(height: r.spacing8),
        ...children,
      ],
    );
  }
}
