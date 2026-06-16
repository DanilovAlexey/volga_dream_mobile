import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/next_tour_screen.dart';
import 'services/service_locator.dart';

void main() {
  runApp(VolgaDreamApp());
}

class VolgaDreamApp extends StatelessWidget {
  const VolgaDreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tourService = ServiceLocator.createTourService();
    final cruiseService = ServiceLocator.createCruiseService();

    final raleway = GoogleFonts.ralewayTextTheme();
    final goldenbook = const TextStyle(fontFamily: 'Goldenbook', fontWeight: FontWeight.w400);

    return MaterialApp(
      title: 'Volga Dream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C484C),
          tertiary: const Color(0xFFbbab8e),
        ),
        textTheme: raleway.copyWith(
          displayLarge: goldenbook.copyWith(fontSize: 43, color: const Color(0xFF202024)),
          displayMedium: goldenbook.copyWith(fontSize: 32, color: const Color(0xFF202024)),
          displaySmall: goldenbook.copyWith(fontSize: 28, color: const Color(0xFF202024)),
          headlineLarge: goldenbook.copyWith(fontSize: 24, color: const Color(0xFF202024)),
          headlineMedium: goldenbook.copyWith(fontSize: 20, color: const Color(0xFF202024)),
          headlineSmall: goldenbook.copyWith(fontSize: 18, color: const Color(0xFF202024)),
          titleLarge: goldenbook.copyWith(fontSize: 19, color: const Color(0xFF202024)),
          titleMedium: goldenbook.copyWith(fontSize: 17, color: const Color(0xFF202024)),
          titleSmall: goldenbook.copyWith(fontSize: 16, color: const Color(0xFF202024)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0C484C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.2,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: NextTourScreen(
        tourService: tourService,
        cruiseService: cruiseService,
      ),
    );
  }
}
