import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/attendance_repository.dart';
import '../bloc/attendance_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'user_history_page.dart';

class StudentsOverviewPage extends StatefulWidget {
  const StudentsOverviewPage({super.key});

  @override
  State<StudentsOverviewPage> createState() => _StudentsOverviewPageState();
}

class _StudentsOverviewPageState extends State<StudentsOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AttendanceRepository _repo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repo = context.read<AttendanceBloc>().repository;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Overview'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthBloc>().logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Current'), Tab(text: 'History')],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.group, size: 28, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _repo.streamOutsideStudents(),
                      builder: (context, snap) {
                        final count = (snap.data ?? []).length;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.outdoor_grill, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text('$count outside', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Current: students outside campus (real-time)
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _repo.streamOutsideStudents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final students = snapshot.data ?? [];
                    if (students.isEmpty) {
                      return const Center(child: Text('No students outside campus'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final s = students[idx];
                        final role = s['role'] ?? 'student';
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: CircleAvatar(child: Text(s['email']?.toString().substring(0,1).toUpperCase() ?? '?')),
                            title: Text(s['email'] ?? ''),
                            subtitle: Text('Phone: ${s['phone'] ?? 'N/A'}  •  Roll: ${s['roll'] ?? 'N/A'}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (choice) async {
                                final newRole = choice == 'promote' ? 'admin' : 'student';
                                try {
                                  await _repo.setUserRole(s['uid'], newRole);
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Role updated to $newRole')),
                                  );
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to update role: $e')),
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                if (role != 'admin') const PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                                if (role == 'admin') const PopupMenuItem(value: 'demote', child: Text('Demote to Student')),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => UserHistoryPage(uid: s['uid'], email: s['email']),
                              ));
                            },
                          ),
                        );
                      },
                    );
                  },
                ),

                // History: list all students (real-time)
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _repo.streamAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final users = snapshot.data ?? [];
                    if (users.isEmpty) {
                      return const Center(child: Text('No students found'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final u = users[idx];
                        final role = u['role'] ?? 'student';
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: CircleAvatar(child: Text(u['email']?.toString().substring(0,1).toUpperCase() ?? '?')),
                            title: Text(u['email'] ?? ''),
                            subtitle: Text('Phone: ${u['phone'] ?? 'N/A'}  •  Roll: ${u['roll'] ?? 'N/A'}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (choice) async {
                                final newRole = choice == 'promote' ? 'admin' : 'student';
                                try {
                                  await _repo.setUserRole(u['uid'], newRole);
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Role updated to $newRole')),
                                  );
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to update role: $e')),
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                if (role != 'admin') const PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                                if (role == 'admin') const PopupMenuItem(value: 'demote', child: Text('Demote to Student')),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => UserHistoryPage(uid: u['uid'], email: u['email']),
                              ));
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
