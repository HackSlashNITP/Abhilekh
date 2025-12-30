import 'package:abhilekh/features/wifi_access/bloc/wifi_access_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/colors.dart';


class WifiAccessGate extends StatelessWidget {
  final Widget child;

  const WifiAccessGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WifiAccessBloc, WifiAccessState>(
      builder: (context, state) {
        if (state is WifiAccessChecking) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is WifiAccessAllowed) {
          return child;
        }

        if (state is WifiAccessDenied) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 72,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Restricted to College Wi‑Fi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(onPressed: () {
                      context.read<WifiAccessBloc>().add(RetryWifiCheck());
                    },
                      icon: const Icon(Icons.refresh, color: Colors.white,),
                      label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        shape: RoundedRectangleBorder(  borderRadius: BorderRadius.circular(20),   ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}


