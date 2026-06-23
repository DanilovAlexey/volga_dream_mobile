import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cruise.dart';
import '../models/cruise_info.dart';
import '../models/reminder.dart';
import '../services/service_interfaces.dart';
import '../services/reminder_service.dart';
import '../services/service_locator.dart';
import 'activity_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final String tourName;
  final String scheduleId;
  final ICruiseService cruiseService;

  const ScheduleScreen({
    super.key,
    required this.tourName,
    required this.scheduleId,
    required this.cruiseService,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  late Future<Cruise> _cruiseFuture;
  late TabController _tabController;
  int _currentTab = 0;
  final _reminderService = ReminderService.instance;
  final _aboutCruiseService = ServiceLocator.createAboutCruiseService();

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
    _aboutCruiseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _currentTab == 0
          ? AppBar(
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
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : AppBar(
              title: Text(
                _currentTab == 1 ? 'Уведомления' : 'О круизе',
                style: const TextStyle(fontFamily: 'Goldenbook'),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        selectedItemColor: theme.colorScheme.primary,
        onTap: (index) {
          setState(() => _currentTab = index);
        },
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

  Widget _buildBody() {
    if (_currentTab == 1) {
      return _NotificationsTab(reminderService: _reminderService);
    }
    if (_currentTab == 2) {
      return _AboutTab(
        aboutCruiseService: _aboutCruiseService,
        scheduleId: widget.scheduleId,
      );
    }
    return _buildScheduleTab();
  }

  Widget _buildScheduleTab() {
    return FutureBuilder<Cruise>(
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
    );
  }
}

class _NotificationsTab extends StatefulWidget {
  final ReminderService reminderService;

  const _NotificationsTab({required this.reminderService});

  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  late Future<List<Reminder>> _remindersFuture;

  @override
  void initState() {
    super.initState();
    _remindersFuture = widget.reminderService.getReminders();
  }

  void _reload() {
    setState(() {
      _remindersFuture = widget.reminderService.getReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Reminder>>(
      future: _remindersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reminders = snapshot.data ?? [];
        if (reminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Нет установленных напоминаний',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Откройте расписание и нажмите на событие,\nчтобы установить напоминание',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    await widget.reminderService.showTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Тестовое уведомление отправлено'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.bug_report, size: 18),
                  label: const Text('Тест уведомления'),
                ),
              ],
            ),
          );
        }
        final sorted = List<Reminder>.from(reminders)
          ..sort((a, b) => a.notifyAt.compareTo(b.notifyAt));
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await widget.reminderService.showTestNotification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Тестовое уведомление отправлено'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.bug_report, size: 16),
                    label: const Text('Тест уведомления'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
              ...sorted.map((r) {
                final past = r.notifyAt.isBefore(DateTime.now());
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        past ? Icons.notifications_off_outlined : Icons.notifications_active,
                        color: past ? Colors.grey : theme.colorScheme.primary,
                      ),
                      title: Text(
                        r.activityTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: past ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDate(r.notifyAt)} ${_formatTime(r.notifyAt)} · День ${r.dayIndex} · за ${r.minutesBefore} мин.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                        onPressed: () async {
                          await widget.reminderService.removeReminder(r.id);
                          _reload();
                        },
                      ),
                    ),
                    if (r != sorted.last) const Divider(height: 1),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m';
  }
}

class _AboutTab extends StatefulWidget {
  final IAboutCruiseService aboutCruiseService;
  final String scheduleId;

  const _AboutTab({
    required this.aboutCruiseService,
    required this.scheduleId,
  });

  @override
  State<_AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<_AboutTab> {
  late Future<CruiseInfo> _infoFuture;

  @override
  void initState() {
    super.initState();
    _infoFuture = widget.aboutCruiseService.fetchAboutCruise(
      scheduleId: widget.scheduleId,
    );
  }

  void _retry() {
    setState(() {
      _infoFuture = widget.aboutCruiseService.fetchAboutCruise(
        scheduleId: widget.scheduleId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<CruiseInfo>(
      future: _infoFuture,
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
                  'Не удалось загрузить информацию о круизе',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                ),
              ],
            ),
          );
        }
        final info = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.direction,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    info.duration,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  if (info.priceFrom != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      info.priceFrom!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Text(
                info.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              if (info.highlights.isNotEmpty) ...[
                Text(
                  'ВСЁ ВКЛЮЧЕНО',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...info.highlights.map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle,
                            size: 18, color: theme.colorScheme.tertiary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            h,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openUrl(context, info.externalUrl),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('ПОДРОБНЕЕ НА САЙТЕ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
