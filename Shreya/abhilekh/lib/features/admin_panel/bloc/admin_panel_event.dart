part of 'admin_panel_bloc.dart';

@immutable
sealed class AdminPanelEvent {}


class LoadStudents extends AdminPanelEvent {}

class ChangeFilter extends AdminPanelEvent {
  final StudentFilter filter;

  ChangeFilter(this.filter);
}