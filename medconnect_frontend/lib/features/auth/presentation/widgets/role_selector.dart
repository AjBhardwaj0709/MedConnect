import 'package:flutter/material.dart';

enum UserRole { patient, doctor }

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  static const primary = Color(0xFF167D9A);
  static const ink = Color(0xFF17324D);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _roleCard(
            role: UserRole.patient,
            title: 'Patient',
            subtitle: 'Find healthcare',
            icon: Icons.favorite_border_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _roleCard(
            role: UserRole.doctor,
            title: 'Doctor',
            subtitle: 'Provide healthcare',
            icon: Icons.medical_services_outlined,
          ),
        ),
      ],
    );
  }

  Widget _roleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = selectedRole == role;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => onChanged(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDF8FA) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? primary : const Color(0xFFE3EAF0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primary, size: 23),
                const Spacer(),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? primary : Colors.blueGrey,
                  size: 19,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}
