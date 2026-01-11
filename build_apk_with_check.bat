@echo off
echo ========================================
echo Flutter APK Builder with Developer Mode Check
echo ========================================
echo.

echo Checking Developer Mode status...
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [WARNING] Developer Mode may not be enabled!
    echo.
    echo Please enable Developer Mode:
    echo 1. Press Windows + I
    echo 2. Go to Update ^& Security ^> For developers
    echo 3. Enable "Developer Mode"
    echo 4. Restart your computer if prompted
    echo.
    echo Opening Developer Mode settings...
    start ms-settings:developers
    echo.
    echo Press any key after enabling Developer Mode to continue...
    pause >nul
)

echo.
echo Step 1: Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 (
    echo [ERROR] Flutter clean failed!
    pause
    exit /b 1
)

echo.
echo Step 2: Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Flutter pub get failed!
    pause
    exit /b 1
)

echo.
echo Step 3: Building APK (Release)...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] APK build failed!
    echo.
    echo Possible solutions:
    echo 1. Make sure Developer Mode is enabled
    echo 2. Run this script as Administrator
    echo 3. Check Flutter installation: flutter doctor
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build completed successfully!
echo ========================================
echo.
echo APK file location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo File size:
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    dir "build\app\outputs\flutter-apk\app-release.apk" | find "app-release.apk"
) else (
    echo [WARNING] APK file not found in expected location!
)
echo.
echo You can now transfer this file to your Android 10 device and install it.
echo.
pause

