// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_time/core/theming/colors.dart';
import 'package:quran_time/core/theming/styles.dart';

ThemeData theme() => ThemeData(
  primaryColor: ColorsManager.mainColor,
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.white;
      }
      return ColorsManager.grey.withOpacity(0.3);
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.mainColor;
      }
      return ColorsManager.grey.withOpacity(0.3);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.mainColor;
      }
      return ColorsManager.grey.withOpacity(0.3);
    }),
    trackOutlineWidth: WidgetStateProperty.all<double>(2),
    thumbIcon: WidgetStateProperty.all<Icon>(
      const Icon(Icons.circle, size: 30, color: ColorsManager.white),
    ),
  ),
  fontFamily: 'poppins',
  scaffoldBackgroundColor: ColorsManager.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorsManager.white,
    surfaceTintColor: ColorsManager.white,
  ),
  timePickerTheme: TimePickerThemeData(
    dayPeriodColor: ColorsManager.white,
    dayPeriodBorderSide: const BorderSide(color: ColorsManager.mainColor),
    dayPeriodTextStyle: TextStyles.font14WhiteBold,
    backgroundColor: ColorsManager.mainColor,
    hourMinuteColor: ColorsManager.white,
    hourMinuteTextColor: ColorsManager.mainColor,
    cancelButtonStyle: ButtonStyle(
      alignment: Alignment.center,
      textStyle: WidgetStateProperty.all<TextStyle>(TextStyles.font14RedBold),
      fixedSize: WidgetStateProperty.all<Size>(Size(80.w, 10.h)),
      foregroundColor: WidgetStateProperty.all<Color>(ColorsManager.red),
    ),
    confirmButtonStyle: ButtonStyle(
      alignment: Alignment.center,
      textStyle: WidgetStateProperty.all<TextStyle>(TextStyles.font14WhiteBold),
      fixedSize: WidgetStateProperty.all<Size>(Size(80.w, 20.h)),
      foregroundColor: WidgetStateProperty.all<Color>(ColorsManager.white),
    ),
    timeSelectorSeparatorColor: WidgetStateProperty.all<Color>(
      ColorsManager.white,
    ),
    entryModeIconColor: ColorsManager.white,
    dayPeriodTextColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.mainColor;
      } else {
        return ColorsManager.white;
      }
    }),
    dialBackgroundColor: ColorsManager.mainColor,
    dialHandColor: ColorsManager.white,
    dialTextStyle: TextStyles.font14WhiteBold,
    helpTextStyle: TextStyles.font14WhiteBold,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: ColorsManager.white,
      counterStyle: TextStyle(color: ColorsManager.white),
      outlineBorder: BorderSide(color: ColorsManager.yellow, width: 2),
    ),
  ),
  datePickerTheme: DatePickerThemeData(
    cancelButtonStyle: ButtonStyle(
      alignment: Alignment.center,
      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyles.font14MainColorBold,
      ),
      fixedSize: WidgetStateProperty.all<Size>(Size(90.w, 10.h)),
      foregroundColor: WidgetStateProperty.all<Color>(ColorsManager.red),
    ),
    confirmButtonStyle: ButtonStyle(
      alignment: Alignment.center,
      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyles.font14MainColorBold,
      ),
      fixedSize: WidgetStateProperty.all<Size>(Size(90.w, 20.h)),
      foregroundColor: WidgetStateProperty.all<Color>(ColorsManager.mainColor),
    ),
    dayStyle: TextStyles.font12WhiteBold,
    headerBackgroundColor: ColorsManager.mainColor,
    headerForegroundColor: ColorsManager.white,
    headerHeadlineStyle: TextStyles.font20WhiteBold,
    headerHelpStyle: TextStyles.font16White,
    shadowColor: ColorsManager.mainColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    dividerColor: ColorsManager.grey,
    elevation: 10,
    weekdayStyle: TextStyles.font12MainColorBold,
    surfaceTintColor: ColorsManager.white,
    yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.mainColor; // Change to your preferred color
      }
      return null;
    }),
    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.white; // Change to your preferred color
      }
      return ColorsManager.mainColor;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.mainColor; // Change to your preferred color
      }
      return null;
    }),
    todayBorder: const BorderSide(color: ColorsManager.mainColor, width: 2),
    todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.mainColor; // Change to your preferred color
      }
      return null;
    }),
    todayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.white; // Change to your preferred color
      }
      return ColorsManager.mainColor;
    }),
    backgroundColor: ColorsManager.white,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: ColorsManager.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  applyElevationOverlayColor: false,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);
