// Verification script for AppTranslations class
import 'dart:io';

void main() {
  print('🔍 Verifying AppTranslations class...\n');

  final content = File('lib/shared/translations/app_translations.dart').readAsStringSync();

  // Check imports
  final hasGetImport = content.contains("import 'package:get/get.dart';");
  final hasPtBRImport = content.contains("import 'pt_BR.dart';");
  final hasEnUSImport = content.contains("import 'en_US.dart';");
  final hasEsESImport = content.contains("import 'es_ES.dart';");

  print('📦 Imports:');
  print('   ${hasGetImport ? "✅" : "❌"} GetX import');
  print('   ${hasPtBRImport ? "✅" : "❌"} pt_BR import');
  print('   ${hasEnUSImport ? "✅" : "❌"} en_US import');
  print('   ${hasEsESImport ? "✅" : "❌"} es_ES import\n');

  if (!hasGetImport || !hasPtBRImport || !hasEnUSImport || !hasEsESImport) {
    print('❌ Missing required imports!\n');
    exit(1);
  }

  // Check class structure
  final extendsTranslations = content.contains('extends Translations');
  final hasKeysGetter = content.contains('@override') && content.contains('Map<String, Map<String, String>> get keys');
  final hasPtBRKey = content.contains("'pt_BR': PtBR.translations");
  final hasEnUSKey = content.contains("'en_US': EnUS.translations");
  final hasEsESKey = content.contains("'es_ES': EsES.translations");

  print('🏗️  Class structure:');
  print('   ${extendsTranslations ? "✅" : "❌"} Extends Translations');
  print('   ${hasKeysGetter ? "✅" : "❌"} Has keys getter');
  print('   ${hasPtBRKey ? "✅" : "❌"} pt_BR locale mapping');
  print('   ${hasEnUSKey ? "✅" : "❌"} en_US locale mapping');
  print('   ${hasEsESKey ? "✅" : "❌"} es_ES locale mapping\n');

  if (!extendsTranslations || !hasKeysGetter || !hasPtBRKey || !hasEnUSKey || !hasEsESKey) {
    print('❌ Class structure is incorrect!\n');
    exit(1);
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ AppTranslations class is correctly structured!');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
