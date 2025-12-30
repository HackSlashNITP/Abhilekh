import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/admin_repository.dart';
import '../data/admin_student_model.dart';
import '../ui/admin_dashboard.dart';

part 'admin_panel_event.dart';
part 'admin_panel_state.dart';

class AdminPanelBloc extends Bloc<AdminPanelEvent, AdminPanelState> {
  final AdminRepository repository;

  AdminPanelBloc(this.repository) : super(AdminInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<ChangeFilter>(_onChangeFilter);
  }

  Future<void> _onLoadStudents(
      LoadStudents event, Emitter<AdminPanelState> emit) async {
    emit(AdminLoading());

    await emit.forEach<List<AdminStudentModel>>(
      repository.getAllStudents(),
      onData: (students) => AdminLoaded(students),
      onError: (e, _) => AdminError(e.toString()),
    );
  }

  void _onChangeFilter(ChangeFilter event, Emitter<AdminPanelState> emit) {
    final currentState = state;
    if (currentState is AdminLoaded) {
      emit(AdminLoaded(currentState.students, filter: event.filter));
    }
  }
}