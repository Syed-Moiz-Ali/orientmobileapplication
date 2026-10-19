// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'crm_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class CrmLocalizationsAr extends CrmLocalizations {
  CrmLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أورينت — إدارة العملاء';

  @override
  String get loginAppName => 'تطبيق أورينت — إدارة العملاء';

  @override
  String get loginAppPurpose =>
      'أدر متابعات العملاء والتواصل وقيادة المبيعات والتذكيرات وأنشطة الدعم.';

  @override
  String get loginIntendedUsers => 'لفريق إدارة العملاء والدعم';

  @override
  String get authSecurityNotice =>
      'بتسجيل الدخول، فإنك توافق على شروط خدمة تطبيق أورينت — إدارة العملاء وسياسة الخصوصية.';

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navLeads => 'العملاء المحتملون';

  @override
  String get navConversations => 'المحادثات';

  @override
  String get navSalesTeam => 'فريق المبيعات';

  @override
  String get navTasks => 'المهام';

  @override
  String get navReports => 'التقارير';

  @override
  String get navIntegrations => 'التكاملات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get shellCrm => 'CRM';

  @override
  String get shellWorkspace => 'مساحة المبيعات';

  @override
  String get shellSubtitle => 'Orient CRM';

  @override
  String get shellBranch => 'الفرع';

  @override
  String get shellAdminName => 'المدير';

  @override
  String get shellAdminRole => 'مدير علاقات العملاء';

  @override
  String get shellAdminBadge => 'مدير';

  @override
  String get chromeSearch => 'ابحث في العملاء…';

  @override
  String get chromeSearchHint => 'اكتب لتصفية العملاء والمحادثات';

  @override
  String get chromeOpenNav => 'فتح التنقل';

  @override
  String get chromeRefresh => 'تحديث مساحة العمل';

  @override
  String get chromeSettings => 'إعدادات CRM';

  @override
  String get chromeShortcut => 'Ctrl+K';

  @override
  String get shellBranchName => 'Bircon, Hifri';

  @override
  String get dashLive => 'مباشر';

  @override
  String get dashTitle => 'لوحة CRM';

  @override
  String dashLeadsPill(int count) {
    return '$count عميل';
  }

  @override
  String dashWonPill(int count) {
    return '$count رابح';
  }

  @override
  String get dashPulse => 'نبض المبيعات';

  @override
  String get dashAttention => 'قائمة الانتباه';

  @override
  String get dashChannels => 'أداء القنوات';

  @override
  String get dashActivity => 'النشاط الأخير';

  @override
  String get dashRecentLeads => 'أحدث العملاء';

  @override
  String get dashNoPipeline => 'لا توجد بيانات';

  @override
  String get dashNoPipelineBody => 'سيبني العملاء خط المبيعات هنا';

  @override
  String get dashNoChannel => 'لا توجد بيانات قنوات بعد';

  @override
  String get dashNoChannelBody => 'ستظهر رسائل المنصات المتصلة هنا';

  @override
  String get dashNoLeads => 'لا يوجد عملاء بعد';

  @override
  String get dashSyncBody => 'زامن CRM المتصل لجلب العملاء';

  @override
  String get dashConnectBody => 'اربط CRM لبدء استقبال العملاء';

  @override
  String get dashNoCrm => 'لا توجد أنظمة CRM مربوطة';

  @override
  String get dashNoCrmBody => 'اربط Meta أو Zoho لرؤية العملاء المباشرين هنا';

  @override
  String get dashConnect => 'اربط';

  @override
  String get dashSyncing => 'جارٍ مزامنة العملاء...';

  @override
  String get dashEmptySync => 'CRM مربوط لكن لا يوجد عملاء بعد';

  @override
  String get dashSyncNow => 'زامن الآن';

  @override
  String get fnTitle => 'قمع المبيعات';

  @override
  String get fnPipeline => 'خط المبيعات';

  @override
  String get fnEmpty => 'لا توجد بيانات بعد';

  @override
  String get fnConversion => 'معدل التحويل';

  @override
  String get fnWonRevenue => 'إيراد الصفقات الرابحة';

  @override
  String get fnClear => 'مسح التصفية';

  @override
  String fnShowing(String stage) {
    return 'عرض عملاء $stage';
  }

  @override
  String get fuEmpty => 'لا توجد متابعات مجدولة';

  @override
  String get fuTitle => 'المتابعات القادمة';

  @override
  String get fuOverdue => 'متأخر';

  @override
  String get acEmpty => 'لا يوجد نشاط بعد';

  @override
  String get acTitle => 'النشاط الأخير';

  @override
  String get rlNo => 'م';

  @override
  String get rlNumber => 'رقم العميل';

  @override
  String get rlName => 'اسم العميل';

  @override
  String get rlSource => 'المصدر';

  @override
  String get rlStatus => 'الحالة';

  @override
  String get leadsSearch => 'ابحث في العملاء...';

  @override
  String get leadsTableView => 'عرض جدولي';

  @override
  String get leadsKanbanView => 'عرض كانبان';

  @override
  String leadsCount(int count) {
    return '$count عميل';
  }

  @override
  String get leadsAdd => 'أضف عميلاً';

  @override
  String get leadsConnectCrm => 'اربط CRM';

  @override
  String get leadsNoCrm => 'لا توجد أنظمة CRM خارجية مربوطة';

  @override
  String get leadsNoCrmBody =>
      'اربط Meta أو Zoho أو منصات أخرى لجلب عملائك وإدارتهم تلقائياً هنا';

  @override
  String get leadsConnectNow => 'اربط الآن';

  @override
  String get leadsAutoNote => 'سيظهر العملاء هنا تلقائياً فور الربط';

  @override
  String get leadsEmpty => 'لا يوجد عملاء بعد';

  @override
  String leadsEmptySync(String source) {
    return 'زامن الآن لجلب العملاء من $source.';
  }

  @override
  String get leadsIntegNote => 'يمكنك أيضاً إدارة الاتصالات في تبويب التكاملات';

  @override
  String get leadsPlatforms => 'منصاتك المتصلة';

  @override
  String get leadsSyncNow => 'زامن الآن';

  @override
  String get colLead => 'العميل';

  @override
  String get colPhone => 'الهاتف';

  @override
  String get colValue => 'القيمة';

  @override
  String get colStage => 'المرحلة';

  @override
  String get colAgent => 'الموظف';

  @override
  String get filterSource => 'المصدر';

  @override
  String get filterAgent => 'الموظف';

  @override
  String get filterAll => 'الكل';

  @override
  String get kbEmptyStage => 'لا يوجد عملاء في هذه المرحلة';

  @override
  String get kbNoContact => 'لا توجد بيانات تواصل';

  @override
  String get kbUnassigned => 'غير مُسند';

  @override
  String get kbLeadOne => 'عميل';

  @override
  String get kbLeadsMany => 'عملاء';

  @override
  String get kbNoStages => 'لا توجد مراحل';

  @override
  String get kbNoStagesBody => 'سيظهر العملاء الجدد هنا عند دخولهم.';

  @override
  String kbMoveTo(String stage) {
    return 'انقل إلى $stage';
  }

  @override
  String kbMoved(String stage) {
    return 'تم نقل العميل إلى $stage';
  }

  @override
  String get dtPhone => 'الهاتف';

  @override
  String get dtEmail => 'البريد';

  @override
  String get dtSource => 'المصدر';

  @override
  String get dtAssigned => 'مُسند إلى';

  @override
  String get dtValue => 'قيمة العميل';

  @override
  String get dtFollowUp => 'المتابعة';

  @override
  String get dtLastActivity => 'آخر نشاط';

  @override
  String get dtUnassigned => 'غير مُسند';

  @override
  String get dtNotes => 'ملاحظات';

  @override
  String get dtActivity => 'سجل النشاط';

  @override
  String get dtNoActivity => 'لا يوجد نشاط بعد';

  @override
  String get dtChangeStatus => 'تغيير الحالة';

  @override
  String get dtDeleteTitle => 'حذف العميل';

  @override
  String dtDeleteBody(String name, String number) {
    return 'حذف $name ($number)؟ لا يمكن التراجع.';
  }

  @override
  String get dtCancel => 'إلغاء';

  @override
  String get dtDelete => 'حذف';

  @override
  String get dtDeleted => 'تم حذف العميل';

  @override
  String dtMarked(String status) {
    return 'تم تعليم العميل كـ $status';
  }

  @override
  String get dtWhatsApp => 'واتساب';

  @override
  String get dtCall => 'اتصال';

  @override
  String get dtEdit => 'تعديل العميل';

  @override
  String get dtCallFail => 'تعذّر فتح تطبيق الاتصال.';

  @override
  String get dtWaFail => 'تعذّر فتح واتساب.';

  @override
  String get fmAddLead => 'أضف عميلاً';

  @override
  String get fmEditLead => 'تعديل العميل';

  @override
  String get fmName => 'اسم العميل';

  @override
  String get fmPhone => 'الهاتف';

  @override
  String get fmPhoneHint => '050 123 4567';

  @override
  String get fmEmail => 'البريد';

  @override
  String get fmSource => 'المصدر';

  @override
  String get fmAssigned => 'مُسند إلى';

  @override
  String get fmValue => 'قيمة العميل (درهم)';

  @override
  String get fmFollowUp => 'تاريخ المتابعة';

  @override
  String get fmNotes => 'ملاحظات';

  @override
  String get fmStatus => 'الحالة';

  @override
  String fmSelectOption(String label) {
    return 'اختر $label';
  }

  @override
  String get fmSelectAssignee => 'اختر الموظف';

  @override
  String get fmSelectDate => 'اختر التاريخ';

  @override
  String get fmNotesHint => 'أضف ملاحظات عن العميل...';

  @override
  String get fmLoadingTeam => 'جارٍ تحميل الفريق...';

  @override
  String get fmTeamFail => 'تعذّر تحميل الفريق';

  @override
  String get fmSaving => 'جارٍ الحفظ...';

  @override
  String get fmSaveChanges => 'حفظ التغييرات';

  @override
  String get fmNameRequired => 'اسم العميل مطلوب';

  @override
  String get fmPhoneInvalid => 'أدخل رقم جوال إماراتي صحيح.';

  @override
  String get fmUpdated => 'تم تحديث العميل';

  @override
  String get fmCreated => 'تم إنشاء العميل';

  @override
  String get fmUnassigned => 'غير مُسند';

  @override
  String tkCount(int count) {
    return '$count مهام';
  }

  @override
  String get tkAdd => 'أضف مهمة';

  @override
  String get tkEmpty => 'لا توجد مهام بعد';

  @override
  String get tkEmptyBody => 'أنشئ مهام لفريقك لمتابعة العملاء';

  @override
  String get tkDeleteTitle => 'حذف المهمة';

  @override
  String tkDeleteBody(String title) {
    return 'حذف \"$title\"؟';
  }

  @override
  String get tkCancel => 'إلغاء';

  @override
  String get tkDelete => 'حذف';

  @override
  String get tkFormEdit => 'تعديل المهمة';

  @override
  String get tkFormAdd => 'أضف مهمة';

  @override
  String get tkFormTitle => 'عنوان المهمة';

  @override
  String get tkFormAssigned => 'مُسند إلى';

  @override
  String get tkFormDue => 'تاريخ الاستحقاق';

  @override
  String get tkFormPriority => 'الأولوية';

  @override
  String get tkHigh => 'عالية';

  @override
  String get tkMedium => 'متوسطة';

  @override
  String get tkLow => 'منخفضة';

  @override
  String get tkLoadingTeam => 'جارٍ تحميل الفريق...';

  @override
  String get tkTeamFail => 'تعذّر تحميل الفريق';

  @override
  String get tkSelectAssignee => 'اختر الموظف';

  @override
  String get tkSaving => 'جارٍ الحفظ...';

  @override
  String get tkSaveChanges => 'حفظ التغييرات';

  @override
  String get tkTitleRequired => 'عنوان المهمة مطلوب';

  @override
  String get tkUnassigned => 'غير مُسند';

  @override
  String get tkNoDue => 'بدون تاريخ';

  @override
  String get tkOverdue => 'متأخر';

  @override
  String get tkDueToday => 'يستحق اليوم';

  @override
  String get tkMarkDone => 'تعليم كمنجزة';

  @override
  String get tkReopen => 'إعادة فتح';
}
