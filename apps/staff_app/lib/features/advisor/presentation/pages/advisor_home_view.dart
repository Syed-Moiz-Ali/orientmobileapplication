import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import '../widgets/advisor_body.dart';
import '../widgets/advisor_fab.dart';
import '../widgets/advisor_bottom_nav.dart';
import 'advisor_jobs_view.dart';
import 'advisor_job_detail_view.dart';
import 'advisor_reports_view.dart';
import '../widgets/advisor_profile_sheet.dart';
import '../widgets/advisor_notification_sheet.dart';
import '../widgets/advisor_approval_sheet.dart';
import '../widgets/advisor_contact_sheet.dart';
import '../widgets/advisor_search_sheet.dart';
import '../widgets/advisor_stat_dialog.dart';

class AdvisorHomeView extends ConsumerStatefulWidget {
  const AdvisorHomeView({super.key});
  @override
  ConsumerState<AdvisorHomeView> createState() => _AdvisorHomeViewState();
}

class _AdvisorHomeViewState extends ConsumerState<AdvisorHomeView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  int _navIndex = 0;

  // void _openChooseInspection() {
  //   HapticFeedback.mediumImpact();
  //   context.push(
  //     AppRoutes.chooseInspection,
  //     extra: {
  //       'onBack': () => context.pop(),
  //       'onSkip': () {
  //         context.push(
  //           AppRoutes.repairOrder,
  //           extra: {
  //             'onBack': () => context.pop(),
  //             'fromInspection': false,
  //           },
  //         );
  //       },
  //       'onSelect': () {
  //         context.pushReplacement(
  //           AppRoutes.inspectionSheet,
  //           extra: {
  //             'onBack': () => context.pop(),
  //             'onSaveDraft': () {
  //               context.pop();
  //               _toast('Draft saved', icon: Icons.save_outlined, color: AppColors.warning);
  //             },
  //             'onPreview': () {
  //               context.push(
  //                 AppRoutes.inspectionPreview,
  //                 extra: {
  //                   'onBack': () => context.pop(),
  //                   'onSubmit': () {
  //                     context.pushReplacement(
  //                       AppRoutes.repairOrder,
  //                       extra: {
  //                         'onBack': () => context.go(AppRoutes.advisorDashboard),
  //                         'fromInspection': true,
  //                       },
  //                     );
  //                   },
  //                 },
  //               );
  //             },
  //           },
  //         );
  //       },
  //     },
  //   );
  // }

  void _openInspectionDirect() {
    HapticFeedback.mediumImpact();
    final callbacks = InspectionCallbacks(
      onBack: () => context.pop(),
      onSaveDraft: () {
        context.pop();
        _toast(
          'Draft saved',
          icon: Icons.save_outlined,
          color: AppColors.warning,
        );
      },
      onPreview: () {
        context.push(
          AppRoutes.inspectionPreview,
          extra: {'onBack': () => context.go(AppRoutes.advisorDashboard)},
        );
      },
    );
    context.push(AppRoutes.inspectionSheet, extra: callbacks);
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(advisorRefreshProvider.notifier).state++;
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _openScan() => context.push(AppRoutes.scanVehicle);

  void _openNewJobCard() => context.push(AppRoutes.vehicleCustomer);

  void _toast(String msg, {IconData? icon, Color color = AppColors.accent}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12)),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        duration: const Duration(seconds: 3),
        elevation: 0,
      ),
    );
  }

  void _sheet(Widget child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => child,
    );
  }

  void _showProfile() {
    _sheet(
      AdvisorProfileSheet(
        onLogout: () async {
          Navigator.pop(context);
          await showLogoutDialog(
            context,
            onLogout: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          );
        },
      ),
    );
  }

  void _showNotifications() {
    HapticFeedback.lightImpact();
    _sheet(const AdvisorNotificationSheet());
  }

  void _onJobCard(JobCardEntity jc) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdvisorJobDetailView(jc: jc)),
    );
  }

  void _onApproval(PendingApprovalEntity pa) {
    HapticFeedback.mediumImpact();
    _sheet(
      AdvisorApprovalSheet(
        pa: pa,
        onApprove: () {
          Navigator.pop(context);
          _persistApproval(pa, 'approved');
          _toast(
            'Estimate ${pa.estimateId} approved',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          );
        },
        onReject: () {
          Navigator.pop(context);
          _persistApproval(pa, 'rejected');
          _toast(
            'Sent back for revision',
            icon: Icons.undo,
            color: AppColors.warning,
          );
        },
      ),
    );
  }

  Future<void> _persistApproval(PendingApprovalEntity pa, String action) async {
    final local = GenericLocalDataSource(
      Hive.box<dynamic>('inspections'),
    );
    await local.save('approval_${pa.estimateId}', {
      'estimateId': pa.estimateId,
      'customerName': pa.customerName,
      'amount': pa.amount,
      'action': action,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    final queue = ref.read(syncQueueProvider);
    final id = await IdGenerator.nextId('APPR');
    await queue.enqueue(
      SyncOperation(
        id: id,
        entityType: 'approval',
        entityId: pa.estimateId,
        changeType: ChangeType.update,
        payload: {
          'estimateId': pa.estimateId,
          'action': action,
          'customerName': pa.customerName,
          'amount': pa.amount,
        },
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await ref.read(syncEngineProvider).syncAll();
  }

  void _onContact(FollowupReminderEntity r) {
    HapticFeedback.lightImpact();
    _sheet(
      AdvisorContactSheet(
        r: r,
        onCall: () {
          Navigator.pop(context);
          _toast('Calling ${r.customerName}…', icon: Icons.phone_outlined);
        },
        onWhatsApp: () {
          Navigator.pop(context);
          _toast(
            'Opening WhatsApp…',
            icon: Icons.chat_outlined,
            color: AppColors.success,
          );
        },
        onSms: () {
          Navigator.pop(context);
          _toast('SMS sent', icon: Icons.sms_outlined);
        },
        onDone: () {
          Navigator.pop(context);
          _toast('Marked as done', icon: Icons.check, color: AppColors.success);
        },
      ),
    );
  }

  void _showSearch() => _sheet(
    AdvisorSearchSheet(
      onScan: () {
        Navigator.pop(context);
        _openScan();
      },
    ),
  );

  void _onStat(String label, int count, Color color) {
    showDialog(
      context: context,
      builder: (_) =>
          AdvisorStatDialog(label: label, count: count, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.navy,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return DashboardShell(
        body: _navIndex == 1
            ? AdvisorJobsListView(onJobCard: _onJobCard)
            : _navIndex == 2
            ? const AdvisorReportsView()
            : AdvisorBody(
                tabCtrl: _tabCtrl,
                onShowProfile: _showProfile,
                onShowNotifications: _showNotifications,
                onShowSearch: _showSearch,
                onOpenScan: _openScan,
                onNewJobCard: _openNewJobCard,
                onOpenInspection: _openInspectionDirect,
                onJobCard: _onJobCard,
                onApproval: _onApproval,
                onContact: _onContact,
                onStat: _onStat,
              ),
        floatingActionButton: AdvisorFab(
          onTap: () {
            HapticFeedback.heavyImpact();
            _openScan();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AdvisorBottomNav(
          navIndex: _navIndex,
          onNavChanged: (i) => setState(() => _navIndex = i),
          onShowProfile: _showProfile,
        ),
    );
  }
}

