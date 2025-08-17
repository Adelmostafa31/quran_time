import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/helper/constant.dart';
import 'package:quran_time/core/helper/extentions.dart';
import 'package:quran_time/core/theming/colors.dart';
import 'package:quran_time/core/theming/styles.dart';
import 'package:quran_time/feature/reading/reading.dart';
import 'package:quran_time/feature/settings/settings.dart';
import 'package:quran_time/generated/l10n.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = '';
  String frequency = '';
  int duration = 0;
  int sessionsCompleted = 0;
  int totalMinutes = 0;
  TimeOfDay? reminderTime;
  List<int> favoriteSurahs = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFavoriteSurahs();
  }

  Future<void> _loadUserData() async {
    setState(() {
      userName = CachHelper.getData(key: 'user_name') ?? '';
      frequency = CachHelper.getData(key: 'frequency') ?? 'daily';
      duration = CachHelper.getData(key: 'duration') ?? 5;
      sessionsCompleted = CachHelper.getData(key: 'sessions_completed') ?? 0;
      totalMinutes = CachHelper.getData(key: 'total_minutes') ?? 0;
      int hour = CachHelper.getData(key: 'reminder_hour') ?? 20;
      int minute = CachHelper.getData(key: 'reminder_minute') ?? 0;
      reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _loadFavoriteSurahs() async {
    String? favoritesJson = CachHelper.getData(key: 'favorite_surahs');
    if (favoritesJson != null) {
      List<dynamic> favoritesList = jsonDecode(favoritesJson);
      setState(() {
        favoriteSurahs = favoritesList.cast<int>();
      });
    }
  }

  void _showFavoriteSurahsDialog() {
    if (favoriteSurahs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا توجد سور مفضلة بعد. اضف بعض السور إلى المفضلة من صفحة القراءة',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: ColorsManager.mainColor,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: ColorsManager.red, size: 20.sp),
              8.width,
              Text(
                'السور المفضلة',
                style: TextStyles.font16MainColor,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300.h,
            child: ListView.builder(
              itemCount: favoriteSurahs.length,
              itemBuilder: (context, index) {
                int surahId = favoriteSurahs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: ColorsManager.white,
                  child: ListTile(
                    leading: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: ColorsManager.mainColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          '$surahId',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      quran.getSurahNameArabic(surahId),
                      style: TextStyles.font14MainColorBold,
                      textDirection: TextDirection.rtl,
                    ),
                    subtitle: Text(
                      '${quran.getVerseCount(surahId)} آية • ${quran.getPlaceOfRevelation(surahId) == 'Makkah' ? 'مكية' : 'مدنية'}',
                      style: TextStyles.font12Grey,
                      textDirection: TextDirection.rtl,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: ColorsManager.mainColor,
                      size: 16.sp,
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); // إغلاق الحوار
                      // حفظ السورة المختارة
                      CachHelper.saveData(
                        key: 'selected_surah',
                        value: surahId,
                      );
                      // الانتقال لصفحة القراءة
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Reading(duration: duration),
                        ),
                      ).then((_) => _loadUserData());
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إغلاق', style: TextStyles.font14MainColorBold),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً $userName', style: TextStyles.font16WhiteBold),
        backgroundColor: ColorsManager.mainColor,
        actions: [
          // أيكون السور المفضلة
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.favorite, color: ColorsManager.white),
                if (favoriteSurahs.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      margin: const EdgeInsets.only(left: 7, bottom: 7),
                      decoration: BoxDecoration(
                        color: ColorsManager.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                      child: Text(
                        '${favoriteSurahs.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFavoriteSurahsDialog,
            tooltip: 'السور المفضلة',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: ColorsManager.white),
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ).then((_) {
                  _loadUserData();
                  _loadFavoriteSurahs();
                }),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    S.of(context).times,
                    '$sessionsCompleted',
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    'Minutes',
                    '$totalMinutes',
                    Icons.timer,
                  ),
                ),
              ],
            ),
            20.height,
            // إضافة كارد السور المفضلة
            if (favoriteSurahs.isNotEmpty) ...[
              GestureDetector(
                onTap: _showFavoriteSurahsDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: ColorsManager.mainColor.withOpacity(0.7),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsManager.red.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: ColorsManager.red,
                        size: 24.sp,
                      ),
                      12.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).favorites,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: ColorsManager.mainColor,
                              ),
                            ),
                            2.height,
                            Text(
                              '${favoriteSurahs.length} ${S.of(context).saved}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: ColorsManager.mainColor,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
              15.height,
            ],
            Row(
              children: [
                Text(
                  S.of(context).completedSurahs,
                  style: TextStyles.font16MainColorBold,
                ),
                const Spacer(),
                Text(
                  '${(((CachHelper.getData(key: 'completed_surahs_count') ?? 0) / 114).toDouble() * 100).toString().substring(0, 4)} %',
                  style: TextStyles.font16MainColorBold,
                ),
              ],
            ),
            10.height,
            LinearProgressIndicator(
              value:
                  double.parse(
                    (CachHelper.getData(key: 'completed_surahs_count') ?? 0)
                        .toString(),
                  ) /
                  114,
              backgroundColor: Colors.grey[300],
              color: ColorsManager.mainColor,
            ),
            20.height,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: ColorsManager.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.book,
                    size: 50,
                    color: ColorsManager.mainColor,
                  ),
                  15.height,
                  Constant.isArabic()
                      ? Text(
                          '$duration ${S.of(context).readyForYour}',
                          style: TextStyles.font16MainColorBold,
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          '${S.of(context).just} $duration ${S.of(context).readyForYour2}',
                          style: TextStyles.font16MainColorBold,
                          textAlign: TextAlign.center,
                        ),
                  5.height,
                  if (reminderTime != null)
                    Text(
                      '${S.of(context).nextReminder}: ${reminderTime!.format(context)}',
                      style: TextStyles.font12GreyBold,
                      textAlign: TextAlign.center,
                    ),
                  10.height,
                  Text(
                    'اللهم اجعل القرآن ربيع قلبي',
                    style: TextStyles.font12Grey,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Reading(duration: duration),
                    ),
                  ).then((_) {
                    _loadUserData();
                    _loadFavoriteSurahs();
                  }),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.mainColor,
                foregroundColor: ColorsManager.white,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: Text(
                S.of(context).startReading,
                style: TextStyles.font16WhiteBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorsManager.mainColor, size: 25.sp),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyles.font14MainColorBold),
                5.height,
                Text(value, style: TextStyles.font16MainColorBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
