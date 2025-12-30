import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class UserHistoryPage extends StatelessWidget {
  final String uid;
  final String? email;

  const UserHistoryPage({super.key, required this.uid, this.email});

  // Realtime stream of logs
  Stream<List<Map<String, dynamic>>> _streamLogs() {
    final firestore = FirebaseFirestore.instance;
    return firestore
        .collection(AppConstants.collectionLogs)
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) {
              final data = d.data();
              return {
                'type': data['type'],
                'timestamp': data['timestamp'],
                'email': data['email'],
              };
            }).toList());
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return 'Unknown time';
    if (ts is Timestamp) {
      final dt = ts.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return ts.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(email ?? 'User History'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _streamLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) return const Center(child: Text('No logs available'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, idx) {
              final log = logs[idx];
              final type = log['type'] ?? 'UNKNOWN';
              final ts = log['timestamp'];
              return ListTile(
                leading: Icon(type == 'ENTRY' ? Icons.login : Icons.logout, color: AppColors.primary),
                title: Text(type == 'ENTRY' ? 'Entered Campus' : 'Left Campus'),
                subtitle: Text(_formatTimestamp(ts)),
              );
            },
          );
        },
      ),
    );
  }
}
