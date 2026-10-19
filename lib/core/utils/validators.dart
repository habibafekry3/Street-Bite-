import 'package:easy_localization/easy_localization.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'emailRequired'.tr();
    final emailRegex = RegExp(r'^[\w\-.]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'emailInvalid'.tr();
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'passwordRequired'.tr();
    if (value.length < 6) return 'passwordTooShort'.tr();
    return null;
  }

  static String? required(String? value, String errorKey) {
    if (value == null || value.trim().isEmpty) return errorKey.tr();
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'confirmPasswordRequired'.tr();
    if (value != original) return 'passwordsDoNotMatch'.tr();
    return null;
  }
}
