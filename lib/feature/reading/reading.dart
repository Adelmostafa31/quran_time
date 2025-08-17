import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/helper/constant.dart';
import 'package:quran_time/core/helper/extentions.dart';
import 'package:quran_time/core/theming/colors.dart';
import 'package:quran_time/core/theming/styles.dart';
import 'package:quran_time/feature/reading/drop_down_list_by_id.dart'
    show DropDownListByIdAR;
import 'package:quran_time/generated/l10n.dart';

class Reading extends StatefulWidget {
  final int duration;

  const Reading({super.key, required this.duration});

  @override
  _ReadingState createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {
  late int remainingSeconds;
  Timer? timer;
  bool isRunning = false;
  bool isCompleted = false;
  int selectedSurahId = 1;

  // متغيرات الصفحات
  int currentPage = 1;
  int versesPerPage = 10; // عدد الآيات في كل صفحة
  late int totalPages;

  // إضافة ScrollController
  late ScrollController scrollController;

  // متغير للمفضلة
  List<int> favoriteSurahs = [];

  // متغير لعدد السور المكتملة
  int completedSurahsCount = 0;

  // قائمة السور المكتملة لتجنب العد المكرر
  Set<int> completedSurahs = {};

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.duration * 60;
    scrollController = ScrollController(); // تهيئة الـ controller
    _loadSelectedSurah();
    _loadFavoriteSurahs();
    _loadCompletedSurahs();
    _calculatePages();
  }

  void _calculatePages() {
    int totalVerses = quran.getVerseCount(selectedSurahId);
    totalPages = (totalVerses / versesPerPage).ceil();
  }

  Future<void> _loadSelectedSurah() async {
    setState(() {
      selectedSurahId = CachHelper.getData(key: 'selected_surah') ?? 1;
      _calculatePages();
      // استرجاع آخر صفحة محفوظة للسورة المحددة
      currentPage =
          CachHelper.getData(key: 'surah_${selectedSurahId}_last_page') ?? 1;
      // التأكد أن الصفحة لا تتجاوز العدد الكلي للصفحات
      if (currentPage > totalPages) {
        currentPage = 1;
      }
    });
  }

  Future<void> _saveSelectedSurah(int surahId) async {
    await CachHelper.saveData(key: 'selected_surah', value: surahId);
  }

  // دالة لتحميل السور المفضلة
  Future<void> _loadFavoriteSurahs() async {
    String? favoritesJson = CachHelper.getData(key: 'favorite_surahs');
    if (favoritesJson != null) {
      List<dynamic> favoritesList = jsonDecode(favoritesJson);
      setState(() {
        favoriteSurahs = favoritesList.cast<int>();
      });
    }
  }

  // دالة لحفظ السور المفضلة
  Future<void> _saveFavoriteSurahs() async {
    String favoritesJson = jsonEncode(favoriteSurahs);
    await CachHelper.saveData(key: 'favorite_surahs', value: favoritesJson);
  }

  // دالة لتحميل السور المكتملة
  Future<void> _loadCompletedSurahs() async {
    // تحميل عدد السور المكتملة
    completedSurahsCount =
        CachHelper.getData(key: 'completed_surahs_count') ?? 0;

    // تحميل قائمة السور المكتملة
    String? completedSurahsJson = CachHelper.getData(
      key: 'completed_surahs_list',
    );
    if (completedSurahsJson != null) {
      List<dynamic> completedList = jsonDecode(completedSurahsJson);
      setState(() {
        completedSurahs = completedList.cast<int>().toSet();
      });
    }
  }

  // دالة لحفظ السور المكتملة
  Future<void> _saveCompletedSurahs() async {
    await CachHelper.saveData(
      key: 'completed_surahs_count',
      value: completedSurahsCount,
    );
    String completedSurahsJson = jsonEncode(completedSurahs.toList());
    await CachHelper.saveData(
      key: 'completed_surahs_list',
      value: completedSurahsJson,
    );
  }

  // دالة للتحقق من اكتمال السورة وإضافتها للعداد
  Future<void> _checkAndMarkSurahAsCompleted() async {
    // إذا وصلنا لآخر صفحة في السورة ولم تكن مكتملة من قبل
    if (currentPage == totalPages &&
        !completedSurahs.contains(selectedSurahId)) {
      setState(() {
        completedSurahs.add(selectedSurahId);
        completedSurahsCount++;
      });

      await _saveCompletedSurahs();

      // إظهار رسالة تهنئة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'مبروك! أكملت سورة ${quran.getSurahNameArabic(selectedSurahId)} ✨\nعدد السور المكتملة: $completedSurahsCount',
            style: const TextStyle(fontFamily: 'Cairo'),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // دالة لإضافة/إزالة السورة من المفضلة
  void _toggleFavorite() {
    setState(() {
      if (favoriteSurahs.contains(selectedSurahId)) {
        favoriteSurahs.remove(selectedSurahId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إزالة سورة ${quran.getSurahNameArabic(selectedSurahId)} من المفضلة',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        favoriteSurahs.add(selectedSurahId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إضافة سورة ${quran.getSurahNameArabic(selectedSurahId)} إلى المفضلة',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: ColorsManager.mainColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
    _saveFavoriteSurahs();
  }

  // التحقق من وجود السورة في المفضلة
  bool get isFavorite => favoriteSurahs.contains(selectedSurahId);

  // التحقق من اكتمال السورة الحالية
  bool get isSurahCompleted => completedSurahs.contains(selectedSurahId);

  // دالة جديدة لحفظ آخر صفحة في السورة الحالية
  Future<void> _saveCurrentPage() async {
    await CachHelper.saveData(
      key: 'surah_${selectedSurahId}_last_page',
      value: currentPage,
    );

    // التحقق من اكتمال السورة عند حفظ الصفحة
    await _checkAndMarkSurahAsCompleted();
  }

  // دالة جديدة للانتقال إلى السورة التالية
  void _goToNextSurah() {
    if (selectedSurahId < 114) {
      // عدد سور القرآن الكريم
      setState(() {
        selectedSurahId++;
        currentPage = 1;
        _calculatePages();
      });
      _saveSelectedSurah(selectedSurahId);
      _saveCurrentPage();
      _scrollToTop();
    }
  }

  void startTimer() {
    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingSeconds = widget.duration * 60;
      isRunning = false;
    });
  }

  void extendTimer(int extraMinutes) {
    setState(() {
      remainingSeconds += extraMinutes * 60;
      isCompleted = false;
    });
    if (!isRunning) startTimer();
  }

  void _completeSession() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      isCompleted = true;
    });
    _saveSession();
  }

  Future<void> _saveSession() async {
    int currentSessions = CachHelper.getData(key: 'sessions_completed') ?? 0;
    int currentMinutes = CachHelper.getData(key: 'total_minutes') ?? 0;

    await CachHelper.saveData(
      key: 'sessions_completed',
      value: currentSessions + 1,
    );
    await CachHelper.saveData(
      key: 'total_minutes',
      value: currentMinutes + widget.duration,
    );
  }

  String get formattedTime {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // تعديل دالة الصفحة التالية مع إضافة الاسكرول
  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
      // التمرير إلى أعلى الصفحة
      _scrollToTop();
      // حفظ الصفحة الحالية
      _saveCurrentPage();
    }
  }

  // تعديل دالة الصفحة السابقة مع إضافة الاسكرول
  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      // التمرير إلى أعلى الصفحة
      _scrollToTop();
      // حفظ الصفحة الحالية
      _saveCurrentPage();
    }
  }

  // دالة للتمرير إلى أعلى الصفحة
  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // دالة للحصول على النص القرآني بالرسم العثماني
  String _getUthmaniVerse(int surahNumber, int verseNumber) {
    // هنا يمكنك استخدام مكتبة للنص العثماني أو قاعدة بيانات
    // في هذا المثال سأستخدم النص العادي مع تحسينات التنسيق
    String verse = quran.getVerse(
      surahNumber,
      verseNumber,
      verseEndSymbol: false,
    );

    // تطبيق بعض التحسينات للنص ليبدو أكثر شبهاً بالرسم العثماني
    verse = verse.replaceAll('ء', 'ٔ'); // همزة على واو
    verse = verse.replaceAll('أ', 'ٱ'); // ألف وصل
    verse = verse.replaceAll('إ', 'ٱ'); // ألف وصل

    return verse;
  }

  List<Widget> _getCurrentPageVerses() {
    int startVerse = (currentPage - 1) * versesPerPage + 1;
    int endVerse = (currentPage * versesPerPage).clamp(
      1,
      quran.getVerseCount(selectedSurahId),
    );

    List<Widget> content = [];

    // إضافة البسملة في الصفحة الأولى فقط (إلا سورة التوبة)
    if (currentPage == 1 && selectedSurahId != 9) {
      content.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Column(
            children: [
              // خط فاصل علوي مزخرف
              Container(
                height: 3,
                width: 200,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      ColorsManager.mainColor.withOpacity(0.3),
                      ColorsManager.mainColor,
                      ColorsManager.mainColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // البسملة بالخط المناسب للرسم العثماني
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorsManager.mainColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: ColorsManager.mainColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  spacing: 10.h,
                  children: [
                    Text(
                      'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: 'amiri',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.mainColor,
                        height: 2.0,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // عرض علامة الاكتمال إذا كانت السورة مكتملة
                        if (isSurahCompleted) ...[
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16.sp,
                          ),
                          5.width,
                        ],
                        Text(
                          '${quran.getPlaceOfRevelation(selectedSurahId) == 'Makkah' ? 'مَكِّيَّة' : 'مَدَنِيَّة'} • ${quran.getVerseCount(selectedSurahId)} آية',
                          style: TextStyles.font14MainColorBold,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '• $totalPages صفحة',
                          style: TextStyles.font12MainColor,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        if (completedSurahsCount > 0) ...[
                          Text(
                            ' • $completedSurahsCount سور مكتملة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // خط فاصل سفلي مزخرف
              Container(
                height: 3,
                width: 200,
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      ColorsManager.mainColor.withOpacity(0.3),
                      ColorsManager.mainColor,
                      ColorsManager.mainColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // بناء محتوى الصفحة مع الآيات
    List<TextSpan> textSpans = [];

    for (int verseNumber = startVerse; verseNumber <= endVerse; verseNumber++) {
      String verseText = _getUthmaniVerse(selectedSurahId, verseNumber);

      // إضافة نص الآية
      textSpans.add(
        TextSpan(
          text: verseText,
          style: TextStyle(
            fontFamily: 'amiri',
            fontSize: 18.sp,
            height: 2.2,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      );

      // إضافة رقم الآية مع الفواصل الملونة
      textSpans.addAll([
        TextSpan(
          text: ' ﴿',
          style: TextStyle(
            fontFamily: 'amiri',
            fontSize: 17.sp,
            height: 2.2,
            color: const Color.fromARGB(255, 183, 138, 3),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        TextSpan(
          text: '$verseNumber',
          style: TextStyle(
            fontFamily: 'amiri',
            fontSize: 17.sp,
            height: 2.2,
            color: const Color.fromARGB(255, 183, 138, 3),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        TextSpan(
          text: '﴾',
          style: TextStyle(
            fontFamily: 'amiri',
            fontSize: 17.sp,
            height: 2.2,
            color: const Color.fromARGB(255, 183, 138, 3),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ]);

      // إضافة مساحة بعد الآية إلا إذا كانت الآية الأخيرة
      if (verseNumber < endVerse) {
        textSpans.add(
          TextSpan(
            text: ' ',
            style: TextStyle(
              fontFamily: 'amiri',
              fontSize: 17.sp,
              height: 2.2,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        );
      }
    }

    // container واحد يحتوي على جميع الآيات
    content.add(
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isSurahCompleted
                ? Colors.green.withOpacity(0.3)
                : ColorsManager.mainColor.withOpacity(0.15),
            width: isSurahCompleted ? 2.5 : 1.5,
          ),
        ),
        child: RichText(
          text: TextSpan(children: textSpans),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
        ),
      ),
    );

    return content;
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose(); // تنظيف الـ controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.white,
      appBar: AppBar(
        title: Text(S.of(context).reading, style: TextStyles.font16WhiteBold),
        backgroundColor: ColorsManager.mainColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Row(
            spacing: 10.w,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isCompleted) ...[
                GestureDetector(
                  onTap: isRunning ? pauseTimer : startTimer,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 30.h,
                    width: 75.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isRunning
                          ? ColorsManager.yellow
                          : ColorsManager.white,
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      isRunning ? S.of(context).pause : S.of(context).start,
                      style: isRunning
                          ? TextStyles.font14WhiteBold
                          : TextStyles.font14MainColorBold,
                    ),
                  ),
                ),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.white,
                  ),
                ),
                GestureDetector(
                  onTap: resetTimer,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 30.h,
                    width: 75.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorsManager.white,
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      S.of(context).reset,
                      style: TextStyles.font14MainColorBold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: Column(
          children: [
            if (isCompleted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ColorsManager.mainColor,
                      ColorsManager.mainColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 50,
                    ),
                    15.height,
                    const Text(
                      'مبروك! الله يتقبل منك',
                      style: TextStyle(
                        fontSize: 28,
                        color: ColorsManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (completedSurahsCount > 0) ...[
                      10.height,
                      Text(
                        'عدد السور المكتملة: $completedSurahsCount',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => extendTimer(5),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: ColorsManager.mainColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            S.of(context).extend,
                            style: TextStyles.font14MainColorBold,
                          ),
                        ),
                        15.width,
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white70,
                            foregroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            S.of(context).finish,
                            style: TextStyles.font14MainColorBold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            // إضافة الـ Row الذي يحتوي على الـ dropdown وزر المفضلة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  // الـ DropDown
                  Expanded(
                    child: DropDownListByIdAR(
                      text: '',
                      selectedValue: selectedSurahId,
                      textEditingController: TextEditingController(),
                      hint: '',
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedSurahId = newValue;
                            currentPage = 1;
                            _calculatePages();
                          });
                          _saveSelectedSurah(newValue);
                          // التمرير إلى أعلى عند تغيير السورة
                          _scrollToTop();
                        }
                      },
                    ),
                  ),
                  15.width,
                  // زر المفضلة
                  GestureDetector(
                    onTap: _toggleFavorite,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 35.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        color: isFavorite ? ColorsManager.red : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isFavorite
                              ? ColorsManager.red.withOpacity(0.1)
                              : ColorsManager.mainColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isFavorite
                                ? ColorsManager.red.withOpacity(0.1)
                                : Colors.white,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? Colors.white
                            : ColorsManager.mainColor,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getCurrentPageVerses(),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // زر الصفحة السابقة
                    GestureDetector(
                      onTap: currentPage > 1 ? _previousPage : null,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: currentPage > 1
                              ? LinearGradient(
                                  colors: [
                                    ColorsManager.mainColor,
                                    ColorsManager.mainColor.withOpacity(0.8),
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [
                                    ColorsManager.grey,
                                    ColorsManager.grey,
                                  ],
                                ),
                          boxShadow: currentPage > 1
                              ? [
                                  BoxShadow(
                                    color: ColorsManager.mainColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          Constant.isArabic()
                              ? Icons.keyboard_arrow_right
                              : Icons.keyboard_arrow_left,
                          color: ColorsManager.white,
                          size: 16,
                        ),
                      ),
                    ),
                    // عداد الصفحات مع معلومات إضافية
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$currentPage',
                          style: TextStyles.font16MainColorBold,
                        ),
                        if (isSurahCompleted) ...[
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 12.sp,
                          ),
                        ],
                      ],
                    ),

                    // زر الصفحة التالية أو السورة التالية
                    if (currentPage < totalPages) ...[
                      // زر الصفحة التالية
                      GestureDetector(
                        onTap: _nextPage,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                ColorsManager.mainColor,
                                ColorsManager.mainColor.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ColorsManager.mainColor.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Constant.isArabic()
                                ? Icons.keyboard_arrow_left
                                : Icons.keyboard_arrow_right,
                            color: ColorsManager.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ] else ...[
                      // زر السورة التالية (يظهر فقط في آخر صفحة من السورة)
                      if (selectedSurahId < 114) ...[
                        GestureDetector(
                          onTap: _goToNextSurah,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.r),
                              gradient: LinearGradient(
                                colors: [
                                  ColorsManager.mainColor,
                                  ColorsManager.mainColor.withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorsManager.mainColor.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  S.of(context).nextSurah,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                5.width,
                                Icon(
                                  Constant.isArabic()
                                      ? Icons.keyboard_double_arrow_left
                                      : Icons.keyboard_double_arrow_right,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // رسالة انتهاء القرآن
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.r),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green,
                                Colors.green.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.celebration,
                                color: Colors.white,
                                size: 16,
                              ),
                              5.width,
                              Text(
                                'انتهيت من القرآن',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
