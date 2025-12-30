part of 'student_panel_bloc.dart';

@immutable
sealed class StudentPanelState {}

final class StudentPanelInitial extends StudentPanelState {}

class StudentLoading extends StudentPanelState{}

class StudentLoaded extends StudentPanelState {
  final bool isInside;
  final List<Movement> history;

  StudentLoaded({
    required this.isInside,
    this.history = const [],
  });
  String get statusText=> isInside? "INSIDE": "OUT";
  Color get statusColor=> isInside? Colors.green: Colors.red;
  String get slideText => isInside ? "EXIT" : "ENTRY";
  Icon get statusIcon => Icon(isInside ? Icons.directions_walk_sharp : Icons.outbond, size: 40, color: AppColors.text,);

}