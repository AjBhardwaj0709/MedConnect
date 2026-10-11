import 'package:flutter/material.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({
    super.key,
    this.initialName = '',
    this.initialEmail = '',

    this.initialSpecialization = '',
    this.initialQualification = '',
    this.initialRegistrationNumber = '',
    this.initialExperience = 0,
    this.initialConsultationFee = 0,
    this.initialAddress = '',
    this.verificationStatus = 'Pending',
    this.onSave,
  });

  final String initialName;
  final String initialEmail;

  final String initialSpecialization;
  final String initialQualification;
  final String initialRegistrationNumber;
  final int initialExperience;
  final double initialConsultationFee;
  final String initialAddress;
  final String verificationStatus;

  final Future<void> Function(Map<String, dynamic> data)? onSave;

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {


  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _email;

  late final TextEditingController _specialization;
  late final TextEditingController _qualification;
  late final TextEditingController _registration;
  late final TextEditingController _experience;
  late final TextEditingController _fee;
  late final TextEditingController _address;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.initialName);
    _email = TextEditingController(text: widget.initialEmail);

    _specialization = TextEditingController(text: widget.initialSpecialization);
    _qualification = TextEditingController(text: widget.initialQualification);
    _registration = TextEditingController(
      text: widget.initialRegistrationNumber,
    );
    _experience = TextEditingController(
      text: widget.initialExperience.toString(),
    );
    _fee = TextEditingController(
      text: widget.initialConsultationFee.toStringAsFixed(0),
    );
    _address = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();

    _specialization.dispose();
    _qualification.dispose();
    _registration.dispose();
    _experience.dispose();
    _fee.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final experience = int.tryParse(_experience.text.trim());
    final fee = double.tryParse(_fee.text.trim());

    if (experience == null || experience < 0) {
      _showMessage('Enter valid years of experience.');
      return;
    }

    if (fee == null || fee < 0) {
      _showMessage('Enter a valid consultation fee.');
      return;
    }

    if (widget.onSave == null) {
      _showMessage(
        'Profile API is not connected yet. Your changes are not saved.',
      );
      return;
    }

    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'email': _email.text.trim(),
     
      'specialization': _specialization.text.trim(),
      'qualification': _qualification.text.trim(),
      'registrationNumber': _registration.text.trim(),
      'experience': experience,
      'consultationFee': fee,
      'address': _address.text.trim(),
    };

    setState(() => _isSaving = true);

    try {
      await widget.onSave!(data);

      if (!mounted) return;

      setState(() => _isEditing = false);
      _showMessage('Profile updated successfully.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not update profile: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final approved = widget.verificationStatus.toLowerCase() == 'approved';

    return Scaffold(
      backgroundColor:AppColors. background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My Profile',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              tooltip: 'Edit profile',
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 22),
              _buildVerificationCard(approved),
              const SizedBox(height: 24),

              _sectionTitle(
                'Personal information',
                'Your basic contact details',
              ),
              const SizedBox(height: 14),

              _field(
                controller: _name,
                label: 'Full name',
                icon: Icons.person_outline_rounded,
                validator: (v) => _required(v, 'Full name'),
              ),
              _field(
                controller: _email,
                label: 'Email address',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(v.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
             
              _field(
                controller: _address,
                label: 'Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 14),
              _sectionTitle(
                'Professional details',
                'Your medical qualifications and practice',
              ),
              const SizedBox(height: 14),

              _field(
                controller: _specialization,
                label: 'Specialization',
                icon: Icons.medical_services_outlined,
                validator: (v) => _required(v, 'Specialization'),
              ),
              _field(
                controller: _qualification,
                label: 'Qualification',
                icon: Icons.school_outlined,
                validator: (v) => _required(v, 'Qualification'),
              ),
              _field(
                controller: _registration,
                label: 'Medical registration number',
                icon: Icons.badge_outlined,
                validator: (v) => _required(v, 'Registration number'),
              ),
              _field(
                controller: _experience,
                label: 'Years of experience',
                icon: Icons.work_outline_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = int.tryParse(v?.trim() ?? '');
                  if (value == null || value < 0) {
                    return 'Enter valid years of experience';
                  }
                  return null;
                },
              ),
              _field(
                controller: _fee,
                label: 'Consultation fee (₹)',
                icon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null || value < 0) {
                    return 'Enter a valid consultation fee';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              if (_isEditing) ...[
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save changes',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() => _isEditing = false);
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Cancel editing'),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit professional profile'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final displayName = _name.text.trim().isEmpty
        ? 'Doctor'
        : _name.text.trim();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF167D9A), Color(0xFF205B83)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70, width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _specialization.text.trim().isEmpty
                ? 'Medical Professional'
                : _specialization.text.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'MEDCONNECT DOCTOR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(bool approved) {
    final rejected = widget.verificationStatus.toLowerCase() == 'rejected';

    final color = approved
        ? const Color(0xFF23875B)
        : rejected
        ? const Color(0xFFB42318)
        : const Color(0xFFB7791F);

    final icon = approved
        ? Icons.verified_rounded
        : rejected
        ? Icons.error_outline_rounded
        : Icons.hourglass_top_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EDF3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification status',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your professional account status',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.verificationStatus,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
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
        Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors. primary, size: 21),
          filled: true,
          fillColor: _isEditing ? Colors.white : const Color(0xFFF0F5F8),
          labelStyle: const TextStyle(color: AppColors. muted, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE5EDF3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE5EDF3)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE5EDF3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors. primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
