import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// IMPORTANT: You must generate this file using "flutterfire configure"
import 'firebase_options.dart'; 

import 'injection_container.dart' as di;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/constants/app_constants.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/attendance/presentation/pages/home_screen.dart';
import 'features/attendance/presentation/pages/students_overview_page.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await di.init(); // Initialize Dependency Injection
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<AttendanceBloc>(create: (_) => di.sl<AttendanceBloc>()),
      ],
      child: MaterialApp(
        title: 'Student Registry',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Route based on auth state and admin role
    return BlocBuilder<AuthBloc, bool>(
      builder: (context, isLoggedIn) {
        if (isLoggedIn) {
          // Check user's role to show correct dashboard
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection(AppConstants.collectionUsers).doc(FirebaseAuth.instance.currentUser!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return const StudentHomeScreen();
              }
              final doc = snapshot.data;
              final role = doc?.data()?['role']?.toString();
              if (role == 'admin') {
                return const StudentsOverviewPage();
              }
              return const StudentHomeScreen();
            },
          );
        }

        return const LoginScreen();
      }, 
    );
  }
}