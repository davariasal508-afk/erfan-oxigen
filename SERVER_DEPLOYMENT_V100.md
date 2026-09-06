# ERFAN OXIGEN V100 — راه‌اندازی سرور و انتقال به سیستم دیگر

## اصل مهم
این پروژه برای راه‌اندازی سرور، هیچ‌کدام از برنامه‌ها یا فایل‌های شخصی ویندوز را حذف نمی‌کند. Backend فقط در مسیرهای تعیین‌شده توسط خودت داده می‌نویسد.

## سیستم فعلی
1. از ریشه پروژه اجرا کن:

```powershell
dart run backend/server.dart
```

2. در یک PowerShell دیگر:

```powershell
curl.exe http://127.0.0.1:8787/health
```

باید `ok: true` ببینی.

3. برای دسترسی گوشی‌های همان Wi‑Fi:

```powershell
ipconfig
```

IPv4 سیستم را پیدا کن، مثلاً `192.168.1.20`.

4. داخل برنامه از تنظیمات Backend، آدرس را بگذار:

```text
http://192.168.1.20:8787
```

## اگر گوشی به سرور وصل نشد
PowerShell را با Administrator باز کن و فقط برای Private Network پورت 8787 را باز کن:

```powershell
New-NetFirewallRule -DisplayName "ERFAN OXIGEN Backend 8787" -Direction Inbound -Protocol TCP -LocalPort 8787 -Action Allow -Profile Private
```

برای بستن همان Rule:

```powershell
Remove-NetFirewallRule -DisplayName "ERFAN OXIGEN Backend 8787"
```

## انتقال سرور به سیستم جدید
### روی سیستم قبلی
سرور را متوقف کن (`Ctrl+C`) و از پوشه داده Backup بگیر:

```powershell
cd E:\Projects\Oxygen
powershell -ExecutionPolicy Bypass -File .\backend\backup_data.ps1 -Destination E:\OxygenServerBackup\latest
```

حداقل این دو پوشه باید منتقل شوند:

```text
backend\data\
backend\files\
```

اگر فایل‌های حجیم داری، پوشه `backend\files` را هم کامل منتقل کن.

### روی سیستم جدید
1. Flutter/Dart نصب باشد.
2. ZIP پروژه را Extract کن.
3. Backup `data` و `files` را در همین مسیرها برگردان:

```text
E:\Projects\Oxygen\backend\data\
E:\Projects\Oxygen\backend\files\
```

4. داخل پروژه:

```powershell
cd E:\Projects\Oxygen
flutter pub get
flutter analyze
```

5. سرور:

```powershell
dart run backend/server.dart
```

6. IP جدید سیستم را بگیر:

```powershell
ipconfig
```

7. آدرس Backend برنامه را با IP جدید تنظیم کن:

```text
http://IP-NEW-SYSTEM:8787
```

## نگه داشتن داده‌ها خارج از سورس (توصیه‌شده برای سرور دائمی)
روی سرور جدید:

```powershell
New-Item -ItemType Directory -Force E:\OxygenServerData\data | Out-Null
New-Item -ItemType Directory -Force E:\OxygenServerData\files | Out-Null
```

سپس:

```powershell
$env:OXIGEN_DATA_DIR="E:\OxygenServerData\data"
$env:OXIGEN_FILES_DIR="E:\OxygenServerData\files"
dart run backend/server.dart
```

در این حالت با تعویض سورس پروژه، داده‌های کاربران و فایل‌ها سر جایشان می‌مانند.

## اجرای سرور با PowerShell Script

```powershell
powershell -ExecutionPolicy Bypass -File .\backend\run_server.ps1 -Port 8787
```

## امنیت
حالت پیش‌فرض برای شبکه داخلی است. برای اینترنت عمومی، بدون احراز هویت و TLS سرور را مستقیم expose نکن. در صورت نیاز یک reverse proxy یا تونل امن جلوی آن قرار بده.
