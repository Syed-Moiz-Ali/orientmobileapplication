// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'shared_core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SharedCoreLocalizationsAr extends SharedCoreLocalizations {
  SharedCoreLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonErrorTitle => 'حدث خطأ ما';

  @override
  String get commonSearchHint => 'بحث';

  @override
  String get commonClearSearch => 'مسح البحث';

  @override
  String get commonLanguage => 'اللغة';

  @override
  String get commonEnglish => 'English';

  @override
  String get commonArabic => 'العربية';

  @override
  String get commonSelectLanguage => 'اختر اللغة';

  @override
  String get topBarBackTooltip => 'رجوع';

  @override
  String get notificationsTooltip => 'الإشعارات';

  @override
  String get dialogCloseTooltip => 'إغلاق';

  @override
  String get offlineBannerMessage =>
      'غير متصل — ستتم المزامنة عند عودة الاتصال';

  @override
  String get offlineBannerSemantics =>
      'وضع غير متصل. ستتم مزامنة التغييرات عند عودة الاتصال.';

  @override
  String get logoutDialogTitle => 'تسجيل الخروج؟';

  @override
  String get logoutDialogMessage =>
      'ستحتاج إلى تسجيل الدخول مجدداً للوصول إلى مساحة العمل.';

  @override
  String get logoutDialogConfirm => 'تسجيل الخروج';

  @override
  String get logoutUnsyncedTitle => 'تغييرات غير متزامنة';

  @override
  String get logoutUnsyncedMessage =>
      'لم تصل بعض التغييرات المحلية إلى الورشة بعد. تسجيل الخروج الآن سيمسح هذه التغييرات المعلّقة.';

  @override
  String get logoutUnsyncedConfirm => 'تسجيل الخروج على أي حال';

  @override
  String get exitDialogTitle => 'الخروج من أورينت للورش؟';

  @override
  String get exitDialogMessage => 'تم حفظ عملك الحالي. إغلاق التطبيق الآن؟';

  @override
  String get exitDialogConfirm => 'خروج';

  @override
  String get profileWelcomeBack => 'مرحباً بعودتك،';

  @override
  String get profileSignOut => 'تسجيل الخروج';

  @override
  String get dateSelectorHint => 'اختر التاريخ';

  @override
  String get mediaUploadLabel => 'اضغط لرفع صور أو مستندات الفحص';

  @override
  String get mediaUploadHelper => 'يدعم JPG وPNG وPDF حتى 25 ميغابايت';

  @override
  String get statusPillRetry => 'إعادة المحاولة';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusVehicleReceived => 'تم استلام المركبة';

  @override
  String get statusApproved => 'معتمد';

  @override
  String get statusWorkAssigned => 'تم إسناد العمل';

  @override
  String get statusInService => 'قيد الخدمة';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusDelivered => 'تم التسليم';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get statusApprovalRequired => 'بانتظار الموافقة';

  @override
  String get statusWaitingParts => 'بانتظار القطع';

  @override
  String get statusSentBack => 'مُعادة';

  @override
  String get statusResolved => 'تم الحل';

  @override
  String get statusPaid => 'مدفوعة';

  @override
  String get statusPartiallyPaid => 'مدفوعة جزئياً';

  @override
  String get statusOverdue => 'متأخرة';

  @override
  String get statusUnpaid => 'غير مدفوعة';

  @override
  String get formatterJustNow => 'الآن';

  @override
  String formatterMinutesAgo(int count) {
    return 'قبل $count د';
  }

  @override
  String formatterHoursAgo(int count) {
    return 'قبل $count س';
  }

  @override
  String formatterDaysAgo(int count) {
    return 'قبل $count ي';
  }

  @override
  String formatterWeeksAgo(int count) {
    return 'قبل $count أ';
  }

  @override
  String formatterMonthsAgo(int count) {
    return 'قبل $count شهر';
  }

  @override
  String formatterYearsAgo(int count) {
    return 'قبل $count سنة';
  }

  @override
  String get commonUndo => 'تراجع';

  @override
  String get commonLoading => 'جارٍ التحميل';

  @override
  String get commonIncrease => 'زيادة';

  @override
  String get commonDecrease => 'إنقاص';

  @override
  String get commonSelect => 'اختر';

  @override
  String get commonNoResults => 'لا توجد نتائج مطابقة';

  @override
  String get commonShowPassword => 'إظهار كلمة المرور';

  @override
  String get commonHidePassword => 'إخفاء كلمة المرور';

  @override
  String get userAvatarOpenProfile => 'فتح الملف الشخصي';

  @override
  String get pendingSyncNotSent => 'لم يُرسل بعد';

  @override
  String get pendingSyncQueued => 'في قائمة الانتظار';

  @override
  String get pendingSyncFailed => 'فشلت المزامنة';

  @override
  String get pendingSyncSynced => 'تمت المزامنة';

  @override
  String get commonOptional => 'اختياري';

  @override
  String get commonNoData => 'لا توجد بيانات بعد';

  @override
  String get chartEmptyMessage => 'لا تتوفر بيانات رسومية لهذه الفترة';

  @override
  String get commonMore => 'المزيد';

  @override
  String navBadgeCount(String label, int count) {
    return '$label، $count جديد';
  }

  @override
  String navBadgeDot(String label) {
    return '$label، نشاط جديد';
  }
}
