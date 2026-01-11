@echo off
echo ========================================
echo Flutter APK Builder - Fixed Kotlin Daemon Issue
echo ========================================
echo.

REM Stop all Gradle daemons
echo Step 0: Stopping Gradle daemons...
cd android
call gradlew.bat --stop >nul 2>&1
cd ..
echo Done.
echo.

REM Clean Flutter build
echo Step 1: Cleaning Flutter build...
call flutter clean
if %errorlevel% neq 0 (
    echo [ERROR] Flutter clean failed!
    pause
    exit /b 1
)
echo Done.
echo.

REM Get dependencies
echo Step 2: Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Flutter pub get failed!
    pause
    exit /b 1
)
echo Done.
echo.

REM Build APK with specific flags to avoid Kotlin daemon issues
echo Step 3: Building APK (Release)...
echo This may take several minutes, please wait...
call flutter build apk --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] APK build failed!
    echo.
    echo Trying alternative build method...
    cd android
    call gradlew.bat assembleRelease --no-daemon
    cd ..
    if %errorlevel% neq 0 (
        echo.
        echo [ERROR] Alternative build method also failed!
        echo.
        echo Possible solutions:
        echo 1. Make sure Developer Mode is enabled in Windows
        echo 2. Check if Java JDK is properly installed
        echo 3. Try running as Administrator
        echo 4. Check Flutter installation: flutter doctor
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo Checking for APK file...
echo ========================================
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo.
    echo [SUCCESS] APK built successfully!
    echo.
    echo APK file location:
    echo %CD%\build\app\outputs\flutter-apk\app-release.apk
    echo.
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do (
        echo File size: %%~zA bytes
        echo Last modified: %%~tA
    )
    echo.
    echo You can now transfer this file to your Android 10 device and install it.
) else (
    echo.
    echo [WARNING] APK file not found in expected location!
    echo.
    echo Searching for APK files...
    dir /s /b build\*.apk 2>nul
    if %errorlevel% neq 0 (
        echo No APK files found. Build may have failed.
    )
)
echo.
pause

