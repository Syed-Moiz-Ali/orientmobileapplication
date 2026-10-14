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

  @override
  String get advisorIntakeTitle => 'إنشاء بطاقة عمل';

  @override
  String get advisorIntakeIntroTitleNew => 'استقبال مركبة جديد';

  @override
  String get advisorIntakeIntroTitleBooking => 'أكمل استقبال المركبة';

  @override
  String get advisorIntakeIntroBody =>
      'ابحث عن سجل موجود أو أدخل بيانات العميل والمركبة أدناه.';

  @override
  String get advisorIntakeRequiredHint => 'الحقول المعلّمة بعلامة * مطلوبة فقط';

  @override
  String get advisorIntakeLinkedBooking => 'مرتبط بالحجز المُسنَد';

  @override
  String get advisorIntakeStepCustomer => 'العميل';

  @override
  String get advisorIntakeStepVehicle => 'المركبة';

  @override
  String get advisorIntakeStepMedia => 'الوسائط والمستندات';

  @override
  String get advisorIntakeStepJob => 'العمل';

  @override
  String get advisorIntakeStepSignature => 'التوقيع';

  @override
  String get advisorIntakeStepReview => 'الحفظ';

  @override
  String get advisorIntakeSectionCustomer => 'بيانات العميل';

  @override
  String get advisorIntakeSectionCustomerSub => 'من يقوم بإحضار المركبة؟';

  @override
  String get advisorIntakeSectionVehicle => 'بيانات المركبة';

  @override
  String get advisorIntakeSectionVehicleSub => 'معلومات التسجيل والخدمة';

  @override
  String get advisorIntakeSectionBody => 'حالة هيكل المركبة';

  @override
  String get advisorIntakeSectionBodySub => 'حدّد أي تلف موجود قبل التسليم';

  @override
  String get advisorIntakeSectionMedia => 'المستندات والوسائط';

  @override
  String get advisorIntakeSectionMediaSub => 'أرفق المستندات والصور والفيديو';

  @override
  String get advisorIntakeSectionJob => 'وصف العمل';

  @override
  String get advisorIntakeSectionJobSub => 'صِف العمل المطلوب';

  @override
  String get advisorIntakeSectionSignature => 'التوقيعات';

  @override
  String get advisorIntakeSectionSignatureSub =>
      'التقط موافقة العميل والمستشار';

  @override
  String get advisorIntakeSectionReview => 'المراجعة والحفظ';

  @override
  String get advisorIntakeSectionReviewSub =>
      'أكّد البيانات قبل إنشاء بطاقة العمل';

  @override
  String get advisorIntakeFindTitle => 'البحث عن سجل موجود';

  @override
  String get advisorIntakeFindSub => 'تجنّب تكرار سجلات العملاء والمركبات';

  @override
  String get advisorIntakeFindHint =>
      'الجوال أو اسم العميل أو رقم اللوحة أو VIN';

  @override
  String get advisorIntakeScanVin => 'مسح VIN';

  @override
  String get advisorIntakeScanQr => 'مسح رمز QR للمركبة';

  @override
  String get advisorIntakeB2B => 'عميل شركات';

  @override
  String get advisorIntakeCustomerName => 'اسم العميل';

  @override
  String get advisorIntakeCustomerNameHint => 'اسم العميل';

  @override
  String get advisorIntakePhone => 'رقم الهاتف';

  @override
  String get advisorIntakePhoneHint => 'رقم الهاتف';

  @override
  String get advisorIntakeEmail => 'البريد الإلكتروني';

  @override
  String get advisorIntakeEmailHint => 'البريد الإلكتروني';

  @override
  String get advisorIntakeCustomerGroup => 'مجموعة العميل';

  @override
  String get advisorIntakeCustomerGroupHint => 'اختر مجموعة العميل';

  @override
  String get advisorIntakeGender => 'الجنس';

  @override
  String get advisorIntakeGenderHint => 'اختر الجنس';

  @override
  String get advisorIntakeAddress => 'العنوان';

  @override
  String get advisorIntakeAddressHint => 'اختر العنوان';

  @override
  String get advisorIntakeTaxNumber => 'الرقم الضريبي';

  @override
  String get advisorIntakeSource => 'المصدر';

  @override
  String get advisorIntakeSourceHint => 'كيف عرفت عنّا؟';

  @override
  String get advisorIntakeShowMore => 'عرض المزيد';

  @override
  String get advisorIntakeShowLess => 'عرض أقل';

  @override
  String get advisorIntakeEmirate => 'الإمارة';

  @override
  String get advisorIntakeEmirateHint => 'اختر الإمارة';

  @override
  String get advisorIntakePlateCode => 'رمز اللوحة';

  @override
  String get advisorIntakePlateCodeHint => 'A';

  @override
  String get advisorIntakePlateNumber => 'رقم اللوحة';

  @override
  String get advisorIntakePlateNumberHint => '2500';

  @override
  String get advisorIntakeVin => 'رقم الهيكل (VIN)';

  @override
  String get advisorIntakeVinHint => 'رقم الهيكل (VIN)';

  @override
  String get advisorIntakeMake => 'الشركة المصنّعة';

  @override
  String get advisorIntakeMakeHint => 'اختر الشركة المصنّعة';

  @override
  String get advisorIntakeModel => 'الطراز';

  @override
  String get advisorIntakeModelHint => 'اختر الطراز';

  @override
  String get advisorIntakeModelYear => 'سنة الطراز';

  @override
  String get advisorIntakeModelYearHint => 'اختر سنة الطراز';

  @override
  String get advisorIntakeSelectBrandFirst =>
      'يرجى اختيار الشركة المصنّعة أولاً';

  @override
  String get advisorIntakeCylinders => 'عدد الأسطوانات';

  @override
  String get advisorIntakeCylindersHint => 'عدد الأسطوانات';

  @override
  String get advisorIntakeEngineCapacity => 'سعة المحرك';

  @override
  String get advisorIntakeVehicleColor => 'لون المركبة';

  @override
  String get advisorIntakeFuelType => 'نوع الوقود';

  @override
  String get advisorIntakeFuelTypeHint => 'اختر نوع الوقود';

  @override
  String get advisorIntakeEngineNumber => 'رقم المحرك';

  @override
  String get advisorIntakeRegistrationCertificate => 'شهادة التسجيل';

  @override
  String get advisorIntakeAddDocument => 'إضافة مستند';

  @override
  String get advisorIntakeJobCategory => 'فئة العمل';

  @override
  String get advisorIntakeJobCategoryHint => 'اختر فئة العمل';

  @override
  String get advisorIntakeInsuranceName => 'اسم شركة التأمين';

  @override
  String get advisorIntakeInsuranceNameHint => 'اختر شركة التأمين';

  @override
  String get advisorIntakeLpoNumber => 'رقم أمر الشراء';

  @override
  String get advisorIntakePolicyNumber => 'رقم البوليصة';

  @override
  String get advisorIntakeAccidentNumber => 'رقم الحادث';

  @override
  String get advisorIntakeInsuranceTaxNumber => 'الرقم الضريبي للتأمين';

  @override
  String get advisorIntakeInsuranceTaxHint => 'أدخل الرقم الضريبي للتأمين';

  @override
  String get advisorIntakeInsuranceAddress => 'عنوان شركة التأمين';

  @override
  String get advisorIntakeInsuranceExpiry => 'تاريخ انتهاء التأمين';

  @override
  String get advisorIntakeInsuranceDocument => 'مستند التأمين';

  @override
  String get advisorIntakeMarkupType => 'نوع هامش الربح';

  @override
  String get advisorIntakeOrderType => 'نوع الطلب';

  @override
  String get advisorIntakeJobDescription => 'وصف العمل';

  @override
  String get advisorIntakeAddDescription => 'إضافة وصف آخر';

  @override
  String get advisorIntakeRemoveRow => 'حذف الصف';

  @override
  String get advisorIntakeDescriptionHint =>
      'صِف العمل المطلوب. استخدم شريط الأدوات للتعريف الغامق أو إضافة نقاط.';

  @override
  String get advisorIntakePriority => 'الأولوية';

  @override
  String get advisorIntakeSelectPriority => 'اختر الأولوية';

  @override
  String get advisorIntakeAttachments => 'المرفقات';

  @override
  String get advisorIntakePhotos => 'الصور';

  @override
  String get advisorIntakeVideo => 'فيديو';

  @override
  String get advisorIntakeAudio => 'صوت';

  @override
  String get advisorIntakeBold => 'غامق';

  @override
  String get advisorIntakeItalic => 'مائل';

  @override
  String get advisorIntakeBullet => 'قائمة نقطية';

  @override
  String advisorIntakeCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String advisorIntakeAddLabel(String label) {
    return 'إضافة $label';
  }

  @override
  String get advisorIntakeOdometer => 'قراءة العداد (كم)';

  @override
  String get advisorIntakeOdometerHint => 'العداد (بالكم)';

  @override
  String get advisorIntakeFuelLevel => 'مستوى الوقود';

  @override
  String get advisorIntakeCustomerConsent => 'موافقة العميل';

  @override
  String get advisorIntakeJobMedia => 'صور وفيديو بطاقة العمل';

  @override
  String get advisorIntakeDigitalSignatures => 'التوقيعات الرقمية';

  @override
  String get advisorIntakeSignatureCustomer => 'العميل';

  @override
  String get advisorIntakeSignatureAdvisor => 'المستشار';

  @override
  String get advisorIntakeSignatureCustomerTitle => 'توقيع العميل';

  @override
  String get advisorIntakeSignatureAdvisorTitle => 'توقيع المستشار';

  @override
  String get advisorIntakeSignatureInstruction => 'وقّع داخل الإطار أدناه';

  @override
  String get advisorIntakeSignatureClear => 'مسح';

  @override
  String get advisorIntakeSignatureUse => 'استخدام التوقيع';

  @override
  String get advisorIntakeSignatureCaptured => 'تم التوقيع';

  @override
  String get advisorIntakeSignatureRedo => 'إعادة';

  @override
  String get advisorIntakeAddRegistration => 'إضافة شهادة التسجيل';

  @override
  String get advisorIntakeAddInsurance => 'إضافة مستند التأمين';

  @override
  String get advisorIntakeTakePhoto => 'التقاط صورة';

  @override
  String get advisorIntakeChooseGallery => 'الاختيار من المعرض';

  @override
  String get advisorIntakeRecordVideo => 'تسجيل فيديو';

  @override
  String get advisorIntakeChooseVideo => 'اختيار فيديو';

  @override
  String get advisorIntakeAudioTitle => 'تسجيل صوتي لوصف العمل';

  @override
  String advisorIntakeAudioRecording(int seconds) {
    return 'جارٍ التسجيل… $seconds ثانية';
  }

  @override
  String get advisorIntakeAudioReplace =>
      'أعد التسجيل لاستبدال التسجيل الحالي.';

  @override
  String get advisorIntakeAudioPrompt => 'سجّل ملاحظة صوتية حتى 60 ثانية.';

  @override
  String get advisorIntakeErrCustomerName => 'يرجى إدخال اسم العميل';

  @override
  String get advisorIntakeErrPhone => 'يرجى إدخال رقم الجوال';

  @override
  String get advisorIntakeErrPhoneValid => 'يرجى إدخال رقم جوال صحيح';

  @override
  String get advisorIntakeErrPlate => 'يرجى إدخال رقم اللوحة';

  @override
  String get advisorIntakeErrMake => 'يرجى اختيار الشركة المصنّعة';

  @override
  String get advisorIntakeErrModel => 'يرجى اختيار طراز المركبة';

  @override
  String get advisorIntakeSyncedTitle => 'تم إنشاء بطاقة العمل ومزامنتها';

  @override
  String get advisorIntakeLocalTitle => 'تم حفظ بطاقة العمل محلياً';

  @override
  String get advisorIntakeSyncedBody =>
      'تم الحفظ على هذا الجهاز والخادم. هل ترغب في بدء الفحص؟';

  @override
  String get advisorIntakeLocalBody =>
      'تعذّر الوصول إلى الخادم. تم حفظ بطاقة العمل بأمان وستتم مزامنتها تلقائياً.';

  @override
  String get advisorIntakeAddInspection => 'إضافة فحص';

  @override
  String get advisorIntakeSkip => 'تخطٍ';

  @override
  String get advisorIntakeSaveFailed =>
      'تعذّر إنشاء بطاقة العمل. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';

  @override
  String get advisorIntakeOfflineNotice =>
      'أنت غير متصل. سيتم حفظ بطاقة العمل على هذا الجهاز ومزامنتها تلقائياً.';

  @override
  String get advisorIntakeSummaryTitle => 'ملخص مباشر';

  @override
  String get advisorIntakeSummaryEmpty =>
      'ابدأ بإدخال البيانات لعرض ملخص مباشر.';

  @override
  String get advisorIntakeSummaryNoName => 'لا يوجد عميل بعد';

  @override
  String get advisorIntakeSummaryCustomer => 'العميل';

  @override
  String get advisorIntakeSummaryVehicle => 'المركبة';

  @override
  String advisorIntakeSummaryProgress(int done, int total) {
    return 'اكتملت $done من $total أقسام';
  }

  @override
  String get advisorIntakeDiscardTitle => 'تجاهل هذا الاستقبال؟';

  @override
  String get advisorIntakeDiscardBody =>
      'لديك تغييرات غير محفوظة. سيؤدي الخروج الآن إلى فقدان البيانات المُدخلة.';

  @override
  String get advisorIntakeDiscardConfirm => 'تجاهل';

  @override
  String get advisorIntakeDiscardCancel => 'متابعة التعديل';

  @override
  String get advisorIntakeActionCreate => 'إنشاء بطاقة عمل';

  @override
  String get advisorIntakeActionCreating => 'جارٍ إنشاء بطاقة العمل…';

  @override
  String get advisorIntakeStatusSaving => 'جارٍ الحفظ محلياً…';

  @override
  String get advisorIntakeStatusQueued => 'في قائمة الانتظار (دون اتصال)';

  @override
  String get advisorIntakeStatusSent => 'تم الإرسال';

  @override
  String advisorIntakeSectionOf(int index, int total) {
    return 'القسم $index من $total';
  }

  @override
  String get advisorScanTitle => 'مسح المركبة';

  @override
  String get advisorScanModePlate => 'اللوحة';

  @override
  String get advisorScanModeVin => 'VIN';

  @override
  String get advisorScanModeQr => 'QR';

  @override
  String get advisorScanHintPlate => 'وجّه الكاميرا نحو لوحة الأرقام';

  @override
  String get advisorScanHintVin => 'امسح رمز VIN على لوحة القيادة';

  @override
  String get advisorScanHintQr => 'امسح رمز QR للمركبة';

  @override
  String get advisorScanManual => 'أو أدخل يدوياً';

  @override
  String get advisorScanManualHint => 'اللوحة / VIN / اسم العميل…';

  @override
  String get advisorScanPermissionTitle => 'إذن الكاميرا مطلوب';

  @override
  String get advisorScanPermissionBody =>
      'يلزم الوصول إلى الكاميرا للمسح. فعّله من الإعدادات للمتابعة.';

  @override
  String get advisorScanOpenSettings => 'فتح الإعدادات';

  @override
  String get advisorScanGrant => 'منح الإذن';

  @override
  String get advisorScanStarting => 'جارٍ تشغيل الكاميرا…';

  @override
  String get advisorScanScanning => 'جارٍ المسح…';

  @override
  String get advisorScanCameraUnavailable => 'الكاميرا غير متاحة';

  @override
  String get advisorScanTorch => 'تبديل الكشاف';

  @override
  String get advisorScanResultTitle => 'نتيجة المسح';

  @override
  String get advisorScanResultUse => 'استخدام هذه القيمة';

  @override
  String get advisorScanEnterValue => 'أدخل قيمة للمتابعة';

  @override
  String get advisorCheckInTitle => 'استلام المركبة';

  @override
  String get advisorCheckInStepDetails => 'العداد والوقود';

  @override
  String get advisorCheckInStepCondition => 'توثيق الحالة';

  @override
  String get advisorCheckInOdometer => 'قراءة العداد (كم)';

  @override
  String get advisorCheckInOdometerHint => 'مثال 14200';

  @override
  String get advisorCheckInFuel => 'مستوى الوقود';

  @override
  String get advisorCheckInNotes => 'ملاحظات العميل';

  @override
  String get advisorCheckInNotesHint => 'أضف أي ملاحظات من العميل';

  @override
  String get advisorCheckInNext => 'التالي: توثيق الحالة';

  @override
  String get advisorCheckInBack => 'رجوع';

  @override
  String get advisorCheckInFront => 'الأمام';

  @override
  String get advisorCheckInRear => 'الخلف';

  @override
  String get advisorCheckInLeft => 'الجانب الأيسر';

  @override
  String get advisorCheckInRight => 'الجانب الأيمن';

  @override
  String get advisorCheckInRoof => 'السقف';

  @override
  String get advisorCheckInAddDamage => 'إضافة تلف';

  @override
  String advisorCheckInDamageTitle(String area) {
    return 'تلف في $area';
  }

  @override
  String get advisorCheckInDamageHint => 'صِف التلف (مثل خدش، انبعاج)';

  @override
  String get advisorCheckInAdd => 'إضافة';

  @override
  String get advisorCheckInComplete => 'إكمال الاستلام';

  @override
  String get advisorCheckInSuccess => 'تم استلام المركبة بنجاح';

  @override
  String get advisorCheckInFailed => 'فشل الاستلام. يرجى المحاولة مرة أخرى.';

  @override
  String advisorCheckInError(String message) {
    return 'خطأ: $message';
  }

  @override
  String get advisorCheckInEmptyDamages => 'لم يتم تسجيل أي تلف بعد';

  @override
  String get advisorCheckInSectionDetails => 'العداد والوقود والملاحظات';

  @override
  String get advisorCheckInSectionDamage => 'التلف الموجود';

  @override
  String get advisorCheckInSectionDamageSub =>
      'اضغط على منطقة لتسجيل أي تلف موجود';

  @override
  String get advisorCheckInRemoveDamage => 'إزالة التلف';
}
