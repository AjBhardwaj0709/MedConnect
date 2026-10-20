import 'package:flutter/material.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';

Widget buildSpecializationField({
  required TextEditingController specializationController,
  required bool isEditing,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: DropdownButtonFormField<String>(
        value: _specializations.contains(specializationController.text.trim())
          ? specializationController.text.trim()
          : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Specialization',
        prefixIcon: const Icon(
          Icons.medical_services_outlined,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: isEditing ? Colors.white : const Color(0xFFF0F5F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      hint: const Text('Select specialization'),
      items: _specializations.map((specialization) {
        return DropdownMenuItem<String>(
          value: specialization,
          child: Text(specialization, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: !isEditing
          ? null
          : (value) {
              if (value != null) {
                specializationController.text = value;
              }
            },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a specialization';
        }
        return null;
      },
    ),
  );
}
const List<String> _specializations = [
  'General Physician',
  'Cardiology',
  'Dermatology',
  'Neurology',
  'Orthopedics',
  'Pediatrics',
  'Gynecology',
  'Ophthalmology',
  'Psychiatry',
  'ENT Specialist',
  'Dentistry',
  'Urology',
  'Nephrology',
  'Gastroenterology',
  'Pulmonology',
  'Endocrinology',
  'Oncology',
  'Radiology',
  'Anesthesiology',
  'General Surgery',
  'Physiotherapy',
  'Other',
];

