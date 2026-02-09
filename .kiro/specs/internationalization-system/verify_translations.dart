// Verification script for translation files
import 'dart:io';

void main() {
  print('🔍 Verifying translation files...\n');

  // Read all translation files
  final ptBRContent = File('lib/shared/translations/pt_BR.dart').readAsStringSync();
  final enUSContent = File('lib/shared/translations/en_US.dart').readAsStringSync();
  final esESContent = File('lib/shared/translations/es_ES.dart').readAsStringSync();

  // Extract keys from each file
  final ptBRKeys = extractKeys(ptBRContent);
  final enUSKeys = extractKeys(enUSContent);
  final esESKeys = extractKeys(esESContent);

  print('📊 Key counts:');
  print('   pt_BR: ${ptBRKeys.length} keys');
  print('   en_US: ${enUSKeys.length} keys');
  print('   es_ES: ${esESKeys.length} keys\n');

  // Check if all files have the same number of keys
  if (ptBRKeys.length == enUSKeys.length && enUSKeys.length == esESKeys.length) {
    print('✅ All files have the same number of keys\n');
  } else {
    print('❌ Files have different number of keys!\n');
    exit(1);
  }

  // Check if all keys are identical
  final ptBRSet = ptBRKeys.toSet();
  final enUSSet = enUSKeys.toSet();
  final esESSet = esESKeys.toSet();

  final missingInEnUS = ptBRSet.difference(enUSSet);
  final missingInEsES = ptBRSet.difference(esESSet);
  final extraInEnUS = enUSSet.difference(ptBRSet);
  final extraInEsES = esESSet.difference(ptBRSet);

  if (missingInEnUS.isEmpty && missingInEsES.isEmpty && 
      extraInEnUS.isEmpty && extraInEsES.isEmpty) {
    print('✅ All files have identical key sets\n');
  } else {
    print('❌ Key sets are not identical!\n');
    if (missingInEnUS.isNotEmpty) {
      print('Missing in en_US: ${missingInEnUS.join(", ")}');
    }
    if (missingInEsES.isNotEmpty) {
      print('Missing in es_ES: ${missingInEsES.join(", ")}');
    }
    if (extraInEnUS.isNotEmpty) {
      print('Extra in en_US: ${extraInEnUS.join(", ")}');
    }
    if (extraInEsES.isNotEmpty) {
      print('Extra in es_ES: ${extraInEsES.join(", ")}');
    }
    exit(1);
  }

  // Check key format (snake_case with prefix)
  final invalidKeys = <String>[];
  final keyPattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');
  
  for (final key in ptBRKeys) {
    if (!keyPattern.hasMatch(key)) {
      invalidKeys.add(key);
    }
  }

  if (invalidKeys.isEmpty) {
    print('✅ All keys follow the naming convention (snake_case)\n');
  } else {
    print('❌ Some keys do not follow the naming convention:\n');
    for (final key in invalidKeys) {
      print('   - $key');
    }
    exit(1);
  }

  // Check for empty values
  final emptyValues = checkEmptyValues(ptBRContent, 'pt_BR') +
                      checkEmptyValues(enUSContent, 'en_US') +
                      checkEmptyValues(esESContent, 'es_ES');

  if (emptyValues.isEmpty) {
    print('✅ No empty translation values found\n');
  } else {
    print('❌ Found empty translation values:\n');
    for (final msg in emptyValues) {
      print('   $msg');
    }
    exit(1);
  }

  // Summary
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ All verification checks passed!');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('\n📈 Summary:');
  print('   Total keys: ${ptBRKeys.length}');
  print('   Languages: 3 (pt_BR, en_US, es_ES)');
  print('   Total translations: ${ptBRKeys.length * 3}');
}

List<String> extractKeys(String content) {
  final keys = <String>[];
  final keyPattern = RegExp(r"'([a-z_]+)':\s*'");
  final matches = keyPattern.allMatches(content);
  
  for (final match in matches) {
    keys.add(match.group(1)!);
  }
  
  return keys;
}

List<String> checkEmptyValues(String content, String fileName) {
  final emptyValues = <String>[];
  final lines = content.split('\n');
  
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.contains("''") && line.contains(':')) {
      final keyMatch = RegExp(r"'([a-z_]+)':\s*''").firstMatch(line);
      if (keyMatch != null) {
        emptyValues.add('$fileName: ${keyMatch.group(1)} (line ${i + 1})');
      }
    }
  }
  
  return emptyValues;
}
