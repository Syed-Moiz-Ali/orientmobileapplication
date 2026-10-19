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
}
