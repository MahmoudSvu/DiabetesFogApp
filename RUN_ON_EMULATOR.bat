@echo off
echo ========================================
echo تشغيل تطبيق مراقبة السكري على المحاكي
echo ========================================
echo.

echo [1/3] التحقق من المحاكيات المتاحة...
flutter emulators

echo.
echo [2/3] تشغيل المحاكي Pixel_9_Pro...
start /B flutter emulators --launch Pixel_9_Pro

echo.
echo انتظر 30 ثانية حتى يبدأ المحاكي...
timeout /t 30 /nobreak

echo.
echo [3/3] التحقق من الأجهزة المتصلة...
flutter devices

echo.
echo [4/4] تشغيل التطبيق...
echo إذا لم يظهر المحاكي، انتظر قليلاً ثم شغّل: flutter run
echo.

flutter run

pause

