// ignore_for_file: camel_case_types, depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_time/core/helper/constant.dart';
import 'package:quran_time/core/theming/colors.dart';
import 'package:quran_time/core/theming/styles.dart';

class CustomFormField extends StatefulWidget {
  const CustomFormField({
    super.key,
    required this.hint,
    this.label,
    this.inputTextStyle,
    this.hintStyle,
    this.isObsecured,
    this.suffixIcon,
    this.fillColor,
    this.controller,
    this.enabled,
    this.prefixIcon,
    this.maxLines,
    required this.validator,
    this.borderColor,
    this.keyboardType,
    this.maxLength,
    this.isHint,
    this.contentPaddingHoriz,
    this.contentPaddingVert,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged, // Add this callback for debounced changes
    this.debounceDuration = const Duration(
      milliseconds: 500,
    ), // Default debounce duration
  });

  final String hint;
  final String? label;
  final bool? isHint;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final double? contentPaddingHoriz;
  final double? contentPaddingVert;
  final bool? isObsecured;
  final bool? enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? fillColor;
  final Color? borderColor;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final Function(String?) validator;
  final Function(String)? onChanged; // Callback for debounced changes
  final Duration debounceDuration; // Duration for debounce
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _onChanged(String value) {
    if (widget.onChanged == null) return;

    // Cancel the previous timer if it's active
    _debounceTimer?.cancel();

    // Start a new timer
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged!(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: widget.maxLength,
      controller: widget.controller,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      canRequestFocus: true,
      inputFormatters: [
        // Corrected Unicode range syntax:
        FilteringTextInputFormatter.deny(
          RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true),
        ),
        if (widget.keyboardType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly,
      ],
      // textCapitalization: TextCapitalization.words,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: const [
        AutofillHints.name,
        AutofillHints.username,
        AutofillHints.email,
        AutofillHints.password,
        AutofillHints.newPassword,
        AutofillHints.oneTimeCode,
        AutofillHints.telephoneNumber,
        AutofillHints.postalAddress,
        AutofillHints.addressCityAndState,
        AutofillHints.addressState,
        AutofillHints.countryName,
        AutofillHints.addressCity,
      ],
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      maxLines: widget.maxLines ?? 1,
      enabled: widget.enabled ?? true,
      onChanged: _onChanged, // Use the debounced onChanged
      decoration: InputDecoration(
        counterText: '',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.contentPaddingHoriz ?? 10.w,
          vertical: widget.contentPaddingVert ?? 13.h,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: ColorsManager.mainColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(18.r),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorsManager.grey.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.borderColor ?? ColorsManager.grey.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(18.r),
        ),
        errorStyle: TextStyles.font12RedBold,
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(18.r),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(18.r),
        ),
        labelText: widget.label,
        labelStyle: widget.hintStyle ?? TextStyles.font14Grey,
        hintText: widget.hint,
        hintStyle: widget.hintStyle ?? TextStyles.font12Grey,
        suffixIcon: widget.suffixIcon,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: Constant.isArabic() ? 0 : 10.w,
            right: Constant.isArabic() ? 10.w : 0,
          ),
          child: widget.prefixIcon,
        ),
        filled: true,
        fillColor: widget.fillColor ?? ColorsManager.grey.withOpacity(0.1),
      ),
      cursorColor: ColorsManager.yellow,
      obscureText: widget.isObsecured ?? false,
      style: widget.inputTextStyle ?? TextStyles.font14BlackBold,
      validator: (value) {
        return widget.validator(value);
      },
    );
  }
}
