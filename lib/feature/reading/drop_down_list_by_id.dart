import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_time/core/theming/colors.dart';
import 'package:quran_time/core/theming/styles.dart';

// Add this line - you'll need to import your quran instance
// import 'your_quran_import_path.dart'; // Replace with actual path

class DropDownListByIdAR extends StatelessWidget {
  final String text;
  final int? selectedValue;
  final TextEditingController? textEditingController;
  final String hint;
  final Function(int?)? onChanged;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final Color? iconColor;
  final double? radiusBottomLeft;
  final double? radiusBottomRight;
  final double? radiusTopLeft;
  final double? radiusTopRight;
  final IconStyleData? customIconStyleData;

  const DropDownListByIdAR({
    super.key,
    required this.text,
    this.selectedValue,
    required this.textEditingController,
    required this.hint,
    this.onChanged,
    this.textStyle,
    this.hintTextStyle,
    this.iconColor,
    this.radiusBottomLeft,
    this.radiusBottomRight,
    this.radiusTopLeft,
    this.radiusTopRight,
    this.customIconStyleData,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyleData buttonStyleData = ButtonStyleData(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(radiusBottomLeft ?? 20),
          bottomRight: Radius.circular(radiusBottomRight ?? 20),
          topLeft: Radius.circular(radiusTopLeft ?? 20),
          topRight: Radius.circular(radiusTopRight ?? 20),
        ),
      ),
      height: 45.h,
      width: double.infinity,
    );

    final DropdownStyleData dropdownStyleData = DropdownStyleData(
      useSafeArea: true,
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      maxHeight: 450,
    );

    const MenuItemStyleData menuItemStyleData = MenuItemStyleData(height: 50);

    final IconStyleData iconStyleData = IconStyleData(
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: iconColor ?? ColorsManager.mainColor,
      ),
    );

    return DropdownButtonHideUnderline(
      child: DropdownButton2<int>(
        isExpanded: true,
        hint: Text(text, style: TextStyles.font14GreyBold),
        items: List.generate(114, (index) {
          final surahNumber = index + 1;
          return DropdownMenuItem<int>(
            value: surahNumber,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${quran.getSurahNameArabic(surahNumber)} ',
                  style: TextStyles.font14MainColorBold,
                ),
                Text(
                  '${quran.getSurahNameEnglish(surahNumber)} ',
                  style: TextStyles.font14MainColorBold,
                ),
              ],
            ),
          );
        }),
        value: selectedValue,
        onChanged: onChanged,
        iconStyleData: customIconStyleData ?? iconStyleData,
        buttonStyleData: buttonStyleData,
        dropdownStyleData: dropdownStyleData,
        menuItemStyleData: menuItemStyleData,
        dropdownSearchData: DropdownSearchData(
          searchController: textEditingController,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Container(
            height: 50.h,
            padding: EdgeInsets.only(
              top: 8.h,
              bottom: 4.h,
              right: 8.w,
              left: 8.w,
            ),
            child: TextFormField(
              controller: textEditingController,
              style: TextStyles.font14BlackBold,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: ColorsManager.mainColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 15.h,
                ),
                hintText: hint,
                hintStyle: hintTextStyle ?? textStyle,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: ColorsManager.softGrey),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            if (item.value == null) return false;

            final surahNumber = item.value as int;

            // Search in both Arabic and English names
            final arabicName = quran
                .getSurahNameArabic(surahNumber)
                .toLowerCase();
            final englishName = quran
                .getSurahNameEnglish(surahNumber)
                .toLowerCase();
            final searchLower = searchValue.toLowerCase();

            return arabicName.contains(searchLower) ||
                englishName.contains(searchLower);
          },
        ),
      ),
    );
  }
}
