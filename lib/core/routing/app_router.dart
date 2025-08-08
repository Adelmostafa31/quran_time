import 'package:flutter/material.dart';
import 'package:quran_time/core/routing/routes.dart';
import 'package:quran_time/feature/home/home.dart';
import 'package:quran_time/feature/onboarding/on_boarding.dart';
import 'package:quran_time/feature/reading/reading.dart';
import 'package:quran_time/feature/settings/settings.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    var arg = settings.arguments;
    switch (settings.name) {
      case Routes.intial:
        return MaterialPageRoute(builder: (context) => const Onboarding());
      case Routes.home:
        return MaterialPageRoute(builder: (context) => const Home());
      case Routes.reading:
        var data = arg as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => Reading(duration: data['duration']),
        );
      case Routes.setting:
        return MaterialPageRoute(builder: (context) => const SettingsScreen());
    }
    return null;
  }
}
