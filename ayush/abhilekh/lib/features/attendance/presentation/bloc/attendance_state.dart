import 'package:equatable/equatable.dart';

abstract class AttendanceState extends Equatable {
  @override
  List<Object> get props => [];
}

class AttendanceInitial extends AttendanceState {}
class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final String currentStatus; // 'INSIDE' or 'OUTSIDE'
  AttendanceLoaded(this.currentStatus);
  @override
  List<Object> get props => [currentStatus];
}

class AttendanceSuccess extends AttendanceState {
  final String message;
  final String? newStatus;
  AttendanceSuccess(this.message, {this.newStatus});
  @override
  List<Object> get props => [message, newStatus ?? ''];
}

class AttendanceFailure extends AttendanceState {
  final String error;
  AttendanceFailure(this.error);
  @override
  List<Object> get props => [error];
}