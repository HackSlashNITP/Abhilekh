import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  // Real-time auth state stream
  Stream<User?> get userStream => auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Authentication Failed");
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> register(String email, String password, String phone, String roll) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      
      if (user != null) {
        // Create user doc in Firestore with initial data
        final docRef = firestore.collection(AppConstants.collectionUsers).doc(user.uid);
        try {
          await docRef.set({
            'uid': user.uid,
            'email': email,
            'phone': phone,
            'roll': roll,
            'role': 'student',
            'createdAt': FieldValue.serverTimestamp(),
            'currentStatus': 'INSIDE',
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          // Verify doc was written
          final written = await docRef.get();
          if (!written.exists) {
            throw Exception('User document not found after write (possible permission issue)');
          }
        } catch (e) {
          // Handle Firestore errors with context
          if (e is FirebaseException) {
            throw Exception('Failed to write user document: code=${e.code} message=${e.message}');
          }
          throw Exception('Failed to write user document: ${e.toString()}');
        }
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration Failed");
    }
  }

  // Ensure user has a role field (defaults to 'student' if missing)
  Future<void> ensureUserRole(String uid) async {
    final docRef = firestore.collection(AppConstants.collectionUsers).doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return; // nothing to do
    final data = snapshot.data();
    if (data == null) return;
    if (data.containsKey('role')) return;

    await docRef.update({'role': 'student'});
  }
}