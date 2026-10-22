import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';
import 'package:medconnect_frontend/features/auth/presentation/providers/auth_providers.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
   final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;
    final profile = user?.profile ?? <String, dynamic>{};

    final email = user?.email ?? '';
    final name =
        _firstValue(profile, [
          'name',
          'fullName',
          'full_name',
          'patientName',
        ]) ??
        (email.contains('@') ? email.split('@').first : 'Patient');

    final phone =
        _firstValue(profile, ['phone', 'phoneNumber', 'mobile']) ?? 'Not added';

    final gender = _firstValue(profile, ['gender']) ?? 'Not added';
    final age = _firstValue(profile, ['age']) ?? 'Not added';
    final address = _firstValue(profile, ['address', 'city']) ?? 'Not added';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: AppColors. textColor, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 43,
                  backgroundColor: Colors.white,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 32,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email.isEmpty ? 'Email not available' : email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Patient Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Personal Information',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _infoTile(
            icon: Icons.person_outline_rounded,
            title: 'Full Name',
            value: name,
          ),
          _infoTile(
            icon: Icons.email_outlined,
            title: 'Email Address',
            value: email.isEmpty ? 'Not added' : email,
          ),
          _infoTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            value: phone,
          ),
          _infoTile(icon: Icons.cake_outlined, title: 'Age', value: age),
          _infoTile(icon: Icons.wc_outlined, title: 'Gender', value: gender),
          _infoTile(
            icon: Icons.location_on_outlined,
            title: 'Address',
            value: address,
          ),
          const SizedBox(height: 26),
          const Text(
            'Account',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _actionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            onTap: () => _showMessage(
              context,
              'Password management will be connected soon.',
            ),
          ),
          _actionTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () =>
                _showMessage(context, 'Help & Support will be available soon.'),
          ),
          _actionTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            color: Colors.red,
            onTap: () => _confirmLogout(context, ref),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'MedConnect • Your health, our priority',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  static String? _firstValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') {
        return value;
      }
    }
    return null;
  }

  static Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFE4F4FA),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors. muted, fontSize: 12)),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  static Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to log out of MedConnect?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authControllerProvider.notifier).logout();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Unable to log out. Please try again.');
      }
    }
  }
}
