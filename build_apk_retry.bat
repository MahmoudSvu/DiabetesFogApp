@echo off
echo ========================================
echo Flutter APK Builder with Retry Mechanism
echo ========================================
echo.

set MAX_RETRIES=3
set RETRY_COUNT=0

:RETRY_LOOP
set /a RETRY_COUNT+=1
echo.
echo Attempt %RETRY_COUNT% of %MAX_RETRIES%
echo.

REM Stop all Gradle daemons
echo Stopping Gradle daemons...
cd android
call gradlew.bat --stop >nul 2>&1
cd ..
echo Done.
echo.

REM Clean Flutter build
echo Cleaning Flutter build...
call flutter clean
if %errorlevel% neq 0 (
    echo [ERROR] Flutter clean failed!
    goto END
)
echo Done.
echo.

REM Get dependencies
echo Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Flutter pub get failed!
    goto END
)
echo Done.
echo.

REM Build APK with retry on network errors
echo Building APK (Release)...
echo This may take several minutes, please wait...
echo.

call flutter build apk --release
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [SUCCESS] APK built successfully!
    echo ========================================
    echo.
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
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
        echo [WARNING] APK file not found in expected location!
    )
    goto END
) else (
    echo.
    echo [ERROR] Build failed on attempt %RETRY_COUNT%
    echo.
    if %RETRY_COUNT% lss %MAX_RETRIES% (
        echo Waiting 10 seconds before retry...
        timeout /t 10 /nobreak >nul
        echo.
        echo Retrying...
        goto RETRY_LOOP
    ) else (
        echo.
        echo [ERROR] Build failed after %MAX_RETRIES% attempts!
        echo.
        echo Possible solutions:
        echo 1. Check your internet connection
        echo 2. Try using VPN if Google services are blocked
        echo 3. Wait a few minutes and try again (temporary server issues)
        echo 4. Try building from Android Studio
        echo 5. Check if firewall is blocking connections
    )
)

:END
echo.
pause

