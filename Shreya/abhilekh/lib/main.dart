import 'package:abhilekh/core/utils/routes/routes.dart';
import 'package:abhilekh/core/utils/routes/routes_name.dart';
import 'package:abhilekh/features/auth/bloc/auth_bloc.dart';
import 'package:abhilekh/features/auth/data/auth_repository.dart';
import 'package:abhilekh/features/wifi_access/bloc/wifi_access_bloc.dart';
import 'package:abhilekh/features/wifi_access/data/wifi_access_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/admin_panel/bloc/admin_panel_bloc.dart';
import 'features/admin_panel/data/admin_repository.dart';
import 'features/student_panel/bloc/student_panel_bloc.dart';
import 'features/student_panel/data/student_repository.dart';
import 'features/wifi_access/ui/wifi_access_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WifiAccessBloc(WifiAccessRepository())
            ..add(CheckWifiAccess()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(AuthRepository())
            ..add(CheckAuthStatus()),
        ),
        BlocProvider(create: (context) => StudentPanelBloc(StudentRepository())),
        BlocProvider(create: (context) => AdminPanelBloc(AdminRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        onGenerateRoute: Routes.generateRoute,
        home: const WifiAccessGate(
          child: AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          if (state.role == 'student') {
            Navigator.pushReplacementNamed(context, RoutesName.student);
          } else {
            Navigator.pushReplacementNamed(context, RoutesName.admin);
          }
        } else if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, RoutesName.login);
        }
      },
      builder: (context, state) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
