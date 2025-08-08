// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Let's set up your Quran reading routine`
  String get onboardingTitle {
    return Intl.message(
      'Let\'s set up your Quran reading routine',
      name: 'onboardingTitle',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get thisFieldIsRequired {
    return Intl.message(
      'This field is required',
      name: 'thisFieldIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Put your name`
  String get putYourName {
    return Intl.message(
      'Put your name',
      name: 'putYourName',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get minutes {
    return Intl.message('min', name: 'minutes', desc: '', args: []);
  }

  /// `Reading Frequency:`
  String get readingFrequency {
    return Intl.message(
      'Reading Frequency:',
      name: 'readingFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Dialy`
  String get daily {
    return Intl.message('Dialy', name: 'daily', desc: '', args: []);
  }

  /// `Weekly`
  String get weekly {
    return Intl.message('Weekly', name: 'weekly', desc: '', args: []);
  }

  /// `Monthly`
  String get monthly {
    return Intl.message('Monthly', name: 'monthly', desc: '', args: []);
  }

  /// `Session Duration:`
  String get sessionDuration {
    return Intl.message(
      'Session Duration:',
      name: 'sessionDuration',
      desc: '',
      args: [],
    );
  }

  /// `Reminder Time:`
  String get reminderTime {
    return Intl.message(
      'Reminder Time:',
      name: 'reminderTime',
      desc: '',
      args: [],
    );
  }

  /// `Remind me at`
  String get remindMeAt {
    return Intl.message('Remind me at', name: 'remindMeAt', desc: '', args: []);
  }

  /// `Start My Journey`
  String get startMyJourney {
    return Intl.message(
      'Start My Journey',
      name: 'startMyJourney',
      desc: '',
      args: [],
    );
  }

  /// `Change Language`
  String get changeLanguage {
    return Intl.message(
      'Change Language',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Times`
  String get times {
    return Intl.message('Times', name: 'times', desc: '', args: []);
  }

  /// `Start Reading`
  String get startReading {
    return Intl.message(
      'Start Reading',
      name: 'startReading',
      desc: '',
      args: [],
    );
  }

  /// `Ready for your `
  String get readyForYour {
    return Intl.message(
      'Ready for your ',
      name: 'readyForYour',
      desc: '',
      args: [],
    );
  }

  /// `next minutes?`
  String get nextMinutes {
    return Intl.message(
      'next minutes?',
      name: 'nextMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Next reminder`
  String get nextReminder {
    return Intl.message(
      'Next reminder',
      name: 'nextReminder',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get setting {
    return Intl.message('Settings', name: 'setting', desc: '', args: []);
  }

  /// `Save Settings`
  String get saveSettings {
    return Intl.message(
      'Save Settings',
      name: 'saveSettings',
      desc: '',
      args: [],
    );
  }

  /// `Settings saved! Notifications updated.`
  String get settingsSaved {
    return Intl.message(
      'Settings saved! Notifications updated.',
      name: 'settingsSaved',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
