# Sarastya Drive Mobile

Flutter client for **Sarastya Drive**, a Telegram-backed cloud drive. 
This application provides a focused read and stream client for mobile users to browse their cloud drive, search items, and stream videos directly from the cloud.

## Features
- JWT Authentication via backend REST API
- Browse folders and items as a grid
- Search functionality
- View item details (metadata, parts)
- Video Streaming using Chewie and VideoPlayer
- Direct downloads deep linking to the Telegram Bot

## Requirements
- Flutter SDK (stable channel)
- Android SDK for building the APK

## Running Locally
1. Clone the repository and checkout the `feat/cloud-drive` branch.
2. Run `flutter pub get` to fetch dependencies.
3. Start the application on a connected device or emulator with `flutter run`.

## Build APK Instructions

To build a release APK for Android:

```bash
flutter build apk --release
```

Once the build process is complete, the generated APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

You can attach this APK to a GitHub Release or distribute it directly to users. Users will need to enable "Install unknown apps" to install the APK on their Android devices.

## API Integration
The application connects to the .NET REST API via `https://drive.tncp.web.id/papi` and fetches stream URLs from `stream.tncp.web.id`. Ensure the VPS deployment is up and running.
