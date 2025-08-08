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
