import 'package:abhilekh/features/student_panel/data/movement_model.dart';
import 'package:abhilekh/features/student_panel/data/student_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

part 'student_panel_event.dart';
part 'student_panel_state.dart';

class StudentPanelBloc
    extends Bloc<StudentPanelEvent, StudentPanelState> {
  final StudentRepository repository;

  StudentPanelBloc(this.repository) : super(StudentPanelInitial()) {
    on<LoadStudentStatus>(_onLoadStudentStatus);
    on<MarkExit>(_onMarkExit);
    on<MarkEntry>(_onMarkEntry);
  }

  Future<void> _onLoadStudentStatus(
      LoadStudentStatus event,
      Emitter<StudentPanelState> emit,
      ) async {
    emit(StudentLoading());

    await emit.forEach<List<Movement>>(
      repository.getMovementHistory(event.uid),
      onData: (history) {
        final isInside =
            history.isNotEmpty && history.first.type == "ENTRY";



        return StudentLoaded(
          isInside: isInside,
          history: history,
        );
      },

    );
  }

  Future<void> _onMarkExit(
      MarkExit event,
      Emitter<StudentPanelState> emit,
      ) async {
    await repository.markMovement(
      uid: event.uid,
      rollNo: event.rollNo,
      isEntry: false,
    );
  }

  Future<void> _onMarkEntry(
      MarkEntry event,
      Emitter<StudentPanelState> emit,
      ) async {
    await repository.markMovement(
      uid: event.uid,
      rollNo: event.rollNo,
      isEntry: true,
    );
  }
}
