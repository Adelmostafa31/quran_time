// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_time/core/theming/colors.dart';

class TextStyles {
  // Main Color
  static TextStyle font14MainColorBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.mainColor,
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font12MainColorBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.mainColor,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font12YellowBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.yellow,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font12MainColor = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.mainColor,
    fontSize: 12.sp,
  );
  static TextStyle font16MainColorBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.mainColor,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font16MainColorBoldUnderLine = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.mainColor,
    fontSize: 16.sp,
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.solid,
    decorationColor: ColorsManager.mainColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font18MainColorBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.mainColor,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font23MainColorBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.mainColor,
    fontSize: 23.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font20MainColorBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.mainColor,
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font28MainColorBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.mainColor,
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
  );

  // White
  static TextStyle font40WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 40.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font30WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 30.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font25WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 25.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font18White = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 18.sp,
  );
  static TextStyle font16White = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 16.sp,
  );
  static TextStyle font16WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font18WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font20WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font23WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 23.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font14White = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 14.sp,
  );
  static TextStyle font12White = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 12.sp,
  );
  static TextStyle font12WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font10WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 10.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font14WhiteBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.white,
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
  );

  // Grey
  static TextStyle font16Grey = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.grey,
    fontSize: 16.sp,
  );
  static TextStyle font16GreyUnderLine = TextStyle(
    fontFamily: 'Cairo',
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.solid,
    decorationColor: ColorsManager.grey,
    fontWeight: FontWeight.bold,
    color: ColorsManager.grey,
    fontSize: 16.sp,
  );
  static TextStyle font12Grey = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.grey,
    fontSize: 12.sp,
  );
  static TextStyle font14Grey = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.grey,
    fontSize: 14.sp,
  );
  static TextStyle font14GreyBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.grey,
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font12GreyBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.grey,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font18Grey = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.grey,
    fontSize: 18.sp,
  );

  // Red
  static TextStyle font12Red = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.red,
    fontSize: 12.sp,
  );
  static TextStyle font14Red = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.red,
    fontSize: 14.sp,
  );
  static TextStyle font12RedBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.red,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font18RedBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.red,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font21RedBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.red,
    fontSize: 21.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font14RedBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.red,
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font16RedBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.red,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font16Red = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.red,
    fontSize: 16.sp,
  );
  static TextStyle font14RedBoldUnderLine = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.red,
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.solid,
    decorationThickness: 2,
    decorationColor: ColorsManager.red,
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
  );

  // Black
  static TextStyle font16BlackBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font21BlackBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 21.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font18BlackBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font16Black = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 16.sp,
  );
  static TextStyle font14Black = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 14.sp,
  );
  static TextStyle font14BlackBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font15BlackBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 15.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font12Black = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 12.sp,
  );
  static TextStyle font12BlackBold = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font10Black = TextStyle(
    fontFamily: 'Cairo',
    color: ColorsManager.black,
    fontSize: 10.sp,
  );
}
