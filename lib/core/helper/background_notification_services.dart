// background_notification_services.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/theming/colors.dart';

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

    // فحص إذا كان الوقت مناسب للإشعار
    if (!_shouldSendReminderNow()) {
      return;
    }

    List<String> motivationalMessages = [
      'وقت القراءة يا $userName! 📖 اجعل القرآن نور قلبك',
      'حان وقت جلستك مع كتاب الله يا $userName 🌟',
      'القرآن ينتظرك يا $userName.. $duration دقائق من النور 💚',
      'بسم الله نبدأ، يا $userName وقت القراءة 🕌',
      'اللهم اجعل القرآن ربيع قلوبنا يا $userName 🤲',
      'دقائق قليلة مع كتاب الله تنير قلبك يا $userName ✨',
      'وقت الهدوء والسكينة مع القرآن يا $userName 🕌',
      'اللهم اجعل القرآن شفيعنا يوم القيامة، يا $userName 🤲',
    ];

    try {
      int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        100000,
      );
      String selectedMessage =
          motivationalMessages[Random().nextInt(motivationalMessages.length)];

      await _notifications.show(
        notificationId,
        'نور - وقت القرآن',
        selectedMessage,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'quran_reminders_bg',
            'تذكير القرآن',
            channelDescription: 'تذكير يومي لقراءة القرآن من الخلفية',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            autoCancel: true,
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            // إعدادات للعمل في background
            showWhen: true,
            when: DateTime.now().millisecondsSinceEpoch,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.active,
            categoryIdentifier: 'quran_reminder',
          ),
        ),
      );

      // تحديث آخر وقت إرسال إشعار
      await CachHelper.saveData(
        key: 'last_reminder_sent',
        value: DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('تم إرسال إشعار التذكير بنجاح في ${DateTime.now()}');
    } catch (e) {
      debugPrint('خطأ في إرسال إشعار التذكير: $e');
    }
  }

  bool _shouldSendReminderNow() {
    try {
      final reminderHour = CachHelper.getData(key: 'reminder_hour');
      final reminderMinute = CachHelper.getData(key: 'reminder_minute');
      final frequency = CachHelper.getData(key: 'reminder_frequency');
      final lastReminderSent = CachHelper.getData(key: 'last_reminder_sent');

      if (reminderHour == null || reminderMinute == null) {
        return false;
      }

      final now = DateTime.now();
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminderHour,
        reminderMinute,
      );

      // فحص إذا كان الوقت الحالي قريب من وقت التذكير (خلال 30 دقيقة)
      final timeDifference = now.difference(reminderTime).abs();
      final isNearReminderTime = timeDifference.inMinutes <= 30;

      if (!isNearReminderTime) {
        return false;
      }

      // فحص التكرار
      if (lastReminderSent != null) {
        final lastSent = DateTime.fromMillisecondsSinceEpoch(lastReminderSent);
        final timeSinceLastReminder = now.difference(lastSent);

        switch (frequency) {
          case 'daily':
            // منع الإشعارات المتكررة في نفس اليوم
            if (timeSinceLastReminder.inHours < 20) {
              return false;
            }
            break;
          case 'weekly':
            if (timeSinceLastReminder.inDays < 6) {
              return false;
            }
            break;
          case 'monthly':
            if (timeSinceLastReminder.inDays < 28) {
              return false;
            }
            break;
        }
      }

      return true;
    } catch (e) {
      debugPrint('خطأ في فحص وقت التذكير: $e');
      return false;
    }
  }

  Future<void> checkAndNotifyProgress() async {
    try {
      await initBackgroundNotifications();

      int totalAyahsRead = CachHelper.getData(key: 'total_ayahs_read') ?? 0;
      String userName = CachHelper.getData(key: 'user_name') ?? 'مستخدم';

      // معالم الإنجاز (ربع، نصف، ثلاثة أرباع، كامل)
      List<int> quarterMilestones = [1515, 3030, 4545, 6236];
      List<String> achievements = [
        'ربع القرآن الكريم',
        'نصف القرآن الكريم',
        'ثلاثة أرباع القرآن الكريم',
        'القرآن الكريم كاملاً',
      ];

      List<String> celebrationMessages = [
        'مبروك يا $userName! 🎉 لقد أتممت',
        'ألف مبروك يا $userName! 🌟 تم إنجاز',
        'الله يتقبل منك يا $userName! 🎊 أكملت',
        'بارك الله فيك يا $userName! ✨ أنهيت',
      ];

      for (int i = 0; i < quarterMilestones.length; i++) {
        String progressKey = 'quarter_${i + 1}_notified';
        bool alreadyNotified = CachHelper.getData(key: progressKey) ?? false;
        int lastNotifiedAyahs =
            CachHelper.getData(key: '${progressKey}_ayahs') ?? 0;

        // فحص إذا وصل للمعلم وما تم إشعاره من قبل
        if (totalAyahsRead >= quarterMilestones[i] &&
            !alreadyNotified &&
            totalAyahsRead > lastNotifiedAyahs) {
          String celebrationMessage =
              celebrationMessages[Random().nextInt(celebrationMessages.length)];

          await _notifications.show(
            2000 + i,
            'إنجاز رائع! 🎉',
            '$celebrationMessage ${achievements[i]}! الله يتقبل منك 🌟📖',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'progress_notifications_enhanced',
                'إشعارات التقدم المحسنة',
                channelDescription: 'إشعارات عند إتمام أجزاء من القرآن الكريم',
                importance: Importance.max,
                priority: Priority.max,
                icon: '@mipmap/ic_launcher',
                autoCancel: false,
                enableVibration: true,
                playSound: true,
                fullScreenIntent: true,
                category: AndroidNotificationCategory.status,
                visibility: NotificationVisibility.public,
                color: ColorsManager.mainColor, // لون أخضر إسلامي
                largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                interruptionLevel: InterruptionLevel.active,
                categoryIdentifier: 'progress_achievement',
              ),
            ),
          );

          // تسجيل أنه تم الإشعار
          await CachHelper.saveData(key: progressKey, value: true);
          await CachHelper.saveData(
            key: '${progressKey}_ayahs',
            value: totalAyahsRead,
          );

          debugPrint('تم إرسال إشعار التقدم: ${achievements[i]}');

          // إشعار واحد فقط في كل مرة
          break;
        }
      }

      // إشعارات إنجازات إضافية (كل 100 آية)
      await _checkMinorAchievements(userName, totalAyahsRead);
    } catch (e) {
      debugPrint('خطأ في فحص وإشعار التقدم: $e');
    }
  }

  Future<void> _checkMinorAchievements(
    String userName,
    int totalAyahsRead,
  ) async {
    try {
      // فحص كل 100 آية
      int currentHundred = (totalAyahsRead ~/ 100) * 100;
      String hundredKey = 'hundred_$currentHundred';
      bool hundredNotified = CachHelper.getData(key: hundredKey) ?? false;

      if (currentHundred > 0 &&
          currentHundred % 100 == 0 &&
          !hundredNotified &&
          totalAyahsRead >= currentHundred) {
        List<String> encouragementMessages = [
          'ما شاء الله يا $userName! وصلت لـ $currentHundred آية 📖✨',
          'بارك الله فيك يا $userName! $currentHundred آية من كتاب الله 🌟',
          'استمر يا $userName! $currentHundred آية إنجاز رائع 💚',
          'الله يثبتك يا $userName! $currentHundred آية من النور 🕌',
        ];

        await _notifications.show(
          3000 + (currentHundred ~/ 100),
          'إنجاز متميز! 📖',
          encouragementMessages[Random().nextInt(encouragementMessages.length)],
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'minor_achievements',
              'الإنجازات الصغيرة',
              channelDescription: 'تشجيع عند كل 100 آية',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              icon: '@mipmap/ic_launcher',
              autoCancel: true,
              enableVibration: false,
              playSound: false,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: false,
              presentSound: false,
              interruptionLevel: InterruptionLevel.passive,
            ),
          ),
        );

        await CachHelper.saveData(key: hundredKey, value: true);
      }
    } catch (e) {
      debugPrint('خطأ في فحص الإنجازات الصغيرة: $e');
    }
  }

  // إعادة تعيين الإنجازات (للاختبار أو عند البداية من جديد)
  Future<void> resetAchievements() async {
    for (int i = 1; i <= 4; i++) {
      await CachHelper.removeData(key: 'quarter_${i}_notified');
      await CachHelper.removeData(key: 'quarter_${i}_notified_ayahs');
    }

    // مسح إنجازات المئات
    for (int i = 100; i <= 6300; i += 100) {
      await CachHelper.removeData(key: 'hundred_$i');
    }
  }
}
