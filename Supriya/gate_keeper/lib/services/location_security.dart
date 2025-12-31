import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationSecurity {
  final NetworkInfo _networkInfo = NetworkInfo();

  final String targetBssid;

  LocationSecurity({this.targetBssid = "00:00:00:00:00:00"});

  Future<bool> isConnectedToCollegeWifi() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      String? wifiBSSID = await _networkInfo.getWifiBSSID();
      print("MY CURRENT BSSID IS : $wifiBSSID");

      if (wifiBSSID != null &&
          wifiBSSID.toLowerCase() == targetBssid.toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}