import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Helper para máscaras de telefone por país
class PhoneMaskHelper {
  /// Retorna a máscara de telefone para o código do país
  static MaskTextInputFormatter getMaskForCountry(String countryCode) {
    switch (countryCode) {
      case '+1': // EUA/Canadá
        return MaskTextInputFormatter(
          mask: '(###) ###-####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );

      case '+55': // Brasil
        return MaskTextInputFormatter(
          mask: '(##) #####-####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );

      case '+34': // Espanha
        return MaskTextInputFormatter(
          mask: '### ### ###',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );

      case '+33': // França
        return MaskTextInputFormatter(
          mask: '# ## ## ## ##',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );

      case '+49': // Alemanha
        return MaskTextInputFormatter(
          mask: '#### #######',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );

      case '+86': // China
        return MaskTextInputFormatter(
          mask: '### #### ####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );

      case '+81': // Japão
        return MaskTextInputFormatter(
          mask: '##-####-####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );

      case '+966': // Arábia Saudita
        return MaskTextInputFormatter(
          mask: '## ### ####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );

      default: // Formato genérico
        return MaskTextInputFormatter(
          mask: '### ### ### ###',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );
    }
  }

  /// Retorna o número mínimo de dígitos para o país
  static int getMinDigitsForCountry(String countryCode) {
    switch (countryCode) {
      case '+1': // EUA/Canadá
        return 10;
      case '+55': // Brasil
        return 11;
      case '+34': // Espanha
        return 9;
      case '+33': // França
        return 9;
      case '+49': // Alemanha
        return 10;
      case '+86': // China
        return 11;
      case '+81': // Japão
        return 10;
      case '+966': // Arábia Saudita
        return 9;
      default:
        return 10; // Padrão
    }
  }

  /// Retorna o placeholder para o país
  static String getPlaceholderForCountry(String countryCode) {
    switch (countryCode) {
      case '+1':
        return '(555) 123-4567';
      case '+55':
        return '(11) 98765-4321';
      case '+34':
        return '612 345 678';
      case '+33':
        return '6 12 34 56 78';
      case '+49':
        return '1234 5678901';
      case '+86':
        return '138 0013 8000';
      case '+81':
        return '90-1234-5678';
      case '+966':
        return '50 123 4567';
      default:
        return '123 456 7890';
    }
  }
}
