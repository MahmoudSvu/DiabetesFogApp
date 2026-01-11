# حل مشاكل الاتصال بالإنترنت أثناء بناء APK

## المشكلة:
```
Could not GET 'https://repo.maven.apache.org/maven2/...'
No such host is known (repo.maven.apache.org)
```

## الحلول:

### 1. التحقق من الاتصال بالإنترنت
- تأكد من أن اتصالك بالإنترنت يعمل
- جرب فتح `https://repo.maven.apache.org` في المتصفح

### 2. استخدام VPN أو Proxy
إذا كنت في منطقة محظورة:
- استخدم VPN
- أو قم بإعداد Proxy في Gradle

### 3. إضافة Mirrors بديلة
تم إضافة mirrors بديلة في ملفات Gradle:
- `https://jcenter.bintray.com/`
- `https://repo1.maven.org/maven2/`

### 4. استخدام Offline Mode (إذا كانت التبعيات محملة مسبقاً)
```bash
cd android
gradlew.bat assembleRelease --offline
```

### 5. تنظيف Cache وإعادة المحاولة
```bash
cd android
gradlew.bat clean
gradlew.bat --refresh-dependencies
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### 6. استخدام Gradle Wrapper مع إعدادات Proxy
إذا كنت تستخدم Proxy، أضف في `gradle.properties`:
```properties
systemProp.http.proxyHost=your.proxy.host
systemProp.http.proxyPort=8080
systemProp.https.proxyHost=your.proxy.host
systemProp.https.proxyPort=8080
```

### 7. بناء بدون Internet (إذا كانت التبعيات محملة)
```bash
flutter build apk --release --offline
```

## ملاحظات:
- البناء الأول قد يستغرق وقتاً طويلاً لأنه يحتاج لتحميل جميع التبعيات
- تأكد من أن Developer Mode مفعّل في Windows
- إذا استمرت المشكلة، جرب البناء من Android Studio مباشرة

