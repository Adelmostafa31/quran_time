import 'package:flutter/material.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/feature/reading/reading.dart';
import 'package:quran_time/feature/settings/settings.dart';

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
        title: Text('مرحباً $userName'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) => _loadUserData()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Sessions',
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
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.book, size: 50, color: Color(0xFF1B5E20)),
                    const SizedBox(height: 15),
                    Text(
                      'Ready for your $duration-minute session?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    if (reminderTime != null)
                      Text(
                        'Next reminder: ${reminderTime!.format(context)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 10),
                    Text(
                      'اللهم اجعل القرآن ربيع قلبي',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                'Start Reading',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1B5E20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
