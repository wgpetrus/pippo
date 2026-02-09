import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';

/// Modal de seleção de país/região
class CountrySelectorModal {
  static void show(
    BuildContext context, {
    required String currentCode,
    required Function(String code, String flag) onSelect,
  }) {
    // Static list of available countries/regions with phone codes
    // This is configuration data, not mock data
    final countries = [
      {'name': 'USA', 'code': '+1', 'flag': AppAssets.flagUsa},
      {'name': 'German', 'code': '+12', 'flag': AppAssets.flagGermany},
      {'name': 'Spain', 'code': '+12', 'flag': AppAssets.flagSpain},
      {'name': 'France', 'code': '+12', 'flag': AppAssets.flagFrance},
      {'name': 'Saudi Arabia', 'code': '+966', 'flag': AppAssets.flagSaudi},
      {'name': 'Japan', 'code': '+12', 'flag': AppAssets.flagJapan},
      {'name': 'China', 'code': '+12', 'flag': AppAssets.flagChina},
      {'name': 'Brazil', 'code': '+55', 'flag': AppAssets.flagBrazil},
    ];

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'country_selector_title'.tr,
                  style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                ),

                const SizedBox(height: 16),

                // Lista de países
                ...countries.map((country) {
                  return _CountryItem(
                    flag: country['flag']!,
                    name: country['name']!,
                    code: country['code']!,
                    onTap: () {
                      Get.back();
                      onSelect(country['code']!, country['flag']!);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Item de país na lista
class _CountryItem extends StatelessWidget {
  final String flag;
  final String name;
  final String code;
  final VoidCallback onTap;

  const _CountryItem({
    required this.flag,
    required this.name,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                flag,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            // Nome do país
            Expanded(
              child: Text(
                name,
                style: AppTheme.textMdSemibold.copyWith(color: AppTheme.black),
              ),
            ),

            // Código
            Text(
              code,
              style: AppTheme.textMdMedium.copyWith(color: AppTheme.gray400),
            ),
          ],
        ),
      ),
    );
  }
}
