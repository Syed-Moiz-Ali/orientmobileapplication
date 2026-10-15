import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/shared_models.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

import 'repair_estimate_math.dart';

/// One invoice line in the customer estimate document.
class RepairInvoiceLine {
  final String name;
  final String detail;
  final double amount;

  const RepairInvoiceLine({
    required this.name,
    required this.detail,
    required this.amount,
  });
}

/// A tiered group of invoice lines (Mandatory Safety / Optional Enhancement).
class RepairInvoiceGroup {
  final String title;
  final List<RepairInvoiceLine> lines;

  const RepairInvoiceGroup({required this.title, required this.lines});

  bool get isEmpty => lines.isEmpty;
}

/// Immutable view-model shared by the review screen and the share sheet.
///
/// Built from provider-owned estimate lines only; totals are the provider's
/// `servicesTotal` / `partsTotal` with the statutory VAT projection.
class RepairInvoiceData {
  final String workshopName;
  final IconData workshopIcon;
  final String workshopMeta;
  final String customerName;
  final String customerPhone;
  final String vehicleLine;
  final String plate;
  final String preparedOn;
  final List<RepairInvoiceGroup> groups;
  final double partsTotal;
  final double servicesTotal;

  const RepairInvoiceData({
    required this.workshopName,
    required this.workshopIcon,
    required this.workshopMeta,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleLine,
    required this.plate,
    required this.preparedOn,
    required this.groups,
    required this.partsTotal,
    required this.servicesTotal,
  });

  RepairEstimateTotals get totals => RepairEstimateTotals.from(
    partsTotal: partsTotal,
    laborTotal: servicesTotal,
  );
}

/// Formal invoice-style estimate document (workshop header, vehicle, grouped
/// lines, totals). Reused by the review screen and the share sheet.
class RepairInvoicePreview extends StatelessWidget {
  final RepairInvoiceData data;

  const RepairInvoicePreview({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));
    final totals = data.totals;

    String money(double value) => MoneyAed(value).format(arabic: arabic);

    return AppCard.outlined(
      borderRadius: AppDimensions.radiusCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: semantic.primarySubtle,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                  border: Border.all(color: semantic.primaryBorder),
                ),
                child: Icon(
                  data.workshopIcon,
                  color: colors.primary,
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.workshopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    if (data.workshopMeta.isNotEmpty)
                      Text(
                        data.workshopMeta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s12),
            child: Divider(height: 1, color: semantic.borderDefault),
          ),
          _DetailLine(
            icon: Icons.person_outline_rounded,
            label: t.advisorEstimateCustomer,
            value: _join([data.customerName, data.customerPhone]),
          ),
          const SizedBox(height: AppDimensions.s10),
          _DetailLine(
            icon: Icons.directions_car_outlined,
            label: t.advisorEstimateVehicle,
            value: _join([data.vehicleLine, data.plate]),
            ltr: data.plate.isNotEmpty,
          ),
          const SizedBox(height: AppDimensions.s10),
          _DetailLine(
            icon: Icons.event_outlined,
            label: t.advisorEstimatePreparedOn,
            value: data.preparedOn,
          ),
          for (final group in data.groups)
            if (!group.isEmpty) ...[
              const SizedBox(height: AppDimensions.s16),
              Text(
                group.title,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurfaceVariant,
                  letterSpacing: AppTypography.tracking(context, 0.6),
                ),
              ),
              const SizedBox(height: AppDimensions.s6),
              for (final line in group.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.s4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                            if (line.detail.isNotEmpty)
                              Text(
                                line.detail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s12),
                      Text(
                        money(line.amount),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s12),
            child: Divider(height: 1, color: semantic.borderDefault),
          ),
          Text(
            t.advisorEstimateSummaryTitle,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurfaceVariant,
              letterSpacing: AppTypography.tracking(context, 0.6),
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          _TotalRow(
            label: t.advisorStudioPartsSubtotal,
            value: money(totals.parts),
          ),
          _TotalRow(label: t.advisorStudioLabor, value: money(totals.labor)),
          _TotalRow(label: t.advisorStudioVat, value: money(totals.vat)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s8),
            child: Divider(height: 1, color: semantic.borderDefault),
          ),
          _TotalRow(
            label: t.advisorStudioTotal,
            value: money(totals.total),
            emphasized: true,
          ),
        ],
      ),
    );
  }

  static String _join(List<String> parts) =>
      parts.where((part) => part.trim().isNotEmpty).join(' · ');
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool ltr;

  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
    this.ltr = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final resolved = value.trim().isEmpty ? '—' : value;
    final valueText = Text(
      resolved,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: colors.onSurfaceVariant),
        const SizedBox(width: AppDimensions.s8),
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
        Expanded(child: ltr ? Directionality(
          textDirection: TextDirection.ltr,
          child: valueText,
        ) : valueText),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (emphasized
                      ? theme.textTheme.titleSmall
                      : theme.textTheme.bodySmall)
                  ?.copyWith(
                    fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
                    color: emphasized
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: emphasized ? 17 : 13,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
              color: emphasized ? colors.onSurface : colors.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Share surface: the invoice document plus the WhatsApp deep-link and
/// copy-link actions. Presented through [showAppModalSheet] so it is a bottom
/// sheet on compact widths and a centred dialog on tablet/desktop.
class RepairEstimateShareSheet extends StatelessWidget {
  final RepairInvoiceData data;
  final bool canShareWhatsApp;
  final VoidCallback onShareWhatsApp;
  final VoidCallback onCopyLink;

  const RepairEstimateShareSheet({
    super.key,
    required this.data,
    required this.onShareWhatsApp,
    required this.onCopyLink,
    this.canShareWhatsApp = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    final semantic = context.semanticColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s16,
        AppDimensions.s8,
        AppDimensions.s16,
        AppDimensions.s20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.ios_share_rounded,
                size: AppDimensions.iconMd,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.advisorEstimateShareTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      t.advisorEstimateShareHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          RepairInvoicePreview(data: data),
          if (!canShareWhatsApp) ...[
            const SizedBox(height: AppDimensions.s10),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppDimensions.iconXs,
                  color: semantic.warning.base,
                ),
                const SizedBox(width: AppDimensions.s6),
                Flexible(
                  child: Text(
                    t.advisorEstimateNoContact,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: semantic.warning.ink,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.s16),
          PrimaryButton(
            label: t.advisorEstimateShareWhatsApp,
            icon: Icons.chat_outlined,
            onPressed: canShareWhatsApp ? onShareWhatsApp : null,
          ),
          const SizedBox(height: AppDimensions.s8),
          SecondaryButton(
            label: t.advisorEstimateCopyLink,
            leadingIcon: Icons.link_rounded,
            onPressed: onCopyLink,
          ),
        ],
      ),
    );
  }
}
