import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../logic/registry/registry_bloc.dart';
import '../../data/models/StudentModel.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  Student? _studentProfile;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<RegistryBloc>().add(FetchStudentProfile(user.uid));
    }
    // Check connectivity on load
    context.read<RegistryBloc>().add(const CheckConnectivity());
  }

  void _handleEntry() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<RegistryBloc>().add(LogEntry(user.uid));
    }
  }

  void _handleExit() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<RegistryBloc>().add(LogExit(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigate to role selection when signed out
        if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/role-selection',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Portal'),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(const SignOutRequested());
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<RegistryBloc, RegistryState>(
        listener: (context, state) {
          if (state is StudentProfileLoaded) {
            setState(() {
              _studentProfile = state.student;
            });
          } else if (state is EntryLogged) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh profile
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              context.read<RegistryBloc>().add(FetchStudentProfile(user.uid));
            }
          } else if (state is ExitLogged) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            // Refresh profile
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              context.read<RegistryBloc>().add(FetchStudentProfile(user.uid));
            }
          } else if (state is RegistryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Connectivity Status
                BlocBuilder<RegistryBloc, RegistryState>(
                  builder: (context, state) {
                    if (state is ConnectivityChecked) {
                      return Card(
                        color: state.isConnected ? Colors.green.shade50 : Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                state.isConnected ? Icons.wifi : Icons.wifi_off,
                                color: state.isConnected ? Colors.green : Colors.red,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  state.message ?? 'Checking connectivity...',
                                  style: TextStyle(
                                    color: state.isConnected ? Colors.green.shade900 : Colors.red.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                // Student Profile Card
                if (_studentProfile != null) ...[
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.green.shade700,
                            child: Text(
                              _studentProfile!.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _studentProfile!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Roll No: ${_studentProfile!.rollNo}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _studentProfile!.status == StudentStatus.inside
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _studentProfile!.status == StudentStatus.inside
                                  ? 'Inside Campus'
                                  : 'Outside Campus',
                              style: TextStyle(
                                color: _studentProfile!.status == StudentStatus.inside
                                    ? Colors.green.shade900
                                    : Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_studentProfile!.lastLogged != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Last Logged: ${_studentProfile!.lastLogged}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action Buttons
                  if (state is! RegistryLoading) ...[
                    ElevatedButton.icon(
                      onPressed: _handleEntry,
                      icon: const Icon(Icons.login, size: 28),
                      label: const Text(
                        'Log Entry',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _handleExit,
                      icon: const Icon(Icons.logout, size: 28),
                      label: const Text(
                        'Log Exit',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ] else
                    const Center(child: CircularProgressIndicator()),
                ] else if (state is RegistryLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else ...[
                  const Center(
                    child: Text(
                      'Unable to load profile',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    ),
    );
  }
}

