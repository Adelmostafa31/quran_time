import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_time/core/helper/background_notification_services.dart';
import 'package:quran_time/core/helper/bloc_observer.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/helper/notification_services.dart';
import 'package:quran_time/core/routing/app_router.dart';
import 'package:quran_time/quran_time.dart';
import 'package:timezone/data/latest.dart' as tz;
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Set to true during development
  );
  tz.initializeTimeZones();
  await NotificationService().initNotifications();
  await BackgroundNotificationService().initBackgroundNotifications();
  await CachHelper.init();
  Bloc.observer = MyBlocObserver();
  await ScreenUtil.ensureScreenSize();
  runApp(QuranTime(appRouter: AppRouter()));
}
