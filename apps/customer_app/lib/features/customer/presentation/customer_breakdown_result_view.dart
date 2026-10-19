import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Confirms exactly what happened to a roadside assistance request.
///
/// The backend offers no way to read a breakdown back, so this page is not a
/// tracking surface: it reports the request the customer just made, and it is
/// careful to distinguish a request the workshop has actually received from one
/// that is still waiting on this device. A sent request shows an honest
/// indeterminate wait — the workshop confirms by phone, so no arrival time,
/// dispatch or towing is ever claimed.
class CustomerBreakdownResultView extends StatelessWidget {
  final Map<String, dynamic> result;

  const CustomerBreakdownResultView({super.key, required this.result});

  bool get _sent => result['sent'] as bool? ?? false;
  String get _reference => (result['reference'] ?? '').toString().trim();
  String get _vehicleName => (result['vehicleName'] ?? '').toString().trim();
  String get _vehiclePlate => (result['vehiclePlate'] ?? '').toString().trim();
  String get _location => (result['location'] ?? '').toString().trim();
  String get _issue => (result['issue'] ?? '').toString().trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    final sent = _sent;
    // A queued request is not a success: it gets a neutral accent, not the
    // positive tone, so the colour cannot contradict the copy.
    final accent = sent ? colors.primary : colors.secondary;

    return Scaffold(
      // Phase 07.1: bespoke AppTopBar migrated to the shared workspace bar.
      appBar: WorkspaceAppBar(
        title: sent ? t.sosSent : t.sosSaved,
        showBack: true,
      ),
      body: AppResponsivePage(
        maxContentWidth: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppDimensions.s12),
            _Outcome(sent: sent, accent: accent, reference: _reference),
            if (sent) ...[
              const SizedBox(height: AppDimensions.s16),
              _WaitPanel(),
            ],
            const SizedBox(height: AppDimensions.s20),
            _Details(
              vehicleName: _vehicleName,
              vehiclePlate: _vehiclePlate,
              location: _location,
              issue: _issue,
            ),
            const SizedBox(height: AppDimensions.s20),
            _WhatHappensNext(sent: sent),
            const SizedBox(height: AppDimensions.s24),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(t.sosDone),
            ),
            const SizedBox(height: AppDimensions.s32),
          ],
        ),
      ),
    );
  }
}

/// The one line that must not overstate: a queued request has not been received.
class _Outcome extends StatelessWidget {
  final bool sent;
  final Color accent;
  final String reference;

  const _Outcome({
    required this.sent,
    required this.accent,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;

    return CustomerSurfacePanel(
      accent: accent,
      emphasised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                sent ? Icons.check_circle_rounded : Icons.cloud_off_rounded,
                size: AppDimensions.iconLg,
                color: accent,
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  sent ? t.sosSentBody : t.sosSavedOutcome,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (!sent) ...[
            const SizedBox(height: AppDimensions.s8),
            Text(
              t.sosQueuedNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
          if (sent && reference.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            Text(
              t.sosRef,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                reference,
                style: AppTextStyles.mono(color: colors.onSurface).copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Honest indeterminate wait: the request is with the workshop, confirmation
/// comes by phone, and nothing about arrival is known. The bar is
/// indeterminate — it marks waiting, never progress.
class _WaitPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                color: colors.primary,
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: Text(
                  t.sosWaitingTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Semantics(
            label: t.sosWaitingBody,
            child: const LinearProgressIndicator(),
          ),
          const SizedBox(height: AppDimensions.s8),
          Text(
            t.sosWaitingBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final String vehicleName;
  final String vehiclePlate;
  final String location;
  final String issue;

  const _Details({
    required this.vehicleName,
    required this.vehiclePlate,
    required this.location,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    final vehicle = vehicleName.isEmpty ? t.sosNoVehicle : vehicleName;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.sosDetails,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s10),
            _Row(
              label: t.bkdVehicleLabel,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      vehicle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (vehiclePlate.isNotEmpty) ...[
                    const SizedBox(width: AppDimensions.s8),
                    CustomerPlateChip(plate: vehiclePlate),
                  ],
                ],
              ),
            ),
            if (location.isNotEmpty)
              _Row(
                label: t.sosLocationRow,
                child: Text(
                  location,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (issue.isNotEmpty)
              _Row(
                label: t.sosIssueRow,
                child: Text(
                  issue,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final Widget child;

  const _Row({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Only claims what the workshop's own flow really does: an advisor is assigned
/// from the workshop queue, and that assignment is what sends a notification.
class _WhatHappensNext extends StatelessWidget {
  final bool sent;

  const _WhatHappensNext({required this.sent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    final steps = sent
        ? [t.sosNotifySent, t.sosNextSentTwo]
        : [t.sosNextSavedOne, t.sosNextSavedTwo];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.sosWhatNext,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.s4),
                    child: Text(
                      steps[i],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
