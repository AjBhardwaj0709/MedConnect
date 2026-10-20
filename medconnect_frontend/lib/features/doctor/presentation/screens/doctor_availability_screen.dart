import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medconnect_frontend/app/theme/app_theme.dart';
import 'package:medconnect_frontend/core/network/api_exception.dart';
import 'package:medconnect_frontend/features/doctor/domain/entities/availability.dart';
import 'package:medconnect_frontend/features/doctor/presentation/providers/availability_providers.dart';

class DoctorAvailabilityScreen extends ConsumerStatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  ConsumerState<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState
    extends ConsumerState<DoctorAvailabilityScreen> {
  bool _isSaving = false;


  String _formatTime(String value) {
    final parts = value.split(':');

    if (parts.length != 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return value;

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  bool _isApprovalError(Object error) {
    if (error is ApiException) {
      return error.statusCode == 403 ||
          error.message.toLowerCase().contains('only approved doctors');
    }

    if (error is DioException) {
      final nestedError = error.error;
      if (nestedError is ApiException) {
        return nestedError.statusCode == 403 ||
            nestedError.message.toLowerCase().contains('only approved doctors');
      }

      return error.response?.statusCode == 403 ||
          error.response?.data is Map &&
              (error.response!.data['message']
                      ?.toString()
                      .toLowerCase()
                      .contains('only approved doctors') ??
                  false);
    }

    final message = error.toString().toLowerCase();
    return message.contains('403') || message.contains('only approved doctors');
  }

  String _apiError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    if (error is DioException) {
      final nestedError = error.error;
      if (nestedError is ApiException) {
        return nestedError.message;
      }

      final responseData = error.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }

      if (error.response == null) {
        return 'Unable to connect to the server. Check your network.';
      }

      return 'Request failed with status ${error.response?.statusCode}.';
    }

    return error.toString();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refreshAvailability() async {
    ref.invalidate(doctorAvailabilityProvider);
  }

  Future<void> _openPeriodForm({Availability? existing}) async {
    if (_isSaving) return;

    final result = await showDialog<_AvailabilityFormResult>(
      context: context,
      builder: (dialogContext) {
      return _AvailabilityFormDialog(existing: existing);
      },
    );

    if (result == null || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(availabilityRepositoryProvider);

      if (existing == null) {
        await repository.createAvailability(
          date: result.date,
          startTime: result.startTime,
          endTime: result.endTime,
          slotDuration: result.slotDuration,
        );

        _showMessage('Working period saved successfully.');
      } else {
        await repository.updateAvailability(
          id: existing.id,
        date: result.date,
          startTime: result.startTime,
          endTime: result.endTime,
          slotDuration: result.slotDuration,
          isAvailable: existing.isAvailable,
        );

        _showMessage('Working period updated successfully.');
      }

      ref.invalidate(doctorAvailabilityProvider);
    } catch (error) {
      _showMessage('Unable to save availability: ${_apiError(error)}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deletePeriod(Availability availability) async {
    if (_isSaving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete working period?'),
          content: Text(
            'Delete availability on ${availability.date} '
            '${_formatTime(availability.startTime)} - '
            '${_formatTime(availability.endTime)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    try {
      await ref
          .read(availabilityRepositoryProvider)
          .deleteAvailability(availability.id);

      ref.invalidate(doctorAvailabilityProvider);
      _showMessage('Working period deleted successfully.');
    } catch (error) {
      _showMessage('Unable to delete availability: ${_apiError(error)}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _toggleAvailability(Availability availability) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await ref
          .read(availabilityRepositoryProvider)
          .updateAvailability(
            id: availability.id,
              date: availability.date,
            startTime: availability.startTime,
            endTime: availability.endTime,
            slotDuration: availability.slotDuration,
            isAvailable: !availability.isAvailable,
          );

      ref.invalidate(doctorAvailabilityProvider);

      _showMessage(
        availability.isAvailable
            ? 'Working period disabled.'
            : 'Working period enabled.',
      );
    } catch (error) {
      _showMessage('Unable to update availability: ${_apiError(error)}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
final availabilityAsync = ref.watch(doctorAvailabilityProvider);

    availabilityAsync.when(
      loading: () {
        debugPrint('[AvailabilityScreen] ⏳ Loading availability...');

        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stackTrace) {
        debugPrint('[AvailabilityScreen] ❌ Failed to load availability');
        debugPrint('[AvailabilityScreen] Error: $error');
        debugPrint('[AvailabilityScreen] Stack trace: $stackTrace');

        if (_isApprovalError(error)) {
          debugPrint('[AvailabilityScreen] Doctor approval required.');
          return _buildApprovalRequiredMessage();
        }

        return _buildErrorState(error);
      },
      data: (availability) {
        debugPrint(
          '[AvailabilityScreen] ✅ Loaded ${availability.length} availability records',
        );

        for (final item in availability) {
          debugPrint('[AvailabilityScreen] Record: $item');
        }

        return _buildAvailabilityList(availability);
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Doctor Availability',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh availability',
            onPressed: _isSaving ? null : _refreshAvailability,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.ink),
          ),
        ],
      ),
      floatingActionButton: availabilityAsync.hasValue && !_isSaving
          ? FloatingActionButton.extended(
              onPressed: () => _openPeriodForm(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add period',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            availabilityAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stackTrace) {
                if (_isApprovalError(error)) {
                  return _buildApprovalRequiredMessage();
                }
                return _buildErrorState(error);
              },
              data: (availability) => _buildAvailabilityList(availability),
            ),
            if (_isSaving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.08),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalRequiredMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.admin_panel_settings_outlined,
              size: 72,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Admin Approval Required',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'You cannot create or access your availability '
              'until your doctor account is approved by the admin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please wait for admin approval. You will be able '
              'to manage your availability once your account is approved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.muted,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load availability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _apiError(error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _refreshAvailability,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
  
Widget _buildAvailabilityList(List<Availability> availability) {
    // Use local calendar dates so today's availability remains visible.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Keep only today's and future availability dates.
    final upcoming = availability.where((item) {
      final parsedDate = DateTime.tryParse(item.date);

      if (parsedDate == null) return false;

      final availabilityDate = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      return !availabilityDate.isBefore(today);
    }).toList();

    // Sort by date, then by start time.
    upcoming.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);

      return dateCompare != 0
          ? dateCompare
          : a.startTime.compareTo(b.startTime);
    });

    // Group availability by date.
    final grouped = <String, List<Availability>>{};

    for (final item in upcoming) {
      grouped.putIfAbsent(item.date, () => []).add(item);
    }

    final dateCount = grouped.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        _buildHeader(upcoming.length, dateCount),
        const SizedBox(height: 24),
        _buildSectionTitle(
          'Upcoming availability',
          'Only today’s and future working periods are displayed.',
        ),
        const SizedBox(height: 14),

        if (upcoming.isEmpty) _buildEmptyState(),

        for (final entry in grouped.entries) ...[
          const SizedBox(height: 12),
          _buildDateHeading(entry.key, entry.value.length),
          const SizedBox(height: 10),
          for (final item in entry.value) _buildPeriodCard(item),
        ],

        const SizedBox(height: 20),
        _buildInfoCard(),
      ],
    );
  }

  Widget _buildDateHeading(String date, int count) {
  final parsed = DateTime.parse(date);
  final displayDate =
      '${parsed.day.toString().padLeft(2, '0')}/'
      '${parsed.month.toString().padLeft(2, '0')}/'
      '${parsed.year}';

  return Row(
    children: [
      Expanded(
        child: Text(
          displayDate,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      Text('$count ${count == 1 ? 'period' : 'periods'}'),
    ],
  );
}  Widget _buildHeader(int periodCount, int workingDays) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF167D9A), Color(0xFF205B83)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Manage your schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.calendar_month_rounded, color: Colors.white, size: 38),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Set consultation hours, create appointment slots, '
            'and schedule breaks.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeaderStat('$workingDays', 'Working days'),
              const SizedBox(width: 12),
              _buildHeaderStat('$periodCount', 'Time periods'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }  Widget _buildPeriodCard(Availability item) {
    final slots = item.generatedSlots;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EDF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.isAvailable
                      ? const Color(0xFFE6F4F7)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: item.isAvailable ? AppColors.primary : AppColors.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatTime(item.startTime)} – '
                      '${_formatTime(item.endTime)}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${item.slotDuration} min per appointment',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                enabled: !_isSaving,
                onSelected: (action) {
                  if (action == 'edit') {
                    _openPeriodForm(existing: item);
                  } else if (action == 'toggle') {
                    _toggleAvailability(item);
                  } else if (action == 'delete') {
                    _deletePeriod(item);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 10),
                        Text('Edit period'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          item.isAvailable
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.isAvailable ? 'Disable period' : 'Enable period',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 10),
                        Text('Delete period'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Text(
                '${item.totalSlots} possible slots',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (!item.isAvailable)
                const Text(
                  'Disabled',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (slots.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: slots.map((slot) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: item.isAvailable
                        ? const Color(0xFFE6F4F7)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    _formatTime(slot),
                    style: TextStyle(
                      color: item.isAvailable
                          ? AppColors.primary
                          : AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EDF3)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          SizedBox(height: 14),
          Text(
            'No working periods added',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first period to define when patients '
            'can potentially book appointments.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.5, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add separate periods for morning and afternoon clinics. '
              'Leave a gap between them for lunch or other breaks. '
              'These are potential slots; appointment booking must '
              'check existing bookings before confirming a slot.',
              style: TextStyle(color: AppColors.ink, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityFormResult {
  const _AvailabilityFormResult({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
  });

  final String date;
  final String startTime;
  final String endTime;
  final int slotDuration;
}

class _AvailabilityFormDialog extends StatefulWidget {
  const _AvailabilityFormDialog({this.existing});

  final Availability? existing;


  @override
  State<_AvailabilityFormDialog> createState() =>
      _AvailabilityFormDialogState();
}

class _AvailabilityFormDialogState extends State<_AvailabilityFormDialog> {
 late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _slotDuration;

  static const List<int> _durations = [15, 20, 30, 45, 60];

  @override
  void initState() {
    super.initState();

    final existingDate = widget.existing?.date;

  _date = existingDate != null
      ? DateTime.parse(existingDate)
      : DateTime.now();

  _startTime = _parseTime(widget.existing?.startTime ?? '09:00');
  _endTime = _parseTime(widget.existing?.endTime ?? '12:00');
  _slotDuration = widget.existing?.slotDuration ?? 30;
  }
Future<void> _pickDate() async {
  final now = DateTime.now();

  final picked = await showDatePicker(
    context: context,
    initialDate: _date.isBefore(DateTime(now.year, now.month, now.day))
        ? DateTime(now.year, now.month, now.day)
        : _date,
    firstDate: DateTime(now.year, now.month, now.day),
    lastDate: DateTime(now.year + 2, 12, 31),
  );

  if (picked != null && mounted) {
    setState(() => _date = picked);
  }
}
String _dateString(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}
   

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');

    if (parts.length != 2) {
      return const TimeOfDay(hour: 9, minute: 0);
    }

    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _to24Hour(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  int get _slotCount {
    final difference = _minutes(_endTime) - _minutes(_startTime);

    if (difference <= 0 || _slotDuration <= 0) {
      return 0;
    }

    return difference ~/ _slotDuration;
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
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

  void _save() {
    final start = _minutes(_startTime);
    final end = _minutes(_endTime);

    if (end <= start) {
      _showFormError('End time must be later than start time.');
      return;
    }

    if (end - start < _slotDuration) {
      _showFormError('The working period must fit at least one appointment.');
      return;
    }

    Navigator.of(context).pop(
      _AvailabilityFormResult(
        date: _dateString(_date),
        startTime: _to24Hour(_startTime),
        endTime: _to24Hour(_endTime),
        slotDuration: _slotDuration,
      ),
    );
  }

  void _showFormError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Add working period' : 'Edit working period',
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
const Text(
              'Select date',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  MaterialLocalizations.of(context).formatMediumDate(_date),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Start time',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _pickTime(isStart: true),
                icon: const Icon(Icons.access_time),
                label: Text(_formatTime(_startTime)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'End time',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _pickTime(isStart: false),
                icon: const Icon(Icons.nights_stay_outlined),
                label: Text(_formatTime(_endTime)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Appointment duration',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            DropdownButtonFormField<int>(
              value: _slotDuration,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _durations.map((duration) {
                return DropdownMenuItem(
                  value: duration,
                  child: Text('$duration minutes'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _slotDuration = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_available_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_slotCount possible appointment slots',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save period'),
        ),
      ],
    );
  }
}
