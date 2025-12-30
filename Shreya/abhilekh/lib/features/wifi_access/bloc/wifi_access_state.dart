part of 'wifi_access_bloc.dart';

@immutable
sealed class WifiAccessState {
  const WifiAccessState();
}

final class WifiAccessInitial extends WifiAccessState {}

class WifiAccessChecking extends WifiAccessState {}

class WifiAccessAllowed extends WifiAccessState {}

class WifiAccessDenied extends WifiAccessState {
  final String message;
  final String? currentBssid;

  const WifiAccessDenied({
    required this.message,
    this.currentBssid,
  });
}

