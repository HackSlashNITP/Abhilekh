import 'package:network_info_plus/network_info_plus.dart';

class WifiAccessRepository {
  final NetworkInfo _networkInfo = NetworkInfo();


  static const List<String> _allowedBssids = <String>[
  //bssid of college wifi
  ];

  Future<String?> getWifiBSSID() async {
    try {
      final bssid = await _networkInfo.getWifiBSSID();
      return bssid;
    } catch (e) {
      return null;
    }
  }

  bool isBssidAllowed(String bssid) {
    if (_allowedBssids.isEmpty) {
      return true;
    }

    final normalized = bssid.toLowerCase();
    return _allowedBssids
        .map((e) => e.toLowerCase())
        .contains(normalized);
  }

  List<String> getAllowedBssids() {
    return List.unmodifiable(_allowedBssids);
  }
}

