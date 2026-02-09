import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../views/search_users_page.dart';

/// Card para navegar para busca de usuários
class FindFriendsCard extends StatelessWidget {
  const FindFriendsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return GestureDetector(
      onTap: () => Get.to(() => const SearchUsersPage()),
      child: Container(
        key: const Key('find_friends_card'),
        margin: EdgeInsets.symmetric(horizontal: r.spacing16),
        padding: EdgeInsets.all(r.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.gray600,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: AppTheme.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: r.spacing12),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'find_friends_title'.tr,
                    style: AppTheme.textMdBold.copyWith(
                      color: AppTheme.black,
                    ),
                  ),
                  SizedBox(height: r.spacing4),
                  Text(
                    'find_friends_subtitle'.tr,
                    style: AppTheme.textSm.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            FaIcon(
              FontAwesomeIcons.chevronRight,
              color: AppTheme.gray400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
