# ERFAN OXIGEN Offline Android Setup

Target toolchain:
- Flutter 3.44.8
- AGP 8.9.1
- Gradle 8.11.1
- Kotlin 2.2.20

If the local offline Gradle home exists at `D:\Oxygen-AGP-8.9.1-Offline`, use the project Gradle wrapper and set `GRADLE_USER_HOME` to that path before building.

PowerShell:
```powershell
$env:GRADLE_USER_HOME='D:\Oxygen-AGP-8.9.1-Offline'
cd E:\Projects\Oxygen
flutter clean
flutter pub get
flutter analyze
flutter run
```

Do not delete Windows files or the existing Flutter installation.
