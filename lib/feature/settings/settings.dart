import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/helper/extentions.dart';
import 'package:quran_time/core/helper/notification_services.dart';
import 'package:quran_time/core/theming/colors.dart';
import 'package:quran_time/core/theming/styles.dart';
import 'package:quran_time/generated/l10n.dart';
import 'package:quran_time/global_manager/ui_cubit.dart';

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

  Future<void> _resetSettings() async {
    // إظهار حوار تأكيد
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24.sp,
              ),
              8.width,
              Expanded(
                child: Text(
                  S.of(context).resetSettings,
                  style: TextStyles.font16MainColorBold,
                ),
              ),
            ],
          ),
          content: Text(
            S.of(context).resetOriginal,
            style: TextStyles.font14Grey,
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(S.of(context).cancel, style: TextStyles.font14Grey),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.mainColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                S.of(context).reset,
                style: TextStyles.font14WhiteBold,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // إرجاع الإعدادات للحالة الأصلية
      setState(() {
        frequency = 'daily';
        duration = 5;
        reminderTime = const TimeOfDay(hour: 20, minute: 0);
      });

      // حفظ الإعدادات الجديدة
      await CachHelper.saveData(key: 'frequency', value: 'daily');
      await CachHelper.saveData(key: 'duration', value: 5);
      await CachHelper.saveData(key: 'reminder_hour', value: 20);
      await CachHelper.saveData(key: 'reminder_minute', value: 0);

      // تحديث الإشعارات
      await NotificationService().scheduleAdvancedReminders(
        userName: userName,
        frequency: frequency,
        duration: duration,
        reminderTime: reminderTime,
      );

      // إظهار رسالة نجاح
      toast(
        context: context,
        message: 'تم إرجاع الإعدادات بنجاح',
        backgroundColor: Colors.orange,
      );
    }
  }

  Future<void> _saveSettings() async {
    await CachHelper.saveData(key: 'frequency', value: frequency);
    await CachHelper.saveData(key: 'duration', value: duration);
    await CachHelper.saveData(key: 'reminder_hour', value: reminderTime.hour);
    await CachHelper.saveData(
      key: 'reminder_minute',
      value: reminderTime.minute,
    );

    await NotificationService().scheduleAdvancedReminders(
      userName: userName,
      frequency: frequency,
      duration: duration,
      reminderTime: reminderTime,
    );

    toast(
      context: context,
      message: S.of(context).settingsSaved,
      backgroundColor: ColorsManager.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorsManager.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(S.of(context).setting, style: TextStyles.font16WhiteBold),
        backgroundColor: ColorsManager.mainColor,
        actions: [
          // زر إرجاع الإعدادات
          IconButton(
            icon: const Icon(Icons.restore, color: ColorsManager.white),
            onPressed: _resetSettings,
            tooltip: 'إرجاع الإعدادات',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).readingFrequency,
              style: TextStyles.font14MainColorBold,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildFrequencyButton('daily', S.of(context).daily),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFrequencyButton('weekly', S.of(context).weekly),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFrequencyButton(
                    'monthly',
                    S.of(context).monthly,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              S.of(context).sessionDuration,
              style: TextStyles.font14MainColorBold,
            ),
            const SizedBox(height: 10),
            Row(
              spacing: 3.w,
              children: [
                Expanded(child: _buildDurationButton(3)),
                Expanded(child: _buildDurationButton(5)),
                Expanded(child: _buildDurationButton(10)),
                Expanded(child: _buildDurationButton(15)),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              S.of(context).reminderTime,
              style: TextStyles.font14MainColorBold,
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
                  color: ColorsManager.grey.withOpacity(0.1),
                  border: Border.all(
                    color: ColorsManager.grey.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: ColorsManager.mainColor,
                    ),
                    10.width,
                    Text(
                      '${S.of(context).remindMeAt} ${reminderTime.format(context)}',
                      style: TextStyles.font14MainColorBold,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: ColorsManager.mainColor,
                    ),
                  ],
                ),
              ),
            ),
            10.height,
            Row(
              children: [
                Text(
                  S.of(context).changeLanguage,
                  style: TextStyles.font16MainColorBold,
                ),
                const Spacer(),
                Switch(
                  value: context.read<UiCubit>().switchedButton,
                  onChanged: (value) {
                    context.read<UiCubit>().changeLange(switched: value);
                    context.read<UiCubit>().switchedButton = value;
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // زر إرجاع الإعدادات كزر منفصل
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton.icon(
                onPressed: _resetSettings,
                icon: const Icon(
                  Icons.restore,
                  color: ColorsManager.mainColor,
                  size: 25,
                ),
                label: Text(
                  S.of(context).resetOriginalSettings,
                  style: TextStyles.font14MainColorBold,
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: ColorsManager.mainColor.withOpacity(0.5),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.mainColor,
                foregroundColor: ColorsManager.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                S.of(context).saveSettings,
                style: TextStyles.font16WhiteBold,
              ),
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
            ? ColorsManager.mainColor
            : ColorsManager.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(
        label,
        style: isSelected
            ? TextStyles.font12WhiteBold
            : TextStyles.font12MainColorBold,
      ),
    );
  }

  Widget _buildDurationButton(int minutes) {
    bool isSelected = duration == minutes;
    return ElevatedButton(
      onPressed: () => setState(() => duration = minutes),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? ColorsManager.mainColor
            : ColorsManager.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(
        '$minutes ${S.of(context).minutes}',
        textAlign: TextAlign.center,
        style: isSelected
            ? TextStyles.font12WhiteBold
            : TextStyles.font12MainColorBold,
      ),
    );
  }
}
