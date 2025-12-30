import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStudentModel {
  final String uid;
  final String name;
  final String rollNo;
  final bool isInside;
  final Timestamp? lastMovementTimestamp;

  AdminStudentModel({
    required this.uid,
    required this.name,
    required this.rollNo,
    required this.isInside,
    this.lastMovementTimestamp,
  });
}
