# تعليمات إضافة لوغو التطبيق

## الخطوات:

### 1. إنشاء/إضافة ملفات اللوغو:
- ضع ملف `logo.png` (512x512) في مجلد `assets/logo/`
- ضع ملف `logo_icon.png` (192x192) في مجلد `assets/logo/`

### 2. تحديث pubspec.yaml:
تم تحديث `pubspec.yaml` بالفعل لإضافة:
```yaml
assets:
  - assets/images/
  - assets/logo/
```

### 3. تحديث أيقونة Android:
- ضع ملفات الأيقونة في `android/app/src/main/res/mipmap-*/`
- أو استخدم Android Asset Studio

### 4. تحديث أيقونة iOS:
- ضع ملفات الأيقونة في `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## ملاحظة:
حالياً، التطبيق يستخدم أيقونة Material Icons (monitor_heart) كبديل مؤقت.
بعد إضافة ملفات اللوغو، سيتم تحديث الكود لاستخدامها.

