import 'package:get/get.dart';
import 'pt_BR.dart';
import 'en_US.dart';
import 'es_ES.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'pt_BR': PtBR.translations,
        'en_US': EnUS.translations,
        'es_ES': EsES.translations,
      };
}
