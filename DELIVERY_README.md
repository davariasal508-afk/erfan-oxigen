ERFAN OXIGEN V101 - Tailscale-ready build

# ERFAN OXIGEN — Ultra Upgrade

این نسخه، نسخه توسعه‌یافته پروژه ERFAN OXIGEN است.

## قابلیت‌های موجود/ارتقایافته
- برند ثابت: ERFAN OXIGEN
- Splash و Login حرفه‌ای
- نقش‌های Admin / Teacher / Student
- Permission
- ذخیره محلی کاربران و آزمون‌ها
- XP / Level / Streak / Badge
- XP قابل تنظیم از پنل ارشد
- نام نمایشی کاربر ارشد (پیش‌فرض: عرفان) قابل تغییر
- Chat حرفه‌ای با پشتیبانی UI برای متن، تصویر، فایل و ویدئو تا ۶۰ ثانیه
- OXIGEN Market / Flash Sale / تخفیف / کد تخفیف
- Portfolio / Courses / Certificate
- Beauty Studio / Color Lab
- Backend محلی با Dart بدون نیاز به نصب Node

## Backend بدون دستکاری سیستم
سرور فقط داخل پوشه پروژه داده ذخیره می‌کند:

```powershell
dart run backend/server.dart
```

داده‌ها در:

`backend/data/`

ذخیره می‌شوند. هیچ فایل سیستمی خارج از پروژه حذف یا overwrite نمی‌شود.

## اجرای برنامه
```powershell
flutter pub get
flutter analyze
flutter run
```

## اتصال اپ به سرور
در تنظیمات مدیر، Backend را روشن کنید و IP سیستم + پورت 8787 را وارد کنید.
مثلاً:

`http://192.168.1.20:8787`

این نسخه عمداً حالت fallback محلی را حفظ می‌کند تا در صورت خاموش بودن سرور، اپ خراب نشود.
