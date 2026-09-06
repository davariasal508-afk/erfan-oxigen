ERFAN OXIGEN V101 - Fixes

Reported problems fixed:
- chat_screen.dart: syntax/parentheses errors
- login_screen.dart: syntax/parentheses errors
- app_theme.dart: AppTheme color/method scoping and invalid const usage
- xp_service.dart: num/double type mismatch and loop style
- settings_screen.dart: async BuildContext lint
- main.dart/splash callbacks: unnecessary multiple underscores

Run in PowerShell:
cd E:\Projects\Oxygen
flutter pub get
flutter analyze
flutter run

If Kotlin daemon connection repeats after Dart errors are gone, run:
cd android
.\gradlew --stop
cd ..
flutter run
