part of 'student_panel_bloc.dart';

@immutable
sealed class StudentPanelEvent {
  const StudentPanelEvent();
}

class LoadStudentStatus extends StudentPanelEvent{
final String uid;

LoadStudentStatus(this.uid);
}

class MarkExit extends StudentPanelEvent{
  final String uid;
  final String rollNo;

  MarkExit(this.uid, this.rollNo);
}

class MarkEntry extends StudentPanelEvent{
  final String uid;
  final String rollNo;

  MarkEntry(this.uid, this.rollNo);

}

