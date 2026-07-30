class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Customer Portal
  static const String customerProfile = '/customers/profile';
  static const String customerVehicles = '/customers/vehicles';
  static const String customerBookings = '/customers/bookings';
  static const String customerNotifications = '/customers/notifications';
  static const String customerServicesActive = '/customers/services/active';
  static const String customerBreakdowns = '/customers/breakdowns';
  static const String serviceTypes = '/services/types';
  static const String createBooking = '/bookings';
  static const String notificationReadAll = '/customers/notifications/read-all';
  static String notificationRead(String id) => '/customers/notifications/$id/read';
  static String customerVehicle(String id) => '/customers/vehicles/$id';
  static const String feedback = '/feedback';
  static const String feedbackStats = '/feedback/stats';

  // Advisor
  static const String advisorStats = '/advisor/stats';
  static const String advisorJobCards = '/advisor/job-cards';
  static const String advisorApprovalsPending = '/advisor/approvals/pending';
  static const String advisorReminders = '/advisor/reminders';
  static const String advisorReports = '/advisor/reports';
  static const String inspections = '/inspections';
  static const String repairOrders = '/repair-orders';
  static const String customerSearch = '/customers/search';
  static const String vehicleSearch = '/vehicles/search';

  // Supervisor
  static const String supervisorKpis = '/supervisor/kpis';
  static const String supervisorAdvisorJobs = '/supervisor/advisor-jobs';
  static const String supervisorJobTypes = '/supervisor/job-types';
  static const String supervisorRevenueMetrics = '/supervisor/revenue-metrics';
  static const String supervisorPendingStatuses = '/supervisor/pending-statuses';
  static const String departments = '/departments';
  static const String technicians = '/technicians';
  static const String workAssignments = '/work-assignments';
  static const String supervisorAssignedJobs = '/supervisor/assigned-jobs';

  // Technician
  static const String technicianProfile = '/technicians/profile';
  static const String attendancePunchIn = '/technicians/attendance/punch-in';
  static const String attendancePunchOut = '/technicians/attendance/punch-out';
  static const String attendanceBreakStart = '/technicians/attendance/break-start';
  static const String attendanceBreakEnd = '/technicians/attendance/break-end';
  static const String technicianAttendance = '/technicians/attendance';
  static const String technicianAssignedJobs = '/technicians/assigned-jobs';
  static const String technicianJobs = '/technicians/jobs';
  static const String technicianJobsSearch = '/technicians/jobs/search';
  static const String jobComplete = '/jobs/complete';
  static const String technicianProductivity = '/technicians/productivity';

  // Owner
  static const String ownerDashboardKpis = '/owner/dashboard/kpis';
  static const String ownerSalesTrend = '/owner/dashboard/sales-trend';
  static const String ownerProfitTrend = '/owner/dashboard/profit-trend';
  static const String ownerExpensesTrend = '/owner/dashboard/expenses-trend';
  static const String ownerJobCardRegister = '/owner/dashboard/job-card-register';
  static const String ownerTopSales = '/owner/dashboard/top-sales';
  static const String ownerJobCards = '/owner/job-cards';
  static const String ownerDocumentsExpiry = '/owner/documents/expiry';
  static const String ownerJobsStatus = '/owner/jobs/status';
  static const String ownerApprovalsCategories = '/owner/approvals/categories';
  static const String ownerJobsPending = '/owner/jobs/pending';
  static const String ownerJobsActive = '/owner/jobs/active';
  static const String ownerInvoices = '/owner/invoices';
  static const String ownerArSummary = '/owner/accounts-receivable/summary';
  static const String ownerArRecords = '/owner/accounts-receivable/records';
  static const String ownerMessages = '/owner/messages';
  static const String ownerActivity = '/owner/activity';

  // CRM
  static const String crmKpis = '/crm/dashboard/kpis';
  static const String crmChannels = '/crm/channels';
  static const String crmConversionTrend = '/crm/conversion-trend';
  static const String crmSalespersonPerf = '/crm/salesperson-performance';
  static const String crmResponseTimes = '/crm/response-times';
  static const String crmLeadSources = '/crm/lead-sources';
  static const String crmKeyMetrics = '/crm/key-metrics';
  static const String crmIntegrations = '/crm/integrations';
  static const String crmSalesTeam = '/crm/sales-team';
  static const String crmConversations = '/crm/conversations';
  static const String crmLeads = '/crm/leads';
  static const String crmTasks = '/crm/tasks';

  // Branches / WhatsApp
  static const String branches = '/branches';
  static const String whatsappSend = '/whatsapp/send';
  static const String whatsappWebhook = '/whatsapp/webhook';
  static const String whatsappMessages = '/whatsapp/messages';

  // Sync
  static const String syncInspections = '/sync/inspections';
  static const String syncJobComplete = '/sync/jobs/complete';
  static const String syncRepairOrders = '/sync/repair-orders';

  // Parameterized path builders
  static String advisorApproval(String id) => '/advisor/approvals/$id';
  static String advisorJobCard(String id) => '/advisor/job-cards/$id';
  static String advisorJobCardStatus(String id) => '/advisor/job-cards/$id/status';
  static String advisorJobCardTechnician(String id) => '/advisor/job-cards/$id/technician';
  static String advisorReminder(String id) => '/advisor/reminders/$id';
  static String inspectionDraft(String id) => '/inspections/$id/draft';
  static String technicianAssignedJobStatus(String id) => '/technicians/assigned-jobs/$id/status';
  static String technicianTask(String jobCard, String task, String action) => '/technicians/jobs/$jobCard/tasks/$task/$action';
  static String technicianJobNotes(String jobCard) => '/technicians/jobs/$jobCard/notes';
  static String branchById(String id) => '/branches/$id';
  static String crmTaskById(String id) => '/crm/tasks/$id';
  static String syncInspection(String id) => '/sync/inspections/$id';
  static String syncJobCompleteById(String id) => '/sync/jobs/complete/$id';
  static String syncRepairOrder(String id) => '/sync/repair-orders/$id';
  static String uploadMedia(String recordId) => '/repair-orders/$recordId/media';

  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}
