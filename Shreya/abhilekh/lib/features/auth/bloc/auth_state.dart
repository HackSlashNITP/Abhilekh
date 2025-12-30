part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

class Authenticated extends AuthState{
  final String uid;
  final String role;
  const Authenticated({
    required this.uid,
    required this.role});
}

class Unauthenticated extends AuthState{}

class AuthLoading extends AuthState{

}
class AuthError extends AuthState{
  final String message;

  const AuthError(   this.message);

}