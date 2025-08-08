// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:quran_time/core/theming/styles.dart';

extension Navigation on BuildContext {
  Future<dynamic> pushNamed(
    String routeName, {
    Object? arguments,
    bool? routerNavigator,
  }) {
    return Navigator.of(
      this,
      rootNavigator: routerNavigator ?? false,
    ).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntill(
    String routeName, {
    Object? arguments,
    bool? routerNavigator,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (route) => routerNavigator ?? false,
      arguments: arguments,
    );
  }

  void pop() => Navigator.of(this).pop();
  void popAlert() => Navigator.of(this, rootNavigator: true).pop();
}

// Sized box
extension IntExtension on int? {
  int validate({int value = 0}) {
    return this ?? value;
  }

  Widget get height => SizedBox(height: this?.toDouble().h);
  Widget get width => SizedBox(width: this?.toDouble().w);
}

ToastFuture toast({
  required BuildContext context,
  Color backgroundColor = Colors.red,
  String message = 'Please Fill All Fields',
}) => showToast(
  message,
  context: context,
  animation: StyledToastAnimation.slideFromBottom,
  reverseAnimation: StyledToastAnimation.sizeFade,
  position: StyledToastPosition.center,
  animDuration: const Duration(milliseconds: 1200),
  duration: const Duration(milliseconds: 2400),
  backgroundColor: backgroundColor,
  borderRadius: BorderRadius.circular(15.r),
  textStyle: TextStyles.font16WhiteBold,
  curve: Curves.fastLinearToSlowEaseIn,
  reverseCurve: Curves.fastLinearToSlowEaseIn,
);
