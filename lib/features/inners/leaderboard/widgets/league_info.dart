import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';

/// Informações da liga atual
class LeagueInfo extends StatelessWidget {
  final String leagueName;
  final int daysLeft;
  final String description;

  const LeagueInfo({
    super.key,
    required this.leagueName,
    required this.daysLeft,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome da liga e dias restantes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leagueName,
                style: AppTheme.textXlBold.copyWith(color: AppTheme.orange),
              ),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.clock,
                    size: 14,
                    color: AppTheme.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$daysLeft Days left',
                    style: AppTheme.textSmSemibold.copyWith(
                      color: AppTheme.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Descrição
          Text(
            description,
            style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray300),
          ),
        ],
      ),
    );
  }
}
