import 'package:flutter/material.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/helper/notification_services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String frequency = 'daily';
  int duration = 5;
  TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 0);
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      frequency = CachHelper.getData(key: 'frequency') ?? 'daily';
      duration = CachHelper.getData(key: 'duration') ?? 5;
      userName = CachHelper.getData(key: 'user_name') ?? '';
      int hour = CachHelper.getData(key: 'reminder_hour') ?? 20;
      int minute = CachHelper.getData(key: 'reminder_minute') ?? 0;
      reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    await CachHelper.saveData(key: 'frequency', value: frequency);
    await CachHelper.saveData(key: 'duration', value: duration);
    await CachHelper.saveData(key: 'reminder_hour', value: reminderTime.hour);
    await CachHelper.saveData(
      key: 'reminder_minute',
      value: reminderTime.minute,
    );

    await NotificationService().scheduleReminders(
      userName: userName,
      frequency: frequency,
      duration: duration,
      reminderTime: reminderTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved! Notifications updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reading Frequency:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildFrequencyButton('daily', 'Daily')),
                const SizedBox(width: 10),
                Expanded(child: _buildFrequencyButton('weekly', 'Weekly')),
                const SizedBox(width: 10),
                Expanded(child: _buildFrequencyButton('monthly', 'Monthly')),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Session Duration:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildDurationButton(3)),
                const SizedBox(width: 10),
                Expanded(child: _buildDurationButton(5)),
                const SizedBox(width: 10),
                Expanded(child: _buildDurationButton(10)),
                const SizedBox(width: 10),
                Expanded(child: _buildDurationButton(15)),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Reminder Time:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: reminderTime,
                );
                if (picked != null) {
                  setState(() => reminderTime = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 10),
                    Text(
                      'Remind me at ${reminderTime.format(context)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyButton(String value, String label) {
    bool isSelected = frequency == value;
    return ElevatedButton(
      onPressed: () => setState(() => frequency = value),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFF1B5E20)
            : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildDurationButton(int minutes) {
    bool isSelected = duration == minutes;
    return ElevatedButton(
      onPressed: () => setState(() => duration = minutes),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFF1B5E20)
            : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text('${minutes}min'),
    );
  }
}
