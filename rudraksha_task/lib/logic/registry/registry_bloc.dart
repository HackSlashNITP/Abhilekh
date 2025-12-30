import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/services/wifi_services.dart';
import '../../data/repositories/registry_repository.dart';
import '../../data/models/StudentModel.dart';
import '../../data/models/RegistryLog.dart';

/// --------------------
/// Events
/// --------------------
abstract class RegistryEvent extends Equatable {
  const RegistryEvent();

  @override
  List<Object?> get props => [];
}

class CheckConnectivity extends RegistryEvent {
  const CheckConnectivity();
}

class LogEntry extends RegistryEvent {
  final String studentId;

  const LogEntry(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LogExit extends RegistryEvent {
  final String studentId;

  const LogExit(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class FetchStudentProfile extends RegistryEvent {
  final String studentId;

  const FetchStudentProfile(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class FetchRegistryHistory extends RegistryEvent {
  final String? studentId;

  const FetchRegistryHistory({this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class FetchOutsideStudents extends RegistryEvent {
  const FetchOutsideStudents();
}

/// --------------------
/// States
/// --------------------
abstract class RegistryState extends Equatable {
  const RegistryState();

  @override
  List<Object?> get props => [];
}

class RegistryInitial extends RegistryState {
  const RegistryInitial();
}

class RegistryLoading extends RegistryState {
  const RegistryLoading();
}

class ConnectivityChecked extends RegistryState {
  final bool isConnected;
  final String? message;

  const ConnectivityChecked({
    required this.isConnected,
    this.message,
  });

  @override
  List<Object?> get props => [isConnected, message];
}

class EntryLogged extends RegistryState {
  final String studentId;
  final String message;

  const EntryLogged({
    required this.studentId,
    required this.message,
  });

  @override
  List<Object?> get props => [studentId, message];
}

class ExitLogged extends RegistryState {
  final String studentId;
  final String message;

  const ExitLogged({
    required this.studentId,
    required this.message,
  });

  @override
  List<Object?> get props => [studentId, message];
}

class StudentProfileLoaded extends RegistryState {
  final Student student;

  const StudentProfileLoaded(this.student);

  @override
  List<Object?> get props => [student];
}

class RegistryHistoryLoaded extends RegistryState {
  final List<RegistryLog> logs;

  const RegistryHistoryLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class OutsideStudentsLoaded extends RegistryState {
  final List<Student> students;

  const OutsideStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class RegistryError extends RegistryState {
  final String message;

  const RegistryError(this.message);

  @override
  List<Object?> get props => [message];
}

/// --------------------
/// BLoC
/// --------------------
class RegistryBloc extends Bloc<RegistryEvent, RegistryState> {
  final WifiService wifiService;
  final RegistryRepository registryRepository;

  RegistryBloc({
    required this.wifiService,
    required this.registryRepository,
  }) : super(const RegistryInitial()) {
    on<CheckConnectivity>(_onCheckConnectivity);
    on<LogEntry>(_onLogEntry);
    on<LogExit>(_onLogExit);
    on<FetchStudentProfile>(_onFetchStudentProfile);
    on<FetchRegistryHistory>(_onFetchRegistryHistory);
    on<FetchOutsideStudents>(_onFetchOutsideStudents);
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<RegistryState> emit,
  ) async {
    emit(const RegistryLoading());

    try {
      final bool isConnected = await wifiService.isConnectedToCollegeWifi();

      emit(ConnectivityChecked(
        isConnected: isConnected,
        message: isConnected
            ? 'Connected to college WiFi'
            : 'Not connected to college WiFi',
      ));
    } catch (e) {
      emit(RegistryError('Error checking connectivity: ${e.toString()}'));
    }
  }

  Future<void> _onLogEntry(
    LogEntry event,
    Emitter<RegistryState> emit,
  ) async {
    emit(const RegistryLoading());

    try {
      //check WiFi connectivity
      final bool isConnected = await wifiService.isConnectedToCollegeWifi();

      if (!isConnected) {
        emit(const RegistryError(
          'Cannot log entry: Not connected to college WiFi',
        ));
        return;
      }

      // If connected, proceed with logging entry
      await registryRepository.logEntry(event.studentId);

      emit(EntryLogged(
        studentId: event.studentId,
        message: 'Entry logged successfully',
      ));
    } catch (e) {
      emit(RegistryError('Error logging entry: ${e.toString()}'));
    }
  }

  Future<void> _onLogExit(
    LogExit event,
    Emitter<RegistryState> emit,
  ) async {
    emit(const RegistryLoading());

    try {
      // check WiFi connectivity
      final bool isConnected = await wifiService.isConnectedToCollegeWifi();

      if (!isConnected) {
        emit(const RegistryError(
          'Cannot log exit: Not connected to college WiFi',
        ));
        return;
      }

      // If connected, proceed with logging exit
      await registryRepository.logExit(event.studentId);

      emit(ExitLogged(
        studentId: event.studentId,
        message: 'Exit logged successfully',
      ));
    } catch (e) {
      emit(RegistryError('Error logging exit: ${e.toString()}'));
    }
  }

  Future<void> _onFetchStudentProfile(
    FetchStudentProfile event,
    Emitter<RegistryState> emit,
  ) async {
    emit(const RegistryLoading());

    try {
      final Student student = await registryRepository.getStudentProfile(
        event.studentId,
      );

      emit(StudentProfileLoaded(student));
    } catch (e) {
      emit(RegistryError('Error fetching student profile: ${e.toString()}'));
    }
  }

  Future<void> _onFetchRegistryHistory(
    FetchRegistryHistory event,
    Emitter<RegistryState> emit,
  ) async {
    emit(const RegistryLoading());

    try {
      final List<RegistryLog> logs = await registryRepository.getRegistryHistory(
        studentId: event.studentId,
      );

      emit(RegistryHistoryLoaded(logs));
    } catch (e) {
      emit(RegistryError('Error fetching registry history: ${e.toString()}'));
    }
  }

  Future<void> _onFetchOutsideStudents(
    FetchOutsideStudents event,
    Emitter<RegistryState> emit,
  ) async {
    emit(const RegistryLoading());

    try {
      final List<Student> students =
          await registryRepository.getStudentsCurrentlyOutside();

      emit(OutsideStudentsLoaded(students));
    } catch (e) {
      emit(RegistryError(
        'Error fetching outside students: ${e.toString()}',
      ));
    }
  }
}

