import 'package:flutter/material.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({
    super.key,
    this.doctorName = 'Doctor',
    this.specialization = 'Medical Professional',
    this.verificationStatus = 'Pending',
  });
  final String doctorName;
  final String specialization;
  final String verificationStatus;

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      const _PlaceholderPage(
        title: 'Appointments',
        subtitle: 'Manage your patient appointments here.',
        icon: Icons.calendar_month_rounded,
      ),
      const _PlaceholderPage(
        title: 'Availability',
        subtitle: 'Manage your working days and time slots.',
        icon: Icons.schedule_rounded,
      ),
      const _PlaceholderPage(
        title: 'My Profile',
        subtitle: 'View and update your professional profile.',
        icon: Icons.person_outline_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDDF2F6),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule_rounded),
            label: 'Availability',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
             _buildHeader(),
              const SizedBox(height: 24),
              _buildWelcomeCard(),
              const SizedBox(height: 22),
              _sectionTitle('Overview', 'Your practice at a glance'),
              const SizedBox(height: 14),
              _buildStatistics(),
              const SizedBox(height: 24),
              _sectionTitle('Quick actions', 'Manage your practice'),
              const SizedBox(height: 14),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _sectionTitle("Today's appointments", 'Your upcoming schedule'),
              const SizedBox(height: 14),
              _buildEmptyAppointments(),
              const SizedBox(height: 24),
              _sectionTitle('Account status', 'Professional verification'),
              const SizedBox(height: 14),
              _buildVerificationCard(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(0xffddf2f6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.medical_services_rounded,
            color: AppColors.primary,
            size: 27,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEDCONNECT',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Doctor workspace',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            _showMessage('Notifications will be connected later.');
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5EDF3)),
          ),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF167D9A), Color(0xFF205B83)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR HEALTHCARE PRACTICE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome, Dr. ${widget.doctorName}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.specialization,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_rounded, color: Colors.white, size: 17),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Your practice, connected.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors. muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: const [
        _StatCard(
          title: 'Total appointments',
          value: '—',
          icon: Icons.calendar_month_rounded,
          color: Color(0xFF167D9A),
        ),
        _StatCard(
          title: "Today's patients",
          value: '—',
          icon: Icons.people_alt_outlined,
          color: Color(0xFF7C63C7),
        ),
        _StatCard(
          title: 'Completed',
          value: '—',
          icon: Icons.check_circle_outline_rounded,
          color: Color(0xFF23875B),
        ),
        _StatCard(
          title: 'Pending',
          value: '—',
          icon: Icons.hourglass_empty_rounded,
          color: Color(0xFFB7791F),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.calendar_month_rounded,
            title: 'Appointments',
            subtitle: 'View schedule',
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAction(
            icon: Icons.access_time_rounded,
            title: 'Availability',
            subtitle: 'Manage hours',
            onTap: () => setState(() => _selectedIndex = 2),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyAppointments() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EDF3)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: AppColors.primary,
            size: 38,
          ),
          SizedBox(height: 12),
          Text(
            'Your schedule will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Connect the appointments API to view real bookings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    final status = widget.verificationStatus.toLowerCase();

    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    final Color statusColor = isApproved
        ? const Color(0xFF23875B)
        : isRejected
            ? const Color(0xFFB42318)
            : const Color(0xFFB7791F);

    final IconData statusIcon = isApproved
        ? Icons.verified_rounded
        : isRejected
            ? Icons.cancel_outlined
            : Icons.hourglass_top_rounded;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EDF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(statusIcon, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doctor verification',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isApproved
                      ? 'Your account is verified.'
                      : isRejected
                          ? 'Your account needs attention.'
                          : 'Your account is awaiting verification.',
                  style: const TextStyle(
                    color: AppColors. muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.verificationStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EDF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 23),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17324D),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF74869A),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5EDF3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF167D9A), size: 25),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF17324D),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF74869A),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 54,
              color: const Color(0xFF167D9A),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17324D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF74869A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


