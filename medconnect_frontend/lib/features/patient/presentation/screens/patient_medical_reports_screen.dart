import 'package:flutter/material.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';

class PatientMedicalReportsScreen extends StatefulWidget {
  const PatientMedicalReportsScreen({super.key});

  @override
  State<PatientMedicalReportsScreen> createState() =>
      _PatientMedicalReportsScreenState();
}

class _PatientMedicalReportsScreenState
    extends State<PatientMedicalReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All Reports';


  final List<String> _categories = [
    'All Reports',
    'Lab Tests',
    'Prescriptions',
    'Scans',
  ];

  @override
  void dispose() {
    _searchController.dispose();
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
          'Medical Reports',
          style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Information',
            onPressed: () => _showInfo(),
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF167D9A), Color(0xFF2358A5)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.folder_shared_rounded,
                    color: Colors.white,
                    size: 43,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Health Records',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Keep your medical documents organized '
                          'and accessible.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search medical reports',
                hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFE8EDF3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFE8EDF3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Report Categories',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 9),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category == _selectedCategory;

                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                  },
                  selectedColor: AppColors. primary.withValues(alpha: 0.13),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 108,
                      width: 108,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4F4FA),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 49,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _searchController.text.trim().isNotEmpty
                          ? 'No matching reports'
                          : 'No medical reports yet',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _searchController.text.trim().isNotEmpty
                          ? 'No reports match your search. '
                                'Try another search term.'
                          : 'Your lab results, scans, and other '
                                'medical documents will appear here '
                                'when they are available.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    if (_selectedCategory != 'All Reports') ...[
                      const SizedBox(height: 12),
                      Text(
                        'Selected: $_selectedCategory',
                        style: const TextStyle(
                          color: AppColors. primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Medical Reports'),
        content: const Text(
          'This section will display your medical reports '
          'retrieved from MedConnect securely. Only authorized '
          'users should be able to access your health records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
