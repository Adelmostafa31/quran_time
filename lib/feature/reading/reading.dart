import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_time/core/helper/cach_helper.dart';

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
        title: Text(
          'Quran Reading - ${quran.getSurahNameArabic(selectedSurahId)}',
          style: GoogleFonts.amiriQuran(),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            color: const Color(0xFF1B5E20),
            child: Column(
              children: [
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isCompleted) ...[
                      ElevatedButton(
                        onPressed: isRunning ? pauseTimer : startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1B5E20),
                        ),
                        child: Text(isRunning ? 'Pause' : 'Start'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: resetTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: const Color(0xFF1B5E20),
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isCompleted) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF2E7D32),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'مبروك! الله يتقبل منك',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => extendTimer(5),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2E7D32),
                        ),
                        child: const Text('Extend +5min'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: const Color(0xFF2E7D32),
                        ),
                        child: const Text('Finish'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedSurahId,
                    isExpanded: true,
                    hint: Text('Select Surah', style: GoogleFonts.amiri()),
                    items: List.generate(114, (index) {
                      final surahNumber = index + 1;
                      return DropdownMenuItem<int>(
                        value: surahNumber,
                        child: Text(
                          '${quran.getSurahNameArabic(surahNumber)} (${quran.getSurahNameEnglish(surahNumber)})',
                          style: GoogleFonts.amiri(),
                        ),
                      );
                    }),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedSurahId = newValue;
                          currentPage = 1; // العودة للصفحة الأولى
                          _calculatePages();
                        });
                        _saveSelectedSurah(newValue);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'صفحة $currentPage من $totalPages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                child: Column(children: _getCurrentPageVerses()),
              ),
            ),
          ),
          // أزرار التنقل بين الصفحات
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: currentPage > 1 ? _previousPage : null,
                  icon: const Icon(Icons.arrow_back_ios),
                  label: const Text('الصفحة السابقة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPage > 1
                        ? const Color(0xFF1B5E20)
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
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
                ElevatedButton.icon(
                  onPressed: currentPage < totalPages ? _nextPage : null,
                  icon: const Icon(Icons.arrow_forward_ios),
                  label: const Text('الصفحة التالية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPage < totalPages
                        ? const Color(0xFF1B5E20)
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
