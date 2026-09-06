# ERFAN OXIGEN V104 — audit fixes + Portfolio workflow + brand refresh

## Critical bug fix
- `initialRoute` was `/design-reference` (an internal preview gallery), so every real launch
  showed the mockup grid instead of the actual app. Fixed to `/splash`.

## Compliance with spec
- Removed all remaining "کاربر ارشد" strings (16 files) and replaced with "مدیر"/"مدیران".
  Internal `role: 'admin'` value is untouched.
- Removed 4 unreferenced/duplicate files: `role_screen.dart`, `login_backup.dart`,
  `main_backup.dart`, `customer_login_screen.dart`.

## New: Portfolio Workflow (spec section 9 — was previously just a static mock screen)
- `lib/models/portfolio_model.dart`, `lib/services/portfolio_service.dart`
- Student: submit with photo (`portfolio_screen.dart`, now real — was a hardcoded stub)
- Teacher: score + feedback or reject (`teacher/portfolio_review_screen.dart`, new)
- Manager: accept teacher score or enter an override score (`admin/portfolio_approval_screen.dart`, new)
- Final score rule implemented exactly as specified: manager override wins only if manager
  explicitly submits a replacement score; otherwise the teacher's score stands.
- Wired into all three dashboards + the role-aware side drawer, with notifications at each step.

## Brand refresh
- Replaced the placeholder painted "EO" logo mark with the real uploaded shield artwork
  (recolored gold-on-transparent for the dark theme, cropped mark-only variant for compact use).
- Added `google_fonts`: Vazirmatn for all Persian UI text, Cinzel for the "ERFAN OXIGEN" Latin
  wordmark specifically.

## Known limitation
This environment has no Flutter SDK / network access, so `flutter analyze`, `flutter test`,
and `flutter build apk` could not be run here. All edits were checked manually (import
resolution, brace/paren balance, duplicate-symbol scan) — run the real analyzer locally
before shipping.
