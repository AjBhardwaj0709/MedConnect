import 'package:flutter/material.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _filter = 'All';

 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'My Appointments',
          style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor:AppColors. primary,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your healthcare visits',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Keep track of your appointments in one place.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _filterChip('All'),
                _filterChip('Pending'),
                _filterChip('Confirmed'),
                _filterChip('Cancelled'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_emptyState(isPast: false), _emptyState(isPast: true)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final selected = _filter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = label),
        selectedColor: AppColors.primary.withValues(alpha: 0.14),
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? AppColors.primary : const Color(0xFFE2E8F0)),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.muted,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _emptyState({required bool isPast}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFE4F4FA),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                isPast ? Icons.history_rounded : Icons.event_available_rounded,
                size: 50,
                color: AppColors. primary,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              isPast ? 'No past appointments' : 'No upcoming appointments',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isPast
                  ? 'Your completed visits will appear here.'
                  : 'You have no appointments to display yet. '
                        'Book a visit with a doctor when you are ready.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.6),
            ),
            if (!isPast) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Doctor search will be connected soon.'),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors. primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Find a Doctor'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
