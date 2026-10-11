import 'package:flutter/material.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';

class DoctorPrescriptionsScreen extends StatefulWidget {
  const DoctorPrescriptionsScreen({
    super.key,
    this.patientId = '',
    this.patientName = '',
    this.onSavePrescription,
  });

  final String patientId;
  final String patientName;

  final Future<void> Function(Map<String, dynamic> data)? onSavePrescription;

  @override
  State<DoctorPrescriptionsScreen> createState() =>
      _DoctorPrescriptionsScreenState();
}

class _DoctorPrescriptionsScreenState extends State<DoctorPrescriptionsScreen> {


  final _formKey = GlobalKey<FormState>();
  final _diagnosis = TextEditingController();
  final _notes = TextEditingController();
  final _followUp = TextEditingController();

  final List<_MedicineEntry> _medicines = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _medicines.add(_MedicineEntry());
  }

  @override
  void dispose() {
    _diagnosis.dispose();
    _notes.dispose();
    _followUp.dispose();

    for (final medicine in _medicines) {
      medicine.dispose();
    }

    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  void _addMedicine() {
    setState(() => _medicines.add(_MedicineEntry()));
  }

  void _removeMedicine(int index) {
    if (_medicines.length == 1) {
      _showMessage('At least one medicine entry is required.');
      return;
    }

    setState(() {
      _medicines.removeAt(index).dispose();
    });
  }

  Future<void> _savePrescription() async {
    FocusScope.of(context).unfocus();

    if (widget.patientId.trim().isEmpty) {
      _showMessage('A patient ID is required.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final medicines = <Map<String, dynamic>>[];

    for (final medicine in _medicines) {
      final name = medicine.name.text.trim();
      final dosage = medicine.dosage.text.trim();
      final frequency = medicine.frequency.text.trim();
      final duration = medicine.duration.text.trim();
      final instructions = medicine.instructions.text.trim();

      if (name.isEmpty ||
          dosage.isEmpty ||
          frequency.isEmpty ||
          duration.isEmpty) {
        _showMessage(
          'Complete the medicine name, dosage, frequency and duration.',
        );
        return;
      }

      medicines.add({
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
        'instructions': instructions,
      });
    }

    if (widget.onSavePrescription == null) {
      _showMessage('Prescription API is not connected yet. Nothing was saved.');
      return;
    }

    final data = <String, dynamic>{
      'patientId': widget.patientId,
      'diagnosis': _diagnosis.text.trim(),
      'medicines': medicines,
      'notes': _notes.text.trim(),
      'followUp': _followUp.text.trim(),
    };

    setState(() => _isSaving = true);

    try {
      await widget.onSavePrescription!(data);

      if (!mounted) return;

      _showMessage('Prescription submitted successfully.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not save prescription: $error');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Create Prescription',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _sectionTitle('Patient', 'Prescription recipient'),
              const SizedBox(height: 12),
              _buildPatientCard(),
              const SizedBox(height: 24),
              _sectionTitle(
                'Clinical information',
                'Enter the diagnosis and relevant notes',
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _diagnosis,
                label: 'Diagnosis',
                hint: 'Enter the diagnosis',
                icon: Icons.health_and_safety_outlined,
                validator: (v) => _required(v, 'Diagnosis'),
              ),
              const SizedBox(height: 8),
              _textField(
                controller: _notes,
                label: 'Additional clinical notes',
                hint: 'Enter relevant instructions or notes',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _sectionTitle(
                      'Medicines',
                      'Add prescribed medicine details',
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Add medicine',
                    onPressed: _addMedicine,
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors. primary,
                      backgroundColor: const Color(0xFFDDF2F6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(
                _medicines.length,
                (index) => _buildMedicineCard(index),
              ),
              const SizedBox(height: 16),
              _textField(
                controller: _followUp,
                label: 'Follow-up instructions',
                hint: 'e.g. Follow up after 7 days',
                icon: Icons.event_note_rounded,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5DF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1DEAC)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF936516)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verify every medicine, dosage and instruction '
                        'before issuing the prescription.',
                        style: TextStyle(
                          color: Color(0xFF795619),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _savePrescription,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors. primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.description_outlined),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save prescription',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF167D9A), Color(0xFF205B83)],
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digital prescription',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Record diagnosis, medicines and follow-up details.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.receipt_long_rounded, size: 44, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    final name = widget.patientName.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EDF3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFDDF2F6),
            child: Icon(Icons.person_rounded, color: AppColors. primary, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Patient not selected' : name,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.patientId.isEmpty
                      ? 'Patient ID unavailable'
                      : 'Patient ID: ${widget.patientId}',
                  style: const TextStyle(color: AppColors. muted, fontSize: 11),
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
        Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }

  Widget _buildMedicineCard(int index) {
    final medicine = _medicines[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EDF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Medicine ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove medicine',
                onPressed: () => _removeMedicine(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFB42318),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _textField(
            controller: medicine.name,
            label: 'Medicine name',
            hint: 'Enter medicine name',
            icon: Icons.medication_outlined,
            validator: (v) => _required(v, 'Medicine name'),
          ),
          const SizedBox(height: 8),
          _textField(
            controller: medicine.dosage,
            label: 'Dosage',
            hint: 'e.g. 1 tablet',
            icon: Icons.science_outlined,
            validator: (v) => _required(v, 'Dosage'),
          ),
          const SizedBox(height: 8),
          _textField(
            controller: medicine.frequency,
            label: 'Frequency',
            hint: 'e.g. twice daily',
            icon: Icons.schedule_rounded,
            validator: (v) => _required(v, 'Frequency'),
          ),
          const SizedBox(height: 8),
          _textField(
            controller: medicine.duration,
            label: 'Duration',
            hint: 'e.g. 5 days',
            icon: Icons.calendar_month_outlined,
            validator: (v) => _required(v, 'Duration'),
          ),
          const SizedBox(height: 8),
          _textField(
            controller: medicine.instructions,
            label: 'Medicine instructions',
            hint: 'e.g. Take after food, if prescribed',
            icon: Icons.info_outline_rounded,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.ink, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: const Color(0xFFFAFCFD),
        labelStyle: const TextStyle(color: AppColors. muted, fontSize: 12),
        hintStyle: const TextStyle(color: Color(0xFF9AA8B6), fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5EDF3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5EDF3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color:AppColors. primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  
}

class _MedicineEntry {
  final name = TextEditingController();
  final dosage = TextEditingController();
  final frequency = TextEditingController();
  final duration = TextEditingController();
  final instructions = TextEditingController();

  void dispose() {
    name.dispose();
    dosage.dispose();
    frequency.dispose();
    duration.dispose();
    instructions.dispose();
  }
}
