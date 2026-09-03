import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

class OwnerAttendanceRecord {
  final String staffId;
  final String empId;
  final String name;
  final String role;
  final String branch;
  final String date;
  final String status;
  final String punchIn;
  final String punchOut;
  final String breakTime;
  final String workHours;

  const OwnerAttendanceRecord({
    required this.staffId,
    required this.empId,
    required this.name,
    required this.role,
    required this.branch,
    required this.date,
    required this.status,
    required this.punchIn,
    required this.punchOut,
    required this.breakTime,
    required this.workHours,
  });

  factory OwnerAttendanceRecord.fromJson(Map<String, dynamic> json) =>
      OwnerAttendanceRecord(
        staffId: '${json['staffId'] ?? ''}',
        empId: json['empId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        branch: json['branch'] as String? ?? '',
        date: json['date'] as String? ?? '',
        status: json['status'] as String? ?? 'notPunchedIn',
        punchIn: json['punchIn'] as String? ?? '',
        punchOut: json['punchOut'] as String? ?? '',
        breakTime: json['breakTime'] as String? ?? '',
        workHours: json['workHours'] as String? ?? '',
      );
}

class OwnerAttendanceState {
  final bool isLoading;
  final DateTime selectedDate;
  final String roleFilter;
  final String error;
  final List<OwnerAttendanceRecord> records;

  OwnerAttendanceState({
    this.isLoading = true,
    DateTime? selectedDate,
    this.roleFilter = 'all',
    this.error = '',
    this.records = const [],
  }) : selectedDate = selectedDate ?? DateTime.now();

  OwnerAttendanceState copyWith({
    bool? isLoading,
    DateTime? selectedDate,
    String? roleFilter,
    String? error,
    List<OwnerAttendanceRecord>? records,
  }) => OwnerAttendanceState(
    isLoading: isLoading ?? this.isLoading,
    selectedDate: selectedDate ?? this.selectedDate,
    roleFilter: roleFilter ?? this.roleFilter,
    error: error ?? this.error,
    records: records ?? this.records,
  );
}

class OwnerAttendanceNotifier extends Notifier<OwnerAttendanceState> {
  ApiClient get _client => ref.read(apiClientProvider);

  @override
  OwnerAttendanceState build() {
    Future.microtask(load);
    return OwnerAttendanceState();
  }

  List<OwnerAttendanceRecord> get filteredRecords => state.roleFilter == 'all'
      ? state.records
      : state.records
            .where((record) => record.role == state.roleFilter)
            .toList();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final raw = (await _client.get<List<dynamic>>(
        ApiEndpoints.ownerAttendance,
        queryParams: {
          'date': DateFormat('yyyy-MM-dd').format(state.selectedDate),
        },
        fromJson: (data) => data as List<dynamic>,
      )).unwrapOrThrow();
      state = state.copyWith(
        isLoading: false,
        records: raw
            .map(
              (item) => OwnerAttendanceRecord.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .e(
            'Could not load owner attendance',
            error: error,
            stackTrace: stackTrace,
          );
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load attendance. Check your connection and retry.',
      );
    }
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await load();
  }

  void setRoleFilter(String role) => state = state.copyWith(roleFilter: role);
}

final ownerAttendanceProvider =
    NotifierProvider<OwnerAttendanceNotifier, OwnerAttendanceState>(
      OwnerAttendanceNotifier.new,
    );
