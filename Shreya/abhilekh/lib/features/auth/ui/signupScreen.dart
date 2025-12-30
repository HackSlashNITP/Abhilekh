import 'package:abhilekh/core/utils/routes/routes_name.dart';
import 'package:abhilekh/core/utils/routes/routes.dart';
import 'package:abhilekh/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:abhilekh/core/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'loginScreen.dart';
class SignupScreen extends StatefulWidget{
  @override
  State<SignupScreen> createState()=> _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool passwordvis= true;
  final _nameController= TextEditingController();
  final _roleController= TextEditingController();
  final _rollNumberController= TextEditingController();
  final _emailController= TextEditingController();
  final _passwordController= TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(

        listener: (context, state) {
          if (state is Authenticated) {
            if (state.role == 'student') {
              Navigator.pushReplacementNamed(context, RoutesName.student);
            } else {
              Navigator.pushReplacementNamed(context, RoutesName.admin);
            }
          } else if (state is Unauthenticated) {
            Navigator.pushReplacementNamed(context, RoutesName.signup);
          }
          else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(),),
            );
          }

          return Scaffold(

            appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.teal.shade100,
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
                        Navigator.pop(context);
                      },
                        icon: Icon(Icons.arrow_back_sharp),
                        color: Colors.white,)),
                )
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery
                        .of(context)
                        .size
                        .height,
                    minWidth: MediaQuery
                        .of(context)
                        .size
                        .width,
                  ),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.grd1, AppColors.grd2],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      )
                  ),
                  child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [

                            Text("Welcome !", style: TextStyle(fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,),),
                            SizedBox(height: 60,),

                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: AppColors.mainColor),
                                hintText: "Enter your Name",
                                labelText: "Name",
                                labelStyle: TextStyle(color: AppColors.text),
                                fillColor: AppColors.lightbgColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),),
                                prefixIcon: Icon(
                                  Icons.person, color: AppColors.mainColor,),

                              ),
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: _roleController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.none,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: AppColors.mainColor),
                                hintText: "Enter role : student/admin",
                                labelText: "Role",
                                labelStyle: TextStyle(color: AppColors.text),
                                fillColor: AppColors.lightbgColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),),
                                prefixIcon: Icon(
                                  Icons.check_circle_outline_outlined,
                                  color: AppColors.mainColor,),

                              ),
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: _rollNumberController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.none,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: AppColors.mainColor),
                                hintText: "Enter your RollNumber: (students only)",
                                labelText: "Roll Number",
                                labelStyle: TextStyle(color: AppColors.text),
                                fillColor: AppColors.lightbgColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),),
                                prefixIcon: Icon(
                                  Icons.numbers, color: AppColors.mainColor,),

                              ),
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.none,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: AppColors.mainColor),
                                hintText: "Enter your Email",
                                labelText: "Email Address",
                                labelStyle: TextStyle(color: AppColors.text),
                                fillColor: AppColors.lightbgColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),),
                                prefixIcon: Icon(
                                  Icons.email, color: AppColors.mainColor,),

                              ),
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: passwordvis,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: AppColors.mainColor),
                                  hintText: "Enter Password",
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: AppColors.text),
                                  fillColor: AppColors.lightbgColor,
                                  filled: true,
                                  suffixIcon: InkWell(onTap: () {
                                    setState(() {
                                      passwordvis = !passwordvis;
                                    });
                                  },
                                    child: Icon((passwordvis) ? Icons
                                        .visibility_off_rounded : Icons
                                        .visibility_rounded,
                                      color: AppColors.mainColor,),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),),
                                  prefixIcon: Icon(
                                    Icons.lock, color: AppColors.mainColor,)
                              ),
                            ),


                            SizedBox(height: 40,),
                            ElevatedButton(onPressed: () {
                              context.read<AuthBloc>().add(
                                SignupRequest(
                                    name: _nameController.text.trim(),
                                    role: _roleController.text.trim(),
                                    rollNumber: _rollNumberController.text
                                        .trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim()
                                ),
                              );
                            }, child: Text("Sign Up", style: TextStyle(
                                fontSize: 20, color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already have an account?",
                                    style: TextStyle(
                                      color: Colors.black, fontSize: 16,)),
                                TextButton(onPressed: () {
                                  Navigator.pushNamed(
                                      context, RoutesName.login);
                                },
                                    child: Text("Login", style: TextStyle(
                                        color: AppColors.lightbgColor,
                                        fontSize: 16),))
                              ],
                            ),

                          ],
                        ),
                      )
                  ),
                ),
              ),
            ),
          );
        },

    );


  }
}