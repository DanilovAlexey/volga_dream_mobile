import 'package:flutter/material.dart';
import '../models/cruise.dart';
import '../services/service_interfaces.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;
  final DayItinerary day;
  final INotificationService notificationService;
  final DateTime tourStartDate;

  const ActivityDetailScreen({
    super.key,
    required this.activity,
    required this.day,
    required this.notificationService,
    required this.tourStartDate,
  });

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

  IconData _iconForType(ActivityType type) {
    switch (type) {
      case ActivityType.lecture:
        return Icons.menu_book;
      case ActivityType.excursion:
        return Icons.directions_walk;
      case ActivityType.meal:
        return Icons.restaurant;
    }
  }

  DateTime _computeActivityStart() {
    final base = DateTime(
      tourStartDate.year,
      tourStartDate.month,
      tourStartDate.day,
    );
    final activityDate = base.add(Duration(days: activity.dayIndex - 1));
    final timeParts = activity.timeRange.split(' – ').first.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return DateTime(
      activityDate.year,
      activityDate.month,
      activityDate.day,
      hour,
      minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withAlpha(160),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _iconForType(activity.type),
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _labelForType(activity.type),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            'День ${activity.dayIndex}',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            activity.timeRange,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ОПИСАНИЕ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (activity.lecturer != null) ...[
                    _InfoRow(
                      icon: Icons.person,
                      label: 'Лектор',
                      value: activity.lecturer!,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'Место проведения',
                    value: activity.location,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Время',
                    value: activity.timeRange,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final startTime = _computeActivityStart();
                        final scheduled =
                            await notificationService.scheduleReminder(
                          activityId: activity.id,
                          title: activity.title,
                          body:
                              'Мероприятие начнётся через 15 минут в ${activity.timeRange.split(' – ').first}',
                          startTime: startTime,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              scheduled
                                  ? 'Уведомление установлено за 15 минут до начала'
                                  : 'Мероприятие уже началось',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Напомнить за 15 минут'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        notificationService.showTestNotification();
                      },
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Тест уведомления'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
