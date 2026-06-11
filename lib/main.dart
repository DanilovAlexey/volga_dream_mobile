import 'package:flutter/material.dart';
import 'screens/next_tour_screen.dart';

void main() {
  runApp(const VolgaDreamApp());
}

class VolgaDreamApp extends StatelessWidget {
  const VolgaDreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volga Dream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D4F6E),
        ),
        useMaterial3: true,
      ),
      home: const NextTourScreen(),
    );
  }
}
