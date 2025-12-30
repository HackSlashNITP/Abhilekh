import 'package:abhilekh/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc(this.repository) : super(AuthInitial()) {
    on<CheckAuthStatus>((event,emit) async{
        final User? user = repository.getCurrentUser();

        if (user != null) {

          try {
            final String role = await repository.getUserRole(user.uid);
            emit(Authenticated(uid: user.uid, role: role));
          } catch (e) {
            await repository.logout();
            emit(Unauthenticated());
          }
        } else {
          emit(Unauthenticated());
        }
        });



   on<LoginRequest>((event, emit) async{
     emit(AuthLoading());
     try{
       final user= await repository.login(event.email,event.password);

       final role= await repository.getUserRole(user!.uid);
       emit(Authenticated(uid: user.uid, role: role));
     }catch(e){
       emit(AuthError("Login Failed!: !"+ e.toString()));
       emit(Unauthenticated());
     }
    });

   on<SignupRequest>((event,emit) async{
     emit(AuthLoading());
     if(event.role =="student" && event.rollNumber==null&&event.rollNumber!.isEmpty){
       emit(AuthError("Roll Number is Mandatory for students"));
       emit(Unauthenticated());
     }

     try{
      await repository.signup(email: event.email, password: event.password, name: event.name, role: event.role, rollNumber: event.rollNumber);
 final user= await repository.login(event.email, event.password);
      final role = await repository.getUserRole(user!.uid);

      emit(Authenticated(uid: user!.uid, role: event.role));
     }catch(e){
       emit(AuthError("SignUp Failed!!: "+ e.toString()));
       emit(Unauthenticated());
     }
   });

   on<LogoutRequest>((event, emit) async{
     await repository.logout();
     emit(Unauthenticated());
   });


  }
}
