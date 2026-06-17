import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadly/assets/themes/colors.dart';
import 'package:roadly/pages/allyoucando/credits_page.dart';
import 'package:roadly/pages/intro_page.dart';
import 'package:roadly/pages/home/start_page.dart';

void main() {
  // Fix orientation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        '/creditspage': (context) => const CreditsPage(),
      },
      theme: ThemeData(
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: Colors.white, // fond clair façon iOS
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          textStyle: const TextStyle(
            color: Colors.black87, // texte sombre
            fontSize: 13,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          preferBelow: false, // affiche au-dessus si possible
        ),
        // ✅ Thème global pour le BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: RoadlyColors.backgroundLight,
          selectedItemColor: RoadlyColors.primary,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}
