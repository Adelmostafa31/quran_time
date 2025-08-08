import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quran_time/generated/l10n.dart';

abstract class Constant {
  static DateTime? startDate;
  static DateTime? endDate;

  static bool isArabic() {
    return Intl.getCurrentLocale() == 'ar';
  }

  static dynamic Function(String?) normalValidator({
    required BuildContext context,
    String? warning,
  }) => (String? value) {
    if (value == null || value.isEmpty || value.trim() == '') {
      return warning ?? S.of(context).thisFieldIsRequired;
    }
  };
}
