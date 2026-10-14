// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'shared_core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SharedCoreLocalizationsEn extends SharedCoreLocalizations {
  SharedCoreLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonErrorTitle => 'Something went wrong';

  @override
  String get commonSearchHint => 'Search';

  @override
  String get commonClearSearch => 'Clear search';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonEnglish => 'English';

  @override
  String get commonArabic => 'العربية';

  @override
  String get commonSelectLanguage => 'Select language';

  @override
  String get topBarBackTooltip => 'Back';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get dialogCloseTooltip => 'Close';

  @override
  String get offlineBannerMessage =>
      'Offline mode — changes will sync when connection is restored';

  @override
  String get offlineBannerSemantics =>
      'Offline mode. Changes will sync when connection is restored.';

  @override
  String get logoutDialogTitle => 'Sign out?';

  @override
  String get logoutDialogMessage =>
      'You will need to authenticate again to access this workspace.';

  @override
  String get logoutDialogConfirm => 'Sign out';

  @override
  String get logoutUnsyncedTitle => 'Unsynced changes';

  @override
  String get logoutUnsyncedMessage =>
      'Some local changes have not reached the workshop yet. Signing out now will clear those pending changes.';

  @override
  String get logoutUnsyncedConfirm => 'Sign out anyway';

  @override
  String get exitDialogTitle => 'Exit Orient Workshop?';

  @override
  String get exitDialogMessage =>
      'Your current work is saved. Close the application now?';

  @override
  String get exitDialogConfirm => 'Exit';

  @override
  String get profileWelcomeBack => 'Welcome back,';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get dateSelectorHint => 'Select date';

  @override
  String get mediaUploadLabel =>
      'Click to upload inspection photos or documents';

  @override
  String get mediaUploadHelper => 'Supports JPG, PNG, PDF up to 25MB';

  @override
  String get statusPillRetry => 'Retry';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusVehicleReceived => 'Vehicle Received';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusWorkAssigned => 'Work Assigned';

  @override
  String get statusInService => 'In Service';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusApprovalRequired => 'Approval Required';

  @override
  String get statusWaitingParts => 'Waiting Parts';

  @override
  String get statusSentBack => 'Sent Back';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPartiallyPaid => 'Partially Paid';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusUnpaid => 'Unpaid';

  @override
  String get formatterJustNow => 'Just now';

  @override
  String formatterMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String formatterHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String formatterDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String formatterWeeksAgo(int count) {
    return '${count}w ago';
  }

  @override
  String formatterMonthsAgo(int count) {
    return '${count}mo ago';
  }

  @override
  String formatterYearsAgo(int count) {
    return '${count}y ago';
  }

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonLoading => 'Loading';

  @override
  String get commonIncrease => 'Increase';

  @override
  String get commonDecrease => 'Decrease';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonNoResults => 'No matches found';

  @override
  String get commonShowPassword => 'Show password';

  @override
  String get commonHidePassword => 'Hide password';

  @override
  String get userAvatarOpenProfile => 'Open profile';

  @override
  String get pendingSyncNotSent => 'Not sent yet';

  @override
  String get pendingSyncQueued => 'Queued';

  @override
  String get pendingSyncFailed => 'Sync failed';

  @override
  String get pendingSyncSynced => 'Synced';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonNoData => 'No data yet';

  @override
  String get chartEmptyMessage => 'No chart data available for this period';

  @override
  String get commonMore => 'More';

  @override
  String navBadgeCount(String label, int count) {
    return '$label, $count new';
  }

  @override
  String navBadgeDot(String label) {
    return '$label, new activity';
  }

  @override
  String get jobStageIntake => 'Intake';

  @override
  String get jobStageInspection => 'Inspection';

  @override
  String get jobStageParts => 'Parts';

  @override
  String get jobStageLabor => 'Labour';

  @override
  String get jobStageQuality => 'Quality Check';

  @override
  String get jobStageReady => 'Ready';

  @override
  String get jobStageCancelled => 'Cancelled';

  @override
  String get telemetryLive => 'Live';

  @override
  String get damageKindScratch => 'Scratch / Scuff';

  @override
  String get damageKindDent => 'Dent / Deformation';

  @override
  String get damageKindGlass => 'Glass / Lamp';

  @override
  String get connectivityOnline => 'Synced';

  @override
  String get connectivityOffline => 'Offline';

  @override
  String connectivityQueuedCount(int count) {
    return '$count queued';
  }

  @override
  String get workspaceSearchTooltip => 'Search';
}
