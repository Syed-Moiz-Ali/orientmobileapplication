import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orientmobileapplication/core/router/app_router.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/widgets/exit_confirmation_dialog.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/followup_reminder_entity.dart';
import '../widgets/advisor_body.dart';
import '../widgets/advisor_fab.dart';
import '../widgets/advisor_bottom_nav.dart';
import '../widgets/advisor_profile_sheet.dart';
import '../widgets/advisor_notification_sheet.dart';
import '../widgets/advisor_job_card_sheet.dart';
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
    context.push(
      AppRoutes.inspectionSheet,
      extra: {
        'onBack': () => context.pop(),
        'onSaveDraft': () {
          context.pop();
          _toast(
            'Draft saved',
            icon: Icons.save_outlined,
            color: AppColors.warning,
          );
        },
        'onPreview': () {
          context.push(
            AppRoutes.inspectionPreview,
            extra: {
              'onBack': () => context.pop(),
              'onSubmit': () {
                _toast(
                  'Inspection Submitted',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                );
                context.go(AppRoutes.advisorDashboard);
              },
            },
          );
        },
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(advisorDashboardProvider);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          _toast(
            'Good morning, Ali. You have 5 pending approvals.',
            icon: Icons.wb_sunny_outlined,
            color: AppColors.accent,
          );
        }
      });
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

  void _showProfile() => _sheet(
    AdvisorProfileSheet(
      onLogout: () {
        Navigator.pop(context);
        _toast('Logged out', icon: Icons.logout, color: AppColors.text3);
      },
    ),
  );

  void _showNotifications() {
    HapticFeedback.lightImpact();
    _sheet(const AdvisorNotificationSheet());
  }

  void _onJobCard(JobCardEntity jc) {
    HapticFeedback.selectionClick();
    _sheet(AdvisorJobCardSheet(jc: jc, onOpen: () => Navigator.pop(context)));
  }

  void _onApproval(PendingApprovalEntity pa) {
    HapticFeedback.mediumImpact();
    _sheet(
      AdvisorApprovalSheet(
        pa: pa,
        onApprove: () {
          Navigator.pop(context);
          _toast(
            'Estimate ${pa.estimateId} approved',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          );
        },
        onReject: () {
          Navigator.pop(context);
          _toast(
            'Sent back for revision',
            icon: Icons.undo,
            color: AppColors.warning,
          );
        },
      ),
    );
  }

  void _onContact(FollowupReminderEntity r) {
    HapticFeedback.lightImpact();
    _sheet(
      AdvisorContactSheet(
        r: r,
        onCall: () {
          Navigator.pop(context);
          _toast(
            'Calling ${r.customerName}…',
            icon: Icons.phone_outlined,
            color: AppColors.accent,
          );
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
          _toast('SMS sent', icon: Icons.sms_outlined, color: AppColors.accent);
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

    final isLoading = ref.watch(advisorDashboardProvider).isLoading;
    return ExitConfirmationWrapper(
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: isLoading
            ? _loadingView()
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
      ),
    );
  }

  Widget _loadingView() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.navy, AppColors.accent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Loading…',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
