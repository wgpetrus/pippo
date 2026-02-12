import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/profile_data_controller.dart';
import '../controllers/profile_auth_controller.dart';
import '../widgets/change_avatar_modal.dart';
import '../widgets/country_selector_modal.dart';
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
  late final ProfileDataController _controller;
  late final ProfileAuthController _authController;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  
  Timer? _debounce;
  String _currentAvatar = '';
  String _currentCountry = 'BR';

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileDataController>();
    // Garantir que ProfileAuthController está disponível
    if (!Get.isRegistered<ProfileAuthController>()) {
      Get.put(ProfileAuthController());
    }
    _authController = Get.find<ProfileAuthController>();
    
    // Inicializar campos com dados do controller
    _nameController.text = _controller.userName.value;
    _usernameController.text = _controller.username.value;
    _bioController.text = _controller.bio.value;
    _currentAvatar = _controller.avatarId.value;
    _currentCountry = _controller.country.value;
    
    // Listener para username com debounce
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_usernameController.text.isNotEmpty) {
        _controller.checkUsernameAvailability(_usernameController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(
        title: 'profile_edit_title'.tr,
        actions: [
          Obx(() => TextButton(
            onPressed: _controller.isLoading.value ? null : _saveProfile,
            child: Text(
              'profile_edit_save'.tr,
              style: AppTheme.textMdBold.copyWith(
                color: _controller.isLoading.value 
                    ? AppTheme.gray 
                    : AppTheme.primary,
              ),
            ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Avatar e Change avatar
              Row(
                children: [
                  // Avatar - Obx para reagir a mudanças
                  Obx(() {
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
                          _getAvatarAsset(_currentAvatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),

                  const Spacer(),

                  // Change avatar
                  GestureDetector(
                    onTap: _changeAvatar,
                    child: Text(
                      'profile_edit_change_avatar'.tr,
                      style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Name
              AppTextField(
                label: 'profile_edit_name_label'.tr,
                hint: 'profile_edit_name_hint'.tr,
                controller: _nameController,
                validator: _controller.validateName,
              ),

              const SizedBox(height: 20),

              // Username com indicador de disponibilidade
              Obx(() => AppTextField(
                label: 'profile_edit_username_label'.tr,
                hint: 'profile_edit_username_hint'.tr,
                controller: _usernameController,
                validator: _controller.validateUsername,
                suffixIcon: _controller.isCheckingUsername.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        ),
                      )
                    : _usernameController.text.isNotEmpty &&
                            _usernameController.text != _controller.username.value
                        ? Icon(
                            _controller.isUsernameAvailable.value
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _controller.isUsernameAvailable.value
                                ? AppTheme.green
                                : AppTheme.red,
                          )
                        : null,
              )),

              const SizedBox(height: 20),

              // Bio
              AppTextField(
                label: 'profile_edit_bio_label'.tr,
                hint: 'profile_edit_bio_hint'.tr,
                controller: _bioController,
                validator: _controller.validateBio,
                maxLines: 3,
                maxLength: 150,
              ),

              const SizedBox(height: 20),

              // Country selector
              GestureDetector(
                onTap: _selectCountry,
                child: AbsorbPointer(
                  child: AppTextField(
                    label: 'profile_edit_country_label'.tr,
                    hint: 'profile_edit_country_hint'.tr,
                    controller: TextEditingController(
                      text: _getCountryName(_currentCountry),
                    ),
                    suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Email (read-only)
              Obx(() => AppTextField(
                label: 'profile_edit_email_label'.tr,
                hint: 'profile_edit_email_hint'.tr,
                controller: TextEditingController(text: _controller.email.value),
                enabled: false,
              )),

              const SizedBox(height: 20),

              // Phone number
              GestureDetector(
                onTap: () => Get.to(() => const PhoneNumberPage()),
                child: AbsorbPointer(
                  child: Obx(() => AppTextField(
                    label: 'profile_edit_phone_label'.tr,
                    hint: _authController.phoneVerified.value
                        ? _authController.phone.value
                        : 'profile_edit_phone_hint'.tr,
                    controller: TextEditingController(),
                    keyboardType: TextInputType.phone,
                    suffixIcon: _authController.phoneVerified.value
                        ? const Icon(Icons.check_circle, color: AppTheme.green)
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                  )),
                ),
              ),

              const SizedBox(height: 32),

              // Mostrar erro se houver
              Obx(() {
                if (_controller.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _controller.errorMessage.value,
                      style: AppTheme.textSm.copyWith(color: AppTheme.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Change password
              AppButton(
                text: 'profile_edit_change_password'.tr,
                isPrimary: false,
                onPressed: () {
                  Get.to(() => const ChangePasswordPage());
                },
              ),

              const SizedBox(height: 16),

              // Delete profile
              AppButton(
                text: 'profile_edit_delete_profile'.tr,
                isPrimary: false,
                color: AppTheme.red,
                onPressed: () {
                  DeleteAccountModal.show(context);
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos

  void _changeAvatar() {
    ChangeAvatarModal.show(
      context,
      currentAvatar: _getAvatarAsset(_currentAvatar),
      onAvatarSelected: (avatar) {
        setState(() {
          _currentAvatar = _getAvatarIdFromAsset(avatar);
        });
      },
    );
  }

  void _selectCountry() {
    CountrySelectorModal.show(
      context,
      currentCode: _currentCountry,
      onSelect: (code, flag) {
        setState(() {
          _currentCountry = code;
        });
      },
    );
  }

  void _saveProfile() {
    // Validar formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Preparar updates
    final updates = <String, dynamic>{};
    
    if (_nameController.text != _controller.userName.value) {
      updates['name'] = _nameController.text;
    }
    
    if (_usernameController.text != _controller.username.value) {
      updates['username'] = _usernameController.text;
    }
    
    if (_bioController.text != _controller.bio.value) {
      updates['bio'] = _bioController.text;
    }
    
    if (_currentAvatar != _controller.avatarId.value) {
      updates['avatarId'] = _currentAvatar;
    }
    
    if (_currentCountry != _controller.country.value) {
      updates['country'] = _currentCountry;
    }

    // Se não há mudanças, apenas voltar
    if (updates.isEmpty) {
      Get.back();
      return;
    }

    // Atualizar perfil
    _controller.updateProfile(updates).then((_) {
      if (_controller.errorMessage.value.isEmpty) {
        Get.back();
      }
    });
  }

  // Helpers

  String _getAvatarAsset(String avatarId) {
    switch (avatarId) {
      case 'avatar_01':
        return AppAssets.charMara;
      case 'avatar_02':
        return AppAssets.charDafny;
      case 'avatar_03':
        return AppAssets.charDiogo;
      case 'avatar_04':
        return AppAssets.charFrancilene;
      case 'avatar_05':
        return AppAssets.charGlauciane;
      case 'avatar_06':
        return AppAssets.charLindoedson;
      case 'avatar_07':
        return AppAssets.charRenner;
      default:
        return AppAssets.charMara;
    }
  }

  String _getAvatarIdFromAsset(String asset) {
    if (asset == AppAssets.charMara) return 'avatar_01';
    if (asset == AppAssets.charDafny) return 'avatar_02';
    if (asset == AppAssets.charDiogo) return 'avatar_03';
    if (asset == AppAssets.charFrancilene) return 'avatar_04';
    if (asset == AppAssets.charGlauciane) return 'avatar_05';
    if (asset == AppAssets.charLindoedson) return 'avatar_06';
    if (asset == AppAssets.charRenner) return 'avatar_07';
    return 'avatar_01';
  }

  String _getCountryName(String countryCode) {
    switch (countryCode) {
      case 'BR':
        return 'profile_edit_country_brazil'.tr;
      case 'US':
        return 'profile_edit_country_usa'.tr;
      case 'FR':
        return 'profile_edit_country_france'.tr;
      case 'ES':
        return 'profile_edit_country_spain'.tr;
      case 'DE':
        return 'profile_edit_country_germany'.tr;
      case 'CN':
        return 'profile_edit_country_china'.tr;
      case 'JP':
        return 'profile_edit_country_japan'.tr;
      case 'SA':
        return 'profile_edit_country_saudi'.tr;
      default:
        return 'profile_edit_country_brazil'.tr;
    }
  }
}
