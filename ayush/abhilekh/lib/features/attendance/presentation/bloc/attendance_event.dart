import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckInRequested extends AttendanceEvent {}
class CheckOutRequested extends AttendanceEvent {}
class LoadUserStatusRequested extends AttendanceEvent {}