import 'package:abhilekh/features/admin_panel/ui/admin_dashboard.dart';
import 'package:abhilekh/features/auth/ui/loginScreen.dart';
import 'package:abhilekh/features/auth/ui/signupScreen.dart';
import 'package:abhilekh/features/student_panel/ui/studentPanel.dart';
import 'package:flutter/material.dart';
import 'package:abhilekh/core/utils/routes/routes_name.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/admin_panel/bloc/admin_panel_bloc.dart';
import '../../../features/student_panel/bloc/student_panel_bloc.dart';


class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){

      case RoutesName.login :
        return MaterialPageRoute(builder:(BuildContext context)=> LoginScreen());
      case RoutesName.signup:
        return MaterialPageRoute(builder:(BuildContext context)=> SignupScreen());
      case RoutesName.student:
    return MaterialPageRoute(
    builder: (BuildContext context) => BlocProvider.value(
    value: BlocProvider.of<StudentPanelBloc>(context),
    child: const StudentPanel(),
    ),);
      case RoutesName.admin:
    return MaterialPageRoute(
    builder: (BuildContext context) => BlocProvider.value(
    value: BlocProvider.of<AdminPanelBloc>(context),
    child: const AdminDashboard(),
    ),);
      default:
        return MaterialPageRoute(builder: (_){
          return Scaffold(
              body: Center(
                  child: Text("No Route found!!")
              )
          );
        });

    }

  }
}