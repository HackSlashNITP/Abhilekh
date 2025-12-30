import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abhilekh/core/theme/colors.dart';
import '../../../core/utils/routes/routes_name.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/student_panel_bloc.dart';

class LoggedInUser {
  final String uid;
  final String rollNo;

  LoggedInUser({required this.uid, required this.rollNo});
}

class StudentPanel extends StatefulWidget {
  const StudentPanel({super.key});

  @override
  State<StudentPanel> createState() => _StudentPanelState();
}

class _StudentPanelState extends State<StudentPanel> {
  LoggedInUser? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final rollNo = doc.data()?['roll_number'] ?? '';

      setState(() {
        currentUser = LoggedInUser(uid: user.uid, rollNo: rollNo);
        isLoading = false;
      });

      context.read<StudentPanelBloc>().add(
          LoadStudentStatus(user.uid));
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightbgColor,
      appBar: AppBar(

          elevation: 0,
          backgroundColor: AppColors.lightbgColor,
          leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
                margin: EdgeInsets.only(
                    left: 10, top: 10, right: 0, bottom: 0),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: IconButton(onPressed: () {
                  Navigator.pushNamed(context, RoutesName.login);
                },
                  icon: Icon(Icons.arrow_back_sharp),
                  color: Colors.white,)),
          ),
        actions: [
          Container(
            margin: EdgeInsets.only(left:0, top: 10, right: 10, bottom:0),
            width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
              child: IconButton(onPressed: (){
                context.read<AuthBloc>().add(
                  LogoutRequest(),
                );
                Navigator.pushNamed(context,RoutesName.signup);
              }, icon:Icon(Icons.logout),color: Colors.white )
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<StudentPanelBloc, StudentPanelState>(
            buildWhen: (previous, current) =>
            previous != current,
            builder: (context, state) {
              if (state is StudentLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is! StudentLoaded) {
                return const Center(child: Text('Something went wrong'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: state.statusColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(4, 2),
                          blurRadius: 12,
                          spreadRadius: 4,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Status:",
                          style: TextStyle(fontSize: 30),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.statusText,
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(thickness: 2),
                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      color: state.statusColor.withValues(alpha:0.5),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Dismissible(
                      key: ValueKey("studentSwipe_${DateTime.now().millisecondsSinceEpoch}"),
                      direction: DismissDirection.horizontal,
                      confirmDismiss: (_) async => true,
                      onDismissed: (direction) {
                        if (state.isInside) {

                          context.read<StudentPanelBloc>().add(
                            MarkExit(currentUser!.uid, currentUser!.rollNo),
                          );
                        } else {

                          context.read<StudentPanelBloc>().add(
                            MarkEntry(currentUser!.uid, currentUser!.rollNo),
                          );
                        }
                        Future.delayed(const Duration(milliseconds: 500), () {
                          context.read<StudentPanelBloc>()
                              .add(LoadStudentStatus(currentUser!.uid));
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          state.isInside
                              ? Icons.location_history
                              : Icons.outbond,
                          size: 40,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Swipe to mark ${state.slideText}",
                    style: const TextStyle(fontSize: 20),
                  ),

                  const SizedBox(height: 20),
                  const Divider(thickness: 2),
                  const SizedBox(height: 10),


                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Movement History",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: state.history.isEmpty
                        ? const Center(
                      child: Text("No movement history yet"),
                    )
                        : ListView.builder(
                      itemCount: state.history.length,
                      itemBuilder: (context, index) {
                        final movement = state.history[index];
                        return Card(
                          color: AppColors.mainColor,
                          elevation: 4,
                          child: ListTile(

                            title: Text(movement.type, style: TextStyle(color: AppColors.textbutton, fontSize: 16,fontWeight: FontWeight.bold),),
                            subtitle: Text(movement.time.toString(), style: TextStyle(color: AppColors.lightbgColor,fontSize: 14,fontWeight:FontWeight.w500),),
                            trailing: Icon(
                              movement.type == "ENTRY"
                                  ? Icons.location_history
                                  : Icons.outbond,
                                size: 36,
                                color: AppColors.lightbgColor
                            ),
                            ),
                          );

                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}