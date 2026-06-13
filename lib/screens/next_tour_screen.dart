import 'package:flutter/material.dart';
import '../models/tour.dart';
import '../services/tour_api_service.dart';
import 'schedule_screen.dart';

class NextTourScreen extends StatefulWidget {
  const NextTourScreen({super.key});

  @override
  State<NextTourScreen> createState() => _NextTourScreenState();
}

class _NextTourScreenState extends State<NextTourScreen> {
  final TourApiService _tourService = TourApiService();
  late Future<TourInfo?> _tourFuture;

  @override
  void initState() {
    super.initState();
    _tourFuture = _tourService.fetchNearestTour(DateTime.now());
  }

  Widget _fallbackIcon(ThemeData theme) {
    return Icon(
      Icons.directions_boat,
      size: 80,
      color: theme.colorScheme.primary,
    );
  }

  String _daysMessage(TourInfo tour) {
    final now = DateTime.now();
    if (now.isBefore(tour.startDate)) {
      final days = tour.daysUntilStart;
      if (days == 0) return 'Тур начинается сегодня!';
      return 'До начала тура осталось $days дн.';
    }
    if (now.isAfter(tour.endDate)) return 'Тур завершён';
    return 'Тур уже идёт';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: FutureBuilder<TourInfo?>(
        future: _tourFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Не удалось загрузить информацию о туре',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _tourFuture =
                              _tourService.fetchNearestTour(DateTime.now());
                          _tourService.dispose();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }
          final tour = snapshot.data;
          if (tour == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Следующий круиз пока не запланирован',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: tour.imageUrl != null
                      ? Image.network(
                          tour.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallbackIcon(theme),
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator()),
                        )
                      : _fallbackIcon(theme),
                ),
                const SizedBox(height: 32),
                Text(
                  'Volga Dream',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Следующий тур',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  tour.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  tour.shipName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _daysMessage(tour),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                  FilledButton.icon(
                    onPressed: () {
                      _tourService.dispose();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ScheduleScreen(tourName: tour.name, scheduleId: tour.scheduleId),
                        ),
                      );
                    },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Подробнее'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
