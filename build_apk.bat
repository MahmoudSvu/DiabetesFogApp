@echo off
echo Building APK for Android 10...
echo.

echo Step 1: Cleaning previous builds...
call flutter clean
echo.

echo Step 2: Getting dependencies...
call flutter pub get
echo.

echo Step 3: Building APK (Release)...
call flutter build apk --release
echo.

echo.
echo ========================================
echo Build completed!
echo ========================================
echo.
echo APK file location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo You can now transfer this file to your Android 10 device and install it.
echo.
pause

