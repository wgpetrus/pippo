import 'package:get/get.dart';

class ValidationHelper {
  // Regex patterns
  static final _nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]{2,50}$');
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Validators
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'error_name_required'.tr;
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'error_name_min_length'.tr;
    }

    if (!_nameRegex.hasMatch(trimmed)) {
      return 'error_name_invalid'.tr;
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'error_email_required'.tr;
    }

    final trimmed = value.trim();

    if (!_emailRegex.hasMatch(trimmed)) {
      return 'error_email_invalid'.tr;
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'error_password_required'.tr;
    }

    if (value.length < 6) {
      return 'error_password_min_length'.tr;
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
