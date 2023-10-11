# Onfly

## Project Description

Onfly is an app designed for travelers, with a focus on managing expenses during their journeys. One of the most essential tasks for travelers is tracking their expenses, and Onfly simplifies this process.

### Key Features

- List and view travel expenses.
- Add new expenses.
- Edit or delete existing expenses.
- Offline Expense Entry: Allows travelers to log expenses even without an internet connection.
- Synchronization: Automatically syncs offline expenses with the backend (API) when an internet connection is available.

## Technologies and Packages Used

Onfly is built using the following technologies and packages:

- [Flutter](https://flutter.dev/): A cross-platform app development framework.
- [Dart](https://dart.dev/): The programming language for Flutter.
- [flex_color_scheme](https://pub.dev/packages/flex_color_scheme): A package for creating beautiful color schemes in Flutter.
- [hooks_riverpod](https://pub.dev/packages/hooks_riverpod): A state management package for Flutter.
- [path_provider](https://pub.dev/packages/path_provider): A package for platform-specific file and directory access.
- [isar](https://pub.dev/packages/isar): A high-performance, easy-to-use database for Flutter.
- [isar_flutter_libs](https://pub.dev/packages/isar_flutter_libs): Flutter libraries for Isar.
- [collection](https://pub.dev/packages/collection): A set of utility functions and classes related to collections.
- [uuid](https://pub.dev/packages/uuid): A package for generating universally unique identifiers (UUIDs).
- [intl](https://pub.dev/packages/intl): A package for internationalization and localization in Dart.
- [http](https://pub.dev/packages/http): A package for making HTTP requests in Dart.
- [internet_connection_checker](https://pub.dev/packages/internet_connection_checker): A package for checking internet connectivity in Flutter apps.
- [geolocator](https://pub.dev/packages/geolocator): Provides precise location information (latitude, longitude, etc.) for accurate expense tracking.


## Installation and Setup

Follow these steps to set up and run the Onfly app:

1. Clone this repository to your local environment:
git clone https://github.com/yvesat/Onfly.git

2. Navigate to the project directory:
cd onfly

3. Install the required dependencies:
flutter pub get

4. Run the app:
flutter run

## Testing

If you want to run tests for the Onfly app, use the following command:
flutter test