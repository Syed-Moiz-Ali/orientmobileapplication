import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// Opens the bookings search sheet: a list-scoped search over the already
/// loaded booking records (no new routes, no logic changes). Result taps reuse
/// the record contract — tapping a result closes the sheet and reveals the
/// record; record actions stay on the record itself.
Future<void> showCustomerBookingsSearchSheet(
  BuildContext context, {
  required List<CustomerBookingEntity> bookings,
  required ValueChanged<CustomerBookingEntity> onSelect,
}) {
  final t = context.cx;
  return showAppModalSheet<void>(
    context: context,
    title: t.bkSearchTitle,
    builder: (_) => _BookingsSearchSheet(
      bookings: bookings,
      onSelect: onSelect,
    ),
  );
}

/// Presentation-only bookings search: filters the loaded records by service,
/// vehicle, plate label or reference substring (case-insensitive; plates
/// compared without punctuation). Mirrors the record content so the sheet can
/// never promise a booking the list does not show.
class _BookingsSearchSheet extends StatefulWidget {
  final List<CustomerBookingEntity> bookings;
  final ValueChanged<CustomerBookingEntity> onSelect;

  const _BookingsSearchSheet({required this.bookings, required this.onSelect});

  @override
  State<_BookingsSearchSheet> createState() => _BookingsSearchSheetState();
}

class _BookingsSearchSheetState extends State<_BookingsSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static String _normalizedPlate(String value) =>
      value.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();

  List<CustomerBookingEntity> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.bookings;
    final normalizedQuery = _normalizedPlate(q);
    return widget.bookings.where((booking) {
      final service = booking.service.toLowerCase();
      final vehicle = booking.vehicleName.toLowerCase();
      final plate = booking.plateNumber.toLowerCase();
      final reference = CustomerBookingsPresentation.referenceOf(
        booking,
      ).toLowerCase();
      return service.contains(q) ||
          vehicle.contains(q) ||
          plate.contains(q) ||
          (reference.isNotEmpty && reference.contains(q)) ||
          (normalizedQuery.isNotEmpty &&
              _normalizedPlate(booking.plateNumber).contains(normalizedQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final results = _results();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: AppSearchField(
            controller: _ctrl,
            hintText: t.bkSearchHint,
            onChanged: (v) => setState(() => _query = v),
            onClear: () => setState(() {
              _ctrl.clear();
              _query = '';
            }),
          ),
        ),
        Flexible(
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.bkSearchNoMatch,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => setState(() {
                          _ctrl.clear();
                          _query = '';
                        }),
                        child: Text(t.bkFilterClear),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (rowContext, index) {
                    final booking = results[index];
                    final service = booking.service.trim();
                    final vehicle = booking.vehicleName.trim();
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(rowContext).pop();
                        widget.onSelect(booking);
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppDimensions.s20,
                          AppDimensions.s8,
                          AppDimensions.s20,
                          AppDimensions.s8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.isEmpty
                                    ? t.bkServiceAppt
                                    : service,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (vehicle.isNotEmpty) ...[
                              const SizedBox(width: AppDimensions.s10),
                              Flexible(
                                child: Text(
                                  vehicle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
