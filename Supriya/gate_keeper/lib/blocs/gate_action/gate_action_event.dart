import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class GateActionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ToggleGateStatus extends GateActionEvent {
  final User user;
  final bool currentIsInside;
  ToggleGateStatus({required this.user, required this.currentIsInside});
}