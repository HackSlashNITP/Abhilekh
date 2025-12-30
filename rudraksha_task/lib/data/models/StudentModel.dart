import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum StudentStatus{inside, outside}

class Student extends Equatable {
  final String id;
  final String name;
  final StudentStatus status;
  final String rollNo;
  final String? lastLogged;

  const Student({
    required this.id,
    required this.name,
    required this.status,
    required this.rollNo,
    required this.lastLogged,
  });
  @override
  List<Object?> get props => [id, name, status, rollNo, lastLogged];

  factory Student.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Student(
      id: documentId,
      name: data['name'] as String,
      status: data['status'] == 'inside' ? StudentStatus.inside : StudentStatus.outside,
      rollNo: data['rollNo'] as String,
      lastLogged: data['lastLogTime'] != null
          ? (data['lastLogTime'] as Timestamp).toDate().toString()
          : null,
    );
  }
}