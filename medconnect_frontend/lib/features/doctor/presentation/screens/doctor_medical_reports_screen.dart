import 'package:flutter/material.dart';

class DoctorMedicalReportsScreen extends StatefulWidget {
  const DoctorMedicalReportsScreen({
    super.key,
    this.patientId = '',
    this.patientName = '',
    this.reports = const [],
    this.onOpenReport,
  });

  final String patientId;
  final String patientName;

  // Each report can contain:
  // id, title, category, date, fileType, status, description
  final List<Map<String, dynamic>> reports;

  // Connect this callback to your API or file viewer later.
  final Future<void> Function(Map<String, dynamic> report)? onOpenReport;

  @override
  State<DoctorMedicalReportsScreen> createState() =>
      _DoctorMedicalReportsScreenState();
}

class _DoctorMedicalReportsScreenState
    extends State<DoctorMedicalReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Blood Test',
    'Imaging',
    'Prescription',
    'Other',
  ];

  List<Map<String, dynamic>> get _filteredReports {
    final query = _searchController.text.trim().toLowerCase();

    return widget.reports.where((report) {
      final title = (report['title'] ?? '').toString().toLowerCase();
      final category = (report['category'] ?? 'Other').toString();

      final matchesSearch =
          title.contains(query) || category.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'All' ||
          category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openReport(Map<String, dynamic> report) async {
    if (widget.onOpenReport == null) {
      _showMessage('Report viewer is not connected to the backend yet.');
      return;
    }

    try {
      await widget.onOpenReport!(report);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Unable to open report. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final reports = _filteredReports;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text(
          'Medical Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF16324F),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPatientHeader(),
            _buildSearchField(),
            _buildCategoryFilters(),
            Expanded(
              child: reports.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        return _buildReportCard(reports[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087F8C), Color(0xFF13A89E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.folder_shared_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Medical Records',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.patientName.isEmpty
                      ? 'All Patient Reports'
                      : widget.patientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.patientId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Patient ID: ${widget.patientId}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search reports...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF087F8C)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
              });
            },
            selectedColor: const Color(0xFFD8F3F0),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? const Color(0xFF087F8C) : Colors.black54,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: selected ? const Color(0xFF087F8C) : Colors.transparent,
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final title = (report['title'] ?? 'Untitled Report').toString();
    final category = (report['category'] ?? 'Other').toString();
    final date = (report['date'] ?? 'Date unavailable').toString();
    final fileType = (report['fileType'] ?? 'FILE').toString().toUpperCase();
    final status = (report['status'] ?? 'Available').toString();
    final description = (report['description'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F5F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getReportIcon(category),
                  color: const Color(0xFF087F8C),
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16324F),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Date: $date',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fileType,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF526579),
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: status.toLowerCase() == 'available'
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openReport(report),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View report'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF087F8C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFE4F5F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_outlined,
                size: 44,
                color: Color(0xFF087F8C),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No medical reports found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16324F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.reports.isEmpty
                  ? 'Patient reports will appear here when they are available.'
                  : 'Try changing your search or selected category.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getReportIcon(String category) {
    switch (category.toLowerCase()) {
      case 'blood test':
        return Icons.bloodtype_outlined;
      case 'imaging':
        return Icons.image_search_outlined;
      case 'prescription':
        return Icons.medication_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}
