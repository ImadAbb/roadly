import 'package:flutter/material.dart';
import 'package:roadly/pages/credits_page.dart';
import 'package:roadly/pages/intro_page.dart';
import 'package:roadly/pages/start_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroPage(),
      routes: {
        '/instropage': (context) => const IntroPage(),
        '/startpage': (context) => const StartPage(),
        '/creditspage':(context) => const CreditsPage(),
      },
    );
  }
}
