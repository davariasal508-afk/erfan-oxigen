# ERFAN OXIGEN Backend - Tailscale mode

For remote access without a public server or domain, use Tailscale. Install Tailscale on the Windows server and each approved Android device, then use the server Tailscale IPv4 with port 8787 as the app Backend URL.

Official downloads:
- Windows: https://tailscale.com/download/windows
- Android: https://tailscale.com/download/android
- Google Play: https://play.google.com/store/apps/details?id=com.tailscale.ipn

## Quick start

```powershell
tailscale ip -4
powershell -ExecutionPolicy Bypass -File .\backend\run_tailscale_server.ps1 -Port 8787
```

The remaining local-server notes are below.

# ERFAN OXIGEN Backend — V100

این backend یک سرور Dart محلی/شبکه‌ای برای پروژه ERFAN OXIGEN است. داده‌ها فقط در پوشه‌های پروژه ذخیره می‌شوند و به‌صورت پیش‌فرض هیچ فایل خارج از پروژه را حذف نمی‌کنند.

## اجرای سریع در همین سیستم
از ریشه پروژه:

```powershell
dart run backend/server.dart
```

پیش‌فرض:
- Host: `0.0.0.0`
- Port: `8787`
- Data: `backend/data/`
- Files: `backend/files/`

تست:

```powershell
curl.exe http://127.0.0.1:8787/health
```

## اجرای امن‌تر با Token
برای شبکه‌ای که فقط به Private/LAN محدود نیست، یک token تعیین کن:

```powershell
$env:OXIGEN_API_TOKEN="CHANGE_ME_LONG_SECRET"
dart run backend/server.dart
```

یا:

```powershell
dart run backend/server.dart --token=CHANGE_ME_LONG_SECRET
```

## تغییر مسیر داده
برای اینکه داده‌ها کنار سورس نباشند:

```powershell
$env:OXIGEN_DATA_DIR="E:\OxygenServerData\data"
$env:OXIGEN_FILES_DIR="E:\OxygenServerData\files"
dart run backend/server.dart
```

این روش برای سیستم سرور جداگانه توصیه می‌شود.

## APIهای اصلی
- `GET /health`
- `GET /meta`
- `GET /api/snapshot`
- `POST /api/snapshot`
- `GET /api/data/<name>`
- `POST /api/data/<name>`

نام‌های پیش‌فرض: `users`, `exams`, `chat_messages`, `chat_threads`, `ads`, `admin_profile`, `portfolio`, `courses`, `certificates`, `notifications`, `schedule`, `customers`, `view_events`.

## انتقال سرور به سیستم دیگر
ساده‌ترین روش:

1. کل پروژه را به سیستم جدید منتقل کن.
2. `backend/data/` را هم منتقل کن تا کاربران و داده‌ها حفظ شوند.
3. روی سیستم جدید Flutter/Dart را نصب کن.
4. داخل پروژه `flutter pub get` بزن.
5. backend را اجرا کن.
6. IP سیستم جدید را پیدا کن:

```powershell
ipconfig
```

7. داخل برنامه، در تنظیمات Backend، آدرس را روی این شکل بگذار:

```text
http://IP-SYSTEM:8787
```

مثلاً:

```text
http://192.168.1.20:8787
```

8. Windows Firewall را فقط برای شبکه Private و فقط روی TCP 8787 اجازه بده.

### نکته مهم
اگر سرور قرار است واقعاً روی یک سیستم سرور دائمی باشد، `backend/data` و `backend/files` را روی یک درایو/پوشه مخصوص داده نگه دار؛ سورس پروژه و داده‌ها را از هم جدا کن. برای مهاجرت، فقط همان دو پوشه داده را کپی کن.

## Backup
قبل از انتقال یا تغییرات:

```powershell
Copy-Item backend\data E:\OxygenServerBackup\data -Recurse -Force
Copy-Item backend\files E:\OxygenServerBackup\files -Recurse -Force
```

برای backup واقعی، پوشه داده‌ها را هنگام خاموش بودن server کپی کن.
