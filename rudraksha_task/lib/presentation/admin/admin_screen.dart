import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../logic/registry/registry_bloc.dart';
import '../../data/models/StudentModel.dart';
import '../../data/models/RegistryLog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch initial data
    context.read<RegistryBloc>().add(const FetchOutsideStudents());
    context.read<RegistryBloc>().add(const FetchRegistryHistory());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.blue.shade700,
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
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Outside Students', icon: Icon(Icons.people_outline)),
              Tab(text: 'Registry History', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _OutsideStudentsTab(),
            _RegistryHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _OutsideStudentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistryBloc, RegistryState>(
      builder: (context, state) {
        if (state is RegistryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OutsideStudentsLoaded) {
          if (state.students.isEmpty) {
            return const Center(
              child: Text(
                'No students currently outside',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<RegistryBloc>().add(const FetchOutsideStudents());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.students.length,
              itemBuilder: (context, index) {
                final student = state.students[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(
                        student.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      student.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Roll No: ${student.rollNo}'),
                        if (student.lastLogged != null)
                          Text(
                            'Last Logged: ${student.lastLogged}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is RegistryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RegistryBloc>().add(const FetchOutsideStudents());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('No data'));
      },
    );
  }
}

class _RegistryHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistryBloc, RegistryState>(
      builder: (context, state) {
        if (state is RegistryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RegistryHistoryLoaded) {
          if (state.logs.isEmpty) {
            return const Center(
              child: Text(
                'No registry history available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<RegistryBloc>().add(const FetchRegistryHistory());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: log.isEntry ? Colors.green : Colors.red,
                      child: Icon(
                        log.isEntry ? Icons.login : Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      log.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gate No: ${log.gateNo}'),
                        Text(
                          'Time: ${log.timeStamp.toString().substring(0, 19)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        log.isEntry ? 'Entry' : 'Exit',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: log.isEntry ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is RegistryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RegistryBloc>().add(const FetchRegistryHistory());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('No data'));
      },
    );
  }
}

