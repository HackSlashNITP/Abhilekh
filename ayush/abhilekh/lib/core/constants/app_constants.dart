class AppConstants {
  // ⚠️ REPLACE WITH YOUR REAL CAMPUS DATA
  // Lat/Lng of your college gate/center
  static const double campusLat = 27.894882;
  static const double campusLng = 78.048598; 

  // The Allowed Radius in meters
  static const int allowedRadiusMeters = 50;

  // The BSSID (MAC Address) of your Router.
  // SSID (Name) is unreliable. BSSID is unique.
  // Format usually: "aa:bb:cc:dd:ee:ff" (Lower case)
  static const String campusBSSID = "9a:d0:a5:35:a5:3e";
  
  static const String collectionUsers = 'users';
  static const String collectionLogs = 'attendance_logs';   
}