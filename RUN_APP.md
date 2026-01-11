# تعليمات تشغيل التطبيق على المحاكي

## الخطوات:

### 1. التأكد من أن المحاكي يعمل:
```bash
flutter devices
```
يجب أن ترى `emulator-5554` في القائمة

### 2. تنظيف المشروع:
```bash
flutter clean
flutter pub get
```

### 3. تشغيل التطبيق:
```bash
flutter run -d emulator-5554
```

أو بشكل تفصيلي:
```bash
flutter run -d emulator-5554 --verbose
```

### 4. إذا لم يظهر التطبيق:

#### أ. تحقق من أن المحاكي يعمل بشكل صحيح:
- افتح Android Studio
- انتقل إلى Tools > Device Manager
- تأكد من أن المحاكي يعمل (Status: Running)

#### ب. أعد تشغيل المحاكي:
```bash
flutter emulators --launch Pixel_9_Pro
```
انتظر حتى يظهر "Home screen" على المحاكي

#### ج. تحقق من الأخطاء:
```bash
flutter run -d emulator-5554 2>&1 | findstr /i "error"
```

#### د. جرب Hot Restart:
بعد تشغيل التطبيق، اضغط `R` في Terminal لإعادة التشغيل

### 5. إذا استمرت المشكلة:

#### أ. تحقق من Logcat:
```bash
adb logcat | findstr /i "flutter"
```

#### ب. أعد بناء التطبيق:
```bash
flutter build apk --debug
adb install build\app\outputs\flutter-apk\app-debug.apk
```

#### ج. تحقق من الصلاحيات:
تأكد من أن التطبيق لديه الصلاحيات المطلوبة في AndroidManifest.xml

### 6. نصائح إضافية:

- تأكد من أن المحاكي لديه اتصال بالإنترنت
- تأكد من أن Google Play Services محدثة على المحاكي
- جرب إعادة تشغيل المحاكي
- تأكد من أن Flutter SDK محدث

