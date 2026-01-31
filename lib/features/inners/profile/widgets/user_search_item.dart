import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../views/user_profile_page.dart';

/// Item de resultado de busca de usuário
class UserSearchItem extends StatelessWidget {
  final String userId;
  final String name;
  final String username;
  final String avatarId;
  final String? country;

  const UserSearchItem({
    super.key,
    required this.userId,
    required this.name,
    required this.username,
    required this.avatarId,
    this.country,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return InkWell(
      onTap: () => Get.to(() => UserProfilePage(userId: userId)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.spacing16,
          vertical: r.spacing12,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(_getAvatarAsset(avatarId)),
            ),
            SizedBox(width: r.spacing12),

            // Nome e username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.textMdBold.copyWith(
                      color: AppTheme.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: r.spacing4),
                  Text(
                    '@$username',
                    style: AppTheme.textSm.copyWith(
                      color: AppTheme.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Bandeira do país (se disponível)
            if (country != null) ...[
              SizedBox(width: r.spacing8),
              Image.asset(
                _getCountryFlag(country!),
                width: 24,
                height: 24,
              ),
            ],
          ],
        ),
      ),
    );
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

  String _getCountryFlag(String countryCode) {
    switch (countryCode) {
      case 'BR':
        return AppAssets.flagBrazil;
      case 'US':
        return AppAssets.flagUsa;
      case 'FR':
        return AppAssets.flagFrance;
      case 'ES':
        return AppAssets.flagSpain;
      case 'DE':
        return AppAssets.flagGermany;
      case 'CN':
        return AppAssets.flagChina;
      case 'JP':
        return AppAssets.flagJapan;
      case 'SA':
        return AppAssets.flagSaudit;
      default:
        return AppAssets.flagBrazil;
    }
  }
}
