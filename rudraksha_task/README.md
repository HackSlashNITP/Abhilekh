# Abhilekh - College Registry System

A Flutter-based college registry management system that tracks student entry and exit using WiFi connectivity validation. The app provides role-based access for both administrators and students, with real-time tracking and Firebase backend integration.

## 🚀 Working Demo and App APK

- **Download the working demo and APK from Google Drive:**  
  [Google Drive Link](https://drive.google.com/drive/folders/1XaAxBdEGzVT00W6Tfks5rOjUW7ly1ULg?usp=drive_link)

## 📱 Features

### For Students
- **WiFi-Based Entry/Exit Logging**: Log entry and exit only when connected to authorized college WiFi
- **Real-time Status**: View current campus status (Inside/Outside)
- **Profile Management**: View personal profile and registration history
- **Connectivity Validation**: Automatic WiFi connectivity check before logging

### For Administrators
- **Outside Students Dashboard**: View all students currently outside the campus
- **Registry History**: Complete log of all entry/exit activities with timestamps
- **Real-time Updates**: Live updates of student status changes
- **Student Management**: Monitor and track student movements

## 🏗️ Architecture

The project follows **Clean Architecture** principles with **BLoC (Business Logic Component)** pattern for state management:

```
lib/
├── core/
│   └── services/
│       └── wifi_services.dart      # WiFi connectivity validation
├── data/
│   ├── models/                     # Data models
│   │   ├── StudentModel.dart
│   │   └── RegistryLog.dart
│   └── repositories/               # Data layer
│       ├── auth_repository.dart
│       ├── registry_repository.dart
│       └── registry_repository_impl.dart
├── logic/                          # Business logic (BLoC)
│   ├── auth/
│   │   └── auth_bloc.dart
│   ├── registry/
│   │   └── registry_bloc.dart
│   └── wifi/
│       └── wifi_bloc.dart
└── presentation/                   # UI layer
    ├── admin/
    │   └── admin_screen.dart
    ├── auth/
    │   ├── login_page.dart
    │   ├── role_selection_page.dart
    │   └── signup_page.dart
    └── student/
        └── student_screen.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK
- Firebase account
- Android Studio / VS Code with Flutter extensions
- Physical Android device or emulator (WiFi features require real device for testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/abhilekh.git
   cd abhilekh/rudraksha_task
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and place it in `android/app/`
   - Configure Firebase for iOS if needed
   - Run `flutterfire configure` or manually configure `firebase_options.dart`

4. **Configure WiFi Networks**
   - Open `lib/core/services/wifi_services.dart`
   - Add your college WiFi BSSIDs to `allowedBSSIDs` list
   - Add SSID names to `allowedSSIDs` list (with and without quotes for Android compatibility)

   ```dart
   static const List<String> allowedBSSIDs = [
     '00:11:22:33:44:55', // Your WiFi BSSID
   ];
   
   static const List<String> allowedSSIDs = [
     '"YourWiFiName"',
     'YourWiFiName',
   ];
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### WiFi Configuration

Edit `lib/core/services/wifi_services.dart` to add authorized WiFi networks:

```dart
static const List<String> allowedBSSIDs = [
  'c0:68:cc:3e:8f:f3', // BSSID of authorized router
];

static const List<String> allowedSSIDs = [
  '"College_Wifi"',    // SSID with quotes (Android)
  'College_Wifi',      // SSID without quotes
];
```

**Note**: Android devices often return SSID with quotes, so include both formats in the allowed list.

### Firebase Firestore Structure

The app expects the following Firestore collections:

#### `users` Collection
```json
{
  "name": "Student Name",
  "rollNo": "ROLL123",
  "role": "student" | "admin",
  "status": "inside" | "outside",
  "email": "student@college.edu",
  "lastLogTime": Timestamp,
}
```

#### `logs` Collection
```json
{
  "studentId": "user_document_id",
  "type": "entry" | "exit",
  "timestamp": Timestamp,
  "gateNo": 0
}
```

## 📦 Dependencies

### Core Dependencies
- `flutter_bloc: ^9.1.1` - State management
- `firebase_core: ^4.3.0` - Firebase initialization
- `firebase_auth: ^6.1.3` - Authentication
- `cloud_firestore: ^6.1.1` - Database
- `network_info_plus: ^7.0.0` - WiFi information
- `permission_handler: ^12.0.1` - Location permissions
- `equatable: ^2.0.7` - Value equality

## 🔐 Permissions

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location permission to verify WiFi connectivity</string>
```

## 🎯 Usage

### Student Flow
1. Launch app → Select "Student" role
2. Login/Sign Up with email and password
3. View connectivity status
4. Tap "Log Entry" or "Log Exit" (requires authorized WiFi)
5. View profile and status updates

### Admin Flow
1. Launch app → Select "Admin" role
2. Login with admin credentials
3. View "Outside Students" tab for current status
4. View "Registry History" tab for complete logs
5. Monitor real-time student movements

## 🧪 Testing

### WiFi Testing
1. Connect to an authorized WiFi network
2. Check console logs for WiFi validation:
   ```
   WiFi Check - BSSID: xx:xx:xx:xx:xx:xx
   WiFi Check - SSID: "NetworkName"
   WiFi Check - BSSID MATCHED! ✅
   ```

### Debug Mode
The app includes debug logging for WiFi checks. Check console output for:
- BSSID values
- SSID values
- Match results

### Finding WiFi BSSID

**On Windows:**
```cmd
netsh wlan show interfaces
```
Look for "BSSID" in the output.

**On Android:**
- Connect to the WiFi network
- Check the app console logs when checking connectivity
- The BSSID will be printed in debug output

## 🛠️ Development

### Project Structure
- **BLoC Pattern**: All business logic in `logic/` directory
- **Repository Pattern**: Data access abstraction in `data/repositories/`
- **Clean Architecture**: Separation of concerns across layers

### Adding New Features
1. Create BLoC in `logic/` directory
2. Add repository methods in `data/repositories/`
3. Create UI in `presentation/` directory
4. Register BLoC in `main.dart`

### State Management
The app uses BLoC pattern for state management:
- **AuthBloc**: Handles authentication state
- **RegistryBloc**: Manages student registry operations and WiFi connectivity
- **WifiBloc**: (Optional) Separate WiFi checking bloc

## 🔍 Troubleshooting

### WiFi Not Detected
- Ensure location permissions are granted
- Check that BSSID/SSID is correctly added to allowed lists
- Verify device is connected to the WiFi network
- Check console logs for actual BSSID/SSID values

### Firebase Connection Issues
- Verify `google-services.json` is in `android/app/`
- Check Firebase project configuration
- Ensure internet connectivity

### Build Issues
- Run `flutter clean` and `flutter pub get`
- Check Flutter SDK version (>=3.9.2)
- Verify all dependencies are compatible

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributors

- Initial development

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- BLoC library maintainers

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Note**: This app requires location permissions to access WiFi information on Android devices. Make sure to grant permissions when prompted. The WiFi validation uses BSSID (MAC address) for security, with SSID as a fallback option.