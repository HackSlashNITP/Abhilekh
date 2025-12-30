import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';

class AuthBloc extends Cubit<bool> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(false) {
    // Listen to auth state changes and sync role
    authRepository.userStream.listen((user) async {
      if (user != null) {
        try {
          await authRepository.ensureUserRole(user.uid);
        } catch (_) {}
      }
      emit(user != null);
    });
  }

  Future<void> login(String email, String password) async {
    if (!email.endsWith('@nitp.ac.in')) {
      throw Exception('Only institutional email allowed');
    }
    try {
      await authRepository.signIn(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password, String phone, String roll) async {
    if (!email.endsWith('@nitp.ac.in')) {
      throw Exception('Please use your institutional email ending with nitp.ac.in');
    }
    if (phone.isEmpty || roll.isEmpty) {
      throw Exception('Phone number and roll number are required');
    }
    try {
      await authRepository.register(email, password, phone, roll);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await authRepository.signOut();
  }
}