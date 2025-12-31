import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/gate_action/gate_action_bloc.dart';
import '../blocs/gate_action/gate_action_event.dart';
import '../blocs/gate_action/gate_action_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Pass"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          bool isInside = snapshot.data!['isInside'] ?? false;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isInside ? Icons.security : Icons.outbond,
                  size: 100,
                  color: isInside ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 20),
                Text(
                  isInside ? "Inside Campus" : "Outside Campus",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                BlocConsumer<GateActionBloc, GateActionState>(
                  listener: (context, state) {
                    if (state is GateActionFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error), backgroundColor: Colors.red));
                    } else if (state is GateActionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message), backgroundColor: Colors.green));
                    }
                  },
                  builder: (context, state) {
                    if (state is GateActionLoading) return const CircularProgressIndicator();

                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        backgroundColor: isInside ? Colors.redAccent : Colors.green,
                      ),
                      onPressed: () {
                        context.read<GateActionBloc>().add(
                            ToggleGateStatus(user: user, currentIsInside: isInside));
                      },
                      icon: Icon(isInside ? Icons.exit_to_app : Icons.login),
                      label: Text(isInside ? "CHECK OUT" : "CHECK IN"),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}