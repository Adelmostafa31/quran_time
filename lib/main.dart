import 'package:flutter/material.dart';

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "quranReminderTask":
        await BackgroundNotificationService().sendReminderNotification(
          inputData?['userName'] ?? 'مستخدم',
          inputData?['duration'] ?? 5,
        );
        break;
      case "progressNotificationTask":
        await BackgroundNotificationService().checkAndNotifyProgress();
        break;
    }
    return Future.value(true);
  });
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
