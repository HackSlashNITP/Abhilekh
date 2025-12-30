# Abhilekh

A Flutter-based college student tracking and attendance management system that monitors student movements and restricts access to college WiFi networks.

## Overview

Abhilekh is a mobile application designed for educational institutions to track student entry and exit movements. The app ensures that only users connected to the college WiFi network can access the system, providing an additional layer of security and location verification.

## Features

### Authentication
-User Registration: Students and administrators can create accounts
- Secure Login: Email and password-based authentication using Firebase Auth
- Role-Based Access: Separate interfaces for students and administrators

### WiFi Access Control
- Network Verification: Automatically checks if the device is connected to the college WiFi network
- BSSID Validation: Validates the WiFi network using BSSID (Basic Service Set Identifier)
- Access Gate: Blocks app access if not connected to authorized WiFi networks

###  Student Panel
- Movement Tracking: View personal entry and exit history
- Status Display: Real-time display of current location status (inside/outside campus)
- Movement History: Access to timestamped movement records

## Admin Panel
- Student Management: View all registered students and their current status
- Movement Monitoring: Track student movements across the campus
- Filtering Options: Filter students by status (all students or students currently outside)
- Real-time Updates: Live updates of student locations and movements

### User Roles
- Student: Can view their own movement history and status
- Admin: Can view all students and their movements

### App Demo and apk
[open folder](https://drive.google.com/drive/folders/1s7gXr1IYfrCQSeLusm1chN-n-m470uiJ?usp=sharing)