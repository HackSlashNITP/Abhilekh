# 📍 Abhilekh - Campus Registry App

**Abhilekh**  is a smart student registry application built with Flutter. It replaces manual entry registers with a secure, location-aware digital system.

The core idea is simple: **You can only mark your attendance if you are actually on campus.**

To achieve this, the app uses a "Double-Lock" validation system:
1.  🌍 **Geofencing:** Checks if the student is within a 100m radius of the campus center.
2.  📶 **Wi-Fi Hardware Check:** Verifies that the student is connected to the specific Campus Router by checking its BSSID (MAC Address), which—unlike a Wi-Fi name—is much harder to spoof.

## 🚀 Features

* **Secure Auth:** Student Login & Sign-up powered by Firebase Authentication.
* **Smart Attendance:** One-tap "Enter Campus" and "Leave Campus" buttons that only work when validation passes.
* **Real-time Status:** Shows if you are currently marked "Inside" or "Outside" (synced via Firestore).
* **Hardware Validation:** Utilizes device sensors (GPS) and Network info to prevent proxy attendance.
* **State Management:** Built using the **BLoC pattern** for clean, predictable code.

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **Backend:** Firebase (Auth & Firestore)
* **State Management:** flutter_bloc
* **Architecture:** Clean Architecture (Separation of Domain, Data, and Presentation)
* **Key Packages:**
    * `geolocator` (For GPS coordinates)
    * `network_info_plus` (For Wi-Fi BSSID reading)
    * `get_it` (Dependency Injection)

---

## ⚙️ How to Run This Project

Since this app relies on Firebase and hardware sensors, you need to do a little setup.

### 1. Prerequisites
* Flutter SDK installed.
* A physical Android device (Simulators **cannot** access Wi-Fi BSSID, so the app will likely fail on a laptop emulator).

### 2. Setup Firebase
This app uses Firebase. You need to connect it to your own project:
1.  Install the CLI: `dart pub global activate flutterfire_cli`
2.  Run configuration: `flutterfire configure`
3.  Select your Firebase project and platforms. This generates the `lib/firebase_options.dart` file automatically.

### 3. Configure Campus Location
The app needs to know *where* your campus is.
* Open `lib/core/constants/app_constants.dart`.
* Update the variables with your actual testing location:
