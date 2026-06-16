import 'package:flutter/material.dart';
import '../models/tour.dart';
import '../services/service_interfaces.dart';
import 'schedule_screen.dart';

class NextTourScreen extends StatefulWidget {
  final ITourService tourService;
  final ICruiseService cruiseService;

  const NextTourScreen({
    super.key,
    required this.tourService,
    required this.cruiseService,
  });

  @override
  State<NextTourScreen> createState() => _NextTourScreenState();
}

class _NextTourScreenState extends State<NextTourScreen> {
  late Future<TourInfo?> _tourFuture;

  @override
  void initState() {
    super.initState();
    _tourFuture = widget.tourService.fetchNearestTour(DateTime.now());
  }

  void _retry() {
    setState(() {
      _tourFuture = widget.tourService.fetchNearestTour(DateTime.now());
    });
  }

  void _openSchedule(TourInfo tour) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          tourName: tour.name,
          scheduleId: tour.scheduleId,
          cruiseService: widget.cruiseService,
        ),
      ),
    );
  }

  static const _months = [
    '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];

  String _formatDate(DateTime d) => '${d.day} ${_months[d.month]}';

  String _formatDateRange(DateTime start, DateTime end) {
    if (start.month == end.month && start.year == end.year) {
      return '${start.day} — ${end.day} ${_months[start.month]} ${start.year}';
    }
    return '${_formatDate(start)} ${start.year} — ${_formatDate(end)} ${end.year}';
  }

  Widget _daysBadge(TourInfo tour) {
    final now = DateTime.now();
    String text;
    Color color;
    if (now.isBefore(tour.startDate)) {
      final days = tour.daysUntilStart;
      text = days == 0 ? 'Тур начинается сегодня!' : 'До начала: $days дн.';
      color = Colors.amber;
    } else if (now.isAfter(tour.endDate)) {
      text = 'Тур завершён';
      color = Colors.grey;
    } else {
      text = 'Тур уже идёт';
      color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
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
                      onPressed: _retry,
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
          return _buildHeroLayout(tour, theme);
        },
      ),
    );
  }

  Widget _buildHeroLayout(TourInfo tour, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        tour.imageUrl != null
            ? Image.network(
                tour.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(theme),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator()),
              )
            : _buildFallback(theme),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0xB3000000),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'VOLGA DREAM',
                  style: TextStyle(
                    fontFamily: 'Goldenbook',
                    fontSize: 18,
                    letterSpacing: 2,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                const Spacer(),
                Text(
                  tour.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.directions_boat,
                        size: 18, color: Colors.white.withAlpha(180)),
                    const SizedBox(width: 6),
                    Text(
                      tour.shipName,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateRange(tour.startDate, tour.endDate),
                  style: TextStyle(
                    color: Colors.white.withAlpha(160),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                _daysBadge(tour),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openSchedule(tour),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Подробнее'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.directions_boat,
          size: 80,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
