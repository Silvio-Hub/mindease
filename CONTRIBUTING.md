# Contributing

This project uses GitHub Actions for Continuous Integration (CI).

## CI Pipeline

The CI workflow is defined in `.github/workflows/flutter_ci.yml`. It runs on every push and pull request to the `main` branch.

### Steps performed:
1.  **Checkout code**: Retrieves the latest code.
2.  **Set up Java**: Installs Java 17.
3.  **Set up Flutter**: Installs the latest stable Flutter SDK.
4.  **Install dependencies**: Runs `flutter pub get`.
5.  **Code Generation**: Runs `dart run build_runner build` to generate code (e.g., for Hive).
6.  **Analyze**: Runs `flutter analyze` to check for lint errors.
7.  **Test**: Runs `flutter test` to execute unit and widget tests.
8.  **Build**: Builds a debug APK for the `production` flavor to ensure the build process works.

## Running CI Locally

You can simulate the CI steps locally by running:

```bash
# 1. Install dependencies
flutter pub get

# 2. Run code generation
dart run build_runner build --delete-conflicting-outputs

# 3. Analyze code
flutter analyze

# 4. Run tests
flutter test

# 5. Build production APK
flutter build apk --debug --flavor production --target lib/app/main_production.dart
```
