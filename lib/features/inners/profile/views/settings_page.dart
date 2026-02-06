import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_list_item.dart';
import '../../../core/auth/controllers/auth_controller.dart';
import '../controllers/profile_settings_controller.dart';
import '../widgets/delete_account_modal.dart';
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
  late final AuthController _authController;
  late final ProfileSettingsController _settingsController;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _settingsController = Get.find<ProfileSettingsController>();
    
    // Carregar configurações ao abrir a página
    _settingsController.loadSettings();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'Configurações',
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

            SizedBox(height: r.spacing24),

            // Danger Zone Section
            _buildSection(
              r: r,
              title: 'Zona de Perigo',
              children: [
                _buildDeleteAccountItem(context),
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

  Widget _buildDeleteAccountItem(BuildContext context) {
    return GestureDetector(
      onTap: () => DeleteAccountModal.show(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  size: 16,
                  color: AppTheme.red,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Label
            Expanded(
              child: Text(
                'Excluir Conta',
                style: AppTheme.textMdSemibold.copyWith(
                  color: AppTheme.red,
                ),
              ),
            ),

            // Seta
            const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 12,
              color: AppTheme.red,
            ),
          ],
        ),
      ),
    );
  }
}
