import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import 'campus_guard_service.dart';

class AttendanceRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final CampusGuardService campusGuard;

  AttendanceRepository({
    required this.firestore,
    required this.auth,
    required this.campusGuard,
  });

  Future<void> markAttendance({required bool isEntry}) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // Validate user is on campus (WiFi & location check)
    await campusGuard.validatePresence();

    // Prepare timestamp and entry/exit type
    final timestamp = FieldValue.serverTimestamp();
    final type = isEntry ? 'ENTRY' : 'EXIT';
    
    // Atomic batch: update user status + create log entry
    final batch = firestore.batch();
    final userRef = firestore.collection(AppConstants.collectionUsers).doc(user.uid);
    final logRef = firestore.collection(AppConstants.collectionLogs).doc();

    batch.update(userRef, {
      'currentStatus': isEntry ? 'INSIDE' : 'OUTSIDE',
      'lastUpdated': timestamp,
    });

    batch.set(logRef, {
      'uid': user.uid,
      'email': user.email,
      'type': type,
      'timestamp': timestamp,
    });

    await batch.commit();
  }

  Future<String> getUserStatus() async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final doc = await firestore.collection(AppConstants.collectionUsers).doc(user.uid).get();
    if (!doc.exists) throw Exception("User document not found");

    return doc['currentStatus'] ?? 'OUTSIDE';
  }

  // Fetch students currently outside campus
  Future<List<Map<String, dynamic>>> getOutsideStudents() async {
    final qs = await firestore
        .collection(AppConstants.collectionUsers)
        .where('currentStatus', isEqualTo: 'OUTSIDE')
        .get();

    return qs.docs.map((d) => {
          'uid': d.id,
          'email': d.data()['email'],
          'phone': d.data()['phone'],
          'roll': d.data()['roll'],
          'currentStatus': d.data()['currentStatus'],
          'role': d.data()['role'],
        }).toList();
  }

  // Fetch all users with their info
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final qs = await firestore.collection(AppConstants.collectionUsers).get();
    return qs.docs.map((d) => {
          'uid': d.id,
          'email': d.data()['email'],
          'phone': d.data()['phone'],
          'roll': d.data()['roll'],
          'currentStatus': d.data()['currentStatus'],
          'role': d.data()['role'],
        }).toList();
  }

  // Real-time stream of students outside campus
  Stream<List<Map<String, dynamic>>> streamOutsideStudents() {
    return firestore
        .collection(AppConstants.collectionUsers)
        .where('currentStatus', isEqualTo: 'OUTSIDE')
        .snapshots()
        .map((qs) => qs.docs.map((d) => {
              'uid': d.id,
              'email': d.data()['email'],
              'phone': d.data()['phone'],
              'roll': d.data()['roll'],
              'currentStatus': d.data()['currentStatus'],
              'role': d.data()['role'],
            }).toList());
  }

  // Real-time stream of all users
  Stream<List<Map<String, dynamic>>> streamAllUsers() {
    return firestore.collection(AppConstants.collectionUsers).snapshots().map((qs) => qs.docs.map((d) => {
          'uid': d.id,
          'email': d.data()['email'],
          'phone': d.data()['phone'],
          'roll': d.data()['roll'],
          'currentStatus': d.data()['currentStatus'],
          'role': d.data()['role'],
        }).toList());
  }

  // Real-time stream of user's attendance logs
  Stream<List<Map<String, dynamic>>> streamUserLogs(String uid) {
    return firestore
        .collection(AppConstants.collectionLogs)
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) {
              final data = d.data();
              return {
                'type': data['type'],
                'timestamp': data['timestamp'],
                'email': data['email'],
              };
            }).toList());
  }


  // Admin-only: promote/demote user roles
  Future<void> setUserRole(String uid, String role) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    // Verify caller is admin
    final adminDoc = await firestore
        .collection(AppConstants.collectionUsers)
        .doc(currentUser.uid)
        .get();

    final adminRole = adminDoc.data()?['role'] ?? 'student';
    if (adminRole != 'admin') {
      throw Exception("Only admins can change user roles");
    }

    // Update target user's role
    final docRef = firestore.collection(AppConstants.collectionUsers).doc(uid);
    await docRef.update({'role': role});
  }
  // Fetch user's attendance logs (newest first)
  Future<List<Map<String, dynamic>>> getUserLogs(String uid) async {
    final qs = await firestore
        .collection(AppConstants.collectionLogs)
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .get();

    return qs.docs.map((d) {
      final data = d.data();
      return {
        'type': data['type'],
        'timestamp': data['timestamp'],
        'email': data['email'],
      };
    }).toList();
  }
}