import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_student_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AdminStudentModel>> getAllStudents() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return AdminStudentModel(
          uid: doc.id,
          name: data['name'] ?? '',
          rollNo: data['roll_number'] ?? '',
          isInside: data['isInside'] ?? false,
          lastMovementTimestamp: data['lastMovementTimestamp'],
        );
      }).toList();
    });
  }
}
