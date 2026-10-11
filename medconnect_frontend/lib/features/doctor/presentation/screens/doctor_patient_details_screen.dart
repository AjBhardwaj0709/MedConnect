import 'package:flutter/material.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';

class DoctorPatientDetailsScreen extends StatefulWidget {
  const DoctorPatientDetailsScreen({
    super.key,
    this.patientId = '',
    this.patientName = 'Patient Name',
    this.email = '',

    this.age,
    this.gender = '',
    this.bloodGroup = '',
    this.address = '',
    this.appointments = const [],
    this.onViewReports,
    this.onCreatePrescription,
    this.onViewAppointment,
  });

  final String patientId;
  final String patientName;
  final String email;
 
  final int? age;
  final String gender;
  final String bloodGroup;
  final String address;

  final List<Map<String, dynamic>> appointments;

  final VoidCallback? onViewReports;
  final VoidCallback? onCreatePrescription;

  final void Function(Map<String, dynamic> appointment)? onViewAppointment;

  @override
  State<DoctorPatientDetailsScreen> createState() =>
      _DoctorPatientDetailsScreenState();
}

class _DoctorPatientDetailsScreenState
    extends State<DoctorPatientDetailsScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor:AppColors. background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Patient Details',
          style: TextStyle(color: AppColors. ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            _buildPatientHeader(),
            const SizedBox(height: 22),
            _sectionTitle(
              'Personal information',
              'Patient contact and basic details',
            ),
            const SizedBox(height: 14),
            _buildPersonalInformation(),
            const SizedBox(height: 24),
            _sectionTitle(
              'Medical workspace',
              'Access clinical records and prescriptions',
            ),
            const SizedBox(height: 14),
            _buildMedicalActions(),
            const SizedBox(height: 24),
            _sectionTitle(
              'Appointment history',
              '${widget.appointments.length} appointment(s)',
            ),
            const SizedBox(height: 14),
            _buildAppointmentHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    final name = widget.patientName.trim();
    final initial = name.isEmpty ? 'P' : name[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF167D9A), Color(0xFF205B83)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name.isEmpty ? 'Patient' : name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            widget.patientId.isEmpty
                ? 'Patient record'
                : 'Patient ID: ${widget.patientId}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _headerInfo(
                  'AGE',
                  widget.age == null ? '—' : '${widget.age} years',
                ),
              ),
              Container(height: 35, width: 1, color: Colors.white30),
              Expanded(
                child: _headerInfo(
                  'GENDER',
                  widget.gender.isEmpty ? '—' : widget.gender,
                ),
              ),
              Container(height: 35, width: 1, color: Colors.white30),
              Expanded(
                child: _headerInfo(
                  'BLOOD GROUP',
                  widget.bloodGroup.isEmpty ? '—' : widget.bloodGroup,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildPersonalInformation() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _informationRow(
            Icons.mail_outline_rounded,
            'Email address',
            widget.email,
          ),
     
          const Divider(height: 25, color: Color(0xFFEAF0F4)),
          _informationRow(
            Icons.location_on_outlined,
            'Address',
            widget.address,
          ),
        ],
      ),
    );
  }

  Widget _informationRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors. primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 5),
              Text(
                value.isEmpty ? 'Not provided' : value,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalActions() {
    return Column(
      children: [
        _medicalAction(
          icon: Icons.folder_open_rounded,
          title: 'Medical reports',
          subtitle: 'View available patient reports',
          onTap: widget.onViewReports,
        ),
        const SizedBox(height: 12),
        _medicalAction(
          icon: Icons.description_outlined,
          title: 'Prescriptions',
          subtitle: 'Create a prescription for this patient',
          onTap: widget.onCreatePrescription,
        ),
      ],
    );
  }

  Widget _medicalAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap:
            onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title screen is not connected yet.')),
              );
            },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5EDF3)),
          ),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.muted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentHistory() {
    if (widget.appointments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: const Column(
          children: [
            Icon(Icons.event_note_rounded, color: AppColors.primary, size: 38),
            SizedBox(height: 12),
            Text(
              'No appointment history',
              style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text(
              'Patient appointments will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: widget.appointments.map((appointment) {
        final date = (appointment['date'] ?? '').toString();
        final status = (appointment['status'] ?? 'Unknown').toString();
        final reason = (appointment['reason'] ?? 'Consultation').toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: _cardDecoration(),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            ),
            title: Text(
              reason,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                date.isEmpty ? status : '$date • $status',
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
            trailing: IconButton(
              tooltip: 'View appointment',
              onPressed: widget.onViewAppointment == null
                  ? null
                  : () => widget.onViewAppointment!(appointment),
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE5EDF3)),
    );
  }
}
