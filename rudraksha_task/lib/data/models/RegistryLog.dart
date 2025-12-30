import 'package:equatable/equatable.dart';

class RegistryLog extends Equatable {
  final String id;
  final String studentId;
  final String name;
  final int gateNo;
  final DateTime timeStamp;
  final bool isEntry;

  const RegistryLog({
    required this.id,
    required this.studentId,
    required this.name,
    required this.gateNo,
    required this.timeStamp,
    required this.isEntry,
  });

  @override
  List<Object?> get props => [id, name, gateNo, timeStamp, isEntry];
}