import 'package:rudraksha_task/data/models/RegistryLog.dart';

import '../models/StudentModel.dart';

abstract class RegistryRepository {
  Future<Student> getStudentProfile(String id);
  Future<void> logEntry(String StudentId);
  Future<void> logExit(String StudentId);

  Future<List<Student>> getStudentsCurrentlyOutside();
  Future<List<RegistryLog>> getRegistryHistory({String? studentId});
}