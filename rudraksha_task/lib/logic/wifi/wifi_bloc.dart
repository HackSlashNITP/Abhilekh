import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/services/wifi_services.dart';

/// --------------------
/// Events
/// --------------------
abstract class WifiEvent extends Equatable {
  const WifiEvent();

  @override
  List<Object?> get props => [];
}

class CheckWifiConnection extends WifiEvent {
  const CheckWifiConnection();
}

/// --------------------
/// States
/// --------------------
abstract class WifiState extends Equatable {
  const WifiState();

  @override
  List<Object?> get props => [];
}

class WifiInitial extends WifiState {
  const WifiInitial();
}

class WifiLoading extends WifiState {
  const WifiLoading();
}

class WifiAuthorized extends WifiState {
  const WifiAuthorized(); // Correct network
}

class WifiUnauthorized extends WifiState {
  const WifiUnauthorized(); // Wrong network
}

class WifiPermissionDenied extends WifiState {
  const WifiPermissionDenied(); // Permission rejected
}

/// --------------------
/// BLoC
/// --------------------
class WifiBloc extends Bloc<WifiEvent, WifiState> {
  final WifiService wifiService;

  WifiBloc({required this.wifiService}) : super(const WifiInitial()) {
    on<CheckWifiConnection>(_onCheckWifiConnection);
  }

  Future<void> _onCheckWifiConnection(
      CheckWifiConnection event,
      Emitter<WifiState> emit,
      ) async {
    emit(const WifiLoading());

    // delay to prevent UI flicker
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final bool isValid =
      await wifiService.isConnectedToCollegeWifi();

      if (isValid) {
        emit(const WifiAuthorized());
      } else {
        emit(const WifiUnauthorized());
      }
    } catch (_) {
      emit(const WifiUnauthorized());
    }
  }
}
