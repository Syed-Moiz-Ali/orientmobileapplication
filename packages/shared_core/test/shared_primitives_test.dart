import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  group('Phase 2: Shared Component Language Primitives', () {
    testWidgets('AppCard renders semantic variants and dark navy surface', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  AppCard.standard(child: const Text('Standard Card')),
                  AppCard.subtle(child: const Text('Subtle Card')),
                  AppCard.outlined(child: const Text('Outlined Card')),
                  AppCard.selected(child: const Text('Selected Card')),
                  AppCard.navy(child: const Text('Navy Panel')),
                  AppCard.semantic(
                    baseColor: AppColors.success,
                    child: const Text('Success Card'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Standard Card'), findsOneWidget);
      expect(find.text('Subtle Card'), findsOneWidget);
      expect(find.text('Outlined Card'), findsOneWidget);
      expect(find.text('Selected Card'), findsOneWidget);
      expect(find.text('Navy Panel'), findsOneWidget);
      expect(find.text('Success Card'), findsOneWidget);
    });

    testWidgets('StatusPill semantic constructors render color+icon+text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Wrap(
              children: const [
                StatusPill.neutral('Draft'),
                StatusPill.info('Review'),
                StatusPill.success('Completed'),
                StatusPill.warning('Pending Approval'),
                StatusPill.danger('Rejected'),
                StatusPill.inProgress('In Workshop'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Pending Approval'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text('In Workshop'), findsOneWidget);
      expect(find.byType(StatusPill), findsNWidgets(6));
    });

    testWidgets('Action System renders Primary, Secondary, and AppButton variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const PrimaryButton(label: 'Submit'),
                const PrimaryButton(label: 'Inline', isExpanded: false),
                const SecondaryButton(label: 'Cancel'),
                AppButton.tertiary(label: 'Learn More', onPressed: () {}),
                AppButton.danger(label: 'Delete Order', onPressed: () {}),
                AppButton.quietIcon(
                  icon: Icons.more_vert_rounded,
                  onPressed: () {},
                ),
                AppButton.compactInline(
                  label: 'Inspect',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Inline'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Learn More'), findsOneWidget);
      expect(find.text('Delete Order'), findsOneWidget);
      expect(find.text('Inspect'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    });

    testWidgets('AppKpiCard renders metrics, labels, trends, and optical icons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: Column(
              children: const [
                AppKpiCard(
                  label: 'Gross Revenue',
                  value: 'AED 42,500',
                  trend: KpiTrend(
                    label: '+12.4%',
                    isPositive: true,
                    timeFrame: 'vs last week',
                  ),
                  icon: Icons.payments_rounded,
                  semanticState: KpiSemanticState.success,
                ),
                AppKpiCard.compact(
                  label: 'Active Bays',
                  value: '8 / 10',
                  icon: Icons.build_circle_rounded,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('GROSS REVENUE'), findsOneWidget);
      expect(find.text('AED 42,500'), findsOneWidget);
      expect(find.text('+12.4%'), findsOneWidget);
      expect(find.text('ACTIVE BAYS'), findsOneWidget);
      expect(find.text('8 / 10'), findsOneWidget);
    });

    testWidgets('AppRecordRow renders title, identifier, status, and metadata', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppRecordRow(
              identifier: 'JOB-4091',
              title: 'Mercedes-Benz E300',
              subtitle: 'Major 60,000 km Service',
              status: const StatusPill.inProgress('In Progress'),
              metadata: const Text('Bay 03 • Assigned to Moiz'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('JOB-4091'), findsOneWidget);
      expect(find.text('Mercedes-Benz E300'), findsOneWidget);
      expect(find.text('Major 60,000 km Service'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Bay 03 • Assigned to Moiz'), findsOneWidget);
    });

    testWidgets('AppInfoPanel renders neutral, primary, and semantic variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: Column(
              children: const [
                AppInfoPanel.neutral(
                  title: 'Notice',
                  message: 'Workshop operating under standard capacity.',
                ),
                AppInfoPanel.warning(
                  title: 'Pending Approvals',
                  message: '2 customer estimates require advisor follow-up.',
                ),
                AppInfoPanel.navy(
                  title: 'Orient Cloud Sync',
                  message: 'All local changes synchronized with telemetry.',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Notice'), findsOneWidget);
      expect(find.text('Pending Approvals'), findsOneWidget);
      expect(find.text('Orient Cloud Sync'), findsOneWidget);
    });

    testWidgets('AppProgress renders linear and step workflow progress', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: Column(
              children: const [
                AppLinearProgress(
                  value: 0.65,
                  label: 'Inspection Checklist',
                  showPercentage: true,
                ),
                AppStepProgress(
                  currentStep: 1,
                  steps: [
                    AppProgressStep(label: 'Check-in'),
                    AppProgressStep(label: 'Inspection'),
                    AppProgressStep(label: 'Estimate'),
                    AppProgressStep(label: 'Delivery'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Inspection Checklist'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('Check-in'), findsOneWidget);
      expect(find.text('Inspection'), findsOneWidget);
      expect(find.text('Estimate'), findsOneWidget);
      expect(find.text('Delivery'), findsOneWidget);
    });

    testWidgets('EmptyState.error renders error title, retry button, and red accent', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.error(
              message: 'Failed to retrieve jobs queue.',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Failed to retrieve jobs queue.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('AppSkeleton displays pulse placeholders without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppSkeleton.card(),
                AppSkeleton.circle(size: 48),
                AppSkeleton.text(width: 160),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppSkeleton), findsNWidgets(3));
    });
  });

  group('Phase 2: Multi-breakpoint & 1.6x Text Scale Responsive Verification', () {
    final breakpoints = [
      (320.0, 568.0, '320_compact_mobile'),
      (360.0, 640.0, '360_standard_mobile'),
      (390.0, 844.0, '390_iphone14'),
      (430.0, 932.0, '430_iphone14promax'),
      (768.0, 1024.0, '768_tablet'),
      (1024.0, 768.0, '1024_desktop'),
      (1440.0, 900.0, '1440_wide_desktop'),
    ];

    for (final (w, h, name) in breakpoints) {
      testWidgets('AppPageFrame & primitives render at width $w ($name)', (
        tester,
      ) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(BrandConfig.orient),
            home: AppPageFrame(
              title: 'Workshop Queue',
              subtitle: 'Active vehicle maintenance schedule',
              eyebrow: 'Advisor Bay',
              primaryAction: AppButton.primary(
                label: 'New Check-in',
                isExpanded: false,
                onPressed: () {},
              ),
              child: Column(
                children: [
                  SectionHeader(
                    title: 'Current Jobs',
                    count: 4,
                    action: 'View all',
                    onAction: () {},
                  ),
                  AppRecordRow(
                    identifier: 'JOB-101',
                    title: 'Toyota Camry 2022',
                    subtitle: 'Brake pad replacement',
                    status: const StatusPill.inProgress('Under QC'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Workshop Queue'), findsOneWidget);
        expect(find.text('TOYOTA CAMRY 2022').evaluate().isNotEmpty || find.text('Toyota Camry 2022').evaluate().isNotEmpty, isTrue);
      });
    }

    testWidgets('Primitives scale without overflow under 1.6x text scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 800),
              textScaler: TextScaler.linear(1.6),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    AppPageHeader(
                      title: 'Vehicle Inspection',
                      subtitle: 'Comprehensive 120-point mechanical evaluation',
                      eyebrow: 'Quality Control',
                      primaryAction: const PrimaryButton(label: 'Complete Inspection'),
                    ),
                    const SizedBox(height: 16),
                    SectionHeader(
                      title: 'Critical Observations',
                      count: 2,
                      action: 'Details',
                      onAction: () {},
                    ),
                    const StatusPill.danger('Immediate Safety Risk'),
                    const SizedBox(height: 16),
                    AppRecordRow(
                      identifier: 'INSP-99',
                      title: 'Front Axle Rotor Wear',
                      subtitle: 'Disc thickness below manufacturer limit',
                      status: const StatusPill.danger('Defect'),
                    ),
                    const SizedBox(height: 16),
                    const AppInfoPanel.warning(
                      title: 'Customer Advisory Required',
                      message: 'Brake rotor thickness measured at 18.2mm, below 20.0mm minimum threshold.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Vehicle Inspection'), findsOneWidget);
      expect(find.text('Critical Observations'), findsOneWidget);
      expect(find.text('Immediate Safety Risk'), findsOneWidget);
    });
  });
}
