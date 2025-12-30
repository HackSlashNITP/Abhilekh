import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc({required this.repository}) : super(AttendanceInitial()) {
    on<CheckInRequested>((event, emit) => _handleAttendance(emit, true));
    on<CheckOutRequested>((event, emit) => _handleAttendance(emit, false));
    on<LoadUserStatusRequested>((event, emit) => _loadUserStatus(emit));
  }

  Future<void> _handleAttendance(Emitter<AttendanceState> emit, bool isEntry) async {
    emit(AttendanceLoading());
    try {
      await repository.markAttendance(isEntry: isEntry);
      final newStatus = isEntry ? 'INSIDE' : 'OUTSIDE';
      emit(AttendanceSuccess(
        isEntry ? "Checked In Successfully!" : "Checked Out Successfully!",
        newStatus: newStatus,
      ));
      await _loadUserStatus(emit);
    } catch (e) {
      // Clean error message for UI
      final cleanError = e.toString().replaceAll("Exception: ", "");
      emit(AttendanceFailure(cleanError));
    }
  }

  Future<void> _loadUserStatus(Emitter<AttendanceState> emit) async {
    try {
      final status = await repository.getUserStatus();
      emit(AttendanceLoaded(status));
    } catch (e) {
      final cleanError = e.toString().replaceAll("Exception: ", "");
      emit(AttendanceFailure(cleanError));
    }
  }
}