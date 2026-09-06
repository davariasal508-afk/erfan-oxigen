# ERFAN OXIGEN — Phone Test Checklist

## Android test
1. Extract this project to a new folder, e.g. `E:\Projects\Oxygen`.
2. Run `flutter pub get`.
3. Run `flutter analyze` and make sure there are no errors.
4. Run `flutter run` with the Android phone connected.

## Recommended Android toolchain
- Flutter 3.44.8
- AGP 8.9.1
- Gradle 8.11.1
- Kotlin 2.2.20

If using the prepared offline Gradle environment:
`$env:GRADLE_USER_HOME="D:\Oxygen-AGP-8.9.1-Offline"`

## What to review on the phone
- Splash / ERFAN OXIGEN branding
- Login routing for admin/teacher/student/customer
- Admin dashboard and side navigation
- Students / teachers / customers
- Exams and grade workflow
- Chat screens
- Schedule and notifications
- Beauty Studio and course prices
- Customer home and birthday offer
- Logout / session persistence

Note: this is a review build for device testing. The backend still needs to be run separately if online/network features are being tested.
