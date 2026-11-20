RAI | راي — إصدار الربط بقاعدة بيانات مشتركة
===============================================

محتويات الحزمة:
- index.html: المتجر العام.
- admin.html: لوحة الإدارة المستقلة.
- rai-config.js: ضع فيه رابط مشروع Supabase ومفتاح anon/public.
- supabase-setup.sql: إنشاء الجداول والصلاحيات.
- README-AR.txt: هذه التعليمات.

مهم: لا يمكن جعل النظام متصلاً فعلياً بمجرد رفع الملفات. يلزم إنشاء مشروع Supabase مرة واحدة وربط بياناته. لا أستطيع إنشاء الحساب أو قبول شروطه نيابة عنك، ولا تضع كلمة مرورك أو مفاتيح الخدمة السرية في GitHub.

الخطوات:
1) أنشئ مشروعاً في https://supabase.com/ وسجل الدخول.
2) من مشروعك افتح SQL Editor ثم New query.
3) افتح ملف supabase-setup.sql وانسخ كل محتواه إلى المحرر ثم اضغط Run.
4) افتح Project Settings > API (أو Data API/Connect حسب الواجهة).
5) انسخ Project URL و anon/public key فقط.
6) افتح rai-config.js وعدّل:
   url: "https://YOUR_PROJECT_ID.supabase.co"
   anonKey: "YOUR_SUPABASE_ANON_PUBLIC_KEY"
   وضع القيم التي نسختها. لا تستخدم service_role key مطلقاً.
7) في Supabase افتح Authentication > Users > Add user، وأنشئ مستخدماً ببريدك وكلمة مرور قوية.
8) بعد إنشاء المستخدم، افتح SQL Editor وشغّل هذا الأمر بعد استبدال USER_UUID بمعرف المستخدم من Authentication > Users:
   insert into public.profiles(id, username, role)
   values ('USER_UUID', 'مدير راي', 'admin')
   on conflict (id) do update set role='admin';
9) ارفع الملفات الأربعة إلى جذر مستودع GitHub (استبدل index.html وadmin.html القديمين، وأضف rai-config.js وsupabase-setup.sql وREADME-AR.txt).
10) انتظر GitHub Pages ثم افتح:
   المتجر: https://bwtyksmtjr-commits.github.io/RAI-STORE/
   الإدارة: https://bwtyksmtjr-commits.github.io/RAI-STORE/admin.html

بعد الربط:
- الطلبات التي يرسلها الزوار تحفظ في قاعدة البيانات وتظهر في لوحة الإدارة.
- رقم الطلب ينشأ عند التأكيد.
- المنتجات والأقسام تُقرأ من قاعدة البيانات ويمكن إدارتها من اللوحة.
- لوحة الإدارة تتطلب تسجيل دخول Supabase Auth.
- إعدادات اللوحة تسمح بتعديل اسم المستخدم الظاهر ورقم وبريد التواصل وتغيير بريد/كلمة مرور دخول المدير.

ملاحظات:
- هذا الإصدار يرسل الطلبات ويخزنها، لكنه لا يتضمن بوابة دفع أو خدمة شحن.
- نموذج الشكاوى في واجهة المتجر يحتاج ربط حقل الإرسال بجدول complaints إذا أضفت نموذج الشكاوى لاحقاً.
- لا تنشر أي service_role key أو كلمة مرور أو بيانات سرية في ملفات GitHub.
- لأمان إضافي: فعّل تأكيد البريد، استخدم كلمة مرور قوية، ولا تشارك بيانات دخول المدير.
