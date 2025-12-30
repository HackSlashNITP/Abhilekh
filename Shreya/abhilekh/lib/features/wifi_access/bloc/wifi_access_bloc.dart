import 'dart:io';

import 'package:abhilekh/features/wifi_access/data/wifi_access_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wifi_access_event.dart';
part 'wifi_access_state.dart';

class WifiAccessBloc extends Bloc<WifiAccessEvent, WifiAccessState> {
  final WifiAccessRepository repository;

  WifiAccessBloc(this.repository) : super(WifiAccessInitial()) {
    on<CheckWifiAccess>(_onCheckWifiAccess);
    on<RetryWifiCheck>(_onRetryWifiCheck);
  }

  Future<void> _onCheckWifiAccess(
      CheckWifiAccess event,
      Emitter<WifiAccessState> emit,
      ) async {
    emit(WifiAccessChecking());

    if (!Platform.isAndroid) {
      emit(WifiAccessAllowed());
      return;
    }

    try {
      final connectivity = Connectivity();
      final status = await connectivity.checkConnectivity();

      if (status != ConnectivityResult.wifi) {
        emit(WifiAccessDenied(
          message:
          'Please connect to the college Wi‑Fi network to use this application.',
        ));
        return;
      }

      final bssid = await repository.getWifiBSSID();

      if (bssid == null || bssid.isEmpty) {
        emit(WifiAccessDenied(
          message:
          'Unable to read Wi‑Fi details. Make sure location permission is granted and you are connected to the college Wi‑Fi.',
        ));
        return;
      }

      final isAllowed = repository.isBssidAllowed(bssid);

      if (isAllowed) {
        emit(WifiAccessAllowed());
      } else {
        emit(WifiAccessDenied(
          message:
          'You are not connected to an authorized college Wi‑Fi access point.\n\n'
              'Current BSSID: $bssid',
          currentBssid: bssid,
        ));
      }
    } catch (e) {
      emit(WifiAccessDenied(
        message: 'Error checking Wi‑Fi access: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRetryWifiCheck(
      RetryWifiCheck event,
      Emitter<WifiAccessState> emit,
      ) async {
    add(CheckWifiAccess());
  }
}

