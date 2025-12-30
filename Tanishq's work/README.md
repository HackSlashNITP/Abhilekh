# Abhilekh: Smart Gate Access System

**Abhilekh** is a secure campus management ecosystem built with Flutter and Firebase. It monitors student movement in real-time using **BSSID (MAC Address) hardware verification** to ensure logs are only created at the authorized campus gate.



## 🔒 Why BSSID Verification?

Unlike SSID (WiFi Name) which can be easily spoofed with a mobile hotspot, **Abhilekh** validates the unique hardware ID of the router:
* **Authorized BSSID:** `f0:ed:b8:ad:5f:e5`
* **Security:** Prevents students from faking their location.
* **Integrity:** Requires system-level GPS to be active, adding a second layer of location verification.

## 🚀 Features

### Mobile Student App
* **Tap-to-Log:** Modern interface with haptic feedback and scale animations.
* **Auto-Toggle:** Automatically switches between "Entry" and "Exit" based on history.
* **Timeline View:** Animated personal activity history.

### Admin Web Dashboard
* **Live Analytics:** Real-time metrics for "Total Movements" and "Students Outside."
* **Clutter-Free Logs:** A spacious, searchable table for monitoring movements.
* **Minimalist Design:** Optimized for security staff to monitor traffic at a glance.



## 🛠️ Tech Stack
* **Frontend:** Flutter (Mobile & Web)
* **Backend:** Firebase (Auth & Firestore)
* **Network Scan:** `network_info_plus`

## 📦 Local Setup
1. **Configure Firebase:** `flutterfire configure --platforms="android,ios,web"`
2. **Run Mobile:** `flutter run`
3. **View Dashboard:** `flutter run -d chrome` (Append `/#/admin` to the URL).



To access the app apk and assets, follow this drive link at it's finest.
https://drive.google.com/drive/folders/1BtDVOq0KsyKn1RYiMpjkjp4VNg5HPTZm?usp=sharing
