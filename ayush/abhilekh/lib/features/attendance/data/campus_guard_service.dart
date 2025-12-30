import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';

class CampusGuardService {
  final NetworkInfo networkInfo;

  CampusGuardService({required this.networkInfo});

  Future<void> validatePresence() async {
    // Step 1: Request location permissions
    await _checkPermissions();

    // Step 2: Verify WiFi MAC address matches campus network
    final String? wifiBSSID = await networkInfo.getWifiBSSID();
    final cleanBSSID = wifiBSSID?.replaceAll('"', '').toLowerCase().trim();
    final targetBSSID = AppConstants.campusBSSID.toLowerCase().trim();

    if (cleanBSSID != targetBSSID) {
      throw Exception(
        'Invalid WiFi.\nConnected: $cleanBSSID\nRequired: $targetBSSID'
      );
    }

    // Step 3: Verify device is within campus radius
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      AppConstants.campusLat,
      AppConstants.campusLng,
    );

    if (distance > AppConstants.allowedRadiusMeters) {
      throw Exception(
        'You are outside campus.\nDistance: ${distance.toInt()}m\nLimit: ${AppConstants.allowedRadiusMeters}m'
      );
    }
  }

  Future<void> _checkPermissions() async {
    var locStatus = await Permission.location.status;
    if (!locStatus.isGranted) {
      await Permission.location.request();
    }
  }
}