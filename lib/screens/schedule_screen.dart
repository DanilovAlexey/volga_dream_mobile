import 'package:flutter/material.dart';
import '../models/cruise.dart';
import '../services/service_interfaces.dart';
import 'activity_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final String tourName;
  final String scheduleId;
  final ICruiseService cruiseService;
  final INotificationService notificationService;
  final DateTime tourStartDate;

  const ScheduleScreen({
    super.key,
    required this.tourName,
    required this.scheduleId,
    required this.cruiseService,
    required this.notificationService,
    required this.tourStartDate,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  late Future<Cruise> _cruiseFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _cruiseFuture =
        widget.cruiseService.fetchCruise(scheduleId: widget.scheduleId);
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VOLGA DREAM', style: TextStyle(fontFamily: 'Goldenbook')),
            Text(
              widget.tourName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Cruise>(
        future: _cruiseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Не удалось загрузить данные',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _cruiseFuture = widget.cruiseService.fetchCruise(scheduleId: widget.scheduleId);
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          final cruise = snapshot.data!;
          _tabController.dispose();
          _tabController = TabController(
            length: cruise.days.length,
            vsync: this,
          );
          return Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.primary,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: cruise.days.map((day) {
                    return Tab(text: 'День ${day.dayIndex}');
                  }).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: cruise.days.map((day) {
                    return _DayTimeline(
                      day: day,
                      onActivityTap: (activity) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActivityDetailScreen(
                              activity: activity,
                              day: day,
                              notificationService: widget.notificationService,
                              tourStartDate: widget.tourStartDate,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Уведомления',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'О круизе',
          ),
        ],
      ),
    );
  }
}

class _DayTimeline extends StatelessWidget {
  final DayItinerary day;
  final void Function(Activity) onActivityTap;

  const _DayTimeline({
    required this.day,
    required this.onActivityTap,
  });

  Color _colorForType(ActivityType type) {
    switch (type) {
      case ActivityType.lecture:
        return const Color(0xFF3B82F6);
      case ActivityType.excursion:
        return const Color(0xFF10B981);
      case ActivityType.meal:
        return const Color(0xFFF59E0B);
    }
  }

  String _labelForType(ActivityType type) {
    switch (type) {
      case ActivityType.lecture:
        return 'Лекция';
      case ActivityType.excursion:
        return 'Экскурсия';
      case ActivityType.meal:
        return 'Приём пищи';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                '${day.dayIndex} ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.dateLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (day.locationName != null)
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          day.locationName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: day.activities.length,
            itemBuilder: (context, index) {
              final activity = day.activities[index];
              final color = _colorForType(activity.type);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => onActivityTap(activity),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(
                          activity.timeRange.split(' – ').first,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 2),
                              color: Colors.white,
                            ),
                          ),
                          if (index < day.activities.length - 1)
                            Container(
                              width: 2,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(30),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _labelForType(activity.type),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.location_on,
                                      size: 14, color: Colors.grey[400]),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      activity.location,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
