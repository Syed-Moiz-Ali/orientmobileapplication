// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'owner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class OwnerLocalizationsAr extends OwnerLocalizations {
  OwnerLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أورينت — المالك';

  @override
  String get loginAppName => 'تطبيق أورينت — المالك';

  @override
  String get loginAppPurpose =>
      'راقب الفروع وبطاقات العمل والموظفين والإيرادات والموافقات والمخزون وأداء الورشة.';

  @override
  String get loginIntendedUsers => 'لمالكي الورش والمشرفين';

  @override
  String get authSecurityNotice =>
      'بتسجيل الدخول، فإنك توافق على شروط خدمة تطبيق أورينت — المالك وسياسة الخصوصية.';

  @override
  String get ownerNavDashboard => 'اللوحة';

  @override
  String get ownerNavTopSales => 'الأعلى مبيعًا';

  @override
  String get ownerNavMessages => 'الرسائل';

  @override
  String get ownerNavActivity => 'النشاط';

  @override
  String get ownerShellWorkspace => 'التنفيذية';

  @override
  String get ownerShellSuite => 'جناح المالك';

  @override
  String get ownerBarDashboard => 'لوحة المالك';

  @override
  String get ownerBarTopSales => 'الأعلى مبيعًا';

  @override
  String get ownerBarTopSalesSub => 'تفصيل الأداء حسب الفئة';

  @override
  String get ownerBarMessages => 'الرسائل';

  @override
  String get ownerBarMessagesSub => 'مراسلات داخلية';

  @override
  String get ownerBarActivity => 'النشاط';

  @override
  String get ownerBarActivitySub => 'سجل نشاط الورشة';

  @override
  String get ownerBarBack => 'عودة إلى النظرة العامة';

  @override
  String get ownerSearchHint => 'ابحث في الوجهات…';

  @override
  String get ownerPeriodToday => 'اليوم';

  @override
  String get ownerPeriodWeek => 'هذا الأسبوع';

  @override
  String get ownerPeriodMonth => 'هذا الشهر';

  @override
  String get ownerPeriodYear => 'هذه السنة';

  @override
  String get ownerOpsTitle => 'التحكم التنفيذي في العمليات';

  @override
  String get ownerOpsSubtitle =>
      'نظرة لحظية على أداء الفرع والإيرادات وخطوط الإصلاح النشطة.';

  @override
  String get ownerPillLive => 'عمليات مباشرة';

  @override
  String ownerPillActive(String value) {
    return '$value نشطة';
  }

  @override
  String ownerPillToday(String value) {
    return '$value اليوم';
  }

  @override
  String get ownerHeroEmpty => 'لا أرقام بعد.';

  @override
  String get ownerHeroEmptyHint => 'اسحب للتحديث عند عودة الاتصال.';

  @override
  String get ownerChartSalesProfit => 'المبيعات والأرباح';

  @override
  String get ownerChartSales => 'المبيعات';

  @override
  String get ownerChartProfit => 'الأرباح';

  @override
  String get ownerChartCost => 'الأرباح والمصروفات';

  @override
  String get ownerChartExpenses => 'المصروفات';

  @override
  String get ownerChartEmpty => 'لا بيانات اتجاه بعد.';

  @override
  String get ownerRegisterTitle => 'سجل بطاقات العمل';

  @override
  String get ownerRegisterAll => 'عرض الكل';

  @override
  String get ownerRegisterCategory => 'الفئة';

  @override
  String get ownerRegisterOpen => 'المفتوحة';

  @override
  String get ownerRegisterTotal => 'الإجمالي';

  @override
  String get ownerRegisterEmpty => 'لا صفوف في السجل.';

  @override
  String get ownerActionsTitle => 'إجراءات سريعة';

  @override
  String get ownerActionJobCards => 'بطاقات العمل';

  @override
  String get ownerActionJobCardsHint => 'سجل الإصلاح';

  @override
  String get ownerActionInventory => 'المخزون';

  @override
  String get ownerActionInventoryHint => 'قطع الغيار والمخزون';

  @override
  String get ownerActionReceivables => 'الذمم';

  @override
  String get ownerActionReceivablesHint => 'الأعمار والفواتير';

  @override
  String get ownerActionApprovals => 'الموافقات';

  @override
  String get ownerActionApprovalsHint => 'التقديرات والخصومات';

  @override
  String get ownerActionJobStatus => 'حالة العمل';

  @override
  String get ownerActionJobStatusHint => 'خط الإصلاح المباشر';

  @override
  String get ownerActionCompliance => 'الامتثال';

  @override
  String get ownerActionComplianceHint => 'انتهاء المستندات';

  @override
  String get ownerActionReviews => 'التقييمات';

  @override
  String get ownerActionReviewsHint => 'تقييمات العملاء';

  @override
  String get ownerActionAttendance => 'الحضور';

  @override
  String get ownerActionAttendanceHint => 'سجل الورديات';

  @override
  String get ownerActionTeam => 'الفريق والأدوار';

  @override
  String get ownerActionTeamHint => 'صلاحيات الموظفين';

  @override
  String get ownerActionTopSales => 'الأعلى مبيعًا';

  @override
  String get ownerActionTopSalesHint => 'رؤى الفئات';

  @override
  String get ownerActionMessages => 'الرسائل';

  @override
  String get ownerActionMessagesHint => 'دردشة داخلية';

  @override
  String get ownerActionSubscription => 'الاشتراك';

  @override
  String get ownerActionSubscriptionHint => 'خطة الورشة';

  @override
  String get ownerSalesHeader => 'الأعلى مبيعًا';

  @override
  String ownerSalesCount(int count) {
    return '$count فئات';
  }

  @override
  String get ownerSalesEmpty => 'لا بيانات مبيعات.';

  @override
  String get ownerSalesNo => 'م.';

  @override
  String get ownerSalesItem => 'الصنف';

  @override
  String get ownerSalesRevenue => 'الإيراد';

  @override
  String ownerMsgSent(int count) {
    return '$count مرسلة';
  }

  @override
  String get ownerMsgCompose => 'بث رسالة إلى الفريق';

  @override
  String get ownerMsgRecipient => 'المستلم';

  @override
  String get ownerMsgRecipientHint => 'اختر موظفًا مستلمًا…';

  @override
  String get ownerMsgBody => 'نص الرسالة';

  @override
  String get ownerMsgBodyHint =>
      'اكتب التعليمات الداخلية أو ملاحظات الورشة هنا…';

  @override
  String get ownerMsgSend => 'إرسال الرسالة';

  @override
  String get ownerMsgSentToast => 'تم تسليم الرسالة إلى بوابة الموظفين.';

  @override
  String get ownerMsgFailToast => 'فشل الإرسال. تحقق من اختيار المستلم.';

  @override
  String get ownerMsgHistory => 'سجل الإرسال';

  @override
  String get ownerMsgEmpty => 'لا بث بعد.';

  @override
  String get ownerMsgEmptyHint => 'ستظهر رسائل الفريق هنا.';

  @override
  String get ownerMsgNoTeam => 'لا يوجد موظفون نشطون.';

  @override
  String get ownerActEmpty => 'لا نشاط بعد';

  @override
  String get ownerActEmptyHint =>
      'ستظهر بطاقات العمل والموافقات والمدفوعات هنا.';

  @override
  String get ownerActToday => 'اليوم';

  @override
  String get ownerActYesterday => 'أمس';

  @override
  String get ownerRegTitle => 'سجل بطاقات العمل';

  @override
  String get ownerRegSubtitle => 'جميع وظائف الورشة النشطة';

  @override
  String get ownerRegSearchHint => 'ابحث برقم العمل أو اللوحة أو العميل…';

  @override
  String get ownerRegIntake => 'الاستلام';

  @override
  String get ownerRegInspect => 'الفحص';

  @override
  String get ownerRegWip => 'قيد التنفيذ';

  @override
  String get ownerRegQc => 'الجودة';

  @override
  String get ownerRegReady => 'جاهزة';

  @override
  String get ownerRegInvoiced => 'مفوترة';

  @override
  String get ownerRegJob => 'العمل';

  @override
  String get ownerRegPlate => 'اللوحة';

  @override
  String get ownerRegCustomer => 'العميل';

  @override
  String get ownerRegTotal => 'الإجمالي';

  @override
  String get ownerRegStatus => 'الحالة';

  @override
  String ownerRegCount(int count) {
    return '$count وظائف';
  }

  @override
  String get ownerRegSelectPrompt => 'اختر عملًا للمعاينة.';

  @override
  String get ownerRegEmpty => 'لا توجد بطاقات عمل.';

  @override
  String get ownerRegNoMatch => 'لا وظائف تطابق هذا البحث.';

  @override
  String get ownerRegOpen => 'فتح السجل';

  @override
  String get ownerJsReceived => 'الاستلام';

  @override
  String get ownerJsInspected => 'الفحص';

  @override
  String get ownerJsPending => 'معلقة';

  @override
  String get ownerJsPendingApproval => 'بانتظار الموافقة';

  @override
  String get ownerJsAwaitSupervisor => 'بانتظار المشرف';

  @override
  String get ownerJsApproved => 'معتمدة';

  @override
  String get ownerJsAssigned => 'مسندة';

  @override
  String get ownerJsProgress => 'قيد التنفيذ';

  @override
  String get ownerJsParts => 'بانتظار القطع';

  @override
  String get ownerJsQc => 'فحص الجودة';

  @override
  String get ownerJsQcPass => 'اجتاز الجودة';

  @override
  String get ownerJsAwaitCustomer => 'بانتظار العميل';

  @override
  String get ownerJsComplete => 'مكتملة';

  @override
  String get ownerJsDelivered => 'تم التسليم';

  @override
  String get ownerJsCancelled => 'ملغاة';

  @override
  String get ownerDetJobs => 'الوظائف';

  @override
  String get ownerDetServices => 'الخدمات';

  @override
  String get ownerDetNoServices => 'لا خدمات مدرجة.';

  @override
  String get ownerDetAssign => 'الإسناد';

  @override
  String get ownerDetTech => 'الأخصائي';

  @override
  String get ownerDetEta => 'التسليم المتوقع';

  @override
  String get ownerDetStage => 'المرحلة';

  @override
  String get ownerDetTotal => 'الإجمالي';

  @override
  String get ownerDetSplitNote => 'تفصيل القطع/العمل غير متاح لهذا السجل.';

  @override
  String get ownerDetStepIntake => 'الاستلام';

  @override
  String get ownerDetStepInspect => 'الفحص';

  @override
  String get ownerDetStepEstimate => 'التقدير';

  @override
  String get ownerDetStepRepair => 'الإصلاح';

  @override
  String get ownerDetStepQc => 'الجودة';

  @override
  String get ownerDetStepReady => 'جاهزة';

  @override
  String get ownerDetComplete => 'إتمام العمل';

  @override
  String get ownerDetShare => 'مشاركة';

  @override
  String get ownerDetConfirmTitle => 'إتمام بطاقة العمل؟';

  @override
  String get ownerDetConfirmBody =>
      'تنتقل البطاقة إلى مكتملة وتتزامن مع سجل الورشة.';

  @override
  String get ownerDetDone => 'تم إتمام بطاقة العمل.';

  @override
  String get ownerDetFail => 'تعذر إتمام البطاقة. حاول مرة أخرى.';

  @override
  String get ownerDetEmpty => 'لم تُختر بطاقة عمل.';

  @override
  String get ownerDetEmptyHint => 'افتح عملًا من السجل.';

  @override
  String get ownerDetCancel => 'إلغاء';

  @override
  String get ownerStTitle => 'خط العمل المباشر';

  @override
  String get ownerStSubtitle => 'مراقبة المراحل مع تحديث تلقائي';

  @override
  String get ownerStSearchHint => 'ابحث برقم العمل أو العميل أو المركبة…';

  @override
  String ownerStUpdated(String time) {
    return 'حُدّثت $time';
  }

  @override
  String get ownerStStale => 'قد تكون البيانات قديمة. اسحب للتحديث.';

  @override
  String get ownerStEmpty => 'لا بطاقات عمل في هذه المرحلة.';

  @override
  String get ownerStPodQueue => 'طابور الاستلام';

  @override
  String get ownerStPodActive => 'النشطة';

  @override
  String get ownerStPodDone => 'المنجزة';

  @override
  String get ownerStPodAttention => 'تحتاج انتباهًا';

  @override
  String get ownerStgInspect => 'الفحص';

  @override
  String get ownerStgPreReq => 'قبل الطلب';

  @override
  String get ownerStgEstimate => 'التقدير';

  @override
  String get ownerStgApproval => 'الموافقة';

  @override
  String get ownerStgParts => 'القطع';

  @override
  String get ownerStgWip => 'قيد التنفيذ';

  @override
  String get ownerStgComplete => 'مكتملة';

  @override
  String get ownerStgCancel => 'ملغاة';

  @override
  String get ownerApTitle => 'التصاريح المعلقة';

  @override
  String get ownerApSubtitle => 'الخصومات والضمان والتجاوزات';

  @override
  String get ownerApAwaiting => 'بانتظار مراجعة المالك';

  @override
  String ownerApCount(int count) {
    return '$count طلبات';
  }

  @override
  String get ownerApList => 'قائمة المراجعة';

  @override
  String get ownerApEmpty => 'لا موافقات معلقة.';

  @override
  String get ownerApEmptyHint => 'ستظهر طلبات الخصم والضمان والتجاوز هنا.';

  @override
  String get ownerApNoAction => 'إجراءات الموافقة غير متاحة في هذه النسخة.';
}
