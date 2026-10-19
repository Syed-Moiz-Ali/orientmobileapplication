// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'customer_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class CustomerLocalizationsAr extends CustomerLocalizations {
  CustomerLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أورينت — العملاء';

  @override
  String get loginAppName => 'تطبيق أورينت — العملاء';

  @override
  String get loginAppPurpose =>
      'احجز الصيانة، وتتبع سيارتك، وراجع التقديرات، واعتمد الإصلاحات، واطلع على الفواتير.';

  @override
  String get loginIntendedUsers => 'لمالكي المركبات وعملاء الصيانة';

  @override
  String get authSecurityNotice =>
      'بتسجيل الدخول، فإنك توافق على شروط خدمة تطبيق أورينت — العملاء وسياسة الخصوصية.';

  @override
  String get garNavHome => 'الرئيسية';

  @override
  String get garNavBookings => 'الحجوزات';

  @override
  String get garNavVehicles => 'المركبات';

  @override
  String get garNavProfile => 'الحساب';

  @override
  String get garBrand => 'أورينت لصيانة السيارات';

  @override
  String get garBrandSub => 'سيارتك في أيدٍ أمينة';

  @override
  String get garHello => 'مرحبًا بعودتك';

  @override
  String get garWelcome => 'أهلًا بك في أورينت';

  @override
  String get garManage => 'إدارة';

  @override
  String get garTitleOne => 'مركبتك';

  @override
  String get garTitleMany => 'مرآبك';

  @override
  String get garHeroEmpty => 'مرآبك فارغ';

  @override
  String get garHeroEmptyBody =>
      'أضف سيارتك لحجز الصيانة ومتابعة تقدم الإصلاح وإبقاء كل تحديث في مكان واحد.';

  @override
  String get garHeroAdd => 'أضف سيارتك';

  @override
  String get garJourneyTitle => 'رحلتك النشطة';

  @override
  String get garJourneyTrack => 'تتبع الصيانة';

  @override
  String get garJourneyView => 'عرض الحجز';

  @override
  String get garJourneyEmpty => 'لا رحلة نشطة الآن.';

  @override
  String get garActionsTitle => 'كيف نخدمك؟';

  @override
  String get garActionBook => 'احجز صيانة';

  @override
  String get garActionBookHint => 'اختر وقتًا يناسبك';

  @override
  String get garActionSos => 'مساعدة الأعطال';

  @override
  String get garActionSosHint => 'المساعدة في الطريق';

  @override
  String get garActionInvoices => 'الفواتير';

  @override
  String get garActionInvoicesHint => 'الإيصالات والفواتير';

  @override
  String get garActionHistory => 'السجل';

  @override
  String get garActionHistoryHint => 'الزيارات السابقة';

  @override
  String get garRecentTitle => 'النشاط الأخير';

  @override
  String get garLoadTitle => 'تعذر تحميل معلوماتك.';

  @override
  String get garLoadBody => 'حاول مرة أخرى بعد قليل.';

  @override
  String get garRetry => 'إعادة المحاولة';

  @override
  String get garRecentAll => 'كل الحجوزات';

  @override
  String get garUpcomingTitle => 'القادم';

  @override
  String get bkTitle => 'الحجوزات';

  @override
  String get bkUpcoming => 'القادمة';

  @override
  String get bkInService => 'قيد الصيانة';

  @override
  String get bkHistory => 'السجل';

  @override
  String get bkBookCta => 'احجز صيانة';

  @override
  String get bkEmptyTitle => 'لا حجوزات بعد';

  @override
  String get bkEmptyBody => 'عندما تكون جاهزًا، احجز صيانة وستظهر هنا.';

  @override
  String get bkEmptyVehiclesTitle => 'لا مركبة بعد';

  @override
  String get bkEmptyVehiclesBody =>
      'أضف سيارتك أولًا لتعرف الورشة ما الذي ستخدمه.';

  @override
  String get bkFailedTitle => 'تحتاج انتباهًا';

  @override
  String get bkRetry => 'إعادة المحاولة';

  @override
  String get bkRemoveTitle => 'حذف الحجز المحفوظ؟';

  @override
  String get bkRemoveBody =>
      'سيؤدي هذا لحذف الحجز المخزن على هذا الجهاز. لم تستلمه الورشة.';

  @override
  String get bkRemoveCta => 'حذف الحجز';

  @override
  String get bkKeepCta => 'إبقاء الحجز';

  @override
  String get bkSendFail => 'تعذر إرسال هذا الحجز. حاول مرة أخرى.';

  @override
  String get bkLoadFailTitle => 'تعذر تحميل حجوزاتك';

  @override
  String get bkLoadFailBody => 'حاول مرة أخرى بعد قليل.';

  @override
  String get bkRetryCta => 'إعادة المحاولة';

  @override
  String get bkUpOne => 'واحد قادم';

  @override
  String bkUpMany(int count) {
    return '$count قادمة';
  }

  @override
  String get bkInOne => 'واحد قيد الصيانة';

  @override
  String bkInMany(int count) {
    return '$count قيد الصيانة';
  }

  @override
  String get bkPastOne => 'صيانة سابقة واحدة';

  @override
  String bkPastMany(int count) {
    return '$count صيانات سابقة';
  }

  @override
  String get bkSubDefault => 'مواعيدك وسجل صيانتك.';

  @override
  String get bkReview => 'مراجعة';

  @override
  String get bkServiceAppt => 'موعد صيانة';

  @override
  String get bkApprovalMsg => 'الموافقة مطلوبة قبل مواصلة العمل';

  @override
  String bkApprovalEst(String amount) {
    return 'التقدير $amount بانتظار الموافقة';
  }

  @override
  String get jsInService => 'قيد الصيانة';

  @override
  String get jsInProgress => 'الصيانة جارية';

  @override
  String jsStage(String stage) {
    return 'المرحلة الحالية · $stage';
  }

  @override
  String jsEta(String value) {
    return 'الإتمام المتوقع · $value';
  }

  @override
  String get jsNoService => 'لا صيانة نشطة';

  @override
  String get jsIdleOne => 'مركبتك ليست في الورشة الآن.';

  @override
  String get jsIdleMany => 'مركباتك ليست في الورشة الآن.';

  @override
  String get jsWorkshopBooking => 'حجز ورشة';

  @override
  String get vhTitle => 'مركباتي';

  @override
  String get vhCountNone => 'المركبات المسجلة تظهر هنا.';

  @override
  String get vhCountOne => 'مركبة واحدة مسجلة';

  @override
  String vhCountMany(int count) {
    return '$count مركبات مسجلة';
  }

  @override
  String get vhAdd => 'إضافة مركبة';

  @override
  String get vhEmptyTitle => 'لا مركبات مضافة بعد';

  @override
  String get vhEmptyBody =>
      'أضف سيارتك الأولى لحجز الصيانة وربط كل زيارة بالمركبة الصحيحة.';

  @override
  String get vhLoadFailTitle => 'تعذر تحميل مركباتك';

  @override
  String get vhLoadFailBody => 'حاول مرة أخرى بعد قليل.';

  @override
  String get vhBook => 'احجز صيانة';

  @override
  String get vhEdit => 'تعديل';

  @override
  String get vhRemove => 'حذف';

  @override
  String get vhRemoveNoName => 'حذف هذه المركبة؟';

  @override
  String vhRemoveTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String vhRemoveBody(String plate) {
    return 'سيتم حذف $plate من مركباتك.';
  }

  @override
  String get vhRemoveBodyNoPlate => 'لن تظهر هذه المركبة في مركباتك بعد الآن.';

  @override
  String get vhRemoveCta => 'حذف المركبة';

  @override
  String get vhKeepCta => 'إبقاء المركبة';

  @override
  String get vhRemoved => 'تم حذف المركبة.';

  @override
  String get vhRemoveFail => 'تعذر حذف هذه المركبة. حاول مرة أخرى.';

  @override
  String get vhSyncFail => 'تعذر إتمام حفظ المركبة.';

  @override
  String get vhDeleteFailTitle => 'تعذر حذف هذه المركبة.';

  @override
  String get vhDeleteFailBody => 'المركبة ما زالت في حساب الورشة.';

  @override
  String get vhRetryRemoval => 'إعادة محاولة الحذف';

  @override
  String get vhRetrying => 'جارٍ إعادة المحاولة…';

  @override
  String get vhTrack => 'تتبع';

  @override
  String get vhRetry => 'إعادة المحاولة';

  @override
  String get vhView => 'عرض';

  @override
  String get vhInService => 'في الورشة الآن';

  @override
  String get vhFallbackName => 'مركبة';

  @override
  String get avTitleAdd => 'إضافة مركبة';

  @override
  String get avTitleEdit => 'تعديل المركبة';

  @override
  String get avStepPlate => 'اللوحة';

  @override
  String get avStepVehicle => 'المركبة';

  @override
  String get avStepDetails => 'التفاصيل';

  @override
  String get avEyebrowReg => 'التسجيل';

  @override
  String get avEyebrowVeh => 'المركبة';

  @override
  String get avEyebrowDet => 'التفاصيل';

  @override
  String get avPlateTitle => 'ما رقم اللوحة؟';

  @override
  String get avPlateBody => 'اللوحة هي ما تعرف به الورشة سيارتك.';

  @override
  String get avPlateLabel => 'اللوحة';

  @override
  String get avPlateHint => 'A 12345';

  @override
  String get avPlateError => 'أدخل لوحة التسجيل';

  @override
  String get avVehicleTitle => 'أي سيارة هي؟';

  @override
  String get avVehicleBody => 'الصنع مطلوب لتسجيلها.';

  @override
  String get avMakeLabel => 'الصنع';

  @override
  String get avMakeHint => 'تويوتا';

  @override
  String get avMakeError => 'أدخل صنع مركبتك';

  @override
  String get avModelLabel => 'الطراز (اختياري)';

  @override
  String get avModelHint => 'لاندكروزر';

  @override
  String get avYearLabel => 'السنة';

  @override
  String get avYearHint => '2021';

  @override
  String avYearError(int max) {
    return 'أدخل سنة بين 1950 و$max';
  }

  @override
  String get avDetailsTitle => 'شيء آخر؟';

  @override
  String get avDetailsBody =>
      'اختياري — يساعد في التعرف على سيارتك. تواريخ الصيانة تبقى كما هي.';

  @override
  String get avVinLabel => 'رقم الهيكل (اختياري)';

  @override
  String get avVinHint => 'رقم الشاسيه';

  @override
  String get avVinHelp => 'يمكن للورشة قراءته من السيارة.';

  @override
  String get avColorLabel => 'اللون';

  @override
  String get avColorHint => 'أبيض';

  @override
  String get avMileageLabel => 'الممشى (اختياري)';

  @override
  String get avMileageHint => '48,200';

  @override
  String get avNext => 'متابعة';

  @override
  String get avBack => 'رجوع';

  @override
  String get avSaveAdd => 'إضافة مركبة';

  @override
  String get avSaveEdit => 'حفظ التعديلات';

  @override
  String get avSaving => 'جارٍ الحفظ…';

  @override
  String get avNoteKept => 'تواريخ الصيانة المسجلة تبقى كما هي هنا.';

  @override
  String get avNoteFresh => 'هذه الشاشة لا تغيّر تواريخ الصيانة المسجلة أبدًا.';

  @override
  String get avSaveFailFallback => 'تعذر حفظ هذه المركبة. حاول مرة أخرى.';

  @override
  String get avRetryCta => 'حاول مرة أخرى';

  @override
  String get pfTitle => 'الحساب';

  @override
  String get pfContact => 'التواصل';

  @override
  String get pfAccount => 'الحساب';

  @override
  String get pfAbout => 'عن التطبيق';

  @override
  String get pfSession => 'الجلسة';

  @override
  String get pfVehicles => 'المركبات';

  @override
  String get pfVehiclesHint => 'سيارات مسجلة في حسابك';

  @override
  String get pfVehiclesNone => 'لا يوجد';

  @override
  String get pfSos => 'نجدة الطريق';

  @override
  String get pfSosHint => 'اطلب المساعدة عند تعطل مركبتك';

  @override
  String get pfPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get pfPasswordHint => 'تحقق برمز لمرة واحدة ثم عيّن كلمة جديدة';

  @override
  String get pfLicences => 'تراخيص المصادر المفتوحة';

  @override
  String get pfLicencesHint => 'البرمجيات المستخدمة في التطبيق';

  @override
  String get pfAccountFallback => 'حسابك';

  @override
  String get pfEmail => 'البريد الإلكتروني';

  @override
  String get pfPhone => 'الهاتف';

  @override
  String get pfSumNone => 'لا مركبات بعد';

  @override
  String get pfSumOne => 'مركبة واحدة';

  @override
  String pfSumMany(int count) {
    return '$count مركبات';
  }

  @override
  String get pfSumLive => 'الصيانة جارية';

  @override
  String get pfRetry => 'إعادة المحاولة';

  @override
  String get pfLoadFail => 'تعذر تحميل حسابك.';

  @override
  String get ntTitle => 'التنبيهات';

  @override
  String get ntMarkAll => 'تعليم الكل كمقروء';

  @override
  String get ntAllRead => 'الكل مقروء';

  @override
  String ntUnread(int count) {
    return '$count غير مقروءة';
  }

  @override
  String get ntCaughtUp => 'أنت مطّلع على كل شيء';

  @override
  String get ntCaughtUpBody =>
      'ستظهر هنا تحديثات حجوزاتك وتقديراتك وتقدم الصيانة.';

  @override
  String get ntUnreadWord => 'غير مقروءة';

  @override
  String get ntReadWord => 'مقروءة';

  @override
  String get ntLoadTitle => 'تعذر تحميل تنبيهاتك.';

  @override
  String get ntLoadBody => 'حاول مرة أخرى بعد قليل.';

  @override
  String get ntMarkFail => 'تعذر تعليم تنبيهاتك كمقروءة.';

  @override
  String get ntRetry => 'إعادة المحاولة';

  @override
  String get ntGroupService => 'تحديثات الصيانة';

  @override
  String get ntGroupApprovals => 'الموافقات';

  @override
  String get ntGroupInvoices => 'الفواتير والإيصالات';

  @override
  String get ntGroupGeneral => 'عامة';

  @override
  String get ntTypeBooking => 'حجز';

  @override
  String get ntTypeApproval => 'موافقة';

  @override
  String get ntTypeService => 'صيانة';

  @override
  String get ntTypeInvoice => 'فاتورة';

  @override
  String get ntTypePayment => 'دفعة';

  @override
  String get ntTypeBreakdown => 'عطل';

  @override
  String get ntTypeUpdate => 'تحديث';
}
