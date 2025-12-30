part of 'admin_panel_bloc.dart';


@immutable
sealed class AdminPanelState {}

final class AdminInitial extends AdminPanelState {}

class AdminLoading extends AdminPanelState {}

class AdminLoaded extends AdminPanelState {
  final List<AdminStudentModel> students;
  final StudentFilter filter;

  AdminLoaded(this.students, {this.filter = StudentFilter.all});
}

class AdminError extends AdminPanelState {
  final String message;

  AdminError(this.message);
}