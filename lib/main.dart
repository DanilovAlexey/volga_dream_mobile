import 'package:flutter/material.dart';
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

    return MaterialApp(
      title: 'Volga Dream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D4F6E),
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
