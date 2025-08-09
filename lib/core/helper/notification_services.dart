import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

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
      'جاهز لقراءة القرأن لمدة $duration دقايق يا $userName! 📖',
      'وقت قراءة الوِرد اليومي, $userName! اللهم بارك 🤲',
      'تذكير بالوِرد اليومي يا, $userName 🌟',
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
