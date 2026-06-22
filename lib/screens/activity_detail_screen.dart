import 'package:flutter/material.dart';
import '../models/cruise.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  final DayItinerary day;

  const ActivityDetailScreen({
    super.key,
    required this.activity,
    required this.day,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final _reminderService = ReminderService.instance;
  int? _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final minutes = await _reminderService.getReminderMinutes(widget.activity.id);
    if (mounted) {
      setState(() {
        _selectedMinutes = minutes;
      });
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

  DateTime _parseStartTime() {
    return ReminderService.parseActivityStart(
      widget.day.dayDate,
      widget.activity.timeRange,
    );
  }

  Future<void> _setReminder(int minutesBefore) async {
    final start = _parseStartTime();
    final id = '${widget.activity.id}_$minutesBefore';
    final reminder = Reminder(
      id: id,
      activityId: widget.activity.id,
      activityTitle: widget.activity.title,
      activityStart: start,
      minutesBefore: minutesBefore,
      dayIndex: widget.activity.dayIndex,
    );
    await _reminderService.setReminder(reminder);
    if (mounted) {
      setState(() => _selectedMinutes = minutesBefore);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Напоминание установлено за $minutesBefore мин. до начала'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeReminder() async {
    await _reminderService.removeReminderByActivity(widget.activity.id);
    if (mounted) {
      setState(() => _selectedMinutes = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Напоминание удалено'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                  if (_selectedMinutes != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _removeReminder,
                        icon: const Icon(Icons.notifications_off),
                        label: Text('Напоминание за $_selectedMinutes мин. (отменить)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else
                    _ReminderSelector(onSelect: _setReminder),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Activity get activity => widget.activity;
}

class _ReminderSelector extends StatelessWidget {
  final void Function(int minutes) onSelect;

  const _ReminderSelector({required this.onSelect});

  static const _options = [15, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'НАПОМИНАНИЕ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ..._options.map((minutes) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onSelect(minutes),
                  icon: const Icon(Icons.notifications_active),
                  label: Text('Напомнить за $minutes минут'),
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
            )),
      ],
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
