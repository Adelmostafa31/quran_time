import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_time/core/helper/cach_helper.dart';
import 'package:quran_time/core/helper/constant.dart';
import 'package:quran_time/core/helper/extentions.dart';
import 'package:quran_time/core/helper/notification_services.dart';
import 'package:quran_time/core/routing/routes.dart';
import 'package:quran_time/core/theming/colors.dart';
import 'package:quran_time/core/theming/styles.dart';
import 'package:quran_time/feature/onboarding/custom_form_field.dart';
import 'package:quran_time/generated/l10n.dart';
import 'package:quran_time/global_manager/ui_cubit.dart';

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
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً - Welcome', style: TextStyles.font16WhiteBold),
        backgroundColor: ColorsManager.mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomFormField(
                controller: nameController,
                prefixIcon: const Icon(
                  Icons.person_2,
                  color: ColorsManager.mainColor,
                ),
                hint: S.of(context).putYourName,
                validator: Constant.normalValidator(context: context),
              ),
              20.height,
              Text(
                S.of(context).readingFrequency,
                style: TextStyles.font14MainColorBold,
              ),
              10.height,
              Row(
                children: [
                  Expanded(
                    child: _buildFrequencyButton('daily', S.of(context).daily),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFrequencyButton(
                      'weekly',
                      S.of(context).weekly,
                    ),
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
              20.height,
              Text(
                S.of(context).sessionDuration,
                style: TextStyles.font14MainColorBold,
              ),
              10.height,
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
              20.height,
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
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _savePreferences();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  S.of(context).startMyJourney,
                  style: TextStyles.font16WhiteBold,
                ),
              ),
            ],
          ),
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
    bool isSelected = selectedDuration == minutes;
    return ElevatedButton(
      onPressed: () => setState(() => selectedDuration = minutes),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? ColorsManager.mainColor
            : ColorsManager.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(
        '$minutes ${S.of(context).minutes}',
        style: isSelected
            ? TextStyles.font12WhiteBold
            : TextStyles.font12MainColorBold,
      ),
    );
  }

  Future<void> _savePreferences() async {
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
