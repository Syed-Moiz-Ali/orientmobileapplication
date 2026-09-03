import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

enum StaffAttendanceStatus { notPunchedIn, working, onBreak, punchedOut }

class StaffAttendanceState {
  final bool isLoading;
  final bool isSaving;
  final StaffAttendanceStatus status;
  final String punchIn;
  final String punchOut;
  final String breakTime;
  final String workHours;
  final String error;

  const StaffAttendanceState({
    this.isLoading = true,
    this.isSaving = false,
    this.status = StaffAttendanceStatus.notPunchedIn,
    this.punchIn = '',
    this.punchOut = '',
    this.breakTime = '',
    this.workHours = '',
    this.error = '',
  });

  StaffAttendanceState copyWith({
    bool? isLoading,
    bool? isSaving,
    StaffAttendanceStatus? status,
    String? punchIn,
    String? punchOut,
    String? breakTime,
    String? workHours,
    String? error,
  }) => StaffAttendanceState(
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    status: status ?? this.status,
    punchIn: punchIn ?? this.punchIn,
    punchOut: punchOut ?? this.punchOut,
    breakTime: breakTime ?? this.breakTime,
    workHours: workHours ?? this.workHours,
    error: error ?? this.error,
  );
}

class StaffAttendanceNotifier extends Notifier<StaffAttendanceState> {
  ApiClient get _client => ref.read(apiClientProvider);
  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  StaffAttendanceState build() {
    Future.microtask(load);
    return const StaffAttendanceState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = (await _client.get<AttendanceResponse>(
        ApiEndpoints.technicianAttendance,
        queryParams: {'date': _today},
        fromJson: (data) => AttendanceResponse.fromJson(data),
      )).unwrapOrThrow();
      state = _fromResponse(response);
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .e(
            'Could not load staff attendance',
            error: error,
            stackTrace: stackTrace,
          );
      state = state.copyWith(
        isLoading: false,
        isSaving: false,
        error: 'Attendance is unavailable. Check your connection and retry.',
      );
    }
  }

  Future<bool> punchIn() async {
    if (state.status != StaffAttendanceStatus.notPunchedIn) return false;
    state = state.copyWith(isSaving: true, error: '');
    try {
      final response = (await _client.post<AttendanceResponse>(
        ApiEndpoints.attendancePunchIn,
        data: {'date': _today},
        fromJson: (data) => AttendanceResponse.fromJson(data),
      )).unwrapOrThrow();
      state = _fromResponse(response);
      return true;
    } catch (error, stackTrace) {
      _saveFailure(error, stackTrace, 'Punch in failed. Please try again.');
      return false;
    }
  }

  Future<bool> punchOut() async {
    if (state.status != StaffAttendanceStatus.working &&
        state.status != StaffAttendanceStatus.onBreak) {
      return false;
    }
    state = state.copyWith(isSaving: true, error: '');
    try {
      (await _client.post(
        ApiEndpoints.attendancePunchOut,
        data: {'date': _today},
      )).unwrapOrThrow();
      await load();
      return state.status == StaffAttendanceStatus.punchedOut;
    } catch (error, stackTrace) {
      _saveFailure(error, stackTrace, 'Punch out failed. Please try again.');
      return false;
    }
  }

  StaffAttendanceState _fromResponse(AttendanceResponse response) =>
      StaffAttendanceState(
        isLoading: false,
        status: StaffAttendanceStatus.values.firstWhere(
          (status) => status.name == response.status,
          orElse: () => StaffAttendanceStatus.notPunchedIn,
        ),
        punchIn: response.punchIn,
        punchOut: response.punchOut,
        breakTime: response.breakTime,
        workHours: response.workHours,
      );

  void _saveFailure(Object error, StackTrace stackTrace, String message) {
    ref.read(loggerProvider).e(message, error: error, stackTrace: stackTrace);
    state = state.copyWith(isSaving: false, error: message);
  }
}

final staffAttendanceProvider =
    NotifierProvider<StaffAttendanceNotifier, StaffAttendanceState>(
      StaffAttendanceNotifier.new,
    );
