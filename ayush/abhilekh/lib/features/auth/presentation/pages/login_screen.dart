import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/auth_bloc.dart';
import 'signup_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../attendance/presentation/pages/students_overview_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _onLoginPressed() async {
    final email = _emailCtrl.text.trim();
    
    // Validate email domain
    if (!email.endsWith('@nitp.ac.in')) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please use your institutional email"),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await context.read<AuthBloc>().login(
        email,
        _passCtrl.text.trim(),
      );

      // After successful sign-in, check if user is admin
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection(AppConstants.collectionUsers).doc(user.uid).get();
        final role = doc.data()?['role']?.toString();
        if (role == 'admin') {
          // Navigate to admin homepage and clear stack
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const StudentsOverviewPage()),
              (route) => false,
            );
            return;
          }
        }
      }

      // For non-admin users, AuthWrapper will navigate to student home.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Modern Header with Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.school, size: 60, color: AppColors.textWhite),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  const Text(
                    "Student Access",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    "Sign in to your account",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Email TextField
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      hintText: "student@nitp.ac.in",
                      prefixIcon: const Icon(Icons.email_outlined),
                                            helperText: "Use your institutional email ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password TextField
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your password",
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                            ),
                          )
                        : const Text(
                            "Sign In",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "New user?",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          'Sign up here',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}