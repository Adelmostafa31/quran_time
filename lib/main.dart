// Background task callback
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_time/core/helper/bloc_observer.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/routing/app_router.dart';
import 'package:quran_time/quran_time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'quranReminderTask':
        await BackgroundNotificationService().sendReminderNotification(
          inputData?['userName'] ?? 'مستخدم',
          inputData?['duration'] ?? 5,
        );
        break;
      case 'progressNotificationTask':
        await BackgroundNotificationService().checkAndNotifyProgress();
        break;
    }
    return Future.value(true);
  });
}

class BackgroundNotificationService {
  static final BackgroundNotificationService _instance =
      BackgroundNotificationService._internal();
  factory BackgroundNotificationService() => _instance;
  BackgroundNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initBackgroundNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  Future<void> sendReminderNotification(String userName, int duration) async {
    await initBackgroundNotifications();

    List<String> motivationalMessages = [
      'وقت القراءة يا $userName! 📖 اجعل القرآن نور قلبك',
      'حان وقت جلستك مع كتاب الله يا $userName 🌟',
      'القرآن ينتظرك يا $userName.. $duration دقائق من النور 💚',
      'بسم الله نبدأ، يا $userName وقت القراءة 🕌',
      'اللهم اجعل القرآن ربيع قلوبنا يا $userName 🤲',
    ];

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'نور - وقت القرآن',
      motivationalMessages[DateTime.now().minute % motivationalMessages.length],
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quran_reminders',
          'تذكير القرآن',
          channelDescription: 'تذكير يومي لقراءة القرآن',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> checkAndNotifyProgress() async {
    await initBackgroundNotifications();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int totalSurahsRead = prefs.getInt('total_surahs_read') ?? 0;
    int totalAyahsRead = prefs.getInt('total_ayahs_read') ?? 0;
    String userName = prefs.getString('user_name') ?? 'مستخدم';

    // Check if user completed a quarter of Quran (approximately 1515 ayahs)
    List<int> quarterMilestones = [
      1515,
      3030,
      4545,
      6236,
    ]; // Quran has 6236 ayahs total

    for (int i = 0; i < quarterMilestones.length; i++) {
      String progressKey = 'quarter_${i + 1}_notified';
      bool alreadyNotified = prefs.getBool(progressKey) ?? false;

      if (totalAyahsRead >= quarterMilestones[i] && !alreadyNotified) {
        await _notifications.show(
          1000 + i,
          'مبروك يا $userName! 🎉',
          'لقد أتممت ${_getQuarterName(i + 1)} من القرآن الكريم! الله يتقبل منك 🌟📖',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'progress_notifications',
              'إشعارات التقدم',
              channelDescription: 'إشعارات عند إتمام أجزاء من القرآن',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
        await prefs.setBool(progressKey, true);
        break;
      }
    }
  }

  String _getQuarterName(int quarter) {
    switch (quarter) {
      case 1:
        return 'ربع القرآن';
      case 2:
        return 'نصف القرآن';
      case 3:
        return 'ثلاثة أرباع القرآن';
      case 4:
        return 'القرآن كاملاً';
      default:
        return 'جزء من القرآن';
    }
  }
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   tz.initializeTimeZones();

//   // Initialize WorkManager
//   await Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: false, // Set to true during development
//   );

//   await NotificationService().initNotifications();
//   await BackgroundNotificationService().initBackgroundNotifications();

//   runApp(const MyApp());
// }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleBackgroundReminders({
    required String userName,
    required String frequency,
    required int duration,
    required TimeOfDay reminderTime,
  }) async {
    // Cancel existing work
    await Workmanager().cancelAll();

    // Schedule background work based on frequency
    Duration period;
    switch (frequency) {
      case 'daily':
        period = const Duration(days: 1);
        break;
      case 'weekly':
        period = const Duration(days: 7);
        break;
      case 'monthly':
        period = const Duration(days: 30);
        break;
      default:
        period = const Duration(days: 1);
    }

    // Register periodic task for reminders
    await Workmanager().registerPeriodicTask(
      'quran-reminder',
      'quranReminderTask',
      frequency: period,
      inputData: {
        'userName': userName,
        'duration': duration,
        'reminderHour': reminderTime.hour,
        'reminderMinute': reminderTime.minute,
      },
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    // Register periodic task for progress notifications
    await Workmanager().registerPeriodicTask(
      'progress-check',
      'progressNotificationTask',
      frequency: const Duration(hours: 6), // Check every 6 hours
      inputData: {'userName': userName},
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  Future<void> scheduleReminders({
    required String userName,
    required String frequency,
    required int duration,
    required TimeOfDay reminderTime,
  }) async {
    await _notifications.cancelAll();

    List<String> motivationalMessages = [
      'Ready for your $duration minutes with the Quran, $userName? 📖',
      'Time for Quran reading, $userName! اللهم بارك 🤲',
      'Your daily Quran session awaits, $userName 🌟',
      'Let\'s read together, $userName. القرآن نور القلب 💚',
      '$userName, your spiritual moment is here 🕌',
    ];

    if (frequency == 'daily') {
      for (int i = 0; i < 30; i++) {
        DateTime scheduledTime = DateTime.now().add(Duration(days: i));
        scheduledTime = DateTime(
          scheduledTime.year,
          scheduledTime.month,
          scheduledTime.day,
          reminderTime.hour,
          reminderTime.minute,
        );

        if (scheduledTime.isAfter(DateTime.now())) {
          final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
            scheduledTime,
            tz.local,
          );

          await _notifications.zonedSchedule(
            i,
            'نور - Quran Time',
            motivationalMessages[i % motivationalMessages.length],
            tzScheduledTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'quran_reminders',
                'Quran Reading Reminders',
                channelDescription: 'Daily reminders for Quran reading',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    }
    // ... similar logic for weekly and monthly

    // Also schedule background reminders
    await scheduleBackgroundReminders(
      userName: userName,
      frequency: frequency,
      duration: duration,
      reminderTime: reminderTime,
    );
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    await Workmanager().cancelAll();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Initialize WorkManager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Set to true during development
  );

  await NotificationService().initNotifications();
  await BackgroundNotificationService().initBackgroundNotifications();
  await CachHelper.init();
  Bloc.observer = MyBlocObserver();
  await ScreenUtil.ensureScreenSize();
  runApp(QuranTime(appRouter: AppRouter()));
}
