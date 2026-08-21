import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/accounts_receivable.dart';
import 'package:owner_app/features/dashboard/presentation/providers/ar_providers.dart';

class AccountsReceivableView extends ConsumerStatefulWidget {
  const AccountsReceivableView({super.key});

  @override
  ConsumerState<AccountsReceivableView> createState() =>
      _AccountsReceivableViewState();
}

class _AccountsReceivableViewState
    extends ConsumerState<AccountsReceivableView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(accountsReceivableProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accounts Receivable',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Outstanding: AED ${_formatAmount(state.summary.totalOutstanding)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            )
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: TextField(
                        onChanged: (q) => ref
                            .read(accountsReceivableProvider.notifier)
                            .onSearch(q),
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search customer name, invoice or AR ID…',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        _AgingCard(
                          label: '0-30 Days',
                          amount: state.summary.days0to30,
                          color: const Color(0xFF10B981),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(width: 8),
                        _AgingCard(
                          label: '31-60 Days',
                          amount: state.summary.days31to60,
                          color: const Color(0xFFF59E0B),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(width: 8),
                        _AgingCard(
                          label: '61-90 Days',
                          amount: state.summary.days61to90,
                          color: const Color(0xFFEF4444),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(width: 8),
                        _AgingCard(
                          label: '90+ Days',
                          amount: state.summary.days90plus,
                          color: const Color(0xFF8B5CF6),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: colorScheme.surfaceContainerLow,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 360;
                        return Row(
                          children: [
                            _TableHeader(text: 'AR REF', flex: 2, textTheme: textTheme, colorScheme: colorScheme),
                            _TableHeader(text: 'CUSTOMER', flex: 3, textTheme: textTheme, colorScheme: colorScheme),
                            _TableHeader(text: 'INVOICED', flex: 2, textTheme: textTheme, colorScheme: colorScheme),
                            if (!narrow)
                              _TableHeader(text: 'DUE DATE', flex: 2, textTheme: textTheme, colorScheme: colorScheme),
                            _TableHeader(text: 'AGING', flex: 2, textTheme: textTheme, colorScheme: colorScheme),
                          ],
                        );
                      },
                    ),
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.filteredRecords.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: colorScheme.outlineVariant),
                      itemBuilder: (_, i) => _ARTableRow(
                        record: state.filteredRecords[i],
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _AgingCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _AgingCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r14),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AED ${_fmt(amount)}',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => v == 0
      ? '0'
      : v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _TableHeader({
    required this.text,
    required this.flex,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ARTableRow extends StatelessWidget {
  final ARRecord record;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ARTableRow({
    required this.record,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    Color agingColor;
    String agingLabel;

    switch (record.aging) {
      case AgingBucket.days0to30:
        agingColor = const Color(0xFF10B981);
        agingLabel = '0-30d';
        break;
      case AgingBucket.days31to60:
        agingColor = const Color(0xFFF59E0B);
        agingLabel = '31-60d';
        break;
      case AgingBucket.days61to90:
        agingColor = const Color(0xFFEF4444);
        agingLabel = '61-90d';
        break;
      case AgingBucket.days90plus:
        agingColor = const Color(0xFF8B5CF6);
        agingLabel = '90d+';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 360;
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  record.arId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    fontFamily: AppFontFamilies.mono,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  record.customer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  record.invoiceDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
              if (!narrow)
                Expanded(
                  flex: 2,
                  child: Text(
                    record.dueDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: agingColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.r6),
                  ),
                  child: Text(
                    agingLabel,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: agingColor,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
