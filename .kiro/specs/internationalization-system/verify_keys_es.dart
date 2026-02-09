import 'dart:io';

void main() {
  // Read pt_BR.dart
  final ptBRFile = File('../../../lib/shared/translations/pt_BR.dart');
  final ptBRContent = ptBRFile.readAsStringSync();
  
  // Read es_ES.dart
  final esESFile = File('../../../lib/shared/translations/es_ES.dart');
  final esESContent = esESFile.readAsStringSync();
  
  // Extract keys from pt_BR
  final ptBRKeys = extractKeys(ptBRContent);
  
  // Extract keys from es_ES
  final esESKeys = extractKeys(esESContent);
  
  print('pt_BR keys: ${ptBRKeys.length}');
  print('es_ES keys: ${esESKeys.length}');
  
  // Find missing keys in es_ES
  final missingInES = ptBRKeys.where((key) => !esESKeys.contains(key)).toList();
  
  // Find extra keys in es_ES
  final extraInES = esESKeys.where((key) => !ptBRKeys.contains(key)).toList();
  
  if (missingInES.isEmpty && extraInES.isEmpty) {
    print('\n✅ SUCCESS: All keys match perfectly!');
    print('Both files have ${ptBRKeys.length} keys.');
  } else {
    if (missingInES.isNotEmpty) {
      print('\n❌ Missing in es_ES (${missingInES.length} keys):');
      for (var key in missingInES) {
        print('  - $key');
      }
    }
    
    if (extraInES.isNotEmpty) {
      print('\n❌ Extra in es_ES (${extraInES.length} keys):');
      for (var key in extraInES) {
        print('  - $key');
      }
    }
    
    exit(1);
  }
}

Set<String> extractKeys(String content) {
  final keys = <String>{};
  final regex = RegExp(r"'([a-z_]+)':\s*'");
  final matches = regex.allMatches(content);
  
  for (var match in matches) {
    keys.add(match.group(1)!);
  }
  
  return keys;
}
