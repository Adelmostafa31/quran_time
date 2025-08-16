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
    // Enhanced day period styling
    dayPeriodColor: ColorsManager.white.withOpacity(0.95),
    dayPeriodBorderSide: const BorderSide(
      color: ColorsManager.mainColor,
      width: 2.0,
    ),
    dayPeriodTextStyle: TextStyles.font14WhiteBold.copyWith(
      letterSpacing: 0.5,
      fontWeight: FontWeight.w600,
    ),

    // Background
    backgroundColor: ColorsManager.mainColor,

    // Hour/minute display
    hourMinuteColor: ColorsManager.white.withOpacity(0.9),
    hourMinuteTextColor: ColorsManager.mainColor,
    hourMinuteTextStyle: TextStyles.font14WhiteBold.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0,
    ),

    // Enhanced buttons
    cancelButtonStyle: ButtonStyle(
      alignment: Alignment.center,
      textStyle: WidgetStateProperty.all<TextStyle>(TextStyles.font14RedBold),
      fixedSize: WidgetStateProperty.all<Size>(Size(90.w, 12.h)),
      foregroundColor: WidgetStateProperty.all<Color>(ColorsManager.red),
      backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: ColorsManager.red.withOpacity(0.5),
            width: 1.0,
          ),
        ),
      ),
    ),

    confirmButtonStyle: ButtonStyle(
      alignment: Alignment.center,
      textStyle: WidgetStateProperty.all<TextStyle>(TextStyles.font14WhiteBold),
      fixedSize: WidgetStateProperty.all<Size>(Size(90.w, 22.h)),
      foregroundColor: WidgetStateProperty.all<Color>(ColorsManager.white),
      backgroundColor: WidgetStateProperty.all<Color>(ColorsManager.mainColor),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      elevation: WidgetStateProperty.all<double>(2.0),
    ),

    // Time separator
    timeSelectorSeparatorColor: WidgetStateProperty.all<Color>(
      ColorsManager.white.withOpacity(0.8),
    ),

    // Entry mode icon
    entryModeIconColor: ColorsManager.white.withOpacity(0.9),

    // Day period text color
    dayPeriodTextColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.mainColor;
      } else {
        return ColorsManager.white.withOpacity(0.9);
      }
    }),
    dialBackgroundColor: ColorsManager.mainColor,
    dialHandColor: ColorsManager.white,
    dialTextColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.mainColor;
      } else {
        return ColorsManager.white;
      }
    }),

    // Enhanced text styling with different weights for selected vs unselected
    dialTextStyle: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        // Selected hour - bold and larger
        return TextStyles.font14WhiteBold.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: ColorsManager.mainColor,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        );
      } else {
        // Unselected hours - smaller and dimmed
        return TextStyles.font14WhiteBold.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ColorsManager.white.withOpacity(0.6),
          shadows: [
            Shadow(
              color: ColorsManager.mainColor.withOpacity(0.3),
              offset: const Offset(0.5, 0.5),
              blurRadius: 1,
            ),
          ],
        );
      }
    }),

    // Help text
    helpTextStyle: TextStyles.font14WhiteBold.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
    ),

    // Enhanced input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorsManager.white.withOpacity(0.95),
      counterStyle: TextStyle(
        color: ColorsManager.white.withOpacity(0.8),
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: ColorsManager.yellow, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: ColorsManager.yellow.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: ColorsManager.yellow, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
    ),

    // Additional styling
    hourMinuteShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: const EdgeInsets.all(20.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
