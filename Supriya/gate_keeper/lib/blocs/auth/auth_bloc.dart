import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    User? user = _auth.currentUser;
    if (user != null) {
      await _loadUserRole(user, emit);
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential creds = await _auth.signInWithEmailAndPassword(
          email: event.email, password: event.password);
      await _loadUserRole(creds.user!, emit);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "Login Failed"));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _loadUserRole(User user, Emitter<AuthState> emit) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        emit(AuthAuthenticated(user: user, role: doc['role']));
      } else {
        emit(AuthError("User record not found in Database"));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError("Database Error: ${e.toString()}"));
      emit(AuthUnauthenticated());
    }
  }
}