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
  String get advisorTodayEyebrow => 'اليوم';

  @override
  String get advisorFilterIntake => 'الاستلام';

  @override
  String get advisorFilterInspection => 'الفحص';

  @override
  String get advisorFilterApproved => 'معتمد';

  @override
  String get advisorFilterWip => 'قيد التنفيذ';

  @override
  String get advisorFilterReady => 'جاهز';

  @override
  String get advisorSortLabel => 'ترتيب';

  @override
  String get advisorSortNewest => 'الأحدث أولاً';

  @override
  String get advisorSortOldest => 'الأقدم أولاً';

  @override
  String get advisorSortCustomer => 'العميل أ–ي';

  @override
  String get advisorSeeAll => 'عرض الكل';

  @override
  String get advisorMetricReady => 'جاهز';

  @override
  String get advisorDueToday => 'مستحق اليوم';

  @override
  String advisorHomeUpdatedAt(String time) {
    return 'آخر تحديث $time';
  }

  @override
  String advisorHeroDueTitle(int count) {
    return '$count عمليات فحص مستحقة اليوم';
  }

  @override
  String get advisorHeroSentence => 'راجع المهام العاجلة أولاً.';

  @override
  String get advisorHeroViewJobs => 'عرض المهام';

  @override
  String get advisorHeroCaughtUp => 'لا مهام عاجلة — ستظهر المهام الجديدة هنا.';

  @override
  String get advisorHomeEmptyTitle => 'لا توجد مهام مسندة بعد';

  @override
  String get advisorHomeEmptyBody =>
      'ستظهر بطاقات العمل الجديدة هنا. أنشئ واحدة للبدء.';

  @override
  String get advisorActionApprovalsTitle => 'الموافقات';

  @override
  String get advisorActionApprovalsSubtitle => 'بانتظار الاعتماد';

  @override
  String get advisorActionSearchTitle => 'بحث';

  @override
  String get advisorActionSearchSubtitle => 'المهام والعملاء';

  @override
  String advisorDeltaToday(int count) {
    return '+$count اليوم';
  }

  @override
  String get advisorSectionStages => 'المراحل';

  @override
  String get advisorSectionChecklist => 'قائمة الفحص';

  @override
  String get advisorSectionEstimates => 'التقديرات';

  @override
  String get advisorSectionInvoices => 'الفواتير';

  @override
  String get advisorSectionNotes => 'الملاحظات';

  @override
  String get advisorStageIntake => 'الاستلام';

  @override
  String get advisorStageInspection => 'الفحص';

  @override
  String get advisorStageEstimate => 'التقدير';

  @override
  String get advisorStageRepair => 'الإصلاح';

  @override
  String get advisorStageQc => 'الجودة';

  @override
  String get advisorStageReady => 'جاهز';

  @override
  String get advisorEmptyEstimates => 'لا توجد تقديرات لهذه المهمة بعد.';

  @override
  String get advisorEmptyInvoices => 'لا توجد فواتير لهذه المهمة بعد.';

  @override
  String get advisorEmptyNotes => 'لا توجد ملاحظات لهذه المهمة بعد.';

  @override
  String get advisorEmptyChecklist => 'لا توجد عناصر فحص مسجلة بعد.';

  @override
  String get advisorSectionActivity => 'النشاط';

  @override
  String get advisorSearchRecent => 'الأخيرة';

  @override
  String get advisorShowLess => 'عرض أقل';

  @override
  String get advisorApprovalTypeEstimate => 'تقدير';

  @override
  String get advisorApprovalTypeJobCard => 'بطاقة عمل';

  @override
  String get advisorApprovalTypeInspection => 'فحص';

  @override
  String get advisorPriorityHigh => 'عاجل';

  @override
  String get advisorPriorityMedium => 'متابعة';

  @override
  String get advisorPriorityLow => 'تذكير';

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
  String get advisorPackageTitle => 'اختر باقة الفحص';

  @override
  String get advisorPackageSubtitle =>
      'اختر مستوى الفحص المناسب لهذه المركبة. يمكنك تغيير الباقة قبل البدء.';

  @override
  String get advisorPackageQuick => 'فحص سريع من 20 نقطة';

  @override
  String get advisorPackageQuickDesc =>
      'مسح سلامة سريع لمنطقة الاستلام والمسار السريع.';

  @override
  String get advisorPackageFull => 'فحص شامل من 60 نقطة';

  @override
  String get advisorPackageFullDesc =>
      'فحص كامل لمنطقة المحرك والمكابح والتعليق والبطارية والإطارات والهيكل الخارجي.';

  @override
  String get advisorPackageSafety => 'تدقيق السلامة وصلاحية الطريق';

  @override
  String get advisorPackageSafetyDesc =>
      'تدقيق المكابح والتوجيه وأحزمة الأمان والإنارة لاعتماد صلاحية الطريق.';

  @override
  String advisorPackageDuration(int minutes) {
    return 'نحو $minutes دقيقة';
  }

  @override
  String advisorPackageCheckpoints(int count) {
    return '$count نقطة فحص';
  }

  @override
  String advisorPackageSections(int count) {
    return '$count أقسام';
  }

  @override
  String get advisorPackageFocus => 'مجالات التركيز';

  @override
  String get advisorFocusBrakes => 'المكابح';

  @override
  String get advisorFocusEngine => 'المحرك';

  @override
  String get advisorFocusSuspension => 'نظام التعليق';

  @override
  String get advisorFocusLighting => 'الإنارة';

  @override
  String get advisorPackageRecommended => 'موصى به';

  @override
  String get advisorPackageSelected => 'محدد';

  @override
  String get advisorPackageStart => 'متابعة';

  @override
  String get advisorPackageSortRecommended => 'موصى به';

  @override
  String get advisorPackageSortQuickest => 'الأسرع';

  @override
  String get advisorPackageSortThorough => 'الأشمل';

  @override
  String get advisorPackageSkip => 'تخطي';

  @override
  String get advisorHudTitle => 'مساحة الفحص';

  @override
  String advisorHudProgress(int done, int total) {
    return '$done من $total نقطة فحص';
  }

  @override
  String get advisorHudTabDamage => 'خريطة الأضرار';

  @override
  String get advisorHudTabChecks => 'نقاط الفحص';

  @override
  String get advisorHudCanvasTitle => 'لوحة الأضرار';

  @override
  String get advisorHudCanvasHint =>
      'انقر على جزء من الهيكل لتسجيل ضرر. قرّب بالتكبير واسحب للتحريك.';

  @override
  String get advisorHudKindTitle => 'ما نوع الضرر؟';

  @override
  String get advisorHudKindMinor => 'خدش بسيط';

  @override
  String get advisorHudKindMinorHint => 'خدش سطحي أو احتكاك';

  @override
  String get advisorHudKindStructural => 'انبعاج هيكلي';

  @override
  String get advisorHudKindStructuralHint => 'انبعاج عميق أو تشوه';

  @override
  String get advisorHudKindGlass => 'كسر زجاج أو مصباح';

  @override
  String get advisorHudKindGlassHint => 'زجاج متشقق أو مجموعة مصباح';

  @override
  String get advisorHudPinsTitle => 'علامات الأضرار';

  @override
  String get advisorHudNoPins => 'لا توجد علامات ضرر بعد';

  @override
  String get advisorHudNoPinsHint =>
      'انقر على السيارة أعلاه لتسجيل أول نقطة ضرر.';

  @override
  String get advisorHudDeletePin => 'حذف العلامة';

  @override
  String get advisorHudZoneFront => 'الأمام';

  @override
  String get advisorHudZoneFrontLeft => 'الأمام الأيسر';

  @override
  String get advisorHudZoneSideLeft => 'الجانب الأيسر';

  @override
  String get advisorHudZoneRearLeft => 'الخلف الأيسر';

  @override
  String get advisorHudZoneRear => 'الخلف';

  @override
  String get advisorHudZoneRearRight => 'الخلف الأيمن';

  @override
  String get advisorHudZoneSideRight => 'الجانب الأيمن';

  @override
  String get advisorHudZoneFrontRight => 'الأمام الأيمن';

  @override
  String get advisorHudRingPass => 'سليم';

  @override
  String get advisorHudRingCaution => 'يحتاج انتباه';

  @override
  String get advisorHudRingFail => 'راسب';

  @override
  String get advisorHudMarkAllPass => 'الكل سليم';

  @override
  String get advisorHudSearchHint => 'ابحث في نقاط الفحص…';

  @override
  String get advisorHudNoMatch => 'لا توجد نقاط مطابقة';

  @override
  String advisorHudSectionRemaining(int count) {
    return '$count متبقٍ';
  }

  @override
  String get advisorHudSectionDone => 'اكتملت جميع نقاط الفحص';

  @override
  String get advisorHudDockTitle => 'الأدلة الصوتية والصور';

  @override
  String get advisorHudVoiceIdle => 'انقر لتسجيل ملاحظة صوتية';

  @override
  String advisorHudVoiceRecording(int seconds) {
    return 'جارٍ التسجيل… $seconds ث';
  }

  @override
  String get advisorHudVoicePlay => 'تشغيل';

  @override
  String get advisorHudVoiceDelete => 'حذف التسجيل';

  @override
  String get advisorHudVoiceSaved => 'تم حفظ الملاحظة الصوتية';

  @override
  String get advisorHudMicDenied => 'تم رفض الوصول إلى الميكروفون';

  @override
  String get advisorHudMicDeniedHint =>
      'فعّل الوصول إلى الميكروفون من إعدادات النظام لتسجيل الملاحظات الصوتية.';

  @override
  String get advisorHudCameraDenied => 'تم رفض الوصول إلى الكاميرا';

  @override
  String get advisorHudCameraDeniedHint =>
      'فعّل الوصول إلى الكاميرا من إعدادات النظام لالتقاط الأدلة المصورة.';

  @override
  String get advisorHudGalleryDenied => 'تم رفض الوصول إلى المعرض';

  @override
  String get advisorHudGalleryDeniedHint =>
      'فعّل الوصول إلى المعرض من إعدادات النظام لإرفاق الصور.';

  @override
  String get advisorHudOpenSettings => 'فتح الإعدادات';

  @override
  String get advisorHudPhotoRetry => 'انقر لإعادة المحاولة';

  @override
  String get advisorHudPhotoError =>
      'تعذّر إرفاق الصورة. تحقق من التخزين وحاول مجدداً.';

  @override
  String get advisorHudReview => 'مراجعة الفحص';

  @override
  String get advisorHudNotifyOwner => 'إشعار المالك بعد الإرسال';

  @override
  String get advisorHudTemplateError =>
      'تعذّر تحميل نموذج الفحص. تحقق من اتصالك وحاول مجدداً.';

  @override
  String get advisorHudRetry => 'إعادة المحاولة';

  @override
  String get advisorHudAddNote => 'إضافة ملاحظة';

  @override
  String get advisorHudClear => 'مسح';

  @override
  String get advisorHudResetGrade => 'إعادة تعيين التقييم';

  @override
  String get advisorHudDone => 'تم';

  @override
  String get advisorHudDoneMarking => 'إنهاء التحديد';

  @override
  String get advisorHudContinue => 'متابعة';

  @override
  String get advisorHudShowPins => 'عرض القائمة';

  @override
  String get advisorHudLegendTitle => 'دليل شدة الضرر';

  @override
  String get advisorHudHidePins => 'إخفاء';

  @override
  String get advisorDamageKindScratch => 'خدش / احتكاك';

  @override
  String get advisorDamageKindDent => 'انبعاج';

  @override
  String get advisorDamageKindCrack => 'شرخ';

  @override
  String get advisorDamageKindPaint => 'تلف الدهان';

  @override
  String get advisorDamageKindBroken => 'مكسور / مفقود';

  @override
  String get advisorDamageMinor => 'بسيط';

  @override
  String get advisorDamageModerate => 'متوسط';

  @override
  String get advisorDamageSevere => 'جسيم';

  @override
  String get advisorDamageSizeCoin => 'بحجم العملة';

  @override
  String get advisorDamageSizePalm => 'بحجم الكف';

  @override
  String get advisorDamageSizeSpan => 'بحجم الشبر';

  @override
  String get advisorDamageCatBody => 'هيكل';

  @override
  String get advisorDamageCatGlass => 'زجاج';

  @override
  String get advisorDamageCatWheel => 'عجلة';

  @override
  String get advisorDamageCatLight => 'مصباح';

  @override
  String get advisorDamageCatMirror => 'مرآة';

  @override
  String get advisorDamageLogTitle => 'تسجيل ضرر';

  @override
  String get advisorDamageEditTitle => 'تعديل الضرر';

  @override
  String get advisorDamageKindSection => 'نوع الضرر';

  @override
  String get advisorDamageSeveritySection => 'درجة الضرر';

  @override
  String get advisorDamageSizeSection => 'الحجم';

  @override
  String get advisorDamageSizeOptional => 'اختياري';

  @override
  String get advisorDamagePhotoSection => 'الدليل المصور';

  @override
  String get advisorDamagePhotoRequired =>
      'الصورة مطلوبة للضرر المتوسط والجسيم.';

  @override
  String get advisorDamageAddPhoto => 'إضافة صورة';

  @override
  String get advisorDamageNoteHint => 'أضف ملاحظة (اختياري)';

  @override
  String get advisorDamageVoiceSection => 'ملاحظة صوتية';

  @override
  String get advisorDamageAddPin => 'إضافة علامة';

  @override
  String get advisorDamageSaveChanges => 'حفظ التعديلات';

  @override
  String get advisorDamageKindRequired => 'اختر نوع الضرر للمتابعة.';

  @override
  String get advisorDamageDeleteTitle => 'حذف هذه العلامة؟';

  @override
  String get advisorDamageDelete => 'حذف';

  @override
  String get advisorDamageEdit => 'تعديل';

  @override
  String get advisorDamageMapLoading => 'جارٍ تحميل خريطة المركبة…';

  @override
  String get advisorDamageMapError => 'تعذّر تحميل خريطة المركبة.';

  @override
  String get advisorDamageResetView => 'إعادة العرض';

  @override
  String get advisorDamageZoomIn => 'تكبير';

  @override
  String get advisorDamageZoomOut => 'تصغير';

  @override
  String get advisorPartFrontBumper => 'المصد الأمامي';

  @override
  String get advisorPartHood => 'غطاء المحرك';

  @override
  String get advisorPartFrontLeftHeadlight => 'المصباح الأمامي الأيسر';

  @override
  String get advisorPartFrontRightHeadlight => 'المصباح الأمامي الأيمن';

  @override
  String get advisorPartFrontWindshield => 'الزجاج الأمامي';

  @override
  String get advisorPartRoof => 'السقف';

  @override
  String get advisorPartRearWindshield => 'الزجاج الخلفي';

  @override
  String get advisorPartTrunk => 'صندوق الأمتعة';

  @override
  String get advisorPartRearBumper => 'المصد الخلفي';

  @override
  String get advisorPartFrontLeftFender => 'الرفرف الأمامي الأيسر';

  @override
  String get advisorPartFrontRightFender => 'الرفرف الأمامي الأيمن';

  @override
  String get advisorPartFrontLeftDoor => 'الباب الأمامي الأيسر';

  @override
  String get advisorPartRearLeftDoor => 'الباب الخلفي الأيسر';

  @override
  String get advisorPartFrontRightDoor => 'الباب الأمامي الأيمن';

  @override
  String get advisorPartRearRightDoor => 'الباب الخلفي الأيمن';

  @override
  String get advisorPartRearLeftQuarter => 'الرفرف الخلفي الأيسر';

  @override
  String get advisorPartRearRightQuarter => 'الرفرف الخلفي الأيمن';

  @override
  String get advisorPartLeftMirror => 'المرآة اليسرى';

  @override
  String get advisorPartRightMirror => 'المرآة اليمنى';

  @override
  String get advisorPartFrontLeftWheel => 'العجلة الأمامية اليسرى';

  @override
  String get advisorPartFrontRightWheel => 'العجلة الأمامية اليمنى';

  @override
  String get advisorPartRearLeftWheel => 'العجلة الخلفية اليسرى';

  @override
  String get advisorPartRearRightWheel => 'العجلة الخلفية اليمنى';

  @override
  String get advisorPartRearLeftTaillight => 'المصباح الخلفي الأيسر';

  @override
  String get advisorPartRearRightTaillight => 'المصباح الخلفي الأيمن';

  @override
  String get advisorHealthTitle => 'تقرير صحة المركبة';

  @override
  String get advisorHealthSubtitle =>
      'راجع جميع النتائج قبل التحويل أو الإرسال.';

  @override
  String advisorHealthScore(int score) {
    return '$score٪ الصحة العامة';
  }

  @override
  String advisorHealthScoredOf(int done, int total) {
    return '$done من $total نقطة تم تقييمها';
  }

  @override
  String get advisorHealthMandatory => 'بنود السلامة الإلزامية';

  @override
  String get advisorHealthRecommended => 'صيانة موصى بها';

  @override
  String get advisorHealthGoodGroup => 'حالة جيدة';

  @override
  String get advisorHealthConvert => 'تحويل إلى تقدير';

  @override
  String get advisorHealthSubmit => 'إرسال الفحص';

  @override
  String get advisorHealthSubmitting => 'جارٍ إرسال الفحص…';

  @override
  String get advisorHealthEmpty => 'لم يتم تقييم أي نقطة بعد';

  @override
  String get advisorHealthEmptyHint =>
      'قيّم نقطة واحدة على الأقل لإنشاء تقرير الصحة.';

  @override
  String advisorHealthRemaining(int count) {
    return '$count نقاط ما زالت بحاجة إلى تقييم';
  }

  @override
  String get advisorHealthBackEdit => 'رجوع للتعديل';

  @override
  String advisorHealthReady(int count) {
    return '$count نقاط جاهزة للإرسال';
  }

  @override
  String get advisorHealthSubmitTitle => 'إرسال هذا الفحص؟';

  @override
  String get advisorHealthSubmitMessage =>
      'تأكد من صحة تقييمات النقاط وعلامات الأضرار والمرفقات.';

  @override
  String get advisorHealthReviewAgain => 'مراجعة مجدداً';

  @override
  String advisorHealthAttachments(int count) {
    return '$count مرفقات';
  }

  @override
  String get advisorHealthShare => 'مشاركة';

  @override
  String get advisorHealthExport => 'تصدير';

  @override
  String get advisorHealthCopied => 'تم نسخ التقرير إلى الحافظة';

  @override
  String get advisorHealthExpand => 'عرض';

  @override
  String get advisorHealthCollapse => 'إخفاء';

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

  @override
  String get advisorJobsColumnCustomer => 'العميل';

  @override
  String get advisorJobsColumnJobCard => 'بطاقة العمل';

  @override
  String get advisorJobsColumnStatus => 'الحالة';

  @override
  String get advisorJobsColumnTime => 'الوقت';

  @override
  String get advisorJobsSelectPrompt => 'اختر بطاقة عمل لمعاينة التفاصيل';

  @override
  String get advisorActionOpenJob => 'فتح بطاقة العمل';

  @override
  String get advisorActionMore => 'المزيد من الإجراءات';

  @override
  String get advisorIntakeWizardNext => 'متابعة';

  @override
  String get advisorIntakeWizardBack => 'رجوع';

  @override
  String advisorIntakeWizardStepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get advisorIntakeWizardContactTitle => 'بيانات العميل';

  @override
  String get advisorIntakeWizardContactSub =>
      'ابحث عن عميل موجود أو أضف عميلاً جديداً';

  @override
  String get advisorIntakeWizardVehicleTitle => 'المركبة واللوحة';

  @override
  String get advisorIntakeWizardVehicleSub =>
      'اللوحة ورقم الهيكل والعلامة التجارية والطراز';

  @override
  String get advisorIntakeWizardCaptureTitle => 'توثيق الصور';

  @override
  String get advisorIntakeWizardCaptureSub => 'المستندات والصور والقراءات';

  @override
  String get advisorIntakeWizardSignoffTitle => 'نطاق العمل والاعتماد';

  @override
  String get advisorIntakeWizardSignoffSub => 'نطاق العمل والتوقيعات والمراجعة';

  @override
  String get advisorIntakeWizardDraftRestored => 'تمت استعادة المسودة السابقة';

  @override
  String get advisorIntakeWizardBlocked => 'أكمل هذه الخطوة للمتابعة';

  @override
  String get advisorScanDecodeIdle => 'ضع الرمز داخل الإطار';

  @override
  String get advisorScanTipsTitle => 'نصائح المسح الضوئي';

  @override
  String get advisorScanTipAlign => 'ثبّت الجهاز على بعد 15–20 سم من الرمز';

  @override
  String get advisorScanTipLight => 'استخدم المصباح في الإضاءة الضعيفة';

  @override
  String get advisorScanTipManual =>
      'تعذّر المسح؟ أدخل القيمة يدوياً دون فقدان أي بيانات';

  @override
  String get advisorScanViewfinderLabel => 'منظار الكاميرا';

  @override
  String get advisorCheckInFuelEmpty => 'فارغ';

  @override
  String get advisorCheckInFuelQuarter => '1/4';

  @override
  String get advisorCheckInFuelHalf => '1/2';

  @override
  String get advisorCheckInFuelThreeQuarter => '3/4';

  @override
  String get advisorCheckInFuelFull => 'ممتلئ';

  @override
  String get advisorCheckInOdoTitle => 'خانات عدّاد المسافة';

  @override
  String get advisorCheckInOdoUnit => 'كم';

  @override
  String get advisorCheckInOdoPlus1k => '+1k';

  @override
  String get advisorCheckInOdoPlus10k => '+10k';

  @override
  String get advisorCheckInOdoClear => 'تصفير';

  @override
  String get advisorCheckInConfirmTitle => 'تأكيد استلام المركبة';

  @override
  String get advisorCheckInConfirmBody =>
      'راجع القراءات قبل تسليم المركبة إلى الفحص.';

  @override
  String get advisorCheckInClusterSub => 'قراءات الاستلام الحية';

  @override
  String get advisorDeliveryTitle => 'تسليم المركبة';

  @override
  String get advisorDeliverySubtitle => 'بروتوكول التسليم الرسمي';

  @override
  String get advisorDeliveryChecklistTitle => 'قائمة التسليم';

  @override
  String advisorDeliveryProgress(int done, int total) {
    return 'تم التحقق من $done من $total';
  }

  @override
  String get advisorDeliveryCheckInvoice => 'تسليم نسخة من الفاتورة للعميل';

  @override
  String get advisorDeliveryCheckKeys => 'تسليم مفاتيح المركبة';

  @override
  String get advisorDeliveryCheckDocs => 'إعادة وثائق المركبة';

  @override
  String get advisorDeliveryCheckService => 'تذكير العميل بموعد الصيانة القادم';

  @override
  String get advisorDeliveryCheckWarranty => 'شرح معلومات الضمان';

  @override
  String get advisorDeliveryMileage => 'قراءة العدّاد النهائية (كم)';

  @override
  String get advisorDeliveryMileageHint => 'مثال: 48250';

  @override
  String get advisorDeliveryMileageError =>
      'أدخل قراءة العدّاد النهائية لإتمام التسليم';

  @override
  String get advisorDeliveryRating => 'رضا العميل';

  @override
  String advisorDeliveryRatingValue(int value) {
    return 'التقييم $value من 5';
  }

  @override
  String get advisorDeliveryNotes => 'ملاحظات التسليم';

  @override
  String get advisorDeliveryNotesHint =>
      'ملاحظات العميل وطلبات الإرجاع وملاحظات الضمان…';

  @override
  String get advisorDeliverySignature => 'توقيع العميل';

  @override
  String get advisorDeliverySignatureHint =>
      'التقط توقيع العميل لإغلاق بروتوكول التسليم';

  @override
  String get advisorDeliverySignAction => 'التقاط التوقيع';

  @override
  String get advisorDeliverySigned => 'تم التوقيع';

  @override
  String get advisorDeliveryComplete => 'إتمام التسليم';

  @override
  String advisorDeliveryRemaining(int count) {
    return 'متبقٍ $count من البنود';
  }

  @override
  String get advisorDeliverySuccess => 'تم تسليم المركبة بنجاح';

  @override
  String get advisorDeliveryFailed => 'تعذّر إتمام التسليم';

  @override
  String advisorDeliveryError(String message) {
    return 'خطأ: $message';
  }

  @override
  String advisorIntakeAttachmentError(String message) {
    return 'تعذّر إضافة المرفق: $message';
  }

  @override
  String get advisorStudioTitle => 'تقدير الإصلاح';

  @override
  String get advisorStudioSubtitle => 'أنشئ تقدير العميل لبطاقة العمل هذه';

  @override
  String get advisorStudioStepParts => 'القطع';

  @override
  String get advisorStudioStepLabor => 'الأجور';

  @override
  String get advisorStudioStepReview => 'المراجعة';

  @override
  String get advisorStudioTierMandatory => 'إصلاحات السلامة الإلزامية';

  @override
  String get advisorStudioTierOptional => 'تحسينات اختيارية';

  @override
  String get advisorStudioCategoryParts => 'القطع';

  @override
  String get advisorStudioCategoryLabor => 'الأجور';

  @override
  String get advisorStudioCategorySublet => 'أعمال خارجية';

  @override
  String advisorStudioEmptyCategory(String category) {
    return 'لا توجد عناصر $category بعد';
  }

  @override
  String advisorStudioAddItem(String category) {
    return 'إضافة $category';
  }

  @override
  String advisorStudioStockIn(int bay) {
    return 'متوفر · خانة $bay';
  }

  @override
  String advisorStudioStockOrder(String hours) {
    return 'طلب · $hours';
  }

  @override
  String advisorStudioLaborDetail(String hours, String rate) {
    return '$hours س × $rate';
  }

  @override
  String get advisorStudioLineTotal => 'إجمالي السطر';

  @override
  String get advisorStudioQuantity => 'الكمية';

  @override
  String get advisorStudioUnitPrice => 'سعر الوحدة';

  @override
  String get advisorStudioDiscountPct => 'نسبة الخصم';

  @override
  String get advisorStudioSuggestPrice => 'اقتراح سعر من السجل';

  @override
  String get advisorStudioRemoveItem => 'حذف العنصر';

  @override
  String get advisorStudioPartsSubtotal => 'إجمالي القطع';

  @override
  String get advisorStudioLabor => 'الأجور';

  @override
  String get advisorStudioVat => 'ضريبة القيمة المضافة (5%)';

  @override
  String get advisorStudioTotal => 'الإجمالي';

  @override
  String get advisorStudioTrustLine =>
      'ضريبة قيمة مضافة إلزامية 5% · الأسعار بالدرهم الإماراتي';

  @override
  String get advisorStudioConfirm => 'مراجعة التقدير';

  @override
  String get advisorStudioAddItems => 'إضافة عناصر التقدير';

  @override
  String get advisorStudioLoading => 'جارٍ تحميل عناصر التقدير…';

  @override
  String get advisorStudioError => 'تعذّر تحميل عناصر التقدير.';

  @override
  String get advisorStudioNoMatch => 'لا توجد عناصر مطابقة';

  @override
  String advisorStudioRemoved(String name) {
    return 'تم حذف $name';
  }

  @override
  String get advisorStudioFromInspection => 'تم الفحص وإرفاقه';

  @override
  String get advisorStudioReset => 'إعادة تعيين';

  @override
  String get advisorStudioResetTitle => 'مسح هذا التقدير؟';

  @override
  String get advisorStudioResetBody =>
      'سيتم حذف جميع الخدمات والقطع والأسعار والملاحظات المدخلة هنا.';

  @override
  String get advisorStudioResetKeep => 'متابعة التحرير';

  @override
  String get advisorStudioResetConfirm => 'مسح التقدير';

  @override
  String get advisorStudioSelectServicesTitle => 'اختر الخدمات المطلوبة';

  @override
  String get advisorStudioSelectServicesSubtitle =>
      'يمكن إدخال الأسعار بعد إضافتها';

  @override
  String get advisorStudioSearchServices => 'ابحث عن الخدمات';

  @override
  String get advisorStudioSelectPartsTitle => 'اختر القطع المطلوبة';

  @override
  String get advisorStudioSelectPartsSubtitle =>
      'يمكن تحديث الكمية والسعر بعد إضافتها';

  @override
  String get advisorStudioSearchParts => 'ابحث عن القطع';

  @override
  String get advisorStudioNoServices => 'لا توجد خدمات';

  @override
  String get advisorStudioNoParts => 'لا توجد قطع';

  @override
  String advisorStudioSelectedCount(int count) {
    return 'تم اختيار $count';
  }

  @override
  String get advisorStudioDone => 'تم';

  @override
  String get advisorStudioAddSelectedServices => 'إضافة الخدمات';

  @override
  String get advisorStudioAddSelectedParts => 'إضافة القطع';

  @override
  String get advisorStudioTapToAdd => 'اضغط للإضافة';

  @override
  String get advisorStudioAdded => 'أُضيف إلى التقدير';

  @override
  String get advisorStudioSubletHint =>
      'يتم حجز الأعمال الخارجية خارج هذا التقدير.';

  @override
  String get advisorEstimateShareTitle => 'مشاركة التقدير';

  @override
  String get advisorEstimateInvoiceTitle => 'تقدير';

  @override
  String get advisorEstimateCustomer => 'العميل';

  @override
  String get advisorEstimateVehicle => 'المركبة';

  @override
  String get advisorEstimatePreparedOn => 'أُعدّ في';

  @override
  String get advisorEstimateShareWhatsApp => 'مشاركة عبر واتساب';

  @override
  String get advisorEstimateCopyLink => 'نسخ الرابط';

  @override
  String get advisorEstimateLinkCopied => 'تم نسخ رابط التقدير';

  @override
  String get advisorEstimateShareHint =>
      'أرسل للعميل تقديراً تفاعلياً للموافقة.';

  @override
  String get advisorEstimateSummaryTitle => 'الملخص';

  @override
  String get advisorEstimateSubTotal => 'المجموع الفرعي';

  @override
  String get advisorEstimateGrandTotal => 'الإجمالي العام';

  @override
  String get advisorEstimateNoContact => 'لا يوجد رقم هاتف للعميل';

  @override
  String get advisorEstimateCreateOrder => 'إنشاء أمر إصلاح';

  @override
  String get advisorEstimateAddSignature => 'إضافة توقيع';

  @override
  String get advisorEstimateSigned => 'تم التوقيع';

  @override
  String get advisorEstimateSignatureLabel => 'توقيع العميل';

  @override
  String get advisorEstimateSignatureTitle => 'توقيع العميل';

  @override
  String get advisorEstimateSignatureClear => 'مسح';

  @override
  String get advisorEstimateSignatureUse => 'استخدام التوقيع';

  @override
  String get advisorEstimateReviewTitle => 'مراجعة التقدير';

  @override
  String get advisorEstimateMissingJob => 'بطاقة العمل مفقودة';

  @override
  String get advisorEstimateNoItems =>
      'لا توجد عناصر إصلاح. أضف عملاً إضافياً أو أعد المحاولة بعد الفحص.';

  @override
  String get advisorEstimateCreated => 'تم إنشاء أمر الإصلاح';

  @override
  String get advisorEstimateCreateFailed => 'تعذّر إنشاء أمر الإصلاح';

  @override
  String get advisorDispatchTitle => 'توزيع الخانات';

  @override
  String get advisorDispatchSubtitle => 'أسند مهام الإصلاح إلى فني';

  @override
  String get advisorDispatchTechnicianSection => 'الفني';

  @override
  String get advisorDispatchSelectTech => 'اختر فنياً';

  @override
  String advisorDispatchLoad(int count) {
    return '$count مهمة نشطة';
  }

  @override
  String get advisorDispatchFree => 'متفرغ الآن';

  @override
  String advisorDispatchAvailableIn(String hours) {
    return 'متفرغ خلال $hours';
  }

  @override
  String get advisorDispatchSkillBrakes => 'الفرامل';

  @override
  String get advisorDispatchSkillAc => 'التكييف';

  @override
  String get advisorDispatchSkillElectrical => 'الكهرباء';

  @override
  String get advisorDispatchTaskSection => 'عناصر الإصلاح';

  @override
  String get advisorDispatchAddExtraWork => 'إضافة عمل إضافي';

  @override
  String get advisorDispatchHoursHint => 'ساعة';

  @override
  String get advisorDispatchTaskHint => 'أضف بند عمل إضافي';

  @override
  String get advisorDispatchEmpty => 'لا توجد عناصر عمل مُنشأة.';

  @override
  String advisorDispatchSelected(String name) {
    return 'تم اختيار $name';
  }

  @override
  String advisorDispatchCta(int count) {
    return 'إسناد $count مهمة';
  }

  @override
  String get advisorDispatchCtaOne => 'إسناد مهمة واحدة';

  @override
  String get advisorDispatchNeedTech => 'الرجاء اختيار فني';

  @override
  String get advisorDispatchNeedTask => 'الرجاء إضافة مهمة واحدة على الأقل';

  @override
  String get advisorDispatchSuccess => 'تم إسناد المهام بنجاح';

  @override
  String get advisorDispatchFailed => 'تعذّر إسناد المهام';

  @override
  String advisorDispatchError(String message) {
    return 'خطأ: $message';
  }

  @override
  String advisorDispatchAssignedTo(String name) {
    return 'مُسند إلى $name';
  }

  @override
  String get advisorDispatchLoading => 'جارٍ تحميل عناصر الإصلاح…';

  @override
  String get advisorStudioDetails => 'تفاصيل التقدير';

  @override
  String get advisorStudioReference => 'رقم المرجع';

  @override
  String get advisorStudioReferenceHint => 'مثال: LPO-2026-001';

  @override
  String get advisorStudioRequests => 'طلبات العميل';

  @override
  String get advisorStudioRequestsHint => 'طلبات / شكاوى العميل';

  @override
  String get advisorStudioRecommendations => 'توصيات الورشة';

  @override
  String get advisorStudioRecommendationsHint => 'أدخل توصيات الورشة هنا';

  @override
  String get advisorStudioDelivery => 'التسليم المتوقع';

  @override
  String get advisorStudioDeliveryPick => 'اختر التاريخ والوقت';

  @override
  String get advisorStudioNotify => 'إشعار المالك (رسائل وبريد)';

  @override
  String get advisorStudioTag => 'الوسم';

  @override
  String get advisorStudioTagHint => 'أدخل وسماً (مثل VIP، أسطول، تأمين)';

  @override
  String get advisorStudioTagAction => 'حفظ الوسم';

  @override
  String get advisorStudioMedia => 'وسائط ما قبل الخدمة';

  @override
  String get advisorStudioMediaAdd => 'إضافة وسائط';

  @override
  String get advisorStudioMediaCamera => 'التقاط صورة';

  @override
  String get advisorStudioMediaGallery => 'اختيار من المعرض';

  @override
  String get advisorStudioMediaVideo => 'تسجيل فيديو';

  @override
  String get advisorEstimateApprovalTitle => 'موافقة العميل';

  @override
  String get advisorEstimateApprovalSubtitle =>
      'اختر كيف سيوافق العميل على هذا التقدير.';

  @override
  String get advisorEstimateApprovalHere => 'موافقة العميل هنا';

  @override
  String get advisorEstimateApprovalHereHint =>
      'استخدمه عندما راجع العميل التقدير وقبله معك.';

  @override
  String get advisorEstimateApprovalApp => 'إرسال إلى تطبيق العميل';

  @override
  String get advisorEstimateApprovalAppHint =>
      'ينتظر العمل حتى يوافق العميل من حسابه.';

  @override
  String get advisorEstimateSubmit => 'إرسال التقدير';

  @override
  String get advisorEstimateSubmitting => 'جارٍ إرسال التقدير…';

  @override
  String get techNavToday => 'اليوم';

  @override
  String get techNavJobs => 'المهام';

  @override
  String get techNavProductivity => 'الإنتاجية';

  @override
  String get techNavProfile => 'الملف الشخصي';

  @override
  String get techProfileLabel => 'ملف الفني';

  @override
  String get techWorkspaceName => 'الفني';

  @override
  String techGreeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get techShiftStart => 'بدء الوردية';

  @override
  String get techShiftBreak => 'أخذ استراحة';

  @override
  String get techShiftResume => 'استئناف الوردية';

  @override
  String get techShiftDone => 'اكتملت الوردية';

  @override
  String get techShiftEnd => 'إنهاء الوردية';

  @override
  String get techShiftClockInHint => 'سجّل حضورك لبدء عمل اليوم';

  @override
  String techShiftWorked(String work, String rest) {
    return 'عمل $work · استراحة $rest';
  }

  @override
  String get techAttendanceNotPunchedIn => 'لم يتم تسجيل الحضور';

  @override
  String get techAttendanceWorking => 'يعمل';

  @override
  String get techAttendanceOnBreak => 'في استراحة';

  @override
  String get techAttendancePunchedOut => 'سجّل الانصراف';

  @override
  String get techBannerActive => 'المهمة النشطة';

  @override
  String get techBannerReady => 'بانتظار مهمة';

  @override
  String get techBannerReadyHint => 'تظهر مهمتك التالية هنا عند إسنادها.';

  @override
  String get techBannerPause => 'إيقاف مؤقت';

  @override
  String get techBannerResume => 'استئناف';

  @override
  String get techBannerOpen => 'فتح المهمة';

  @override
  String techBannerStarted(String time) {
    return 'بدأ $time';
  }

  @override
  String get techTodayCurrentWork => 'العمل الحالي';

  @override
  String get techTodayOnBay => 'في منطقة العمل';

  @override
  String get techTodayReady => 'بانتظار مهمة';

  @override
  String get techTodayNoActive => 'لا يوجد إصلاح نشط الآن';

  @override
  String get techTodayNoActiveHint =>
      'افتح قائمة المهام لمراجعة المركبة التالية، أو ابدأ المهمة التالية أدناه.';

  @override
  String get techTodayOpenJobs => 'افتح المهام';

  @override
  String get techTodayQueue => 'قائمة المهام المسندة';

  @override
  String get techTodayUpNext => 'التالي';

  @override
  String get techTodayViewAll => 'عرض الكل';

  @override
  String get techTodayQueueClear => 'القائمة فارغة';

  @override
  String get techTodayQueueClearHint =>
      'لا توجد إصلاحات بانتظارك. تظهر المهام الجديدة هنا عند جدولتها.';

  @override
  String get techTodaySummary => 'ملخص الوردية';

  @override
  String get techTodayActiveBay => 'قناة نشطة';

  @override
  String get techTodayTasksDone => 'مهام منجزة';

  @override
  String get techTodayRepairsDone => 'إصلاحات مكتملة';

  @override
  String get techTodayEmpty => 'لا توجد مهام مسندة';

  @override
  String get techTodayEmptyHint =>
      'ليس لديك إصلاحات مسندة لهذه الوردية. اسحب للتحديث، أو عُد عندما يجدول المكتب عملاً.';

  @override
  String get techTodayRefresh => 'تحديث';

  @override
  String get techTodayLoadError => 'تعذّر تحميل عمل اليوم';

  @override
  String get techTodayErrorHint => 'تحقق من الاتصال وحاول مجدداً.';

  @override
  String get techTodayRetry => 'إعادة المحاولة';

  @override
  String get techTodayJobDetails => 'تفاصيل المهمة';

  @override
  String get techTodayTasks => 'المهام';

  @override
  String get techTodayRequestPart => 'طلب قطعة';

  @override
  String get techTodayEscalate => 'تصعيد';

  @override
  String get techTodayCompleteTask => 'إكمال المهمة';

  @override
  String get techTodayStartTask => 'بدء المهمة التالية';

  @override
  String get techTodayReviewJob => 'مراجعة المهمة';

  @override
  String get techTodayNextTask => 'المهمة التالية';

  @override
  String get techTodayInProgress => 'قيد التنفيذ';

  @override
  String get techTodayJobOnHold => 'المهمة متوقفة';

  @override
  String get techTodayDelayedHint => 'هذا الإصلاح معلّق في الورشة.';

  @override
  String techTodayProgress(int done, int total) {
    return '$done من $total مهام';
  }

  @override
  String techTodayStartsAt(String time) {
    return 'يبدأ $time';
  }

  @override
  String techTodayUpdated(String time) {
    return 'حُدّث $time';
  }

  @override
  String get techPlateMissing => 'اللوحة غير مسجلة';

  @override
  String get techVehicleFallback => 'مركبة';

  @override
  String get techJobsSearch => 'ابحث في المهام';

  @override
  String get techJobsLoadError => 'تعذّر تحميل مهامك';

  @override
  String get techJobsEmpty => 'لا توجد مهام مسندة';

  @override
  String get techJobsEmptyHint => 'لا توجد مهام مسندة إليك الآن.';

  @override
  String get techJobsNoMatch => 'لا توجد مهام مطابقة';

  @override
  String get techJobsNoMatchHint => 'لا توجد مهام تطابق البحث والتصفية.';

  @override
  String get techJobsClearFilters => 'مسح التصفية';

  @override
  String techJobsFilterSemantics(String label, int count) {
    return 'تصفية المهام: $label، $count مهام';
  }

  @override
  String techJobsProgress(int done, int total) {
    return '$done من $total مهام';
  }

  @override
  String get techDetailTitle => 'تفاصيل المهمة';

  @override
  String get techDetailCurrentTask => 'المهمة الجارية';

  @override
  String get techDetailCurrentTitle => 'المهمة الحالية';

  @override
  String get techDetailNextTask => 'المهمة التالية';

  @override
  String get techDetailNextTitle => 'المهمة القادمة';

  @override
  String get techDetailOnHold => 'متوقفة';

  @override
  String get techDetailAllDone => 'اكتملت مهام الإصلاح';

  @override
  String get techDetailNoTasks => 'لا توجد مهام';

  @override
  String get techDetailExecution => 'التنفيذ';

  @override
  String techDetailTasksAssigned(int count) {
    return '$count مسندة';
  }

  @override
  String get techDetailAllTasks => 'كل المهام';

  @override
  String get techDetailCompleteTask => 'إكمال المهمة';

  @override
  String get techDetailStartTask => 'بدء المهمة التالية';

  @override
  String get techDetailResumeTask => 'استئناف المهمة';

  @override
  String get techDetailStarting => 'جارٍ البدء…';

  @override
  String get techDetailCompleting => 'جارٍ الإكمال…';

  @override
  String get techDetailResuming => 'جارٍ الاستئناف…';

  @override
  String get techDetailStart => 'بدء';

  @override
  String get techDetailHold => 'تعليق';

  @override
  String get techDetailHoldTask => 'تعليق المهمة';

  @override
  String get techDetailResume => 'استئناف';

  @override
  String get techDetailComplete => 'إكمال';

  @override
  String get techDetailElapsed => 'المنقضي';

  @override
  String get techDetailPaused => 'متوقف';

  @override
  String get techDetailNoTasksHint =>
      'لم تُضف أي مهام لهذه المهمة. راجع المستشار قبل بدء العمل.';

  @override
  String get techDetailQcNotice => 'تم إرسال العمل للمراجعة من مشرف الجودة.';

  @override
  String get techDetailLockedNotice =>
      'اكتمل هذا الإصلاح. تعديلات الفني مقفلة.';

  @override
  String get techDetailDelayed => 'معلّقة';

  @override
  String get techDetailDelayedHint =>
      'هذا الإصلاح معلّق في الورشة. يمكنك متابعة المهام أدناه بعد حل المشكلة.';

  @override
  String get techDetailSupport => 'الدعم';

  @override
  String get techDetailNeedHelp => 'تحتاج مساعدة؟';

  @override
  String get techDetailCompleteRepair => 'إكمال الإصلاح';

  @override
  String get techDetailConfirmTitle => 'إكمال الإصلاح؟';

  @override
  String get techDetailConfirmBody =>
      'سيتم تسجيل جميع المهام المتبقية كمكتملة وإرسال المهمة لمراجعة مشرف الجودة.';

  @override
  String get techDetailCancel => 'إلغاء';

  @override
  String techDetailTaskLabel(int index, String desc, String status) {
    return 'المهمة $index، $desc، $status';
  }

  @override
  String get techProdTitle => 'إنتاجية اليوم';

  @override
  String get techProdToday => 'اليوم';

  @override
  String get techProdWorkDone => 'العمل المنجز';

  @override
  String get techProdRepairOne => 'إصلاح مكتمل اليوم';

  @override
  String get techProdRepairMany => 'إصلاحات مكتملة اليوم';

  @override
  String get techProdNoTasks => 'لا توجد مهام مسجلة في عملك.';

  @override
  String get techProdQueue => 'قائمتك';

  @override
  String techProdAssigned(int count) {
    return '$count مسندة';
  }

  @override
  String get techProdInProgress => 'قيد التنفيذ';

  @override
  String get techProdPending => 'بانتظار';

  @override
  String get techProdDelayed => 'معلّقة';

  @override
  String get techProdQc => 'مراجعة الجودة';

  @override
  String get techProdCompleted => 'مكتملة';

  @override
  String get techProdShift => 'الوردية';

  @override
  String get techProdClockedIn => 'سُجّل الحضور';

  @override
  String get techProdBreakTaken => 'استراحة مأخوذة';

  @override
  String get techProdNetHours => 'صافي الساعات';

  @override
  String get techProdClockedOut => 'سُجّل الانصراف';

  @override
  String get techProdShiftDone => 'اكتملت الوردية لهذا اليوم.';

  @override
  String get techProdEmpty => 'لا توجد بيانات إنتاجية بعد';

  @override
  String get techProdEmptyHint =>
      'يظهر العمل المنجز هنا مع تقدمك في المهام المسندة.';

  @override
  String get techProdLoadError => 'تعذّر تحميل إنتاجيتك';

  @override
  String get techProdFigures => 'أرقام الورشة';

  @override
  String get techProdEfficiency => 'الكفاءة';

  @override
  String get techProdDayProgress => 'تقدم اليوم';

  @override
  String techProdDelayedAlert(int count) {
    return '$count معلّقة — تحتاج انتباهاً';
  }

  @override
  String get techProdTimePerRepair => 'الوقت لكل إصلاح';

  @override
  String get techProdHoursLogged => 'الساعات المسجلة';

  @override
  String get techPartsTitle => 'طلب قطعة';

  @override
  String get techPartsClose => 'إغلاق';

  @override
  String get techPartsName => 'اسم القطعة';

  @override
  String get techPartsNameHint => 'ما القطعة أو المادة التي تحتاجها؟';

  @override
  String get techPartsNameError => 'أدخل القطعة التي تحتاجها';

  @override
  String get techPartsNumber => 'رقم القطعة (اختياري)';

  @override
  String get techPartsNumberHint => 'مرجع الشركة أو الورشة';

  @override
  String get techPartsQty => 'الكمية';

  @override
  String get techPartsQtyHint => 'الوحدات المطلوبة';

  @override
  String get techPartsDec => 'إنقاص الكمية';

  @override
  String get techPartsInc => 'زيادة الكمية';

  @override
  String get techPartsUrgency => 'الأولوية';

  @override
  String get techPartsNormal => 'عادية';

  @override
  String get techPartsUrgent => 'عاجلة';

  @override
  String get techPartsNotes => 'ملاحظات (اختياري)';

  @override
  String get techPartsNotesHint => 'تفاصيل التركيب أو البدائل المفضلة';

  @override
  String techPartsSendCount(int count) {
    return 'إرسال الطلب · $count';
  }

  @override
  String get techPartsSending => 'جارٍ الإرسال…';

  @override
  String get techPartsSent => 'تم إرسال الطلب.';

  @override
  String get techPartsError =>
      'تعذّر إرسال الطلب. تحقق من الاتصال وحاول مجدداً.';

  @override
  String get techEscTitle => 'تصعيد مشكلة';

  @override
  String get techEscWhat => 'ماذا حدث؟';

  @override
  String get techEscDetails => 'تفاصيل المشكلة';

  @override
  String get techEscDetailsHint => 'صف ما وجدته وما تحتاجه…';

  @override
  String get techEscDetailsError => 'صف المشكلة';

  @override
  String get techEscSafety =>
      'عند وجود خطر مباشر على السلامة، أوقف العمل وتواصل مع المشرف مباشرة.';

  @override
  String get techEscSend => 'تصعيد المشكلة';

  @override
  String get techEscSending => 'جارٍ الإرسال…';

  @override
  String get techEscSent => 'تم إرسال التصعيد.';

  @override
  String get techEscError =>
      'تعذّر إرسال التصعيد. تحقق من الاتصال وحاول مجدداً.';

  @override
  String get svWorkspaceName => 'المشرف';

  @override
  String svGreeting(String name) {
    return 'قيادة الأرضية، $name';
  }

  @override
  String svBaysOccupied(int occupied, int total) {
    return '$occupied/$total منصة قيد العمل';
  }

  @override
  String get svNavFloor => 'الأرضية';

  @override
  String get svNavJobs => 'الأعمال';

  @override
  String get svNavQueue => 'الطابور';

  @override
  String get svNavReview => 'المراجعة';

  @override
  String get svNavReports => 'التقارير';

  @override
  String get svNavStaff => 'الفريق';

  @override
  String get svNavSchedule => 'الجدول';

  @override
  String get svProfileLabel => 'ملف المشرف';

  @override
  String get svNotificationsTitle => 'إشعارات الأرضية';

  @override
  String get svNotificationsEmpty => 'لا إشعارات';

  @override
  String get svNotificationsEmptyMessage => 'لا جديد لديك.';

  @override
  String get svNotificationsMarkAll => 'تعليم الكل كمقروء';

  @override
  String get svSearchTitle => 'بحث في الأرضية';

  @override
  String get svSearchHint => 'ابحث برقم المهمة أو العميل أو اللوحة';

  @override
  String get svFloorTitle => 'أرضية الورشة';

  @override
  String svFloorSubtitle(int count, int total) {
    return '$count قيد العمل · $total منصة';
  }

  @override
  String get svFloorLegend => 'حالة المنصة';

  @override
  String get svBayOccupied => 'مشغولة';

  @override
  String get svBayIdle => 'شاغرة';

  @override
  String get svBayPartsDelay => 'تأخّر قطع';

  @override
  String get svBayQc => 'فحص الجودة';

  @override
  String get svFloorTapHint => 'اضغط على منصة لإسناد فني';

  @override
  String get svFloorEmpty => 'لا أعمال نشطة على الأرضية';

  @override
  String get svFloorEmptyMessage => 'تظهر الأعمال الجديدة فور إسنادها.';

  @override
  String get svFloorNoMatch => 'لا منصات مطابقة لهذه التصفية';

  @override
  String get svFloorErrorTitle => 'الأرضية غير متاحة';

  @override
  String get svFloorError => 'تعذّر تحميل الأرضية. اسحب للتحديث.';

  @override
  String get svFloorQueueTitle => 'الطابور الوارد';

  @override
  String get svFloorQueueEmpty => 'الطابور فارغ';

  @override
  String get svFloorUtilisation => 'إشغال الأرضية';

  @override
  String get svBaysLabel => 'المنصات';

  @override
  String get svQueueTitle => 'الطابور الوارد';

  @override
  String get svQueueSubtitle => 'حجوزات وأعطال مرتّبة حسب الأولوية';

  @override
  String get svQueuePriorityVip => 'كبار العملاء';

  @override
  String get svQueuePriorityPromised => 'وعد اليوم';

  @override
  String get svQueuePriorityInsurance => 'تأمين';

  @override
  String get svQueuePriorityEmergency => 'طوارئ';

  @override
  String get svQueueBookings => 'الحجوزات';

  @override
  String get svQueueBreakdowns => 'الأعطال';

  @override
  String get svQueueAssign => 'إسناد مستشار';

  @override
  String get svQueueEmpty => 'الطابور فارغ';

  @override
  String get svQueueEmptyMessage => 'لا حجوزات أو أعطال بالانتظار.';

  @override
  String get svQueueNoMatch => 'لا عناصر مطابقة في الطابور';

  @override
  String get svQueueError => 'تعذّر تحديث طابور الإرسال.';

  @override
  String get svQueueAssignTitle => 'توجيه إلى مستشار';

  @override
  String get svQueueAssignHint => 'مستشار الخدمة';

  @override
  String get svQueueAssigned => 'تم إسناد الحجز';

  @override
  String get svQueueDispatched => 'تم إرسال البلاغ';

  @override
  String get svQueueAssignFailed => 'تعذّر الإسناد. حاول مجدداً.';

  @override
  String get svQueueNoAdvisors => 'لا مستشارون نشطون متاحون للإسناد';

  @override
  String get svJobsTitle => 'الأعمال النشطة';

  @override
  String svJobsSubtitle(int count) {
    return '$count على الأرضية';
  }

  @override
  String get svJobsSearchHint => 'ابحث برقم المهمة أو العميل أو اللوحة';

  @override
  String get svJobsEmpty => 'لا أعمال نشطة';

  @override
  String get svJobsEmptyMessage => 'أسند عملاً لعرض المهام على الأرضية.';

  @override
  String get svJobsNoMatch => 'لا أعمال مطابقة';

  @override
  String get svJobsError => 'تعذّر تحميل الأعمال النشطة.';

  @override
  String get svJobsTotal => 'الإجمالي';

  @override
  String get svJobsInProgress => 'قيد التنفيذ';

  @override
  String get svJobsCompleted => 'مكتملة';

  @override
  String svJobsTasks(int done, int total) {
    return '$done/$total مهام';
  }

  @override
  String get svJobsAssign => 'إسناد عمل';

  @override
  String get svReviewTitle => 'مراقبة الجودة';

  @override
  String get svReviewSubtitle => 'تحقّق من الإصلاحات المكتملة قبل التسليم';

  @override
  String get svReviewStart => 'بدء الفحص';

  @override
  String get svReviewEmpty => 'لا شيء بانتظار الاعتماد';

  @override
  String get svReviewEmptyMessage => 'تظهر الإصلاحات المكتملة هنا للتحقق.';

  @override
  String get svReviewError => 'تعذّر تحميل أعمال الفحص.';

  @override
  String svReviewProgress(int done, int total) {
    return '$done/$total مكتملة';
  }

  @override
  String get svQcTitle => 'مراجعة مراقبة الجودة';

  @override
  String get svQcRepairVerification => 'التحقق من الإصلاح';

  @override
  String get svQcRoadTest => 'اختبار الطريق';

  @override
  String get svQcTorque => 'تدقيق العزم';

  @override
  String get svQcFluid => 'مستويات السوائل';

  @override
  String get svQcWash => 'الغسيل النهائي';

  @override
  String get svQcCheckpoints => 'نقاط الاعتماد';

  @override
  String get svQcPhotoProof => 'إثبات مصوّر';

  @override
  String get svQcPhotoAdd => 'إضافة صورة';

  @override
  String get svQcPhotoAttached => 'مرفقة';

  @override
  String get svQcPhotoUnavailable => 'التقاط الصور غير متاح لهذه المهمة.';

  @override
  String get svQcNotes => 'ملاحظات المفتش';

  @override
  String get svQcNotesHint => 'مطلوبة عند الإرجاع — صف العمل المطلوب';

  @override
  String get svQcReject => 'إرجاع';

  @override
  String get svQcApprove => 'اعتماد ونجاح';

  @override
  String svQcVerified(int count, int total) {
    return '$count/$total تم التحقق';
  }

  @override
  String get svQcRejectReasonRequired => 'أضف تفاصيل المراجعة قبل الإرجاع.';

  @override
  String get svQcVerifyAll => 'تحقق من كل نقطة للاعتماد.';

  @override
  String get svQcApproved => 'نجح الفحص — تم اعتماد المهمة';

  @override
  String get svQcRejected => 'تم الإرجاع للمراجعة';

  @override
  String get svQcFailed => 'تعذّر إكمال مراجعة الجودة. حاول مجدداً.';

  @override
  String get svReportsTitle => 'تقرير العمليات';

  @override
  String get svReportsSubtitle => 'الإنتاجية وإعادة العمل وإشغال الأرضية';

  @override
  String get svReportsThroughput => 'الإنتاجية';

  @override
  String get svReportsRework => 'إعادة العمل';

  @override
  String get svReportsUtilisation => 'الاستغلال';

  @override
  String get svReportsJobsPerTech => 'أعمال لكل فني';

  @override
  String get svReportsCategories => 'فئات الأعمال';

  @override
  String get svReportsCategoriesEmpty => 'لا بيانات فئات مسجّلة';

  @override
  String get svReportsWorkload => 'حِمل المستشارين';

  @override
  String get svReportsWorkloadEmpty => 'لا بيانات حِمل مسجّلة';

  @override
  String get svReportsFloor => 'حالة الأرضية';

  @override
  String get svReportsTechnicians => 'الفنيون';

  @override
  String get svReportsDepartments => 'الأقسام';

  @override
  String get svReportsInQueue => 'في الطابور';

  @override
  String get svReportsFinancial => 'المالية';

  @override
  String get svReportsEmpty => 'لا بيانات تقرير';

  @override
  String get svReportsError => 'بيانات التقرير المباشرة غير متاحة حالياً.';

  @override
  String get svReportsNoHistory =>
      'لا سجل بعد — تُعرض أرقام الأرضية الحالية فقط.';

  @override
  String get svStaffTitle => 'كشف الورشة';

  @override
  String svStaffSubtitle(int count) {
    return '$count متخصص في المناوبة';
  }

  @override
  String get svStaffTechnicians => 'الفنيون';

  @override
  String get svStaffDepartments => 'الأقسام';

  @override
  String get svStaffEmpty => 'لا فريق في المناوبة';

  @override
  String get svStaffEmptyMessage => 'لا فنيون مسجّلون.';

  @override
  String get svStaffDeptEmpty => 'لا أقسام';

  @override
  String get svStaffDeptEmptyMessage => 'لا وحدات ورشة مسجّلة.';

  @override
  String get svStaffRole => 'متخصص أرضية';

  @override
  String get svStaffOnShift => 'في المناوبة';

  @override
  String svStaffLoad(int count) {
    return '$count نشط';
  }

  @override
  String get svScheduleTitle => 'جدول المنصات';

  @override
  String get svScheduleSubtitle => 'أجندة مواعيد اليوم';

  @override
  String get svScheduleTime => 'الوقت';

  @override
  String get svScheduleVehicle => 'العميل · المركبة';

  @override
  String get svScheduleService => 'الخدمة';

  @override
  String get svScheduleStatus => 'الحالة';

  @override
  String get svScheduleEmpty => 'لا مواعيد مجدولة';

  @override
  String get svScheduleEmptyMessage => 'تظهر الحجوزات القادمة هنا.';

  @override
  String get svScheduleViewInQueue => 'عرض في الطابور';

  @override
  String get svScheduleToday => 'اليوم';

  @override
  String get svScheduleError => 'تعذّر تحميل الجدول.';

  @override
  String get svAssignTitle => 'إسناد إلى فني';

  @override
  String get svAssignSubtitle => 'اختر فنياً لتنفيذ هذه المهمة';

  @override
  String get svAssignTarget => 'المهمة المستهدفة';

  @override
  String get svAssignTargetHint => 'رقم بطاقة العمل (مثال JC-2026-1042)';

  @override
  String get svAssignTechTitle => 'الفنيون';

  @override
  String get svAssignSkills => 'المهارات';

  @override
  String svAssignLoad(int count) {
    return '$count نشط';
  }

  @override
  String get svAssignDispatch => 'إسناد';

  @override
  String svAssignDispatched(String name) {
    return 'أُسندت إلى $name';
  }

  @override
  String get svAssignEmpty => 'لا فنيون متاحون';

  @override
  String get svAssignEmptyMessage => 'سجّل الفنيين لإسناد الأعمال.';

  @override
  String get svAssignNoTarget => 'أضف بطاقة عمل مستهدفة قبل الإسناد.';

  @override
  String get svAssignFailed => 'تعذّر الإسناد. حاول مجدداً.';

  @override
  String get svAssignBrief => 'ملخص المهمة (اختياري)';

  @override
  String get svAssignBriefHint => 'صف العمل للفني';

  @override
  String get svRouteAssignTitle => 'إسناد الأعمال';

  @override
  String get svRouteAssignSubtitle => 'إسناد المهام للفنيين';

  @override
  String get svRouteJobsTitle => 'الأعمال النشطة';

  @override
  String get svRouteJobsSubtitle => 'عمليات الورشة';

  @override
  String get svRouteQueueTitle => 'الأعمال الواردة';

  @override
  String get svRouteQueueSubtitle => 'الحجوزات والأعطال';

  @override
  String get svRouteReviewTitle => 'مراقبة الجودة';

  @override
  String get svRouteReviewSubtitle => 'تحقق من الإصلاحات المكتملة';

  @override
  String get svRouteStaffTitle => 'كشف الورشة';

  @override
  String get svRouteStaffSubtitle => 'الفنيون والأقسام';

  @override
  String get svRouteScheduleTitle => 'المواعيد المجدولة';

  @override
  String get svRouteScheduleSubtitle => 'حجوزات اليوم';

  @override
  String get svRouteReportsTitle => 'تقرير العمليات';

  @override
  String get svRouteReportsSubtitle => 'ملخص الورشة والمؤشرات';

  @override
  String get svBreadcrumbConsole => 'منصة المشرف';

  @override
  String get svProfileShift => 'الخط الزمني للمناوبة';

  @override
  String get svProfileSettings => 'الإعدادات';

  @override
  String get staffProfileTitle => 'الملف الشخصي';

  @override
  String get staffProfileWork => 'معلومات العمل';

  @override
  String get staffProfileContact => 'بيانات التواصل';

  @override
  String get staffProfileDesignation => 'المسمى الوظيفي';

  @override
  String get staffProfileDepartment => 'القسم';

  @override
  String get staffProfileBranch => 'الفرع';

  @override
  String get staffProfileShift => 'الوردية';

  @override
  String get staffProfileEmail => 'البريد الإلكتروني';

  @override
  String get staffProfilePhone => 'الهاتف';

  @override
  String get staffProfileAccount => 'الحساب';

  @override
  String get staffProfileResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get staffProfileResetSubtitle =>
      'تحقق من هويتك ثم اختر كلمة مرور جديدة';

  @override
  String get staffProfileLicences => 'تراخيص المصادر المفتوحة';

  @override
  String get staffProfileLicencesSubtitle =>
      'إشعارات قانونية للبرامج في هذا التطبيق';

  @override
  String get staffProfilePrefs => 'التفضيلات';

  @override
  String get staffProfileChangePassword => 'تغيير كلمة المرور';

  @override
  String get staffProfileChangePasswordTitle => 'تغيير كلمة المرور؟';

  @override
  String get staffProfileChangePasswordBody =>
      'يتم تغيير كلمة المرور عبر رمز تحقق لمرة واحدة. تابع إلى تدفق الاسترداد لاختيار كلمة مرور جديدة.';

  @override
  String get staffProfileContinue => 'متابعة';

  @override
  String get staffProfileCancel => 'إلغاء';

  @override
  String get staffProfileStorage => 'التخزين والمزامنة';

  @override
  String get staffProfileStorageSubtitle =>
      'النسخ المحلية وحالة المزامنة وذاكرة التخزين';

  @override
  String get staffProfileDanger => 'منطقة الخطر';

  @override
  String get staffProfileSignOut => 'تسجيل الخروج';

  @override
  String get staffProfileSignOutTitle => 'تسجيل الخروج؟';

  @override
  String get staffProfileSignOutMessage =>
      'ستحتاج إلى تسجيل الدخول مجدداً للمتابعة.';

  @override
  String get staffProfileSignOutUnsyncedTitle =>
      'تسجيل الخروج مع عمل غير مُزامَن؟';

  @override
  String get staffProfileSignOutUnsyncedMessage =>
      'لا يزال بعض العمل بانتظار المزامنة. سيؤدي تسجيل الخروج إلى إزالة التغييرات المحفوظة على هذا الجهاز.';

  @override
  String get staffProfileStaySignedIn => 'البقاء مسجلاً';

  @override
  String get staffAttTitle => 'الحضور';

  @override
  String get staffAttNotPunched => 'لم يتم تسجيل الحضور';

  @override
  String get staffAttWorking => 'يعمل';

  @override
  String get staffAttOnBreak => 'في استراحة';

  @override
  String get staffAttShiftComplete => 'اكتملت الوردية';

  @override
  String get staffAttNotPunchedHint =>
      'لم تبدأ ورديتك بعد. سجّل حضورك لبدء تسجيل ساعات اليوم.';

  @override
  String get staffAttWorkingHint => 'الوردية نشطة. يتم تسجيل ساعاتك.';

  @override
  String get staffAttBreakHint => 'الوردية متوقفة مؤقتاً للاستراحة.';

  @override
  String get staffAttDoneHint => 'انتهت وردية اليوم. تم إرسال الساعات المسجلة.';

  @override
  String get staffAttCurrentStatus => 'الحالة الحالية';

  @override
  String get staffAttPunchIn => 'تسجيل الحضور';

  @override
  String get staffAttPunchingIn => 'جارٍ تسجيل الحضور…';

  @override
  String get staffAttPunchOut => 'تسجيل الانصراف';

  @override
  String get staffAttPunchingOut => 'جارٍ تسجيل الانصراف…';

  @override
  String get staffAttPunchInTitle => 'تسجيل الحضور الآن؟';

  @override
  String get staffAttPunchInBody => 'سيتم تسجيل وقت وصولك لدى خادم الورشة.';

  @override
  String get staffAttPunchOutTitle => 'تسجيل الانصراف الآن؟';

  @override
  String get staffAttPunchOutBody => 'يُكمل هذا وردية اليوم ويسجل ساعات عملك.';

  @override
  String get staffAttInToast => 'تم تسجيل حضورك.';

  @override
  String get staffAttOutToast => 'تم تسجيل انصرافك.';

  @override
  String get staffAttFailToast => 'تعذّر تحديث الحضور.';

  @override
  String get staffAttTodayRecord => 'الوقت المسجل اليوم';

  @override
  String get staffAttPunchInRow => 'تسجيل الحضور';

  @override
  String get staffAttPunchOutRow => 'تسجيل الانصراف';

  @override
  String get staffAttHours => 'ساعات العمل';

  @override
  String get staffAttBreakRow => 'وقت الاستراحة';

  @override
  String get staffAttDoneLine =>
      'اكتملت وردية اليوم. ساعاتك المسجلة معروضة أعلاه.';

  @override
  String staffAttPunchedAt(String time) {
    return 'تم تسجيل الحضور في $time';
  }

  @override
  String staffAttOutAt(String time) {
    return 'تم تسجيل الانصراف في $time';
  }

  @override
  String staffAttOnShiftFor(String time) {
    return 'على رأس العمل منذ $time';
  }

  @override
  String get staffAttBasis => 'على أساس يوم عمل 8 ساعات';

  @override
  String get staffAttMonthTitle => 'هذا الشهر';

  @override
  String get staffAttHistoryNote =>
      'لا يُحفظ على هذا الجهاز سوى سجل اليوم. الأيام السابقة تحتاج إلى سجل من الورشة.';

  @override
  String get staffAttDayTitle => 'سجل اليوم';

  @override
  String get staffAttNoRecord => 'لا يوجد سجل لهذا اليوم.';

  @override
  String get staffShiftTitle => 'تفاصيل الوردية';

  @override
  String get staffShiftSubtitle => 'ساعات العمل المجدولة والمهمة';

  @override
  String get staffShiftSchedule => 'جدول الوردية';

  @override
  String get staffShiftAssigned => 'الوردية المسندة';

  @override
  String get staffShiftStart => 'بداية الوردية';

  @override
  String get staffShiftEnd => 'نهاية الوردية';

  @override
  String get staffShiftAssignment => 'تفاصيل المهمة';

  @override
  String get staffShiftMember => 'عضو الفريق';

  @override
  String get staffShiftEmpId => 'الرقم الوظيفي';

  @override
  String get staffShiftBranch => 'الفرع المسند';

  @override
  String get staffShiftSupervisor => 'المشرف المناوب';

  @override
  String get staffShiftBay => 'قناة العمل المسندة';

  @override
  String get staffShiftBreaks => 'الاستراحات';

  @override
  String get staffShiftDefault => 'وردية عادية';

  @override
  String get staffShiftEmpty => 'لم تتم مشاركة تفاصيل الوردية مع هذا الجهاز.';

  @override
  String get staffSettingsTitle => 'الإعدادات';

  @override
  String get staffSettingsSubtitle => 'معلومات التطبيق والتخزين المحلي';

  @override
  String get staffSettingsSync => 'البيانات والمزامنة';

  @override
  String get staffSettingsSyncStatus => 'حالة المزامنة المحلية';

  @override
  String staffSettingsPending(int count) {
    return '$count عمليات معلقة';
  }

  @override
  String get staffSettingsPendingHint =>
      'التغييرات المحلية في قائمة الانتظار وستُزامَن عند عودة الاتصال.';

  @override
  String get staffSettingsIdle => 'لا توجد عمليات محلية معلقة';

  @override
  String get staffSettingsIdleHint => 'تمت معالجة جميع الإجراءات المسجلة.';

  @override
  String get staffSettingsPendingPill => 'معلّق';

  @override
  String get staffSettingsIdlePill => 'متزامن';

  @override
  String get staffSettingsForceSync => 'مزامنة الآن';

  @override
  String get staffSettingsSyncing => 'جارٍ المزامنة…';

  @override
  String get staffSettingsSyncedToast => 'اكتملت المزامنة.';

  @override
  String get staffSettingsSyncFailed =>
      'فشلت المزامنة. ستُعاد المحاولة تلقائياً.';

  @override
  String staffSettingsLastAttempt(String time) {
    return 'آخر محاولة $time (هذه الجلسة)';
  }

  @override
  String get staffSettingsApp => 'التطبيق';

  @override
  String get staffSettingsVersion => 'إصدار التطبيق';

  @override
  String get staffSettingsDevice => 'الجهاز';

  @override
  String get staffSettingsCache => 'البيانات المخزنة';

  @override
  String staffSettingsCacheHint(int count) {
    return '$count عناصر مخزنة على هذا الجهاز';
  }

  @override
  String get staffSettingsClearCache => 'مسح التخزين';

  @override
  String get staffSettingsClearTitle => 'مسح البيانات المخزنة؟';

  @override
  String get staffSettingsClearBody =>
      'يزيل نسخ المهام والمسودات وعمليات الرفع المعلقة من هذا الجهاز. حسابك وسجلات الخادم لن تتأثر.';

  @override
  String get staffSettingsCacheCleared => 'تم مسح التخزين المؤقت.';

  @override
  String get advisorClientBroughtBy => 'أحضرها';

  @override
  String get advisorClientBroughtByHint => 'اسم من أحضر المركبة';

  @override
  String advisorClientAdvisorHandled(String name) {
    return 'بمعالجة $name';
  }

  @override
  String get advisorClientComments => 'ملاحظات';

  @override
  String get advisorClientCommentsEmpty => 'لا توجد ملاحظات بعد.';

  @override
  String get advisorClientCommentsAdd => 'إضافة ملاحظة';

  @override
  String get advisorClientCommentsHint => 'اكتب ملاحظة…';

  @override
  String get advisorClientCommentsDeleteTitle => 'حذف هذه الملاحظة؟';

  @override
  String get advisorClientSignatures => 'التوقيعات';

  @override
  String get advisorClientSigCustomer => 'العميل';

  @override
  String get advisorClientSigAdvisor => 'المستشار';

  @override
  String advisorClientSigSignedOn(String time) {
    return 'تم التوقيع $time';
  }

  @override
  String get advisorClientSigMissing => 'لم يتم التوقيع بعد';

  @override
  String get advisorClientSigClear => 'مسح';

  @override
  String get advisorClientShareTitle => 'مشاركة بطاقة العمل';

  @override
  String advisorClientShareSummary(String id, String customer, String vehicle) {
    return 'المهمة $id · $customer · $vehicle';
  }

  @override
  String get advisorClientShareWhatsApp => 'واتساب';

  @override
  String get advisorClientShareEmail => 'البريد الإلكتروني';

  @override
  String get advisorClientShareNoPhone => 'أضف رقم العميل للمشاركة على واتساب.';

  @override
  String get advisorClientPlatesTitle => 'اللوحات المسجلة';

  @override
  String get advisorClientPlatesNew => 'لوحة جديدة';

  @override
  String get advisorClientPlatesHint => 'اختر لوحة أو أدخل واحدة جديدة';

  @override
  String get advisorClientSavedOnDevice => 'محفوظ على الجهاز';

  @override
  String advisorClientSavedBy(String name) {
    return 'حفظه $name على الجهاز';
  }

  @override
  String get advisorClientCommentsSave => 'حفظ';

  @override
  String get advisorClientCommentsDeleteConfirm => 'حذف';

  @override
  String get advisorClientSigRequest => 'طلب التوقيع';

  @override
  String get advisorClientSigResend => 'إعادة الإرسال';

  @override
  String get advisorClientSigMarkSigned => 'تأكيد التوقيع';

  @override
  String advisorClientSigRequested(String time) {
    return 'طُلب عبر واتساب · $time';
  }

  @override
  String get advisorClientSigRequestSent => 'أُرسل طلب التوقيع عبر واتساب';

  @override
  String get advisorClientSigLinkError => 'تعذّر فتح واتساب. حاول مجدداً.';

  @override
  String get advisorClientSharePdf => 'مشاركة PDF';

  @override
  String get advisorClientSharePdfDone => 'تمت مشاركة PDF';

  @override
  String get advisorClientSharePdfFail => 'تعذّر مشاركة PDF. حاول مجدداً.';

  @override
  String get advisorClientSharePdfBuilding => 'جارٍ تجهيز PDF…';

  @override
  String get advisorClientPdfTitle => 'بطاقة العمل';

  @override
  String get advisorClientPdfCustomer => 'العميل';

  @override
  String get advisorClientPdfVehicle => 'المركبة';

  @override
  String get advisorClientPdfWork => 'الأعمال';

  @override
  String get advisorClientPdfTotal => 'الإجمالي';

  @override
  String get advisorClientPlatesSearching => 'جارٍ البحث عن اللوحات…';
}
