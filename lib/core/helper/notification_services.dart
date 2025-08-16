// notification_services.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // طلب إذن الإشعارات أولاً
    await requestPermissions();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          requestProvisionalPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // معالجة الضغط على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    // يمكن إضافة navigation للتطبيق هنا
  }

  Future<bool> requestPermissions() async {
    // طلب إذن الإشعارات
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    // طلب إذن البطارية optimization (مهم جداً للأندرويد)
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }

    // طلب إذن تجاهل battery optimization
    await _requestBatteryOptimizationDisable();

    return status.isGranted;
  }

  Future<void> _requestBatteryOptimizationDisable() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      // طلب تعطيل battery optimization
      await android.requestNotificationsPermission();

      // طلب إذن exact alarm (مهم للأندرويد 12+)
      await android.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleAdvancedReminders({
    required String userName,
    required String frequency,
    required int duration,
    required TimeOfDay reminderTime,
  }) async {
    // إلغاء كل الإشعارات القديمة
    await _notifications.cancelAll();
    await Workmanager().cancelAll();

    List<String> motivationalMessages = [
      'وقت القراءة يا $userName! 📖 اجعل القرآن نور قلبك',
      'حان وقت جلستك مع كتاب الله يا $userName 🌟',
      'القرآن ينتظرك يا $userName.. $duration دقائق من النور 💚',
      'بسم الله نبدأ، يا $userName وقت القراءة 🕌',
      'اللهم اجعل القرآن ربيع قلوبنا يا $userName 🤲',
    ];

    // جدولة الإشعارات المحلية (أكثر دقة)
    if (frequency == 'daily') {
      await _scheduleDailyNotifications(
        userName,
        duration,
        reminderTime,
        motivationalMessages,
      );
    } else if (frequency == 'weekly') {
      await _scheduleWeeklyNotifications(
        userName,
        duration,
        reminderTime,
        motivationalMessages,
      );
    } else if (frequency == 'monthly') {
      await _scheduleMonthlyNotifications(
        userName,
        duration,
        reminderTime,
        motivationalMessages,
      );
    }

    // جدولة background tasks كـ backup
    await _scheduleBackgroundTasks(userName, frequency, duration, reminderTime);

    // حفظ إعدادات التذكير للاستخدام في background
    await _saveReminderSettings(userName, frequency, duration, reminderTime);
  }

  Future<void> _scheduleDailyNotifications(
    String userName,
    int duration,
    TimeOfDay reminderTime,
    List<String> messages,
  ) async {
    for (int i = 0; i < 60; i++) {
      // جدولة لشهرين
      DateTime now = DateTime.now();
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      ).add(Duration(days: i));

      if (scheduledTime.isAfter(now)) {
        final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
          scheduledTime,
          tz.local,
        );

        await _notifications.zonedSchedule(
          i, // notification ID
          'نور - وقت القرآن',
          messages[i % messages.length],
          tzScheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'quran_daily_reminders',
              'تذكير القرآن اليومي',
              channelDescription: 'تذكير يومي لقراءة القرآن',
              importance: Importance.max,
              priority: Priority.max,
              icon: '@mipmap/ic_launcher',
              autoCancel: false,
              ongoing: false,
              enableVibration: true,
              playSound: true,
              // إعدادات مهمة للعمل في background
              fullScreenIntent: true,
              category: AndroidNotificationCategory.reminder,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.active,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'quran_reminder_$i',
        );
      }
    }
  }

  Future<void> _scheduleWeeklyNotifications(
    String userName,
    int duration,
    TimeOfDay reminderTime,
    List<String> messages,
  ) async {
    for (int i = 0; i < 12; i++) {
      // جدولة لـ 3 شهور
      DateTime scheduledTime = DateTime.now().add(Duration(days: i * 7));
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
          100 + i,
          'نور - وقت القرآن',
          messages[i % messages.length],
          tzScheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'quran_weekly_reminders',
              'تذكير القرآن الأسبوعي',
              channelDescription: 'تذكير أسبوعي لقراءة القرآن',
              importance: Importance.max,
              priority: Priority.max,
              icon: '@mipmap/ic_launcher',
              fullScreenIntent: true,
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

  Future<void> _scheduleMonthlyNotifications(
    String userName,
    int duration,
    TimeOfDay reminderTime,
    List<String> messages,
  ) async {
    for (int i = 0; i < 6; i++) {
      // جدولة لـ 6 شهور
      DateTime scheduledTime = DateTime.now().add(Duration(days: i * 30));
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
          200 + i,
          'نور - وقت القرآن',
          messages[i % messages.length],
          tzScheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'quran_monthly_reminders',
              'تذكير القرآن الشهري',
              channelDescription: 'تذكير شهري لقراءة القرآن',
              importance: Importance.max,
              priority: Priority.max,
              icon: '@mipmap/ic_launcher',
              fullScreenIntent: true,
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

  Future<void> _scheduleBackgroundTasks(
    String userName,
    String frequency,
    int duration,
    TimeOfDay reminderTime,
  ) async {
    Duration period;
    switch (frequency) {
      case 'daily':
        period = const Duration(minutes: 15); // تشغيل كل 15 دقيقة للتأكد
        break;
      case 'weekly':
        period = const Duration(hours: 1); // كل ساعة
        break;
      case 'monthly':
        period = const Duration(hours: 6); // كل 6 ساعات
        break;
      default:
        period = const Duration(minutes: 15);
    }

    // مهمة التذكير الأساسية
    await Workmanager().registerPeriodicTask(
      'quran-reminder-backup',
      'quranReminderBackupTask',
      frequency: period,
      initialDelay: _calculateInitialDelay(reminderTime),
      inputData: {
        'userName': userName,
        'duration': duration,
        'reminderHour': reminderTime.hour,
        'reminderMinute': reminderTime.minute,
        'frequency': frequency,
      },
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    // مهمة فحص التقدم
    await Workmanager().registerPeriodicTask(
      'progress-check-enhanced',
      'progressNotificationEnhancedTask',
      frequency: const Duration(hours: 2), // كل ساعتين
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

  Duration _calculateInitialDelay(TimeOfDay reminderTime) {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      // إذا كان الوقت قد مر اليوم، جدولة لغداً
      return scheduledTime.add(const Duration(days: 1)).difference(now);
    } else {
      // الوقت لم يحن بعد اليوم
      return scheduledTime.difference(now);
    }
  }

  Future<void> _saveReminderSettings(
    String userName,
    String frequency,
    int duration,
    TimeOfDay reminderTime,
  ) async {
    await CachHelper.saveData(key: 'reminder_user_name', value: userName);
    await CachHelper.saveData(key: 'reminder_frequency', value: frequency);
    await CachHelper.saveData(key: 'reminder_duration', value: duration);
    await CachHelper.saveData(key: 'reminder_hour', value: reminderTime.hour);
    await CachHelper.saveData(
      key: 'reminder_minute',
      value: reminderTime.minute,
    );
    await CachHelper.saveData(
      key: 'reminder_last_set',
      value: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // فحص الإشعارات المجدولة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // إعادة جدولة الإشعارات إذا لزم الأمر
  Future<void> rescheduleIfNeeded() async {
    final pendingNotifications = await getPendingNotifications();

    if (pendingNotifications.isEmpty) {
      // إعادة جدولة من المعلومات المحفوظة
      final userName = CachHelper.getData(key: 'reminder_user_name');
      final frequency = CachHelper.getData(key: 'reminder_frequency');
      final duration = CachHelper.getData(key: 'reminder_duration');
      final hour = CachHelper.getData(key: 'reminder_hour');
      final minute = CachHelper.getData(key: 'reminder_minute');

      if (userName != null &&
          frequency != null &&
          duration != null &&
          hour != null &&
          minute != null) {
        await scheduleAdvancedReminders(
          userName: userName,
          frequency: frequency,
          duration: duration,
          reminderTime: TimeOfDay(hour: hour, minute: minute),
        );
      }
    }
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    await Workmanager().cancelAll();

    // مسح الإعدادات المحفوظة
    await CachHelper.removeData(key: 'reminder_user_name');
    await CachHelper.removeData(key: 'reminder_frequency');
    await CachHelper.removeData(key: 'reminder_duration');
    await CachHelper.removeData(key: 'reminder_hour');
    await CachHelper.removeData(key: 'reminder_minute');
  }
}
