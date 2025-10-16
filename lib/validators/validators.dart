import 'package:flutter/material.dart';

import '../utils.dart';

class Validators {
  static String? validateRequiredField({
    required String? value,
    required String labelText,
    required BuildContext context,
  }) {
    if (value == null || value.isEmpty) {
      return labelText;
    }
    return null;
  }

  static String? validateEmail({
    required String? value,
    required String labelText,
    required BuildContext context,
  }) {
    if (value == null || value.isEmpty) {
      return labelText;
    }
    if (!Regxs.validateEmail(value)) {
      return labelText;
    }
    return null;
  }

  static String? validatePassword({
    required String? value,
    required String labelText,
    required BuildContext context,
  }) {
    if (value == null || value.isEmpty) {
      return labelText;
    }
    if (!Regxs.validatePassword(value)) {
      return ' 1 special , 1 digit, 1 uppercase, 1 lowercase and mini-length 8';
    }
    return null;
  }
}
