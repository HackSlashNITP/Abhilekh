import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
            )
          ],
          bottom: const TabBar(tabs: [Tab(text: "Live Status"), Tab(text: "Logs")]),
        ),
        body: const TabBarView(children: [LiveStatusTab(), LogsTab()]),
      ),
    );
  }
}

class LiveStatusTab extends StatelessWidget {
  const LiveStatusTab({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users')
          .where('role', isEqualTo: 'student').where('isInside', isEqualTo: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var students = snapshot.data!.docs;
        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(students[i]['name']),
            subtitle: Text("Roll: ${students[i]['rollNumber']}"),
            trailing: const Text("OUT", style: TextStyle(color: Colors.red)),
          ),
        );
      },
    );
  }
}

class LogsTab extends StatelessWidget {
  const LogsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('logs')
          .orderBy('timestamp', descending: true).limit(50).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var logs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, i) {
            Timestamp t = logs[i]['timestamp'];
            return ListTile(
              title: Text(logs[i]['studentName']),
              subtitle: Text(DateFormat('MM/dd HH:mm').format(t.toDate())),
              trailing: Text(logs[i]['action']),
            );
          },
        );
      },
    );
  }
}