import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _firebaseAuth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // Sign In & Fetch Role
  Future<String> signIn({required String email, required String password}) async {
    try {
      // Authenticate with Firebase Auth
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch User Role from Firestore 'users' collection
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // Return the role
        return userDoc.get('role') as String;
      } else {
        throw Exception("User data not found in Firestore");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}