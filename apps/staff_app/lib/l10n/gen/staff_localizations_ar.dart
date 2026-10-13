// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'staff_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class StaffLocalizationsAr extends StaffLocalizations {
  StaffLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أورينت — الموظفون';

  @override
  String get loginAppName => 'تطبيق أورينت — الموظفون';

  @override
  String get loginAppPurpose =>
      'تأكيد الحجوزات واستلام المركبات وإجراء الفحوصات وإسناد أعمال الإصلاح وتحديث المهام وإكمال فحوص الجودة.';

  @override
  String get loginIntendedUsers => 'للمستشارين والفنيين والمشرفين';

  @override
  String get authSecurityNotice =>
      'بتسجيل الدخول، فإنك توافق على شروط خدمة تطبيق أورينت — الموظفون وسياسة الخصوصية.';

  @override
  String get supervisorLoginTitle => 'دخول المشرف';

  @override
  String get supervisorLoginSubtitle =>
      'سجّل الدخول لإدارة الحجوزات والإسناد وفحوص الجودة وعمليات الورشة.';

  @override
  String get supervisorAppName => 'منصة أورينت — المشرف';

  @override
  String get supervisorAppPurpose =>
      'راجع الحجوزات الواردة وأسند المهام للمستشارين والفنيين وتابع الأعمال وأكمل فحوص الجودة.';

  @override
  String get supervisorIntendedUsers => 'لمشرفي الورشة';

  @override
  String get supervisorUsernameLabel => 'اسم المستخدم أو البريد الإلكتروني';

  @override
  String get supervisorUsernameHint => 'أدخل اسم المستخدم أو البريد الإلكتروني';

  @override
  String get supervisorEnterCredentials => 'أدخل اسم المستخدم وكلمة المرور';

  @override
  String get advisorNavToday => 'اليوم';

  @override
  String get advisorNavJobs => 'المهام';

  @override
  String get advisorNavReports => 'التقارير';

  @override
  String get advisorWorkspaceName => 'المستشار';

  @override
  String get advisorProfileLabel => 'ملف المستشار';

  @override
  String get advisorRoleEyebrow => 'مستشار خدمة';

  @override
  String get advisorDeskTitle => 'مكتب الخدمة';

  @override
  String advisorGreeting(String name) {
    return 'مرحباً $name';
  }

  @override
  String advisorShiftContext(String branch, String shift) {
    return '$branch · $shift';
  }

  @override
  String get advisorFreshnessLive => 'بيانات الورشة المباشرة';

  @override
  String get advisorSearchPillTitle => 'ابحث عن استلام أو عميل أو رقم الهيكل…';

  @override
  String get advisorSearchPillSubtitle =>
      'اطّلع على أوامر الإصلاح والتقديرات والسجل';

  @override
  String get advisorQuickActionsEyebrow => 'إجراءات سريعة';

  @override
  String get advisorActionScanTitle => 'مسح المركبة';

  @override
  String get advisorActionScanSubtitle => 'الهيكل / اللوحة';

  @override
  String get advisorActionNewJobTitle => 'بطاقة عمل جديدة';

  @override
  String get advisorActionNewJobSubtitle => 'استلام العميل';

  @override
  String get advisorActionInspectionTitle => 'فحص المركبة';

  @override
  String get advisorActionInspectionSubtitle => 'نقاط الفحص';

  @override
  String get advisorActionReportsTitle => 'تقارير الورشة';

  @override
  String get advisorActionReportsSubtitle => 'سجلات الأداء';

  @override
  String get advisorAttentionTitle => 'بحاجة إلى إجراء';

  @override
  String get advisorWorkSummary => 'ملخص العمل';

  @override
  String get advisorActionAnalytics => 'التحليلات';

  @override
  String get advisorAssignedWorkOrders => 'أوامر العمل المسندة';

  @override
  String advisorViewAll(int count) {
    return 'عرض الكل ($count)';
  }

  @override
  String get advisorNoActiveJobs => 'لا توجد بطاقات عمل نشطة مسندة';

  @override
  String get advisorMetricTotalOrders => 'إجمالي الأوامر';

  @override
  String get advisorMetricInProgress => 'قيد التنفيذ';

  @override
  String get advisorMetricDelivered => 'تم التسليم';

  @override
  String get advisorDataError => 'تعذّر تحميل بعض بيانات الورشة المباشرة.';

  @override
  String get advisorOfflineNotice =>
      'يتم عرض بيانات محفوظة. ستتم المزامنة عند عودة الاتصال.';

  @override
  String get advisorActiveArrival => 'وصول نشط';

  @override
  String get advisorConfirmedAppointment => 'موعد مؤكد';

  @override
  String advisorClientPrefix(String name) {
    return 'العميل: $name';
  }

  @override
  String get advisorJobsTitle => 'بطاقات عمل الورشة';

  @override
  String get advisorJobsSearchHint => 'ابحث باللوحة أو العميل أو المعرّف…';

  @override
  String get advisorFilterAll => 'الكل';

  @override
  String get advisorFilterInProgress => 'قيد التنفيذ';

  @override
  String get advisorFilterCompleted => 'مكتمل';

  @override
  String get advisorFilterPending => 'بالانتظار';

  @override
  String get advisorFilterQc => 'فحص الجودة';

  @override
  String get advisorFilterCancelled => 'ملغى';

  @override
  String get advisorAssignedIntakeQueue => 'قائمة الاستلام المسندة';

  @override
  String advisorPendingCount(int count) {
    return '$count بالانتظار';
  }

  @override
  String get advisorActionCheckIn => 'بدء الاستلام';

  @override
  String get advisorNoMatchingJobs => 'لا توجد بطاقات عمل مطابقة';

  @override
  String get advisorNoJobs => 'لا توجد بطاقات عمل بعد';

  @override
  String get advisorNoJobsHint => 'ستظهر بطاقات العمل الجديدة هنا عند إنشائها.';

  @override
  String get advisorReportsTitle => 'تحليلات المستشار';

  @override
  String get advisorRangeToday => 'اليوم';

  @override
  String get advisorRangeWeek => 'هذا الأسبوع';

  @override
  String get advisorRangeMonth => 'هذا الشهر';

  @override
  String get advisorReportTotalJobs => 'إجمالي المهام';

  @override
  String get advisorReportCompleted => 'مكتمل';

  @override
  String get advisorReportInProgress => 'قيد التنفيذ';

  @override
  String get advisorReportCancelled => 'ملغى';

  @override
  String get advisorJobActivity => 'نشاط المهام';

  @override
  String get advisorStatusAllocation => 'توزيع الحالات';

  @override
  String get advisorExportCsv => 'تصدير CSV';

  @override
  String get advisorReportUnavailable =>
      'بيانات التقرير غير متاحة حالياً. لم تُستبدل بيانات مهامك بالأصفار.';

  @override
  String get advisorJobDetailsTitle => 'تفاصيل بطاقة العمل';

  @override
  String get advisorSectionNextStep => 'الخطوة التالية';

  @override
  String get advisorSectionCustomerDetails => 'تفاصيل العميل';

  @override
  String get advisorSectionVehicleDetails => 'تفاصيل المركبة';

  @override
  String get advisorSectionFuelLevel => 'مستوى الوقود';

  @override
  String get advisorSectionBodyCondition => 'حالة هيكل المركبة';

  @override
  String get advisorSectionWorkItems => 'عناصر العمل';

  @override
  String get advisorSectionInspectionSummary => 'ملخص الفحص';

  @override
  String get advisorSectionServiceInformation => 'معلومات الخدمة';

  @override
  String get advisorSectionCustomerRequests => 'طلبات العميل';

  @override
  String get advisorFieldName => 'الاسم';

  @override
  String get advisorFieldPhone => 'الهاتف';

  @override
  String get advisorFieldEmail => 'البريد الإلكتروني';

  @override
  String get advisorFieldGroup => 'المجموعة';

  @override
  String get advisorFieldVehicle => 'المركبة';

  @override
  String get advisorFieldPlate => 'اللوحة';

  @override
  String get advisorFieldVin => 'رقم الهيكل';

  @override
  String get advisorFieldYear => 'السنة';

  @override
  String get advisorFieldColor => 'اللون';

  @override
  String get advisorFieldOdometer => 'العدّاد';

  @override
  String get advisorFieldServiceType => 'نوع الخدمة';

  @override
  String get advisorFieldAdvisor => 'المستشار';

  @override
  String get advisorFieldTechnician => 'الفني';

  @override
  String get advisorFieldCreated => 'أُنشئت';

  @override
  String get advisorFieldLastUpdated => 'آخر تحديث';

  @override
  String get advisorFieldReference => 'المرجع';

  @override
  String get advisorFieldGaugeLevel => 'مستوى المؤشر';

  @override
  String get advisorServiceTypeInspection => 'فحص المركبة';

  @override
  String get advisorAdvisorAssigned => 'مُسند';

  @override
  String advisorOdometerValue(String value) {
    return '$value كم';
  }

  @override
  String get advisorActionCallCustomer => 'الاتصال بالعميل';

  @override
  String get advisorActionDeliverVehicle => 'تسليم المركبة';

  @override
  String get advisorActionAddInspection => 'إضافة فحص';

  @override
  String get advisorActionStartInspection => 'بدء الفحص';

  @override
  String get advisorActionCreateEstimate => 'إنشاء تقدير';

  @override
  String get advisorActionWaitingApproval => 'بانتظار موافقة العميل';

  @override
  String get advisorActionAssignTechnician => 'إسناد فني';

  @override
  String get advisorActionReviewWorkItems => 'مراجعة عناصر العمل';

  @override
  String get advisorActionRefreshJobCard => 'تحديث بطاقة العمل';

  @override
  String get advisorVehicleAlreadyDelivered => 'تم تسليم المركبة بالفعل';

  @override
  String get advisorNextStepInspectionHint => 'أكمل الفحص قبل المتابعة';

  @override
  String get advisorNextStepContinueHint => 'تابع بطاقة العمل عبر الورشة';

  @override
  String get advisorWorkItemsHint => 'مهام أُنشئت من الفحص المكتمل';

  @override
  String get advisorBodyConditionHint =>
      'العلامات والأضرار المسجلة عند الاستلام';

  @override
  String advisorWorkItemsProgress(int done, int total) {
    return '$done/$total مكتمل';
  }

  @override
  String get advisorInspectionGood => 'جيد';

  @override
  String get advisorInspectionFair => 'مقبول';

  @override
  String get advisorInspectionPoor => 'ضعيف';

  @override
  String get advisorJobDetailLoadError =>
      'تعذّر تحميل بطاقة العمل هذه. تحقق من اتصالك وحاول مجدداً.';

  @override
  String get advisorProfileMyProfile => 'ملفي الشخصي';

  @override
  String get advisorProfileAttendance => 'الحضور · تسجيل الدخول/الخروج';

  @override
  String get advisorProfileLogout => 'تسجيل الخروج';

  @override
  String get advisorOnShift => 'في المناوبة';

  @override
  String get advisorNotificationsTitle => 'الإشعارات';

  @override
  String get advisorClearAll => 'مسح الكل';

  @override
  String get advisorNoNotifications => 'لا توجد إشعارات بعد';

  @override
  String get advisorNoNotificationsHint =>
      'ستظهر تحديثات الموافقات والتذكيرات هنا.';

  @override
  String get advisorSearchTitle => 'بحث';

  @override
  String get advisorSearchHint =>
      'ابحث عن العملاء والمركبات وبطاقات العمل والموافقات…';

  @override
  String get advisorNoResults => 'لا توجد نتائج';

  @override
  String get advisorSearchGroupJobCards => 'بطاقات العمل';

  @override
  String get advisorSearchGroupCustomers => 'العملاء / المركبات';

  @override
  String get advisorSearchGroupApprovals => 'الموافقات';

  @override
  String get advisorActionSendBack => 'إعادة';

  @override
  String get advisorActionApprove => 'موافقة';

  @override
  String get advisorActionReview => 'مراجعة';

  @override
  String get advisorContactCall => 'اتصال';

  @override
  String get advisorContactWhatsApp => 'واتساب';

  @override
  String get advisorContactSms => 'رسالة نصية';

  @override
  String get advisorActionMarkReminderDone => 'تعليم التذكير كمكتمل';

  @override
  String get advisorStatViewAllHint => 'اضغط بالأسفل لعرض القائمة الكاملة';

  @override
  String get advisorActionClose => 'إغلاق';

  @override
  String get advisorActionViewAll => 'عرض الكل';

  @override
  String advisorToastApproved(String type, String id) {
    return 'تمت الموافقة على $type $id';
  }

  @override
  String advisorToastRejected(String type, String id) {
    return 'تم رفض $type $id';
  }

  @override
  String advisorToastCalling(String name) {
    return 'جارٍ الاتصال بـ $name…';
  }

  @override
  String get advisorToastOpeningWhatsApp => 'جارٍ فتح واتساب…';

  @override
  String get advisorToastSmsSent => 'تم إرسال الرسالة';

  @override
  String get advisorToastMarkedDone => 'تم التعليم كمكتمل';

  @override
  String get advisorStatusPending => 'بالانتظار';

  @override
  String get advisorStatusInProgress => 'قيد التنفيذ';

  @override
  String get advisorStatusCompleted => 'مكتمل';

  @override
  String get advisorStatusWaitingParts => 'بانتظار القطع';

  @override
  String get advisorStatusQc => 'فحص الجودة';

  @override
  String get advisorStatusCancelled => 'ملغى';

  @override
  String get advisorStatusAwaitingSupervisor => 'بانتظار المشرف';

  @override
  String get advisorStatusVehicleReceived => 'تم استلام المركبة';

  @override
  String get advisorStatusInspected => 'تم الفحص';

  @override
  String get advisorStatusApproved => 'تمت الموافقة';

  @override
  String get advisorStatusWorkAssigned => 'تم إسناد العمل';

  @override
  String get advisorStatusWaitingCustomerApproval => 'بانتظار موافقة العميل';

  @override
  String get advisorStatusDelivered => 'تم التسليم';

  @override
  String get advisorStatusQcPassed => 'اجتاز فحص الجودة';

  @override
  String get advisorStatusPendingApproval => 'بانتظار الموافقة';
}
