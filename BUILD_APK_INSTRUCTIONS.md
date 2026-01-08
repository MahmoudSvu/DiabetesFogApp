# تعليمات بناء APK للتطبيق

## الطريقة الأولى: استخدام Flutter CLI

1. افتح Terminal أو Command Prompt في مجلد المشروع
2. قم بتنفيذ الأوامر التالية:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

3. بعد اكتمال البناء، ستجد ملف APK في المسار التالي:
   - `build/app/outputs/flutter-apk/app-release.apk`

## الطريقة الثانية: استخدام Android Studio

1. افتح المشروع في Android Studio
2. انتقل إلى: Build > Flutter > Build APK
3. اختر "Release" عند السؤال
4. ستجد ملف APK في نفس المسار المذكور أعلاه

## تثبيت APK على جهاز Android 10

1. انقل ملف `app-release.apk` إلى جهاز Android
2. على الجهاز، افتح الإعدادات > الأمان
3. فعّل "السماح بتثبيت التطبيقات من مصادر غير معروفة"
4. افتح ملف APK من مدير الملفات
5. اضغط "تثبيت"

## ملاحظات مهمة

- تأكد من أن جهاز Android 10 يدعم Android API level 21 أو أعلى
- قد تحتاج إلى تفعيل "مصادر غير معروفة" في إعدادات الأمان
- إذا واجهت مشاكل، تأكد من أن Flutter SDK مثبت بشكل صحيح

