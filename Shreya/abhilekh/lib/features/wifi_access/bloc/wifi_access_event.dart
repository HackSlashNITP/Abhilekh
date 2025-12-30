part of 'wifi_access_bloc.dart';

@immutable
sealed class WifiAccessEvent {
  const WifiAccessEvent();
}

class CheckWifiAccess extends WifiAccessEvent {
  const CheckWifiAccess();
}

class RetryWifiCheck extends WifiAccessEvent {
  const RetryWifiCheck();
}

