# Project Zoe Mobile App

This is the official mobile application for Project Zoe, built with Flutter. It serves as the frontend for the Project Zoe ecosystem and is designed to work with the [Project Zoe Backend](../backend/README.md).

## Description

This Flutter application provides a mobile interface for users to interact with the Project Zoe platform. As it is in the early stages of development, it currently contains the basic setup for a Flutter project.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

-   **Flutter SDK**: This project uses a Dart SDK version compatible with `^3.9.2`. You can find installation instructions on the [official Flutter website](https://flutter.dev/docs/get-started/install).
-   **An IDE**: It is recommended to use [Visual Studio Code](https://code.visualstudio.com/) with the Flutter extension, or [Android Studio](https://developer.android.com/studio) / [IntelliJ IDEA](https://www.jetbrains.com/idea/) with the Flutter plugin.
-   **A Target Device**: You will need either a physical mobile device (Android or iOS) or an emulator/simulator set up in your development environment.

## Getting Started

Follow these steps to get the application running on your local machine.

### 1. Clone the Repository

If you haven't already, clone the main project repository to your local machine.

### 2. Navigate to the Frontend Directory

All commands must be run from the `frontend` directory:
```bash
cd frontend
```

### 3. Install Dependencies

Install the necessary packages for the project by running:
```bash
flutter pub get
```

## Running the Application

1.  **Ensure the Backend is Running**: This mobile app will likely require the backend service to be running to function correctly. Please refer to the [backend README](../backend/README.md) for instructions on how to run it.

2.  **Run the App**: Make sure you have a device connected or an emulator running. Then, start the application using the following command:
    ```bash
    flutter run
    ```

The application will be built and installed on your target device. The console will display the logs, and the app will launch automatically.

## Project Structure

The main source code for the application is located in the `lib` directory.

-   `lib/main.dart`: The entry point of the application.
-   `pubspec.yaml`: Defines the project's metadata and dependencies.
-   `assets/`: This directory (if created) will contain static assets like images and fonts.
-   `test/`: Contains the tests for the application.

## Building for Production

To create a production build of the application, you can use the following commands:

-   **Android**:
    ```bash
    flutter build apk --release
    ```
    The output APK will be located in `build/app/outputs/flutter-apk/`.

-   **iOS**:
    ```bash
    flutter build ipa --release
    ```
    This requires a valid Apple Developer account and code signing configuration.

For more detailed instructions on building and releasing, please refer to the official Flutter documentation on [Android](https://flutter.dev/docs/deployment/android) and [iOS](https://flutter.dev/docs/deployment/ios) deployment.
