# ERFAN OXIGEN — Final UI Direction

This build uses one design language across the whole app: dark charcoal surfaces, metallic gold accents, premium glass cards, responsive spacing, a shared side drawer, subtle motion, and a men's barber/academy identity.

## Automatic login role detection
The first login screen asks for the mobile number only. The app looks up the number in the registered users/customers data:
- admin/teacher/student -> password step
- registered customer -> OTP step
- unknown number -> rejected before OTP generation

There is no role picker on the primary login flow.

## Men's-only visual direction
All course/service sample content was aligned toward men's barbering: fade, beard, classic cuts and men's hair color. Female/bridal sample items were removed from the default catalog.

## Build
```powershell
cd E:\Projects\Oxygen
flutter clean
flutter pub get
flutter analyze
flutter run
```

The generated poster `DESIGN_REFERENCE_ERFAN_OXIGEN.png` is only a visual reference; the live app UI is implemented using Flutter widgets and the shared design system in `lib/theme/app_theme.dart`.
