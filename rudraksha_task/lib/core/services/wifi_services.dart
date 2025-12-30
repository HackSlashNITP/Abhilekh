import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiService {
  final NetworkInfo _networkInfo = NetworkInfo();

  // Add your BSSIDs here
  static const List<String> allowedBSSIDs = [
    '00:11:22:33:44:55', // Sir, You can add your BSSID here to test
    '11:22:33:44:55:66', // Router 2
  ];

  // Fallback: If BSSID fails, check the Name (Less secure but easier)
  // Note: Android often includes quotes in the SSID, so we check with quotes
  static const List<String> allowedSSIDs = [
    // '"AndroidWifi"', for check on emulator on windows
    // 'AndroidWifi',
    '"College_Wifi"',
    'College_Wifi',
  ];

  Future<bool> isConnectedToCollegeWifi() async {
    try {
      // Request Location Permission (required for WiFi info on Android)
      var status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        status = await Permission.locationWhenInUse.request();
        if (!status.isGranted) {
          print("WiFi Check: Location permission denied");
          return false;
        }
      }

      // Get Wi-Fi Details
      final String? wifiBSSID = await _networkInfo.getWifiBSSID();
      final String? wifiName = await _networkInfo.getWifiName(); // SSID

      // Debug logging
      print("WiFi Check - BSSID: $wifiBSSID");
      print("WiFi Check - SSID: $wifiName");

      // Validation Logic - Check BSSID first (most secure)
      if (wifiBSSID != null && wifiBSSID.isNotEmpty) {
        final bssidLower = wifiBSSID.toLowerCase();
        print("WiFi Check - BSSID (lowercase): $bssidLower");
        if (allowedBSSIDs.contains(bssidLower)) {
          print("WiFi Check - BSSID MATCHED! ✅");
          return true;
        }
      }

      // Fallback check - Check SSID name (less secure but easier)
      if (wifiName != null && wifiName.isNotEmpty) {
        // Remove quotes if present for comparison
        final cleanedName = wifiName.replaceAll('"', '');
        print("WiFi Check - SSID (cleaned): $cleanedName");
        
        // Check both with and without quotes, case-insensitive
        for (final allowedSSID in allowedSSIDs) {
          final cleanedAllowed = allowedSSID.replaceAll('"', '');
          if (cleanedName.toLowerCase() == cleanedAllowed.toLowerCase() ||
              wifiName.toLowerCase() == allowedSSID.toLowerCase()) {
            print("WiFi Check - SSID MATCHED! ✅");
            return true;
          }
        }
      }

      print("WiFi Check - No match found ❌");
      return false;
    } catch (e) {
      print("WiFi Check Error: $e");
      return false;
    }
  }
}