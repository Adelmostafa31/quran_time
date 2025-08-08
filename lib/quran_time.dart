import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نور - Quran Timer',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.amiriQuranTextTheme(
          Theme.of(context).textTheme.copyWith(
            displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(fontSize: 18),
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
