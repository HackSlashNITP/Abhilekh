
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository{
  final FirebaseAuth _auth= FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login( String email, String password) async{

     final result= await _auth.signInWithEmailAndPassword(email: email, password: password);

     return result.user;
  }

  User? getCurrentUser(){
    return _auth.currentUser;
  }



  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String role,
   String? rollNumber}) async{
    if(role =='student'&&rollNumber==null) {
      throw Exception("Please enter your roll number.");
    }

    final result= await _auth.createUserWithEmailAndPassword(email: email, password: password);

    final data={
      'name': name,
      'role': role,
      'isInside': true,
      'created_at': FieldValue.serverTimestamp(),
    };

    if(role=='student'){
      data['roll_number']=rollNumber! ;
    }

    await _firestore.collection("users").doc(result.user!.uid).set(data);

  }

  Future<String> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception("User document does not exist");
    }

    return doc['role'] as String;
  }


  Future<void> logout() async{
await _auth.signOut();
}


}