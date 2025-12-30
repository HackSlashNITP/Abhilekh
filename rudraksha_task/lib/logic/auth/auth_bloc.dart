import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/repositories/auth_repository.dart';

/// --------------------
/// Events
/// --------------------
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStateChanged extends AuthEvent {
  final User? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String rollNo;
  final String role;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.rollNo,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, rollNo, role];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// --------------------
/// States
/// --------------------
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;
  final String role;

  const Authenticated({
    required this.user,
    required this.role,
  });

  @override
  List<Object?> get props => [user, role];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// --------------------
/// BLoC
/// --------------------
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AuthStateChanged>(_onAuthStateChanged);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);

    // Listen to auth state changes
    authRepository.user.listen((user) {
      add(AuthStateChanged(user));
    });
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user == null) {
      emit(const Unauthenticated());
    } else {
      try {
        // Fetch role from Firestore directly
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(event.user!.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.get('role') as String;
          emit(Authenticated(user: event.user!, role: role));
        } else {
          emit(const Unauthenticated());
        }
      } catch (e) {
        emit(const Unauthenticated());
      }
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final role = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        emit(Authenticated(user: user, role: role));
      } else {
        emit(const AuthError('Sign in failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Create user with Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Create user document in Firestore
      await FirebaseAuth.instance.currentUser?.updateDisplayName(event.name);

      // Store user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': event.name,
        'rollNo': event.rollNo,
        'role': event.role,
        'status': 'outside', // Default status
        'email': event.email,
      });

      // Sign in to get role
      final role = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      emit(Authenticated(user: userCredential.user!, role: role));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.signOut();
    emit(const Unauthenticated());
  }
}

