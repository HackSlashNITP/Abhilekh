import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/routes/routes_name.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/admin_panel_bloc.dart';
import '../data/admin_student_model.dart';


enum StudentFilter { all, outside }

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  @override
  void initState() {
    super.initState();
    context.read<AdminPanelBloc>().add(LoadStudents());
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Time not available';
    final dt = timestamp.toDate();
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}, $hour:$minute $amPm';
  }

  List<AdminStudentModel> getFilteredStudents(
      List<AdminStudentModel> students, StudentFilter filter) {
    if (filter == StudentFilter.outside) {
      return students.where((s) => !s.isInside).toList();
    }
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightbgColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Admin Dashboard", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
      body: BlocBuilder<AdminPanelBloc, AdminPanelState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminLoaded) {
            final filtered = getFilteredStudents(state.students, state.filter);

            return Column(
              children: [
                const SizedBox(height: 10),
                // Filter Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilterChip(
                      elevation: 4,
                      selectedColor: Colors.amber,
                      disabledColor: Colors.amberAccent,
                      label: const Text("All",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      selected: state.filter == StudentFilter.all,
                      onSelected: (_) {
                        context
                            .read<AdminPanelBloc>()
                            .add(ChangeFilter(StudentFilter.all));
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      elevation: 4,
                      selectedColor: Colors.amber,
                      disabledColor: Colors.amberAccent,
                      label: const Text("Outside", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                      selected: state.filter == StudentFilter.outside,
                      onSelected: (_) {
                        context
                            .read<AdminPanelBloc>()
                            .add(ChangeFilter(StudentFilter.outside));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Student List
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text("No students to display"))
                      : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final student = filtered[index];
                      return Card(
                        color: AppColors.mainColor.withValues(alpha: 0.5),
                        child: ListTile(
                          leading: Icon(
                            student.isInside ? Icons.location_history : Icons.outbond,
                            color: student.isInside ? Colors.lightGreenAccent : Colors.red,
                            size: 36,
                          ),
                          title: Text(student.name,style: TextStyle(color: AppColors.textbutton, fontSize: 28,fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Roll No: ${student.rollNo}", style: TextStyle( fontSize: 16, color: AppColors.lightbgColor, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                student.isInside
                                    ? "Inside campus"
                                    : "Out since: ${formatTimestamp(student.lastMovementTimestamp)}",
                                style: TextStyle(
                                    fontSize: 18, color: AppColors.lightbgColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (state is AdminError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          // Fallback for AdminInitial
          return const Center(child: Text("Initializing..."));
        },
      ),
    );
  }
}