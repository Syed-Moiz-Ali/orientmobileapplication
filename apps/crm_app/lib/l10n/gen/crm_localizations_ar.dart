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

  @override
  String get cvInbox => 'الوارد';

  @override
  String get cvTitle => 'المحادثات';

  @override
  String get cvEmptySub => 'ستظهر رسائل العملاء من القنوات المتصلة هنا.';

  @override
  String get cvThreadsOne => 'محادثة عميل نشطة واحدة عبر كل القنوات.';

  @override
  String cvThreadsMany(int count) {
    return '$count محادثات عملاء نشطة عبر كل القنوات.';
  }

  @override
  String get cvEmpty => 'لا توجد محادثات بعد';

  @override
  String get cvEmptyBody =>
      'اربط قناة مراسلة لجمع محادثات العملاء في قائمة واحدة.';

  @override
  String cvUnread(int count) {
    return '$count رسائل غير مقروءة';
  }

  @override
  String get cvLatest => 'أحدث رسالة';

  @override
  String get cvNoThread => 'اختر محادثة';

  @override
  String get cvNoThreadBody => 'اختر محادثة لقراءة أحدث رسالة وتفاصيل العميل.';

  @override
  String get cvBack => 'رجوع';

  @override
  String get cvDossier => 'ملف العميل';

  @override
  String get cvStatus => 'الحالة';

  @override
  String get cvChannel => 'القناة';

  @override
  String get cvTime => 'الوقت';

  @override
  String get cvHistoryNote =>
      'سجل الرسائل الكامل في القناة المتصلة — أحدث رسالة معروضة هنا.';

  @override
  String get tmTitle => 'لوحة الصدارة';

  @override
  String get tmSub => 'مرتبة حسب الإيراد المحقق هذه الفترة.';

  @override
  String get tmLeads => 'العملاء';

  @override
  String get tmWon => 'الرابح';

  @override
  String get tmWinRate => 'معدل الفوز';

  @override
  String get tmRevenue => 'الإيراد';

  @override
  String get tmSearchTitle => 'البحث في الفريق';

  @override
  String get tmSearchHint => 'ابحث بالاسم أو الدور';

  @override
  String get tmSearchNoMatch => 'لا يوجد أعضاء فريق يطابقون بحثك.';

  @override
  String get tmEmpty => 'لا يوجد موظفون بعد';

  @override
  String get tmEmptyBody => 'سيظهر أعضاء الفريق هنا فور إضافتهم.';

  @override
  String get rpConversion => 'اتجاهات التحويل';

  @override
  String get rpNoConversion => 'لا توجد بيانات تحويل بعد';

  @override
  String get rpWon => 'رابح';

  @override
  String get rpLost => 'خاسر';

  @override
  String get rpActive => 'نشط';

  @override
  String get rpSources => 'مصادر العملاء';

  @override
  String get rpNoSources => 'لا توجد بيانات مصادر بعد';

  @override
  String get rpPerf => 'أداء الموظفين';

  @override
  String get rpNoPerf => 'لا توجد بيانات موظفين بعد';

  @override
  String get rpLeads => 'العملاء';

  @override
  String get rpResponse => 'تحليل زمن الاستجابة';

  @override
  String get rpNoResponse => 'لا توجد بيانات زمن استجابة بعد';

  @override
  String get rpMetrics => 'المقاييس الرئيسية';

  @override
  String get rpTotal => 'الإجمالي';

  @override
  String get itDataSources => 'مصادر البيانات';

  @override
  String get itTitle => 'التكاملات';

  @override
  String get itSub =>
      'اربط مصدراً لجلب العملاء ورسائل العملاء إلى مساحة العمل.';

  @override
  String itConnected(int done, int total) {
    return '$done من $total مصادر مربوطة وجاهزة للمزامنة.';
  }

  @override
  String get itSyncing => 'جارٍ المزامنة...';

  @override
  String get itSyncError => 'خطأ في المزامنة';

  @override
  String get itConnectedBadge => 'مربوط';

  @override
  String get itNotConnected => 'غير مربوط';

  @override
  String get itLeads => 'عميل';

  @override
  String get itConnectedTitle => 'مربوط ويزامن العملاء';

  @override
  String get itJustConnected => 'مربوط';

  @override
  String get itLeadsFetched => 'العملاء المجلبون';

  @override
  String get itLastSync => 'آخر مزامنة';

  @override
  String get itStatus => 'الحالة';

  @override
  String get itReady => 'جاهز';

  @override
  String get itSyncNow => 'زامن الآن';

  @override
  String get itDisconnect => 'افصل';

  @override
  String get itSyncFail => 'فشلت المزامنة. تحقق من بيانات الاعتماد.';

  @override
  String get itSyncDone => 'اكتملت المزامنة - تم تحديث العملاء';

  @override
  String itDisconnected(String name) {
    return 'تم فصل $name';
  }

  @override
  String get seWorkspace => 'مساحة العمل';

  @override
  String get seTitle => 'الإعدادات';

  @override
  String get seSub => 'تحكم في كيفية استلام فريقك للعمل ودخول العملاء الجدد.';

  @override
  String get seWorkflow => 'سير العمل';

  @override
  String get sePush => 'الإشعارات الفورية';

  @override
  String get sePushBody => 'نبهني عند وصول عميل جديد أو رسالة عميل.';

  @override
  String get seAutoAssign => 'إسناد تلقائي للعملاء';

  @override
  String get seAutoAssignBody =>
      'وجّه العملاء الواردين إلى الموظفين المتاحين عبر قائمة الفريق.';

  @override
  String get seAppearance => 'المظهر';

  @override
  String get seDark => 'مظهر داكن';

  @override
  String get seDarkBody => 'استخدم لوحة العمل الداكنة عندما يدعمها سمة تطبيقك.';

  @override
  String get seLangNote => 'تُحفظ تفضيلات المظهر في ملف مساحة العمل هذا.';

  @override
  String get csTitle => 'اربط CRM';

  @override
  String get csSub => 'اختر منصة لجلب العملاء تلقائياً';

  @override
  String get csMetaSub => 'إعلانات فيسبوك وإنستغرام للعملاء';

  @override
  String get csZohoSub => 'عملاء Zoho CRM';

  @override
  String get csPageId => 'معرف الصفحة';

  @override
  String get csPageIdHint => 'مثال: 123456789012345';

  @override
  String get csToken => 'رمز الوصول';

  @override
  String get csTokenHint => 'رمز وصول طويل الأمد للصفحة';

  @override
  String get csMetaHelp =>
      'احصل عليها من developers.facebook.com > تطبيقك > إعلانات العملاء > إعداد API';

  @override
  String get csClientId => 'معرف العميل';

  @override
  String get csClientIdHint => 'معرف عميل Zoho OAuth';

  @override
  String get csSecret => 'سر العميل';

  @override
  String get csSecretHint => 'سر عميل Zoho OAuth';

  @override
  String get csRefresh => 'رمز التحديث';

  @override
  String get csRefreshHint => 'رمز تحديث Zoho OAuth';

  @override
  String get csZohoHelp =>
      'أنشئ تطبيقاً في Zoho API Console > عميل خادم > نطاق عملاء CRM';

  @override
  String get csConnecting => 'جارٍ الربط...';

  @override
  String csConnect(String platform) {
    return 'اربط $platform';
  }

  @override
  String get csNeedMeta => 'أدخل معرف الصفحة ورمز الوصول';

  @override
  String get csNeedZoho => 'أدخل معرف العميل وسر العميل ورمز التحديث';

  @override
  String csDone(String platform) {
    return 'تم ربط $platform! اضغط زامن الآن لجلب العملاء';
  }

  @override
  String get csFail => 'فشل الاتصال. تحقق من بيانات الاعتماد وحاول مرة أخرى.';

  @override
  String get leadsSearchTitle => 'البحث في العملاء';

  @override
  String get leadsSearchNoMatch => 'لا يوجد عملاء يطابقون بحثك.';

  @override
  String get leadsFilterTitle => 'تصفية العملاء';

  @override
  String get leadsFilterShow => 'عرض النتائج';

  @override
  String get leadsFilterNoMatch => 'لا يوجد عملاء يطابقون هذه التصفية.';

  @override
  String get leadsFilterClear => 'مسح';

  @override
  String leadsCountN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عميل',
      one: 'عميل واحد',
      zero: '0 عميل',
    );
    return '$_temp0';
  }

  @override
  String get tasksSearchTitle => 'البحث في المهام';

  @override
  String get tasksSearchHint => 'ابحث بالعنوان أو المسؤول';

  @override
  String get tasksSearchNoMatch => 'لا توجد مهام مطابقة لبحثك.';

  @override
  String tkCountN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      one: 'مهمة واحدة',
      zero: '0 مهمة',
    );
    return '$_temp0';
  }

  @override
  String get leadsSelectLead => 'اختر عميلاً لعرض التفاصيل';
}
