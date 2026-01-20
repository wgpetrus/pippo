class ValidationHelper {
  // Regex patterns
  static final _nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]{2,50}$');
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Validators
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório.';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres.';
    }

    if (!_nameRegex.hasMatch(trimmed)) {
      return 'Nome deve conter apenas letras e espaços.';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório.';
    }

    final trimmed = value.trim();

    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Por favor, insira um e-mail válido.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória.';
    }

    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres.';
    }

    return null;
  }

  // Sanitizers
  static String sanitizeName(String value) {
    return value.trim();
  }

  static String sanitizeEmail(String value) {
    return value.trim().toLowerCase();
  }
}
