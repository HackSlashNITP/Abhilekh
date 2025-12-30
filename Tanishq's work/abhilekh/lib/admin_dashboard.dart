import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  "ABHILEKH",
                  style: TextStyle(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 60),
                _sidebarItem(Icons.grid_view_rounded, "Overview", true),
                const Spacer(),
                const Text("ADMIN PANEL v1.0", style: TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 30),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Campus Activity", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const Text("Real-time traffic overview", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),
                  _buildMetricsRow(),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Movement Logs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildSearchField(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildLogTable()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('logs').snapshots(),
      builder: (context, snapshot) {
        int total = snapshot.data?.docs.length ?? 0;
        int outside = 0;
        if (snapshot.hasData) {
          Map<String, String> statusMap = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            statusMap[data['email'] ?? 'unknown'] = data['status'] ?? 'Unknown';
          }
          outside = statusMap.values.where((v) => v == "Exit").length;
        }

        return Row(
          children: [
            _metricCard("Total Movements", total.toString(), Colors.indigo),
            const SizedBox(width: 30),
            _metricCard("Students Outside", outside.toString(), Colors.orange),
            const SizedBox(width: 30),
            _metricCard("Gate System", "Active", Colors.green),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: 320,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: const InputDecoration(
          hintText: "Search student email...",
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 10),
        ),
      ),
    );
  }

  Widget _buildLogTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('logs').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var logs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['email'] ?? "").toString().toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return SingleChildScrollView(
            child: DataTable(
              horizontalMargin: 30,
              columnSpacing: 40,
              dataRowMaxHeight: 70,
              headingRowHeight: 60,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              columns: const [
                DataColumn(label: Text("STUDENT")),
                DataColumn(label: Text("ACTION")),
                DataColumn(label: Text("TIME")),
                DataColumn(label: Text("NETWORK")),
              ],
              rows: logs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                DateTime date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                bool isEntry = data['status'] == "Entry";

                return DataRow(cells: [
                  DataCell(Text(data['email'] ?? "Unknown", style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500))),
                  DataCell(_buildStatusBadge(isEntry)),
                  DataCell(Text("${date.hour}:${date.minute.toString().padLeft(2, '0')} • ${date.day}/${date.month}/${date.year}")),
                  DataCell(Text(data.containsKey('wifi') ? data['wifi'] : (data.containsKey('bssid') ? data['bssid'] : "-"), style: const TextStyle(color: Colors.grey))),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool isEntry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isEntry ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isEntry ? "ENTRY" : "EXIT",
        style: TextStyle(
          color: isEntry ? const Color(0xFF166534) : const Color(0xFF92400E),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: active ? Colors.indigo.withOpacity(0.05) : Colors.transparent,
        leading: Icon(icon, color: active ? Colors.indigo : Colors.grey, size: 20),
        title: Text(label, style: TextStyle(color: active ? Colors.indigo : Colors.grey, fontWeight: active ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
      ),
    );
  }
}