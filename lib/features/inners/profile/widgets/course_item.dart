import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';

/// Item de curso com bandeira e botões de ação
class CourseItem extends StatelessWidget {
  final String flagAsset;
  final String name;
  final bool isPrimary;
  final VoidCallback? onSetPrimary;
  final VoidCallback? onDelete;

  const CourseItem({
    super.key,
    required this.flagAsset,
    required this.name,
    this.isPrimary = false,
    this.onSetPrimary,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? AppTheme.primary : AppTheme.gray600,
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Bandeira
          ClipOval(
            child: Image.asset(
              flagAsset,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // Nome do idioma e badge de principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.textMdSemibold.copyWith(color: AppTheme.black),
                ),
                if (isPrimary) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'course_item_primary_badge'.tr,
                      style: AppTheme.textXsRegular.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Botão definir como principal (se não for principal)
          if (!isPrimary && onSetPrimary != null) ...[
            GestureDetector(
              onTap: onSetPrimary,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary, width: 1),
                ),
                child: Text(
                  'course_item_set_primary'.tr,
                  style: AppTheme.textXsRegular.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Botão deletar
          GestureDetector(
            onTap: onDelete,
            child: const FaIcon(
              FontAwesomeIcons.solidTrashCan,
              size: 20,
              color: AppTheme.red,
            ),
          ),
        ],
      ),
    );
  }
}
