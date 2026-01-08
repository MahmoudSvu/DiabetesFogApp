# تفعيل Developer Mode في Windows

## المشكلة:
عند بناء تطبيق Flutter مع plugins، قد تواجه رسالة:
```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

## الحل:

### الطريقة الأولى: من خلال الإعدادات
1. اضغط `Windows + I` لفتح إعدادات Windows
2. اذهب إلى: **Update & Security** > **For developers**
3. فعّل **Developer Mode**
4. قد يطلب منك إعادة تشغيل الكمبيوتر

### الطريقة الثانية: من خلال الأمر
1. اضغط `Windows + R`
2. اكتب: `ms-settings:developers`
3. اضغط Enter
4. فعّل **Developer Mode**

### الطريقة الثالثة: من خلال PowerShell (كمسؤول)
```powershell
# فتح الإعدادات مباشرة
start ms-settings:developers
```

## بعد التفعيل:
1. أعد تشغيل الكمبيوتر (إن طُلب منك)
2. افتح Command Prompt أو PowerShell
3. انتقل إلى مجلد المشروع
4. نفّذ الأوامر:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

## ملاحظات:
- Developer Mode يسمح لـ Windows بإنشاء symlinks (روابط رمزية) التي تحتاجها plugins
- هذا آمن ولا يؤثر على أمان النظام
- قد تحتاج إلى صلاحيات المسؤول في بعض الحالات

