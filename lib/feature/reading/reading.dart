import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.duration * 60;
    scrollController = ScrollController(); // تهيئة الـ controller
    _loadSelectedSurah();
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

  // دالة جديدة لحفظ آخر صفحة في السورة الحالية
  Future<void> _saveCurrentPage() async {
    await CachHelper.saveData(
      key: 'surah_${selectedSurahId}_last_page',
      value: currentPage,
    );
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
                    Text(
                      '${quran.getPlaceOfRevelation(selectedSurahId) == 'Makkah' ? 'مَكِّيَّة' : 'مَدَنِيَّة'} • ${quran.getVerseCount(selectedSurahId)} آية',
                      style: TextStyles.font14MainColorBold,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      '• $totalPages صفحة',
                      style: TextStyles.font12MainColor,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
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
            color: ColorsManager.mainColor.withOpacity(0.15),
            width: 1.5,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                    // عداد الصفحات
                    Text('$currentPage', style: TextStyles.font16MainColorBold),
                    GestureDetector(
                      onTap: currentPage < totalPages ? _nextPage : null,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: currentPage < totalPages
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
                          boxShadow: currentPage < totalPages
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
                              ? Icons.keyboard_arrow_left
                              : Icons.keyboard_arrow_right,
                          color: ColorsManager.white,
                          size: 16,
                        ),
                      ),
                    ),
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
