import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';

/// Item de curso com bandeira e botão de deletar
class CourseItem extends StatelessWidget {
  final String flagAsset;
  final String name;
  final VoidCallback? onDelete;

  const CourseItem({
    super.key,
    required this.flagAsset,
    required this.name,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray600, width: 1),
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

          // Nome do idioma
          Expanded(
            child: Text(
              name,
              style: AppTheme.textMdSemibold.copyWith(color: AppTheme.black),
            ),
          ),

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
