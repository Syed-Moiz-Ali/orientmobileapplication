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
  String get garShowAll => 'عرض الكل';

  @override
  String get garSearchTitle => 'بحث';

  @override
  String get garSearchHint => 'ابحث في المركبات والحجوزات';

  @override
  String get garSearchEmpty => 'اكتب للبحث في مركباتك وحجوزاتك.';

  @override
  String get garSearchNoMatch => 'لا توجد نتائج. جرّب بحثًا مختلفًا.';

  @override
  String get garAttentionMoreOne => 'عنصر آخر يحتاج إلى مراجعة';

  @override
  String garAttentionMoreMany(int count) {
    return '$count عناصر أخرى تحتاج إلى مراجعة';
  }

  @override
  String get garUnpaidBody => 'راجع وسدد فواتيرك المستحقة.';

  @override
  String get garUnpaidCta => 'مراجعة الفواتير';

  @override
  String get garUnpaidChip => 'غير مدفوعة';

  @override
  String get garStatusBooked => 'محجوز';

  @override
  String get garStatusRequested => 'مطلوب';

  @override
  String get garStatusLastService => 'آخر صيانة';

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
  String get vhSearchTitle => 'البحث في المركبات';

  @override
  String get vhSearchHint => 'ابحث بالاسم أو اللوحة أو اللون';

  @override
  String get vhSearchNoMatch => 'لا توجد مركبات مطابقة لبحثك.';

  @override
  String get vhFilterTitle => 'تصفية المركبات';

  @override
  String get vhFilterAll => 'الكل';

  @override
  String get vhFilterBooked => 'محجوزة أو مطلوبة';

  @override
  String get vhFilterLastService => 'آخر صيانة';

  @override
  String get vhFilterNone => 'لا يوجد نشاط حالي';

  @override
  String get vhFilterShow => 'عرض النتائج';

  @override
  String get vhFilterNoMatch => 'لا توجد مركبات مطابقة لهذه التصفية.';

  @override
  String get vhFilterClear => 'مسح';

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

  @override
  String get wizTitle => 'احجز خدمة';

  @override
  String get wizStepVehicle => 'المركبة';

  @override
  String get wizStepPackage => 'الخدمة';

  @override
  String get wizStepSlot => 'الموعد';

  @override
  String get wizStepDropoff => 'التسليم';

  @override
  String get wizVehicleTitle => 'أي سيارة ستأتي إلينا؟';

  @override
  String get wizVehicleSub =>
      'اختر المركبة المسجلة التي سيستلمها مركز الصيانة.';

  @override
  String get wizGarageEmptyTitle => 'لا توجد مركبة بعد';

  @override
  String get wizGarageEmptyBody =>
      'يتطلب الحجز مركبة مسجلة. أضف مركبتك في أقل من دقيقة.';

  @override
  String get wizAddVehicle => 'أضف مركبتك';

  @override
  String get wizPackageTitle => 'ما الذي تحتاجه؟';

  @override
  String get wizPackageSub =>
      'اختر خدمة أو أكثر. الأسعار معلنة مقدماً بالدرهم.';

  @override
  String get wizServicesLoadFail => 'تعذّر تحميل الخدمات.';

  @override
  String get wizRetryServices => 'إعادة تحميل الخدمات';

  @override
  String get wizNoServicesTitle => 'لا توجد خدمات حالياً';

  @override
  String get wizNoServicesBody =>
      'قائمة خدمات المركز فارغة. حاول مرة أخرى بعد قليل.';

  @override
  String get wizSlotTitle => 'متى يناسبك؟';

  @override
  String get wizSlotSub => 'الأيام والأوقات مأخوذة مباشرة من جدول المركز.';

  @override
  String get wizChooseDate => 'اختر اليوم';

  @override
  String get wizTimesFor => 'الأوقات المتاحة';

  @override
  String get wizNoDateBody => 'اختر يوماً أعلاه لرؤية أوقاته.';

  @override
  String get wizSlotsLoadFail => 'تعذّر تحميل الأوقات المتاحة.';

  @override
  String get wizRetryTimes => 'إعادة تحميل الأوقات';

  @override
  String get wizNoTimesTitle => 'لا توجد أوقات متبقية في هذا اليوم';

  @override
  String get wizNoTimesBody =>
      'جرّب يوماً آخر — تُفتح مواعيد جديدة مع تحرك الجدول.';

  @override
  String get wizMorning => 'صباحاً';

  @override
  String get wizAfternoon => 'ظهراً';

  @override
  String get wizDropTitle => 'كيف تصلنا السيارة؟';

  @override
  String get wizDropSub => 'أحضرها بنفسك، أو دع سائقنا يستلمها.';

  @override
  String get wizSelfTitle => 'تسليم ذاتي';

  @override
  String get wizSelfBody => 'أحضر السيارة إلى المركز في موعدك.';

  @override
  String get wizValetTitle => 'استلام بالسائق';

  @override
  String get wizValetBody => 'يستلم سائقنا السيارة ويعيدها بعد انتهاء العمل.';

  @override
  String get wizAddressLabel => 'عنوان الاستلام';

  @override
  String get wizAddressHint => 'الشارع، المبنى، علامة مميزة';

  @override
  String get wizAddressRequired =>
      'أضف عنوان الاستلام ليتمكن السائق من الوصول إليك.';

  @override
  String get wizNotesLabel => 'ملاحظات للمركز';

  @override
  String get wizNotesHint => 'اختياري — مثلاً صوت عند الفرملة';

  @override
  String get wizNeedVehicle => 'اختر مركبة للمتابعة.';

  @override
  String get wizNeedPackage => 'اختر خدمة واحدة على الأقل للمتابعة.';

  @override
  String get wizNeedSlot => 'اختر اليوم والوقت للمتابعة.';

  @override
  String get wizSummaryTitle => 'حجزك';

  @override
  String get wizSummaryEmpty => 'لم تختر شيئاً بعد — ستظهر اختياراتك هنا.';

  @override
  String get wizRowVehicle => 'المركبة';

  @override
  String get wizRowServices => 'الخدمات';

  @override
  String get wizRowSlot => 'الموعد';

  @override
  String get wizTotal => 'الإجمالي';

  @override
  String get wizTotalPending => 'يُؤكَّد في المركز';

  @override
  String get wizTrust => 'فحص مجاني خلال ٧ أيام';

  @override
  String get wizContinue => 'متابعة';

  @override
  String get wizBack => 'رجوع';

  @override
  String get wizConfirm => 'تأكيد الحجز';

  @override
  String get wizBooking => 'جارٍ الحجز…';

  @override
  String get wizChange => 'تغيير';

  @override
  String get wizSubmitFail => 'تعذّر إنشاء هذا الحجز. حاول مرة أخرى.';

  @override
  String get wizRetrySync => 'إعادة مزامنة المركبة';

  @override
  String get wizTryAgain => 'حاول مرة أخرى';

  @override
  String get bkdTitle => 'تفاصيل الحجز';

  @override
  String get bkdPassTitle => 'بطاقة المركز';

  @override
  String get bkdPassHint => 'اعرضها عند الوصول';

  @override
  String get bkdAddCalendar => 'أضف إلى التقويم';

  @override
  String get bkdCalendarFail => 'تعذّر فتح التقويم.';

  @override
  String get bkdApprovalTitle => 'يلزم اعتماد قبل مواصلة العمل';

  @override
  String get bkdServiceLabel => 'الخدمة';

  @override
  String get bkdVehicleLabel => 'المركبة';

  @override
  String get bkdApptLabel => 'الموعد';

  @override
  String get bkdDateLabel => 'تاريخ الخدمة';

  @override
  String get bkdRefLabel => 'رقم الحجز';

  @override
  String get bkdConfirmedNote =>
      'سيارتك محجوزة. سنتولى الأمر من هنا فور وصولك.';

  @override
  String get bkdRequestedNote => 'استلم المركز طلبك وسيؤكد الموعد قريباً.';

  @override
  String get bkdTrack => 'تتبع الخدمة';

  @override
  String get bkdReviewEstimate => 'مراجعة التقدير';

  @override
  String get bkdCancelTitle => 'إلغاء الحجز؟';

  @override
  String get bkdCancelBody => 'سيتم إبلاغ المركز فوراً.';

  @override
  String get bkdCancelCta => 'إلغاء الحجز';

  @override
  String get bkdKeepCta => 'الاحتفاظ بالحجز';

  @override
  String get bkdCancelling => 'جارٍ الإلغاء…';

  @override
  String get bkdCancelled => 'تم إلغاء الحجز.';

  @override
  String get bkdCancelFail => 'تعذّر إلغاء هذا الحجز. حاول مرة أخرى.';

  @override
  String get bkdRetry => 'إعادة المحاولة';

  @override
  String get bksRequested => 'تم طلب الحجز';

  @override
  String get bksSaved => 'تم حفظ الحجز';

  @override
  String get bksRequestedSub => 'سيؤكد المركز موعدك قريباً.';

  @override
  String get bksSavedSub => 'سيصل إلى المركز عندما تعود إلى الاتصال.';

  @override
  String get bksRefLabel => 'رقم الحجز';

  @override
  String get bksStatusLabel => 'الحالة';

  @override
  String get bksNotSent => 'لم يُرسَل بعد';

  @override
  String get bksServiceLabel => 'الخدمة';

  @override
  String get bksVehicleLabel => 'المركبة';

  @override
  String get bksApptLabel => 'الموعد';

  @override
  String get bksQueuedTitle => 'محفوظ على هذا الجهاز';

  @override
  String get bksQueuedBody => 'سيُرسَل تلقائياً عند عودة الاتصال.';

  @override
  String get bksPendingBody => 'موعدك غير مؤكد بعد. سيؤكد المركز الموعد.';

  @override
  String get bksPendingTitle => 'غير مؤكد بعد';

  @override
  String get bksNextTitle => 'ماذا بعد؟';

  @override
  String get bksNextOne => 'يؤكد المركز موعدك.';

  @override
  String get bksNextTwo => 'سلّم السيارة — أو انتظر السائق.';

  @override
  String get bksNextThree => 'تتبع كل مرحلة من الحجوزات.';

  @override
  String get bksDone => 'تم';

  @override
  String get bksViewBooking => 'عرض الحجز';

  @override
  String get bksViewBookings => 'عرض الحجوزات';

  @override
  String get sosTitle => 'المساعدة على الطريق';

  @override
  String get sosSub => 'المساعدة على بُعد نقرة، ليلاً ونهاراً.';

  @override
  String get sosVehicleTitle => 'أي مركبة تحتاج المساعدة؟';

  @override
  String get sosLocationTitle => 'أين أنت؟';

  @override
  String get sosLocationHint => 'أدخل موقعك الحالي أو علامة قريبة';

  @override
  String get sosLocationHelp => 'اكتب عنواناً أو مخرجاً أو علامة قريبة.';

  @override
  String get sosLocationRequired =>
      'أضف مكان المركبة لتتمكن الورشة من الوصول إليك.';

  @override
  String get sosIssueTitle => 'ما المشكلة؟';

  @override
  String get sosDetailHint => 'أي شيء يجب أن يعرفه السائق (اختياري)';

  @override
  String get sosIssueRequired => 'أخبرنا بما حدث لتتمكن الورشة من مساعدتك.';

  @override
  String get sosTyre => 'إطار مثقوب';

  @override
  String get sosNoStart => 'لا تعمل';

  @override
  String get sosBattery => 'بطارية فارغة';

  @override
  String get sosOverheat => 'ارتفاع الحرارة';

  @override
  String get sosBrake => 'مشكلة في الفرامل';

  @override
  String get sosWarning => 'ضوء تحذيري';

  @override
  String get sosAccident => 'ضرر حادث';

  @override
  String get sosLockout => 'مغلقة والمفتاح بالداخل';

  @override
  String get sosOther => 'شيء آخر';

  @override
  String get sosCallWorkshop => 'اتصل بالمركز';

  @override
  String get sosSend => 'طلب المساعدة';

  @override
  String get sosSending => 'جارٍ إرسال الطلب…';

  @override
  String get sosRetry => 'إعادة إرسال الطلب';

  @override
  String get sosRetrying => 'جارٍ إعادة الإرسال…';

  @override
  String get sosRemove => 'حذف الطلب';

  @override
  String get sosKeep => 'الاحتفاظ بالطلب';

  @override
  String get sosRemoveTitle => 'حذف الطلب المحفوظ؟';

  @override
  String get sosRemoveBody =>
      'سيحذف هذا النسخة المخزنة على جهازك. لم يستلمها المركز.';

  @override
  String get sosSavedTitle => 'محفوظ على هذا الجهاز';

  @override
  String get sosSavedBody =>
      'لم يُرسَل بعد. أعد الإرسال عندما تعود إلى الاتصال.';

  @override
  String get sosDialFail => 'تعذّر فتح تطبيق الاتصال.';

  @override
  String get sosSent => 'تم إرسال الطلب';

  @override
  String get sosSaved => 'تم حفظ الطلب';

  @override
  String get sosSentBody => 'استلم المركز طلبك.';

  @override
  String get sosRef => 'المرجع';

  @override
  String get sosDetails => 'ما طلبته';

  @override
  String get sosDone => 'تم';

  @override
  String get sosWhatNext => 'ماذا بعد؟';

  @override
  String get sosNextSentOne => 'يتصل بك المركز لتأكيد إرسال المساعدة.';

  @override
  String get sosNextSentTwo => 'ابقَ مع المركبة وهاتفك مفتوحاً.';

  @override
  String get sosNextSavedOne => 'طلبك محفوظ على هذا الجهاز.';

  @override
  String get sosNextSavedTwo => 'أعد الإرسال فور عودتك إلى الاتصال.';

  @override
  String get sosWaitingTitle => 'بانتظار المركز';

  @override
  String get sosWaitingBody =>
      'يؤكد المركز إرسال المساعدة عبر الهاتف — لا يوجد موعد وصول مباشر بعد.';

  @override
  String get bkdActionRequired => 'يلزم إجراء';

  @override
  String get bkdCurrentStage => 'المرحلة الحالية';

  @override
  String get bkdInProgress => 'الخدمة جارية';

  @override
  String bkdEstCompletion(String eta) {
    return 'الانتهاء المتوقع · $eta';
  }

  @override
  String bkdProgressLabel(int progress) {
    return 'تقدم الخدمة، $progress بالمئة';
  }

  @override
  String get bkdYourVehicle => 'مركبتك';

  @override
  String get sosSendingNote => 'جارٍ إرسال طلبك…';

  @override
  String get sosRecoveryOne => 'تعذّر إرسال طلب المساعدة';

  @override
  String get sosRecoveryMany => 'تعذّر إرسال طلبات المساعدة';

  @override
  String get sosRecoveryBodyOne =>
      'إنه محفوظ على جهازك، لكن المركز لم يستلمه. حاول إرساله مجدداً، أو اتصل بالمركز إذا كنت تحتاج المساعدة الآن.';

  @override
  String get sosRecoveryBodyMany =>
      'إنها محفوظة على جهازك، لكن المركز لم يستلمها. حاول مجدداً، أو اتصل بالمركز إذا كنت تحتاج المساعدة الآن.';

  @override
  String sosSavedCount(int count) {
    return '$count طلبات محفوظة';
  }

  @override
  String get sosRetryDone => 'تم إرسال طلبك المحفوظ إلى المركز.';

  @override
  String get sosRetryFail => 'ما زلنا عاجزين عن إرسال طلبك. لم يستلمه المركز.';

  @override
  String get sosRemoved => 'تم حذف الطلب المحفوظ.';

  @override
  String get sosTimeout =>
      'تعذّر التأكد مما إذا استلم المركز هذا الطلب. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get sosSendFail => 'تعذّر إرسال طلبك. حاول مرة أخرى.';

  @override
  String get sosQueueFail => 'تعذّر حفظ هذا الطلب على جهازك.';

  @override
  String get sosNoVehicles => 'لا توجد مركبات مسجلة بعد';

  @override
  String get sosNoVehiclesBody =>
      'يمكنك إرسال الطلب. إضافة المركبة تساعد المركز على حفظ سجلك في مكان واحد.';

  @override
  String get sosAddVehicle => 'أضف مركبة';

  @override
  String get sosDetailLabel => 'شيء آخر؟ (اختياري)';

  @override
  String get sosDetailHint2 => 'مثلاً: متوقفة في القبو، يصعب رؤيتها';

  @override
  String get sosIntro =>
      'أخبر المركز أي مركبة تحتاج المساعدة، وأين هي، وما المشكلة.';

  @override
  String get sosHotlineLabel => 'الخط الساخن للمركز';

  @override
  String get sosNoVehicle => 'لم تُختر مركبة';

  @override
  String get sosLocationRow => 'الموقع';

  @override
  String get sosIssueRow => 'ما المشكلة';

  @override
  String get sosSavedOutcome => 'محفوظ على هذا الجهاز — لم يُرسَل بعد.';

  @override
  String get sosQueuedNote =>
      'سيُرسَل تلقائياً عند عودة اتصالك. وحتى ذلك الحين لا يمكن للمركز رؤية هذا الطلب — اتصل بالمركز إذا كنت تحتاج المساعدة الآن.';

  @override
  String get sosNotifySent => 'سنُعلمك عندما يُسند المركز مستشاراً لهذا الطلب.';

  @override
  String get sosNotifyQueued => 'سنرسل هذا الطلب ونُعلمك فور توفر الاتصال.';

  @override
  String get stLiveBadge => 'قيد التنفيذ';

  @override
  String get stServiceFallback => 'الخدمة جارية';

  @override
  String get stCurrentStage => 'المرحلة الحالية';

  @override
  String stProgressLabel(int progress) {
    return 'تقدم الخدمة، $progress بالمئة';
  }

  @override
  String stEstCompletion(String eta) {
    return 'الانتهاء المتوقع · $eta';
  }

  @override
  String get stViewBooking => 'عرض الحجز';

  @override
  String get stWorkshopBooking => 'حجز المركز';

  @override
  String get stApptScheduled => 'تم تحديد الموعد';

  @override
  String get stBookedNote =>
      'تم حجز خدمتك. ستظهر تحديثات المركز هنا فور استلام مركبتك.';

  @override
  String get stJobRef => 'مرجع بطاقة العمل';

  @override
  String get stStarted => 'بدأت';

  @override
  String get stTechnician => 'الفني';

  @override
  String get stBookingRef => 'رقم الحجز';

  @override
  String get stIdleTitle => 'لا شيء لتتبعه الآن';

  @override
  String get stIdleWithVehicles => 'مركبتك غير محجوزة حالياً ولا في المركز.';

  @override
  String get stIdleNoVehicles => 'أضف مركبتك لحجز خدمة ومتابعة تقدمها هنا.';

  @override
  String get stBookService => 'احجز خدمة';

  @override
  String get stViewBookings => 'عرض الحجوزات';

  @override
  String get stAddVehicle => 'أضف مركبتك';

  @override
  String get stTitle => 'حالة الخدمة';

  @override
  String get stLiveSub => 'مركبتك في المركز الآن.';

  @override
  String get stBookedSub => 'موعدك محجوز.';

  @override
  String get stIdleSub => 'لا يوجد حجز أو عمل جارٍ.';

  @override
  String get stLoadFail => 'تعذّر تحميل حالة خدمتك';

  @override
  String get stLoadRetry => 'حاول مرة أخرى بعد قليل.';

  @override
  String get stRetry => 'إعادة المحاولة';

  @override
  String get stActionRequired => 'يلزم إجراء';

  @override
  String get stOtherOne => 'حجز قادم آخر';

  @override
  String stOtherMany(int count) {
    return '$count حجوزات قادمة أخرى';
  }

  @override
  String get stJourneyTitle => 'رحلة الخدمة';

  @override
  String get stDone => 'تم';

  @override
  String get stCurrent => 'الحالية';

  @override
  String get stUpcoming => 'القادمة';

  @override
  String get stStageFallback => 'مرحلة المركز';

  @override
  String get stAttentionTitle => 'تحتاج انتباهك';

  @override
  String stAttentionEst(String amount) {
    return 'تقدير $amount بانتظار اعتمادك';
  }

  @override
  String get stAttentionGeneric => 'يوجد تقدير بانتظار اعتمادك';

  @override
  String get stRefreshFail => 'تعذّر تحديث معلوماتك.';

  @override
  String get stServiceDetails => 'تفاصيل الخدمة';

  @override
  String get stWaitingTitle => 'بانتظار المركز';

  @override
  String get stWaitingBody =>
      'يؤكد المركز التقدم من منطقة العمل — لا يوجد موعد وصول مضمون.';

  @override
  String stAttentionEstMany(int count) {
    return '$count تقديرات بانتظار اعتمادك';
  }

  @override
  String get stUnpaidOne => 'فاتورة واحدة غير مدفوعة';

  @override
  String stUnpaidMany(int count) {
    return '$count فواتير غير مدفوعة';
  }

  @override
  String get apTitle => 'الاعتمادات والفواتير';

  @override
  String get apDetailTitle => 'الاعتماد';

  @override
  String get apNeedsDecision => 'بانتظار قرارك';

  @override
  String get apInvoices => 'الفواتير';

  @override
  String get apLoadFail => 'تعذّر تحميل اعتماداتك';

  @override
  String get apPullRetry => 'اسحب للأسفل للمحاولة مجدداً.';

  @override
  String get apEmptyTitle => 'لا شيء بانتظارك';

  @override
  String get apEmptyBody =>
      'عندما يرسل المركز تقديراً أو بطاقة عمل أو فحصاً لاعتمادك، سيظهر هنا وفي حجزك.';

  @override
  String get apInvoicesEmpty => 'ستظهر الفواتير هنا فور إصدار فاتورة عملك.';

  @override
  String get apActionRequired => 'يلزم إجراء';

  @override
  String get apReviewPrefix => 'مراجعة';

  @override
  String apSentAt(String date) {
    return 'أُرسل $date';
  }

  @override
  String get apTypeEstimate => 'تقدير';

  @override
  String get apTypeJobCard => 'بطاقة عمل';

  @override
  String get apTypeInspection => 'فحص';

  @override
  String get apDetailLoadFail => 'تعذّر تحميل هذا الطلب';

  @override
  String get apDetailReplaced =>
      'ربما استبدله المركز. يمكنك المحاولة مجدداً أو مراجعة اعتماداتك الأخرى.';

  @override
  String get apTryAgain => 'حاول مرة أخرى';

  @override
  String get apViewAll => 'عرض كل الاعتمادات';

  @override
  String get apRecordJobCard => 'اعتماد بطاقة عمل';

  @override
  String get apRecordInspection => 'اعتماد فحص';

  @override
  String get apRecordEstimate => 'الإجمالي التقديري';

  @override
  String get apCovers => 'ما يغطيه هذا التقدير';

  @override
  String get apServices => 'الخدمات';

  @override
  String get apParts => 'القطع';

  @override
  String get apItemFallback => 'بند';

  @override
  String apQtyRate(int qty, String rate) {
    return 'الكمية $qty × $rate';
  }

  @override
  String apDiscount(String pct) {
    return '−$pct٪';
  }

  @override
  String get apSummary => 'الملخص';

  @override
  String get apTotal => 'الإجمالي';

  @override
  String get apDecidedApprovedEst =>
      'اعتمدت هذا التقدير. سينفذ المركز العمل المذكور أعلاه.';

  @override
  String apDecidedApprovedSubject(String subject) {
    return 'اعتمدت $subject. تم إبلاغ المركز.';
  }

  @override
  String get apDecidedRejectedEst =>
      'رفضت هذا التقدير. تم إبلاغ المركز ويمكنه إرسال تقدير معدل.';

  @override
  String apDecidedRejectedSubject(String subject) {
    return 'رفضت $subject. تم إبلاغ المركز.';
  }

  @override
  String get apSubjectEstimate => 'التقدير';

  @override
  String get apSubjectJobCard => 'بطاقة العمل';

  @override
  String get apSubjectInspection => 'الفحص';

  @override
  String apApproveSubject(String subject) {
    return 'اعتماد $subject';
  }

  @override
  String apRejectSubject(String subject) {
    return 'رفض $subject';
  }

  @override
  String get apSending => 'جارٍ الإرسال…';

  @override
  String get apSendingNote => 'جارٍ إرسال قرارك إلى المركز…';

  @override
  String apConfirmApproveTitle(String subject) {
    return 'اعتماد $subject؟';
  }

  @override
  String apConfirmRejectTitle(String subject) {
    return 'رفض $subject؟';
  }

  @override
  String apConfirmApproveEst(String amount) {
    return 'أنت تعتمد عملاً بإجمالي $amount.';
  }

  @override
  String apConfirmApproveEstVehicle(String amount, String vehicle) {
    return 'أنت تعتمد عملاً بإجمالي $amount لـ $vehicle.';
  }

  @override
  String apConfirmApproveSubject(String subject) {
    return 'أنت تعتمد $subject.';
  }

  @override
  String apConfirmApproveSubjectVehicle(String subject, String vehicle) {
    return 'أنت تعتمد $subject لـ $vehicle.';
  }

  @override
  String get apConfirmRejectEst =>
      'سيتم إبلاغ المركز بأنك لا تقبل هذا التقدير. يمكنك طلب تقدير معدل.';

  @override
  String apConfirmRejectSubject(String subject) {
    return 'سيتم إبلاغ المركز بأنك لا تقبل $subject.';
  }

  @override
  String get apConfirm => 'اعتماد';

  @override
  String apConfirmReject(String subject) {
    return 'رفض $subject';
  }

  @override
  String get apNotNow => 'ليس الآن';

  @override
  String get apKeepReviewing => 'مواصلة المراجعة';

  @override
  String apApprovedToast(String label) {
    return 'تم اعتماد $label — تم إبلاغ المركز.';
  }

  @override
  String apRejectedToast(String label) {
    return 'تم رفض $label — تم إبلاغ المركز.';
  }

  @override
  String get apDecisionFail => 'تعذّر إرسال قرارك. حاول مرة أخرى.';

  @override
  String get apRetry => 'إعادة المحاولة';

  @override
  String get apLabelEstimate => 'التقدير';

  @override
  String get apLabelJobCard => 'بطاقة العمل';

  @override
  String get apLabelInspection => 'الفحص';

  @override
  String get invTitle => 'تفاصيل الفاتورة';

  @override
  String get invBilledTo => 'صدرت إلى';

  @override
  String get invIssued => 'تاريخ الإصدار';

  @override
  String get invSubtotal => 'المجموع الفرعي';

  @override
  String invVat(String pct) {
    return 'الضريبة ($pct٪)';
  }

  @override
  String get invTotal => 'الإجمالي';

  @override
  String get invReceiptNote => 'إيصالك المفصل من المركز.';

  @override
  String get fbTitle => 'التقييم';

  @override
  String get fbSubmitFail => 'تعذّر إرسال تقييمك. حاول مرة أخرى.';

  @override
  String get fbNext => 'التالي';

  @override
  String get fbSubmit => 'إرسال';

  @override
  String get fbThanks => 'شكراً لك';

  @override
  String get fbThanksBody => 'يساعدنا تقييمك على تحسين خدمتنا.';

  @override
  String get fbBookNext => 'احجز خدمتك التالية';

  @override
  String get fbBackHome => 'العودة للرئيسية';

  @override
  String get fbOverallTitle => 'كيف كانت تجربتك؟';

  @override
  String get fbCategoriesTitle => 'قيّم جوانب محددة';

  @override
  String get fbCatWork => 'جودة العمل';

  @override
  String get fbCatComm => 'التواصل';

  @override
  String get fbCatTime => 'الالتزام بالوقت';

  @override
  String get fbCatValue => 'القيمة مقابل السعر';

  @override
  String get fbCommentTitle => 'أي تعليقات أخرى؟';

  @override
  String get fbCommentHint => 'أخبرنا المزيد (اختياري)';

  @override
  String get fbRecommend => 'هل تنصح بنا؟';

  @override
  String get fbYes => 'نعم';

  @override
  String get fbNo => 'لا';

  @override
  String get fbTagsTitle => 'ما الذي أعجبك؟';

  @override
  String get fbTagFast => 'خدمة سريعة';

  @override
  String get fbTagClean => 'منطقة نظيفة';

  @override
  String get fbTagClear => 'شرح واضح';
}
