import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Confirms exactly what happened to a roadside assistance request.
///
/// The backend offers no way to read a breakdown back, so this page is not a
/// tracking surface: it reports the request the customer just made, and it is
/// careful to distinguish a request the workshop has actually received from one
/// that is still waiting on this device.
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
    final sent = _sent;
    final accent = sent ? colors.primary : colors.tertiary;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(title: sent ? 'Request sent' : 'Request saved'),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                maxContentWidth: 720,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.s12),
                    _Outcome(sent: sent, accent: accent, reference: _reference),
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
                      child: const Text('Done'),
                    ),
                    const SizedBox(height: AppDimensions.s32),
                  ],
                ),
              ),
            ),
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
                  sent
                      ? 'The workshop has received your request.'
                      : "Saved on this device — it hasn't been sent yet.",
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
              "It will be sent automatically when you're back online. Until "
              'then the workshop cannot see this request — call the workshop '
              'if you need help now.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
          if (sent && reference.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            Text(
              'Reference',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              reference,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
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
    final vehicle = vehicleName.isEmpty ? 'No vehicle selected' : vehicleName;

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
              'What you asked for',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s10),
            _Row(
              label: 'Vehicle',
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
                label: 'Location',
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
                label: "What's wrong",
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.campaign_outlined,
          size: AppDimensions.iconMd,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Text(
            sent
                ? "We'll notify you when the workshop assigns an advisor to "
                      'this request.'
                : "We'll send this request and notify you as soon as a "
                      'connection is available.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
