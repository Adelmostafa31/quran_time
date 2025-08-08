import 'package:flutter/material.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/helper/extentions.dart';
import 'package:quran_time/core/helper/notification_services.dart';
import 'package:quran_time/core/routing/routes.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  TextEditingController nameController = TextEditingController();
  String selectedFrequency = 'daily';
  int selectedDuration = 5;
  TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مرحباً - Welcome'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Let\'s set up your Quran reading routine',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Your name (اسمك)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Reading Frequency:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 20),
            const Text(
              'Session Duration:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 20),
            const Text(
              'Reminder Time:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Start My Journey',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyButton(String value, String label) {
    bool isSelected = selectedFrequency == value;
    return ElevatedButton(
      onPressed: () => setState(() => selectedFrequency = value),
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
    bool isSelected = selectedDuration == minutes;
    return ElevatedButton(
      onPressed: () => setState(() => selectedDuration = minutes),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFF1B5E20)
            : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text('${minutes}min'),
    );
  }

  Future<void> _savePreferences() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    await CachHelper.saveData(
      key: 'user_name',
      value: nameController.text.trim(),
    );
    await CachHelper.saveData(key: 'frequency', value: selectedFrequency);
    await CachHelper.saveData(key: 'duration', value: selectedDuration);
    await CachHelper.saveData(key: 'reminder_hour', value: reminderTime.hour);
    await CachHelper.saveData(
      key: 'reminder_minute',
      value: reminderTime.minute,
    );
    await CachHelper.saveData(key: 'first_time', value: false);
    await CachHelper.saveData(key: 'sessions_completed', value: 0);
    await CachHelper.saveData(key: 'total_minutes', value: 0);
    await CachHelper.saveData(key: 'selected_surah', value: 1);

    await NotificationService().scheduleReminders(
      userName: nameController.text.trim(),
      frequency: selectedFrequency,
      duration: selectedDuration,
      reminderTime: reminderTime,
    );

    await context.pushNamedAndRemoveUntill(Routes.home);
  }
}
