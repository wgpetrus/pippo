import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';

/// Item do ranking
class RankItem extends StatelessWidget {
  final int rank;
  final String avatarAsset;
  final String name;
  final int xp;
  final bool isCurrentUser;
  final String? statusEmoji;
  final VoidCallback? onTap;

  const RankItem({
    super.key,
    required this.rank,
    required this.avatarAsset,
    required this.name,
    required this.xp,
    this.isCurrentUser = false,
    this.statusEmoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? AppTheme.orange : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentUser
              ? null
              : Border.all(color: AppTheme.gray700, width: 1),
        ),
        child: Row(
          children: [
            // Posição ou medalha
            SizedBox(
              width: 36,
              child: rank == 1
                  ? Image.asset(AppAssets.top1Medal, width: 32, height: 32)
                  : Text(
                      rank.toString().padLeft(2, '0'),
                      style: AppTheme.textMdBold.copyWith(
                        color: isCurrentUser ? AppTheme.white : AppTheme.gray300,
                      ),
                    ),
            ),
            const SizedBox(width: 8),

            // Avatar com status
            Stack(
              clipBehavior: Clip.none,
              children: [
                Builder(
                  builder: (context) {
                    final avatarSize = ResponsiveUtils.width(44, min: 36, max: 52);
                    return Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.pink100,
                        border: Border.all(
                          color: isCurrentUser ? AppTheme.white : AppTheme.gray600,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(avatarAsset, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),

                // Status emoji
                if (statusEmoji != null)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(statusEmoji!, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Nome
            Expanded(
              child: Text(
                isCurrentUser ? 'Me' : name,
                style: AppTheme.textMdBold.copyWith(
                  color: isCurrentUser ? AppTheme.white : AppTheme.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // XP
            Text(
              '$xp XP',
              style: AppTheme.textMdBold.copyWith(
                color: isCurrentUser ? AppTheme.white : AppTheme.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
