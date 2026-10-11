import 'package:flutter/material.dart';
import 'package:medconnect_frontend/app/theme/app_theme.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key, this.onSave});

  final Future<void> Function(Map<String, dynamic> data)? onSave;

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {


  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Set<String> _selectedDays = {
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  };

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  int _slotDuration = 30;
  bool _isSaving = false;

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  String _to24Hour(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  int get _totalSlots {
    final difference = _minutes(_endTime) - _minutes(_startTime);

    if (difference <= 0 || _slotDuration <= 0) return 0;

    return difference ~/ _slotDuration;
  }

  Future<void> _selectTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary:AppColors. primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _saveAvailability() async {
    if (_selectedDays.isEmpty) {
      _showMessage('Please select at least one working day.');
      return;
    }

    if (_minutes(_endTime) <= _minutes(_startTime)) {
      _showMessage('End time must be later than start time.');
      return;
    }

    if (widget.onSave == null) {
      _showMessage(
        'Availability API is not connected yet. Changes are not saved.',
      );
      return;
    }

    final data = <String, dynamic>{
      'days': _days.where(_selectedDays.contains).toList(),
      'startTime': _to24Hour(_startTime),
      'endTime': _to24Hour(_endTime),
      'slotDuration': _slotDuration,
    };

    setState(() => _isSaving = true);

    try {
      await widget.onSave!(data);

      if (!mounted) return;

      _showMessage('Availability saved successfully.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to save availability: $error');
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
        backgroundColor: AppColors. background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Availability',
          style: TextStyle(color: AppColors. ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _sectionTitle(
              'Working days',
              'Choose the days you accept appointments.',
            ),
            const SizedBox(height: 14),
            _buildDaySelector(),
            const SizedBox(height: 24),
            _sectionTitle('Consultation hours', 'Set your daily working time.'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildTimeCard(
                    title: 'START TIME',
                    time: _startTime,
                    icon: Icons.wb_sunny_outlined,
                    onTap: () => _selectTime(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeCard(
                    title: 'END TIME',
                    time: _endTime,
                    icon: Icons.nights_stay_outlined,
                    onTap: () => _selectTime(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle(
              'Appointment slots',
              'Choose the duration of each consultation.',
            ),
            const SizedBox(height: 14),
            _buildSlotSelector(),
            const SizedBox(height: 20),
            _buildSummary(),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveAvailability,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save availability',
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF167D9A), Color(0xFF205B83)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage your schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Set your working days and consultation hours.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.calendar_month_rounded, size: 48, color: Colors.white),
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

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: _days.map((day) {
          final selected = _selectedDays.contains(day);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedDays.remove(day);
                  } else {
                    _selectedDays.add(day);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFE6F4F7) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors. primary : const Color(0xFFE5EDF3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: selected ? AppColors.primary : AppColors.muted,
                      size: 21,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      selected ? 'Working' : 'Off',
                      style: TextStyle(
                        color: selected ? AppColors.primary : AppColors. muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeCard({
    required String title,
    required TimeOfDay time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _formatTime(time),
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.edit_outlined, size: 13, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Change time',
                  style: TextStyle(color: AppColors.primary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotSelector() {
    const durations = [15, 20, 30, 45, 60];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Duration per appointment',
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: durations.map((duration) {
              final selected = duration == _slotDuration;

              return ChoiceChip(
                label: Text('$duration min'),
                selected: selected,
                selectedColor: const Color(0xFFDDF2F6),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color: selected ? AppColors.primary : const Color(0xFFE5EDF3),
                ),
                onSelected: (_) {
                  setState(() => _slotDuration = duration);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule summary',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_selectedDays.length} working day(s) · '
                  '${_formatTime(_startTime)} – ${_formatTime(_endTime)}',
                  style: const TextStyle(color: AppColors.ink, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _totalSlots > 0
                      ? 'Up to $_totalSlots slots per working day'
                      : 'Choose a valid time range to calculate slots.',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
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
