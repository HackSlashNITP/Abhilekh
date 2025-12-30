import 'package:equatable/equatable.dart';

abstract class GateActionState extends Equatable {
  @override
  List<Object> get props => [];
}

class GateActionInitial extends GateActionState {}
class GateActionLoading extends GateActionState {}

class GateActionSuccess extends GateActionState {
  final String message;
  GateActionSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class GateActionFailure extends GateActionState {
  final String error;
  GateActionFailure({required this.error});
  @override
  List<Object> get props => [error];
}