import 'package:abhilekh/core/utils/routes/routes_name.dart';
import 'package:abhilekh/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:abhilekh/core/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 final _emailController= TextEditingController();

 final _passwordController= TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc,AuthState>(

        listener: (context,state){
          if (state is Authenticated) {
            if (state.role == 'student') {
              Navigator.pushReplacementNamed(context, RoutesName.student);
            } else {
              Navigator.pushReplacementNamed(context, RoutesName.admin);
            }
          } else if(state is AuthError){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
      builder:( context,state) {
          if(state is AuthLoading){
            return const Scaffold(
              body:Center(child: CircularProgressIndicator(),),
            );
          }
          return Scaffold(

            appBar: AppBar(
                elevation:0,
                backgroundColor: Colors.teal.shade100,
                leading: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                      margin: EdgeInsets.only(left: 10, top: 10, right: 0, bottom:0),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),


                      child: IconButton(onPressed: (){
                        Navigator.pushNamed(context, RoutesName.signup);
                      }, icon: Icon(Icons.arrow_back_sharp), color: Colors.white,)),
                )
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                 constraints: BoxConstraints(
                   maxHeight: MediaQuery.of(context).size.height,
                   maxWidth: MediaQuery.of(context).size.width,
                 ),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.grd1, AppColors.grd2],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      )
                  ),
                  child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            SizedBox(height: 100,),
                            Text("Welcome Back!",style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.black, ), ),
                            SizedBox(height: 120,),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.none,
                              decoration: InputDecoration(
                                labelText: "Email:",
                                labelStyle: TextStyle(color: AppColors.text),
                                hintStyle: TextStyle(color: AppColors.mainColor),
                                hintText: "Enter your Email",
                                fillColor: AppColors.lightbgColor,
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), ),
                                prefixIcon: Icon(Icons.email, color: AppColors.mainColor,),

                              ),
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: _passwordController,
                              obscureText:true,
                              decoration: InputDecoration(
                                  labelText: "Password:",
                                  labelStyle: TextStyle(color: AppColors.text),
                                  hintStyle: TextStyle(color: AppColors.mainColor),
                                  hintText: "Enter your Password",
                                  fillColor: AppColors.lightbgColor,
                                  filled: true,
                                  border:OutlineInputBorder(borderRadius: BorderRadius.circular(20), ),
                                  prefixIcon: Icon(Icons.lock, color: AppColors.mainColor,)
                              ),
                            ),
                            SizedBox(height: 40,),
                            ElevatedButton(onPressed: (){
                              context.read<AuthBloc>().add(
                                LoginRequest(
                                    _emailController.text.trim(), _passwordController.text.trim()
                                ),

                              );

                            }, child: Text("Login",style: TextStyle(fontSize: 20, color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonColor,
                                shape: RoundedRectangleBorder(  borderRadius: BorderRadius.circular(20),   ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account?", style: TextStyle(color: Colors.black, fontSize: 16,)),
                                TextButton(onPressed: (){
                                  Navigator.pushNamed(context, RoutesName.signup);
                                }, child: Text("Sign Up", style: TextStyle(color: AppColors.lightbgColor, fontSize: 16),))
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