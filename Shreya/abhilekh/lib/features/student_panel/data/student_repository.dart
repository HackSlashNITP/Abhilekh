import 'package:abhilekh/features/student_panel/data/movement_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> fetchCurrentStatus(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    return doc.data()?["isInside"] ?? true;
  }

  Future<void> markMovement({
    required String uid,
    required String rollNo,
    required bool isEntry,
  }) async {
    final batch = _firestore.batch();
    final timestamp = FieldValue.serverTimestamp();

    final movementRef = _firestore.collection('movements').doc();
    batch.set(movementRef, {
      'uid': uid,
      'rollno': rollNo,
      'type': isEntry ? "ENTRY" : "EXIT",
      'timeStamp': timestamp,
    });

    final userRef = _firestore.collection('users').doc(uid);
    batch.update(userRef, {
      'isInside': isEntry,
      'lastMovementTimestamp': timestamp,
    });

    await batch.commit();
  }

  Stream<List<Movement>> getMovementHistory(String uid) {
    return _firestore
        .collection('movements')
        .where('uid', isEqualTo: uid)
        .orderBy('timeStamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final Timestamp? timestamp = data['timeStamp'] as Timestamp?;
        return Movement(
          time: timestamp?.toDate() ?? DateTime.now(),
          type: doc['type'],
        );
      }).toList();
    });
  }
}