import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rudraksha_task/data/models/RegistryLog.dart';
import '../models/StudentModel.dart';
import 'registry_repository.dart'; // Import the interface from Phase 1

class RegistryRepositoryImpl implements RegistryRepository {
  final FirebaseFirestore _firestore;

  RegistryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> logEntry(String studentId) async {
    // A Batch ensures both operations succeed or both fail
    WriteBatch batch = _firestore.batch();

    // 1. Create a new log entry
    DocumentReference newLogRef = _firestore.collection('logs').doc();
    batch.set(newLogRef, {
      'studentId': studentId,
      'type': 'entry',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Update student status to 'inside'
    DocumentReference studentRef = _firestore.collection('users').doc(studentId);
    batch.update(studentRef, {
      'status': 'inside',
      'lastLogTime': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> logExit(String studentId) async {
    WriteBatch batch = _firestore.batch();

    // Create a new log entry
    DocumentReference newLogRef = _firestore.collection('logs').doc();
    batch.set(newLogRef, {
      'studentId': studentId,
      'type': 'exit',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update student status to 'outside'
    DocumentReference studentRef = _firestore.collection('users').doc(studentId);
    batch.update(studentRef, {
      'status': 'outside',
      'lastLogTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<List<Student>> getStudentsCurrentlyOutside() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student') // Ensuring we only get students
          .where('status', isEqualTo: 'outside')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Student.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching outside students: $e');
    }
  }

  Stream<List<Student>> getOutsideStudentsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('status', isEqualTo: 'outside')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Student.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<List<RegistryLog>> getRegistryHistory({String? studentId}) async {
    try {
      Query query = _firestore.collection('logs');
      if (studentId != null && studentId.isNotEmpty) {
        query = query.where('studentId', isEqualTo: studentId);
      }
      query = query.orderBy('timestamp', descending: true);
      final QuerySnapshot snapshot = await query.get();

      final List<RegistryLog> logs = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final logStudentId = data['studentId'] as String? ?? '';

        // Fetch student name from users collection
        String studentName = 'Unknown';
        int gateNo = data['gateNo'] as int? ?? 0;
        
        if (logStudentId.isNotEmpty) {
          try {
            final studentDoc = await _firestore.collection('users').doc(logStudentId).get();
            if (studentDoc.exists) {
              final studentData = studentDoc.data() as Map<String, dynamic>;
              studentName = studentData['name'] as String? ?? 'Unknown';
            }
          } catch (e) {
            // If fetching student name fails, use default
            print('Error fetching student name: $e');
          }
        }

        final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

        logs.add(RegistryLog(
          id: doc.id,
          studentId: logStudentId,
          isEntry: data['type'] == 'entry',
          name: studentName,
          gateNo: gateNo,
          timeStamp: timestamp,
        ));
      }

      return logs;

    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  @override
  Future<Student> getStudentProfile(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        return Student.fromFirestore(data, doc.id);
      } else {
        throw Exception('Student profile not found');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }
}