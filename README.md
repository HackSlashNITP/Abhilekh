# Abhilekh
# 🎓 College Gate Registry App (GateKeeper)

A secure, location-restricted mobile application designed to streamline the entry and exit process for college students. This app replaces manual logbooks with a digital, real-time tracking system that ensures accurate attendance and campus safety.

## 🚀 Overview

The **College Gate Registry** serves two main user groups:
1.  **Students:** Allows quick check-in and check-out at the campus gate.
2.  **Admins:** Provides a real-time dashboard to monitor how many students are off-campus and view historical logs.

> **Note:** This application is designed to function **strictly** within the college campus premises.

## 🛡️ Security Architecture: BSSID Validation

To ensure the integrity of the attendance data, this app implements **Hardware-Level Location Validation**.

### Why BSSID instead of SSID?
Most apps rely on the **SSID** (Network Name, e.g., "College_WiFi") to verify if a user is on campus. However, SSIDs are easily spoofed—a student could simply rename their personal mobile hotspot to "College_WiFi" to bypass restrictions and check out from home.

**This app uses BSSID (Basic Service Set Identifier) validation.**
* **How it works:** We validate the unique **MAC address** of the wireless access point (router) at the college gate.
* **The Benefit:** BSSID is tied to the physical hardware. It is significantly harder to spoof than a network name, ensuring that a check-in/out action can *only* occur when the device is physically connected to the authorized college gate router.

## ✨ Key Features

### 🧑‍🎓 Student View
* **One-Tap Action:** Simple interface to switch status between "Inside Campus" and "Outside Campus."
* **Live Status Indicator:** Visual cues (Green/Red) showing current status.
* **Wi-Fi Lock:** The interface remains locked unless connected to the specific College Gate Wi-Fi hardware.

### 👮 Admin View
* **Real-Time Metrics:** Instantly see the total count of students currently outside the campus.
* **Student Directory:** Searchable list of all students.
* **Movement History:** Detailed logs of every entry and exit with timestamps for audit purposes.
* **Status Indicators:** Quick visual tags to see who is currently in or out.

## 🛠️ Tech Stack
* **Frontend:** [Insert Framework, e.g., Flutter / React Native]
* **Backend:** [Insert Backend, e.g., Firebase / Node.js]
* **Database:** [Insert Database]
* **Connectivity:** Native Wi-Fi Info packages for BSSID retrieval.

## 📸 Screenshots
| Student View (Locked) | Student View (Active) | Admin Dashboard |
|:---:|:---:|:---:|
| *[Insert Image]* | *[Insert Image]* | *[Insert Image]* |

## ⚙️ Installation & Setup

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/yourusername/college-registry-app.git](https://github.com/yourusername/college-registry-app.git)
    ```
2.  **Install Dependencies**
    ```bash
    [Insert command, e.g., flutter pub get]
    ```
3.  **Configure BSSID**
    * Open `lib/config/constants.dart` (or your config file).
    * Update the `ALLOWED_BSSIDS` array with the MAC addresses of your college gate routers.
4.  **Run the App**
    ```bash
    [Insert command, e.g., flutter run]
    ```

## 🤝 Contribution
Contributions are welcome! Please ensure any changes to the Wi-Fi validation logic are thoroughly tested to maintain security standards.

## 📄 License
This project is licensed under the MIT License.