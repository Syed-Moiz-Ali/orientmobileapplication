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

  @override
  String get ownerReqRequired => 'هذا الحقل مطلوب.';

  @override
  String get ownerReqEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get ownerReqPhone => 'أدخل رقم جوال صالحًا.';

  @override
  String get ownerReqPassword => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل.';

  @override
  String get ownerReqMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get ownerArTitle => 'الذمم';

  @override
  String ownerArSubtitle(String amount) {
    return 'المستحق $amount';
  }

  @override
  String get ownerArSearchHint => 'ابحث بالعميل أو الفاتورة أو رقم الذمة…';

  @override
  String get ownerArCurrent => 'الحالية';

  @override
  String get ownerArOverdue => 'المتأخرة';

  @override
  String get ownerArCritical => 'الحرجة';

  @override
  String get ownerArAge030 => '0–30 يومًا';

  @override
  String get ownerArAge3160 => '31–60 يومًا';

  @override
  String get ownerArAge61 => '60+ يومًا';

  @override
  String get ownerArRef => 'المرجع';

  @override
  String get ownerArCustomer => 'العميل';

  @override
  String get ownerArAmount => 'المبلغ';

  @override
  String get ownerArAge => 'العمر';

  @override
  String get ownerArAge030pill => '0–30';

  @override
  String get ownerArAge3160pill => '31–60';

  @override
  String get ownerArAge6190pill => '61–90';

  @override
  String get ownerArAge90pill => '90+';

  @override
  String get ownerArEmpty => 'لا ذمم مستحقة.';

  @override
  String get ownerArNoMatch => 'لا مدينين يطابقون هذا البحث.';

  @override
  String get ownerArContact => 'جهة الفوترة';

  @override
  String ownerArCount(int count) {
    return '$count مدينين';
  }

  @override
  String get ownerInTitle => 'المخزون';

  @override
  String get ownerInValuation => 'تقييم المخزون';

  @override
  String get ownerInAtCost => 'بالتكلفة';

  @override
  String ownerInLow(int count) {
    return '$count عند حد إعادة الطلب أو دونه';
  }

  @override
  String ownerInOut(int count) {
    return '$count نافذة';
  }

  @override
  String get ownerInStockOk => 'مستويات المخزون سليمة.';

  @override
  String get ownerInParts => 'القطع';

  @override
  String get ownerInSuppliers => 'الموردون';

  @override
  String get ownerInOrders => 'الطلبات';

  @override
  String get ownerInSearchHint => 'ابحث بالاسم أو الرمز أو الفئة…';

  @override
  String get ownerInFilter => 'تصفية المخزون';

  @override
  String get ownerInCategory => 'الفئة';

  @override
  String get ownerInAvailability => 'التوفر';

  @override
  String get ownerInAllStock => 'كل المخزون';

  @override
  String get ownerInLowOnly => 'المنخفض فقط';

  @override
  String get ownerInApply => 'تطبيق';

  @override
  String get ownerInClear => 'مسح';

  @override
  String get ownerInEmpty => 'لا قطع في المخزون.';

  @override
  String get ownerInNoMatch => 'لا قطع تطابق هذا البحث.';

  @override
  String ownerInStockLeft(int count) {
    return 'المتبقي $count';
  }

  @override
  String get ownerInAdd => 'إضافة قطعة';

  @override
  String get ownerInAddTitle => 'إضافة قطعة للمخزون';

  @override
  String get ownerInName => 'اسم القطعة';

  @override
  String get ownerInSku => 'الرمز / رقم القطعة';

  @override
  String get ownerInPrice => 'السعر (د.إ)';

  @override
  String get ownerInQty => 'الكمية الأولية';

  @override
  String get ownerInQtyCol => 'الكمية';

  @override
  String get ownerInReorder => 'حد تنبيه إعادة الطلب';

  @override
  String get ownerInSubmit => 'إضافة للمستودع';

  @override
  String get ownerInAdded => 'تمت إضافة القطعة للمستودع.';

  @override
  String get ownerInAddFail => 'تعذر إضافة الصنف.';

  @override
  String get ownerInAdjustFail => 'تعذر تعديل المخزون.';

  @override
  String get ownerInNoSuppliers => 'لا موردون مسجلون.';

  @override
  String get ownerInNoOrders => 'لا طلبات شراء.';

  @override
  String get ownerInNoPhone => 'لا هاتف مسجل.';

  @override
  String get ownerTmTitle => 'الفريق';

  @override
  String ownerTmSubtitle(int active, int total) {
    return '$active من $total نشطون';
  }

  @override
  String get ownerTmDirectory => 'دليل الموظفين';

  @override
  String get ownerTmSearchHint =>
      'ابحث بالاسم أو الرقم أو الهاتف أو الدور أو الفرع…';

  @override
  String get ownerTmAdvisors => 'المستشارون';

  @override
  String get ownerTmSupervisors => 'المشرفون';

  @override
  String get ownerTmTechnicians => 'الفنيون';

  @override
  String get ownerTmEmpty => 'لا موظفون يطابقون هذا الترشيح.';

  @override
  String get ownerTmActive => 'نشط';

  @override
  String get ownerTmOff => 'موقوف';

  @override
  String get ownerTmOnShift => 'على رأس العمل';

  @override
  String get ownerTmOffShift => 'خارج العمل';

  @override
  String get ownerTmAdd => 'إضافة عضو';

  @override
  String get ownerTmAddTitle => 'إنشاء دخول موظف';

  @override
  String get ownerTmAddSubtitle => 'أنشئ دخوله لتطبيق الموظفين وبيانات الورشة.';

  @override
  String get ownerTmName => 'الاسم الكامل';

  @override
  String get ownerTmEmpId => 'الرقم الوظيفي (مثال ADV002)';

  @override
  String get ownerTmRole => 'دور تطبيق الموظفين';

  @override
  String get ownerTmLogin => 'بيانات الدخول';

  @override
  String get ownerTmPhone => 'الجوال مع رمز الدولة';

  @override
  String get ownerTmEmail => 'البريد الإلكتروني';

  @override
  String get ownerTmPassword => 'كلمة مرور أولية (8 أحرف على الأقل)';

  @override
  String get ownerTmPassword2 => 'تأكيد كلمة المرور الأولية';

  @override
  String get ownerTmOtpNote =>
      'يمكنه الدخول بالبريد أو الجوال + كلمة المرور، أو برمز لمرة واحدة.';

  @override
  String get ownerTmWork => 'بيانات العمل';

  @override
  String get ownerTmDesignation => 'المسمى';

  @override
  String get ownerTmDepartment => 'القسم';

  @override
  String get ownerTmBranch => 'الفرع';

  @override
  String get ownerTmBranchHint => 'اختر الفرع';

  @override
  String get ownerTmNoBranches => 'لا فروع مُعدّة.';

  @override
  String get ownerTmShift => 'الوردية';

  @override
  String get ownerTmSubmit => 'إنشاء حساب الموظف';

  @override
  String get ownerTmCreated => 'تم إنشاء دخول الموظف.';

  @override
  String get ownerTmCreatedBody =>
      'شارك كلمة المرور الأولية بأمان واطلب منه تغييرها بعد الدخول.';

  @override
  String get ownerTmDone => 'تم';

  @override
  String get ownerAtTitle => 'الحضور';

  @override
  String get ownerAtSubtitle => 'سجل الدوام اليومي';

  @override
  String get ownerAtTotal => 'إجمالي الموظفين';

  @override
  String get ownerAtPresent => 'الحاضرون';

  @override
  String get ownerAtDone => 'المكتملون';

  @override
  String get ownerAtAbsent => 'الغائبون';

  @override
  String get ownerAtAllRoles => 'كل الأدوار';

  @override
  String get ownerAtEmpty => 'لا سجلات حضور.';

  @override
  String get ownerAtIn => 'الحضور';

  @override
  String get ownerAtOut => 'الانصراف';

  @override
  String get ownerAtHours => 'الساعات';

  @override
  String get ownerAtWorking => 'يعمل';

  @override
  String get ownerAtBreak => 'في استراحة';

  @override
  String get ownerAtComplete => 'مكتمل';

  @override
  String get ownerAtIdle => 'لم يسجل حضور';

  @override
  String get ownerExTitle => 'الامتثال';

  @override
  String get ownerExSubtitle => 'الرخص والتصاريح والتأشيرات';

  @override
  String get ownerExSearchHint => 'ابحث بالموظف أو الدور أو المستند…';

  @override
  String get ownerExCritical => 'حرجة';

  @override
  String get ownerExUrgent => 'عاجلة';

  @override
  String get ownerExWatch => 'للمراقبة';

  @override
  String ownerExDaysLeft(int days) {
    return 'متبقٍ $days يوم';
  }

  @override
  String ownerExOverdue(int days) {
    return 'متأخر $days يوم';
  }

  @override
  String get ownerExEmpty => 'لا مستندات.';

  @override
  String ownerExAlerts(int count) {
    return '$count تنبيهات';
  }

  @override
  String get ownerFbTitle => 'التقييمات';

  @override
  String get ownerFbSubtitle => 'صندوق تقييمات العملاء';

  @override
  String get ownerFbEmpty => 'لا تقييمات بانتظار المراجعة.';

  @override
  String get ownerFbVerified => 'عميل موثّق';

  @override
  String get ownerFbApprove => 'اعتماد';

  @override
  String get ownerFbReject => 'رفض';

  @override
  String get ownerFbDone => 'تمت مراجعة التقييم.';

  @override
  String get ownerFbFail => 'فشلت المراجعة. حاول مرة أخرى.';

  @override
  String get ownerFbNoRespond => 'الردود غير متاحة في هذه النسخة.';

  @override
  String get ownerSbTitle => 'الاشتراك';

  @override
  String get ownerSbCurrent => 'الباقة الحالية';

  @override
  String ownerSbRenews(String date) {
    return 'التجديد $date';
  }

  @override
  String get ownerSbPlans => 'باقات الورشة';

  @override
  String get ownerSbSelect => 'اختيار';

  @override
  String get ownerSbCurrentPlan => 'الحالية';

  @override
  String get ownerSbChanged => 'تم تحديث الباقة.';

  @override
  String get ownerSbChangeFail => 'تعذر تحديث الباقة.';

  @override
  String get ownerSbStarter => 'الأساسية';

  @override
  String get ownerSbStarterHint => 'ورش الفروع الواحدة';

  @override
  String get ownerSbPro => 'الاحترافية';

  @override
  String get ownerSbProHint => 'متعدد الفروع + CRM + مخزون';

  @override
  String get ownerSbEnterprise => 'المؤسسات';

  @override
  String get ownerSbEnterpriseHint => 'SSO واتفاقيات ومدير مخصص';

  @override
  String get ownerSbStarterPrice => '499 د.إ / شهر';

  @override
  String get ownerSbProPrice => '1,299 د.إ / شهر';

  @override
  String get ownerSbEnterprisePrice => '2,499 د.إ / شهر';
}
