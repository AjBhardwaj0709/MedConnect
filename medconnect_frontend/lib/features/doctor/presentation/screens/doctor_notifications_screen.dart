
import 'package:flutter/material.dart';

class DoctorNotificationsScreen extends StatefulWidget {
  const DoctorNotificationsScreen({
    super.key,
    this.notifications = const [],
    this.onNotificationTap,
    this.onMarkAllRead,
  });

  // Supported fields:
  // id, title, message, type, time, isRead
  final List<Map<String, dynamic>> notifications;

  final ValueChanged<Map<String, dynamic>>? onNotificationTap;
  final VoidCallback? onMarkAllRead;

  @override
  State<DoctorNotificationsScreen> createState() =>
      _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState
    extends State<DoctorNotificationsScreen> {
  late List<Map<String, dynamic>> _notifications;
  String _filter = 'All';

  final List<String> _filters = [
    'All',
    'Unread',
    'Appointments',
    'System',
  ];

  @override
  void initState() {
    super.initState();

    // Copy the list so local UI changes don't mutate the caller's list.
    _notifications = widget.notifications
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int get _unreadCount => _notifications.where((item) {
        return item['isRead'] != true;
      }).length;

  List<Map<String, dynamic>> get _filteredNotifications {
    return _notifications.where((item) {
      final type = (item['type'] ?? 'system')
          .toString()
          .toLowerCase();

      switch (_filter) {
        case 'Unread':
          return item['isRead'] != true;
        case 'Appointments':
          return type == 'appointment';
        case 'System':
          return type == 'system';
        default:
          return true;
      }
    }).toList();
  }

  void _markRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _markAllRead() {
    setState(() {
      for (final item in _notifications) {
        item['isRead'] = true;
      }
    });

    widget.onMarkAllRead?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
      ),
    );
  }

  void _openNotification(Map<String, dynamic> notification) {
    final id = notification['id'];

    final index = _notifications.indexWhere(
      (item) => item['id'] == id,
    );

    if (index != -1) {
      _markRead(index);
    }

    widget.onNotificationTap?.call(notification);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _typeIcon(
                    (notification['type'] ?? 'system').toString(),
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      (notification['title'] ?? 'Notification')
                          .toString(),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16324F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                (notification['message'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                (notification['time'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleNotifications = _filteredNotifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF16324F),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF087F8C),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(),
          _buildFilters(),
          Expanded(
            child: visibleNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      24,
                    ),
                    itemCount: visibleNotifications.length,
                    itemBuilder: (context, index) {
                      final notification =
                          visibleNotifications[index];

                      return _buildNotificationCard(
                        notification,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087F8C),
            Color(0xFF13A89E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay up to date',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _unreadCount == 0
                      ? 'You are all caught up!'
                      : 'You have $_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _filter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) {
              setState(() => _filter = filter);
            },
            selectedColor: const Color(0xFFD8F3F0),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected
                  ? const Color(0xFF087F8C)
                  : Colors.black54,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            side: BorderSide(
              color: selected
                  ? const Color(0xFF087F8C)
                  : const Color(0xFFE9EEF4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
  ) {
    final isRead = notification['isRead'] == true;
    final type = (notification['type'] ?? 'system').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFEEFAF8),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: isRead
              ? const Color(0xFFE9EEF4)
              : const Color(0xFFBDE8E1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => _openNotification(notification),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _typeIcon(type),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            (notification['title'] ??
                                    'Notification')
                                .toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: const Color(0xFF16324F),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            height: 8,
                            width: 8,
                            margin: const EdgeInsets.only(
                              left: 8,
                              top: 5,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF087F8C),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (notification['message'] ?? '').toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      (notification['time'] ?? '').toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeIcon(String type, {double size = 23}) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return Icon(
          Icons.calendar_month_outlined,
          color: const Color(0xFF087F8C),
          size: size,
        );
      case 'prescription':
        return Icon(
          Icons.medication_outlined,
          color: Colors.deepPurple,
          size: size,
        );
      case 'payment':
        return Icon(
          Icons.currency_rupee_rounded,
          color: Colors.green,
          size: size,
        );
      default:
        return Icon(
          Icons.info_outline_rounded,
          color: Colors.orange.shade700,
          size: size,
        );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFDDF4F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: Color(0xFF087F8C),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No notifications found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16324F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'New updates will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
