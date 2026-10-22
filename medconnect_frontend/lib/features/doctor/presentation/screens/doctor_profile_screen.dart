import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';
import 'package:medconnect_frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:medconnect_frontend/shared/specialization.dart';

class DoctorProfileScreen extends ConsumerStatefulWidget {
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
    this.initialClinicName = '',
    this.initialLanguages = const [],
    this.verificationStatus = 'pending',
    this.initialProfileImage,
    this.onUploadImage,
    this.onDeleteImage,
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
  final String initialClinicName;
  final List<String> initialLanguages;
  final String verificationStatus;
  final String? initialProfileImage;

  final Future<String?> Function(XFile image)? onUploadImage;
  final Future<void> Function()? onDeleteImage;
  final Future<void> Function(Map<String, dynamic> data)? onSave;

  @override
  ConsumerState<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _specialization;
  late final TextEditingController _qualification;
  late final TextEditingController _registration;
  late final TextEditingController _experience;
  late final TextEditingController _fee;
  late final TextEditingController _address;
  late final TextEditingController _clinicName;

  final ImagePicker _imagePicker = ImagePicker();
  final Set<String> _selectedLanguages = {};

  String? _profileImage;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isImageBusy = false;

  static const List<String> _commonLanguages = [
    'Hindi',
    'English',
    'Haryanvi',
    'Punjabi',
    'Bengali',
    'Marathi',
    'Telugu',
    'Tamil',
    'Gujarati',
    'Kannada',
    'Malayalam',
    'Odia',
    'Assamese',
    'Urdu',
    'Sanskrit',
    'Kashmiri',
    'Konkani',
    'Manipuri',
    'Nepali',
    'Sindhi',
    'Bhojpuri',
    'Maithili',
    'Dogri',
    'Santali',
    'French',
    'Spanish',
    'Arabic',
    'German',
    'Portuguese',
    'Russian',
    'Chinese',
    'Japanese',
    'Korean',
    'Italian',
    'Thai',
    'Turkish',
    'Persian',
    'Swahili',
    'Indonesian',
    'Vietnamese',
  ];

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
    _clinicName = TextEditingController(text: widget.initialClinicName);

    _selectedLanguages.addAll(
      widget.initialLanguages
          .map((language) => language.trim())
          .where((language) => language.isNotEmpty),
    );

    _profileImage = widget.initialProfileImage;
  }

  @override
  void didUpdateWidget(covariant DoctorProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialProfileImage != widget.initialProfileImage) {
      _profileImage = widget.initialProfileImage;
    }
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
    _clinicName.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickAndUploadImage() async {
    if (_isImageBusy || widget.onUploadImage == null) return;

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null || !mounted) return;

      setState(() => _isImageBusy = true);

      final uploadedUrl = await widget.onUploadImage!(image);

      if (!mounted) return;

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() => _profileImage = uploadedUrl);
        _showMessage('Profile photo updated successfully.');
      } else {
        _showMessage('Upload finished, but no image URL was returned.');
      }
    } catch (error) {
      _showMessage('Could not upload profile photo: $error');
    } finally {
      if (mounted) {
        setState(() => _isImageBusy = false);
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    if (_isImageBusy || widget.onDeleteImage == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove profile photo?'),
        content: const Text('Your current profile photo will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isImageBusy = true);

    try {
      await widget.onDeleteImage!();

      if (!mounted) return;

      setState(() => _profileImage = null);
      _showMessage('Profile photo removed successfully.');
    } catch (error) {
      _showMessage('Could not remove profile photo: $error');
    } finally {
      if (mounted) {
        setState(() => _isImageBusy = false);
      }
    }
  }

  Future<void> _selectLanguages() async {
    final temporarySelection = Set<String>.from(_selectedLanguages);
    final searchController = TextEditingController();

    final result = await showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final query = searchController.text.trim().toLowerCase();

            final extraSelected = temporarySelection
                .where((language) => !_commonLanguages.contains(language))
                .toList();

            final filteredLanguages = _commonLanguages
                .where((language) => language.toLowerCase().contains(query))
                .toList();

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Languages spoken',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: 420,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search languages...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController.clear();
                                  setDialogState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF0F5F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${temporarySelection.length} selected',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: filteredLanguages.isEmpty && extraSelected.isEmpty
                          ? const Center(child: Text('No languages found.'))
                          : ListView(
                              children: [
                                for (final language in [
                                  ...extraSelected,
                                  ...filteredLanguages,
                                ])
                                  CheckboxListTile(
                                    value: temporarySelection.contains(
                                      language,
                                    ),
                                    onChanged: (checked) {
                                      setDialogState(() {
                                        if (checked == true) {
                                          temporarySelection.add(language);
                                        } else {
                                          temporarySelection.remove(language);
                                        }
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      language,
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () =>
                      Navigator.pop(dialogContext, temporarySelection),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    searchController.dispose();

    if (!mounted || result == null) return;

    setState(() {
      _selectedLanguages
        ..clear()
        ..addAll(result);
    });
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
      _showMessage('Profile update is not connected.');
      return;
    }

    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'specialization': _specialization.text.trim(),
      'qualification': _qualification.text.trim(),
      'registrationNumber': _registration.text.trim(),
      'experience': experience,
      'consultationFee': fee,
      'clinicName': _clinicName.text.trim(),
      'clinicAddress': _address.text.trim(),
      'languages': _selectedLanguages.toList()..sort(),
    };

    setState(() => _isSaving = true);

    try {
      await widget.onSave!(data);

      if (!mounted) return;

      setState(() => _isEditing = false);
      _showMessage('Profile updated successfully.');
    } catch (error) {
      _showMessage('Could not update profile: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _name.text = widget.initialName;
      _email.text = widget.initialEmail;
      _specialization.text = widget.initialSpecialization;
      _qualification.text = widget.initialQualification;
      _registration.text = widget.initialRegistrationNumber;
      _experience.text = widget.initialExperience.toString();
      _fee.text = widget.initialConsultationFee.toStringAsFixed(0);
      _address.text = widget.initialAddress;
      _clinicName.text = widget.initialClinicName;

      _selectedLanguages
        ..clear()
        ..addAll(widget.initialLanguages);

      _profileImage = widget.initialProfileImage;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.verificationStatus.toLowerCase();
    final approved = status == 'approved';
    final rejected = status == 'rejected';

    final statusColor = approved
        ? const Color(0xFF23875B)
        : rejected
        ? const Color(0xFFB42318)
        : const Color(0xFFB7791F);

    return Scaffold(
      backgroundColor: AppColors.background,
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

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5EDF3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      approved
                          ? Icons.verified_rounded
                          : rejected
                          ? Icons.error_outline_rounded
                          : Icons.hourglass_top_rounded,
                      color: statusColor,
                      size: 30,
                    ),
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
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your professional account status',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.verificationStatus,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                fieldEnabled: false,
              ),
              _field(
                controller: _clinicName,
                label: 'Clinic name',
                icon: Icons.local_hospital_outlined,
              ),
              _field(
                controller: _address,
                label: 'Clinic address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),

              _buildLanguageField(),

              const SizedBox(height: 14),
              _sectionTitle(
                'Professional details',
                'Your qualifications and medical practice',
              ),
              const SizedBox(height: 14),

              buildSpecializationField(
                specializationController: _specialization,
                isEditing: _isEditing,
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
                  onPressed: _isSaving ? null : _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Cancel editing'),
                ),
              ] else
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
                onTap: () =>
                    _showMessage('Password management will be connected soon.'),
              ),
              _actionTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () =>
                    _showMessage('Help & Support will be available soon.'),
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
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
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
        _showMessage('Unable to log out. Please try again.');
      }
    }
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
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 2),
                ),
                child: ClipOval(
                  child: _profileImage != null && _profileImage!.isNotEmpty
                      ? Image.network(
                          _profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            size: 55,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 55,
                          color: Colors.white,
                        ),
                ),
              ),
              if (_isImageBusy)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (_isEditing) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: _isImageBusy || widget.onUploadImage == null
                      ? null
                      : _pickAndUploadImage,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Change photo'),
                ),
                if (_profileImage != null && _profileImage!.isNotEmpty)
                  TextButton.icon(
                    onPressed: _isImageBusy || widget.onDeleteImage == null
                        ? null
                        : _deleteProfileImage,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remove'),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 8),
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

  Widget _buildLanguageField() {
    final sortedLanguages = _selectedLanguages.toList()..sort();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _isEditing ? _selectLanguages : null,
            borderRadius: BorderRadius.circular(15),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Languages spoken',
                prefixIcon: const Icon(
                  Icons.language_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: Icon(
                  _isEditing
                      ? Icons.arrow_drop_down_rounded
                      : Icons.lock_outline_rounded,
                  color: AppColors.muted,
                ),
                filled: true,
                fillColor: _isEditing ? Colors.white : const Color(0xFFF0F5F8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFE5EDF3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFE5EDF3)),
                ),
              ),
              child: sortedLanguages.isEmpty
                  ? const Text(
                      'Select languages',
                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                    )
                  : Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: sortedLanguages.map((language) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F4F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                language,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_isEditing) ...[
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedLanguages.remove(language);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          if (_isEditing)
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 6),
              child: Text(
                'Select one or more languages and search the list.',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
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
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
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
    bool? fieldEnabled,
  }) {
    final isEnabled = fieldEnabled ?? _isEditing;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
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
          prefixIcon: Icon(icon, color: AppColors.primary, size: 21),
          filled: true,
          fillColor: isEnabled ? Colors.white : const Color(0xFFF0F5F8),
          labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
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
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
