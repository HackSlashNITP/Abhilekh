part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

class CheckAuthStatus extends AuthEvent{}
class LoginRequest extends AuthEvent{
  final String email;
  final String password;

  const LoginRequest(this.email,this.password);
}

class SignupRequest extends AuthEvent{
  final String email;
  final String password;
  final String name;
  final String role;
  final String? rollNumber;

  const SignupRequest({
      required this.name,
      required this.role,
      this.rollNumber,
      required this.email,
      required this.password});
}

class LogoutRequest extends AuthEvent{
}
