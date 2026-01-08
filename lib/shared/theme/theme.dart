import 'package:flutter/material.dart';

/// Tema do app
class AppTheme {
  static const String fontFamily = 'Nunito';

  // PRIMARY COLORS
  static const Color primary = Color(0xFF07B7FA);
  static const Color primaryDark = Color(0xFF0099D4);
  static const Color primaryLight = Color(0xFF4DD0FF);
  static const Color primary100 = Color(0xFFE3F7FE);
  static const Color primary500 = Color(0xFF97E3FF);
  static const Color white = Color(0xFFFFFFFF);

  // GRAY COLORS
  static const Color gray700 = Color(0xFFE6E6E6);
  static const Color gray600 = Color(0xFFD9D9D9);
  static const Color gray500 = Color(0xFFCCCCCC);
  static const Color gray400 = Color(0xFFAAAAAA);
  static const Color gray300 = Color(0xFF888888);
  static const Color gray200 = Color(0xFF666666);
  static const Color gray100 = Color(0xFF444444);
  static const Color black = Color(0xFF171717);

  // ACCENT COLORS
  static const Color orange = Color(0xFFFE8111);
  static const Color orange100 = Color(0xFFFFE9C7);
  static const Color gold = Color(0xFFFAA510);
  static const Color gold100 = Color(0xFFFFF2DB);
  static const Color green = Color(0xFF33C800);
  static const Color green100 = Color(0xFFE1FFD6);
  static const Color red = Color(0xFFFF0000);
  static const Color red100 = Color(0xFFFFCDCD);
  static const Color pink = Color(0xFFFF49C8);
  static const Color pink100 = Color(0xFFFFD0F1);
  static const Color blue = Color(0xFF004CBD);
  static const Color blue100 = Color(0xFFE2EEFF);
  static const Color brightCyanBlue = Color(0xFF00C3EC);
  static const Color brightCyanBlue100 = Color(0xFFBFF4FF);
  static const Color purple = Color(0xFF9200FF);
  static const Color purple100 = Color(0xFFF6EBFF);
  static const Color darkYellow = Color(0xFFCBA900);

  // DISPLAY LG
  static const TextStyle displayLgRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: -0.96,
  );
  static const TextStyle displayLgMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.96,
  );
  static const TextStyle displayLgSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -0.96,
  );
  static const TextStyle displayLgBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -0.96,
  );
  static const TextStyle displayLgExtrabold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  // DISPLAY MD
  static const TextStyle displayMdRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: -0.72,
  );
  static const TextStyle displayMdMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.72,
  );
  static const TextStyle displayMdSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -0.72,
  );
  static const TextStyle displayMdBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -0.72,
  );
  static const TextStyle displayMdExtrabold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  // DISPLAY SM
  static const TextStyle displaySmRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );
  static const TextStyle displaySmMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
  static const TextStyle displaySmSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
  static const TextStyle displaySmBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );
  static const TextStyle displaySmExtrabold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  // DISPLAY XS
  static const TextStyle displayXsRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );
  static const TextStyle displayXsMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
  static const TextStyle displayXsSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
  static const TextStyle displayXsBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );
  static const TextStyle displayXsExtrabold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  // TEXT XL
  static const TextStyle textXlRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );
  static const TextStyle textXlMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
  static const TextStyle textXlSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
  static const TextStyle textXlBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );
  static const TextStyle textXlExtrabold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  // TEXT LG
  static const TextStyle textLgRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );
  static const TextStyle textLgMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
  static const TextStyle textLgSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
  static const TextStyle textLgBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );
  static const TextStyle textLgExtrabold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  // TEXT MD
  static const TextStyle textMdRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );
  static const TextStyle textMdMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
  static const TextStyle textMdSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
  static const TextStyle textMdBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );
  static const TextStyle textMdExtrabold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  // TEXT SM
  static const TextStyle textSmRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );
  static const TextStyle textSmMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
  static const TextStyle textSmSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
  static const TextStyle textSmBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );
  static const TextStyle textSmExtrabold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  // TEXT XS
  static const TextStyle textXsRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );
  static const TextStyle textXsMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
  static const TextStyle textXsSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
  static const TextStyle textXsBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );
  static const TextStyle textXsExtrabold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );
}
