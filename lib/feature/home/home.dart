import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً $userName', style: TextStyles.font16WhiteBold),
        backgroundColor: ColorsManager.mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: ColorsManager.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) => _loadUserData()),
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
                  Text(
                    '${S.of(context).readyForYour} $duration ${S.of(context).nextMinutes}',
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Reading(duration: duration),
                ),
              ).then((_) => _loadUserData()),
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
