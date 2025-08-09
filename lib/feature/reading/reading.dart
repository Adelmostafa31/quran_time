import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_time/core/helper/cach_helper.dart';
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

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.duration * 60;
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
    });
  }

  Future<void> _saveSelectedSurah(int surahId) async {
    await CachHelper.saveData(key: 'selected_surah', value: surahId);
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

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  List<Widget> _getCurrentPageVerses() {
    int startVerse = (currentPage - 1) * versesPerPage + 1;
    int endVerse = (currentPage * versesPerPage).clamp(
      1,
      quran.getVerseCount(selectedSurahId),
    );

    List<Widget> verses = [];

    // إضافة البسملة في الصفحة الأولى فقط (إلا سورة التوبة)
    if (currentPage == 1 && selectedSurahId != 9) {
      verses.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            quran.basmala,
            style: GoogleFonts.amiriQuran(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    for (int verseNumber = startVerse; verseNumber <= endVerse; verseNumber++) {
      verses.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            quran.getVerse(selectedSurahId, verseNumber, verseEndSymbol: true),
            style: GoogleFonts.amiriQuran(fontSize: 20, height: 2.2),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }

    return verses;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).reading, style: TextStyles.font16WhiteBold),
        backgroundColor: ColorsManager.mainColor,
        foregroundColor: Colors.white,
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
                    height: 25.h,
                    width: 70.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isRunning
                          ? ColorsManager.yellow
                          : ColorsManager.white,
                      borderRadius: BorderRadius.circular(20.r),
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.white,
                    // fontFamily: 'Cairo',
                  ),
                ),
                GestureDetector(
                  onTap: resetTimer,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 25.h,
                    width: 70.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorsManager.white,
                      borderRadius: BorderRadius.circular(20.r),
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
                padding: const EdgeInsets.all(20),
                color: ColorsManager.mainColor,
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 40,
                    ),
                    10.height,
                    const Text(
                      'مبروك! الله يتقبل منك',
                      style: TextStyle(
                        fontSize: 24,
                        color: ColorsManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    15.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => extendTimer(5),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: ColorsManager.mainColor,
                          ),
                          child: Text(
                            S.of(context).extend,
                            style: TextStyles.font12MainColorBold,
                          ),
                        ),
                        10.width,
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white70,
                            foregroundColor: const Color(0xFF2E7D32),
                          ),
                          child: Text(
                            S.of(context).finish,
                            style: TextStyles.font12MainColorBold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: DropDownListByIdAR(
                text: '',
                selectedValue: selectedSurahId,
                textEditingController:
                    TextEditingController(), // Add a controller
                hint: '',
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedSurahId = newValue;
                      currentPage = 1;
                      _calculatePages();
                    });
                    _saveSelectedSurah(newValue);
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getCurrentPageVerses(),
                  ),
                ),
              ),
            ),
            // أزرار التنقل بين الصفحات
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: currentPage > 1 ? _previousPage : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: currentPage > 1
                            ? ColorsManager.mainColor
                            : ColorsManager.grey,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        spacing: 5.w,
                        children: [
                          const Icon(
                            Icons.keyboard_arrow_right,
                            color: ColorsManager.white,
                            size: 13,
                          ),
                          Text(
                            S.of(context).previousPage,
                            style: TextStyles.font12WhiteBold,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$currentPage / $totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: currentPage < totalPages ? _nextPage : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: currentPage < totalPages
                            ? ColorsManager.mainColor
                            : ColorsManager.grey,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        spacing: 5.w,
                        children: [
                          Text(
                            S.of(context).nextPage,
                            style: TextStyles.font12WhiteBold,
                          ),
                          const Icon(
                            Icons.keyboard_arrow_left,
                            color: ColorsManager.white,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
