import 'package:abhilekh/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'features/attendance/data/campus_guard_service.dart';
import 'features/attendance/data/attendance_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Attendance feature setup
  sl.registerFactory(() => AttendanceBloc(repository: sl()));
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepository(
      firestore: sl(),
      auth: sl(),
      campusGuard: sl(),
    ),
  );
  sl.registerLazySingleton(() => CampusGuardService(networkInfo: sl()));

  // Auth feature setup
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton(() => AuthRepository(auth: sl(), firestore: sl()));

  // External services
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => NetworkInfo());
}