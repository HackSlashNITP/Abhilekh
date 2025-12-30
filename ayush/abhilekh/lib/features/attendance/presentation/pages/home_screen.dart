import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/action_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load user's current campus status when screen opens
    Future.delayed(Duration.zero, () {
      context.read<AttendanceBloc>().add(LoadUserStatusRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Registry"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        titleTextStyle: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textWhite),
            onPressed: () => context.read<AuthBloc>().logout(),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: BlocConsumer<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is AttendanceFailure) {
              _showErrorDialog(context, state.error);
            }
          },
          builder: (context, state) {
            // Show loader while processing check-in/out
            if (state is AttendanceLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            // Determine current campus status
            String currentStatus = 'OUTSIDE';
            if (state is AttendanceLoaded) {
              currentStatus = state.currentStatus;
            } else if (state is AttendanceSuccess && state.newStatus != null) {
              currentStatus = state.newStatus!;
            }

            final isInside = currentStatus == 'INSIDE';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - kToolbarHeight - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: isInside ? AppColors.primaryGradient : AppColors.secondaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isInside ? AppColors.primary : AppColors.secondary).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Status icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.textWhite.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isInside ? Icons.location_city : Icons.location_off,
                            size: 48,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Status label
                        Text(
                          isInside ? "ON CAMPUS" : "OFF CAMPUS",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Current status text
                        Text(
                          currentStatus,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Quick action buttons
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Quick Action",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Check-in button (visible when outside)
                  if (!isInside)
                    ActionButton(
                      label: "ENTER CAMPUS",
                      color: AppColors.success,
                      icon: Icons.login_rounded,
                      onTap: () => context.read<AttendanceBloc>().add(CheckInRequested()),
                    ),
                  
                  // Check-out button (visible when inside)
                  if (isInside)
                    ActionButton(
                      label: "LEAVE CAMPUS",
                      color: AppColors.error,
                      icon: Icons.logout_rounded,
                      onTap: () => context.read<AttendanceBloc>().add(CheckOutRequested()),
                    ),
                ],
              ),
            ),
          );
          },
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Registration Failed"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }
}