import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/location_security.dart';
import 'gate_action_event.dart';
import 'gate_action_state.dart';

class GateActionBloc extends Bloc<GateActionEvent, GateActionState> {
  final LocationSecurity _securityService = LocationSecurity();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GateActionBloc() : super(GateActionInitial()) {
    on<ToggleGateStatus>(_onToggleGateStatus);
  }

  Future<void> _onToggleGateStatus(
      ToggleGateStatus event, Emitter<GateActionState> emit) async {
    emit(GateActionLoading());

    try {

      bool isSecured = await _securityService.isConnectedToCollegeWifi();
      if (!isSecured) {
        emit(GateActionFailure(error: "⚠️ Denied: Connect to College Gate Wi-Fi!"));
        return;
      }

      bool newStatus = !event.currentIsInside;
      String action = newStatus ? "Check-In" : "Check-Out";

      WriteBatch batch = _firestore.batch();

      batch.update(_firestore.collection('users').doc(event.user.uid), {
        'isInside': newStatus,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      batch.set(_firestore.collection('logs').doc(), {
        'uid': event.user.uid,
        'studentName': event.user.displayName ?? "Student",
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      emit(GateActionSuccess(message: "Success: You are now $action"));

    } catch (e) {
      emit(GateActionFailure(error: "Error: ${e.toString()}"));
    }
  }
}