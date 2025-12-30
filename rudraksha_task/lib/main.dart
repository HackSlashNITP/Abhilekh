import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'logic/auth/auth_bloc.dart';
import 'logic/registry/registry_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/registry_repository_impl.dart';
import 'core/services/wifi_services.dart';
import 'presentation/auth/role_selection_page.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/auth/signup_page.dart';
import 'presentation/admin/admin_screen.dart';
import 'presentation/student/student_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          )..add(const AuthStateChanged(null)),
        ),
        // Registry BLoC
        BlocProvider(
          create: (context) => RegistryBloc(
            wifiService: WifiService(),
            registryRepository: RegistryRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Abhilekh - Registry System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const _AuthWrapper(),
          '/role-selection': (context) => const RoleSelectionPage(),
          '/login': (context) => LoginPage(
                role: ModalRoute.of(context)?.settings.arguments as String?,
              ),
          '/signup': (context) => SignUpPage(
                role: ModalRoute.of(context)?.settings.arguments as String?,
              ),
          '/admin': (context) => const AdminScreen(),
          '/student': (context) => const StudentScreen(),
        },
      ),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // navigation when authentication state changes
        if (state is Authenticated) {
          // Navigate to appropriate screen based on role
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != '/admin' && currentRoute != '/student') {
              if (state.role == 'admin') {
                Navigator.pushReplacementNamed(context, '/admin');
              } else {
                Navigator.pushReplacementNamed(context, '/student');
              }
            }
          });
        } else if (state is Unauthenticated) {
          // Navigate back to role selection when signed out
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != '/' && currentRoute != '/role-selection') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/role-selection',
                (route) => false,
              );
            }
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            // Show loading while navigating
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is Unauthenticated || state is AuthInitial) {
            return const RoleSelectionPage();
          } else if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const RoleSelectionPage();
        },
      ),
    );
  }
}
