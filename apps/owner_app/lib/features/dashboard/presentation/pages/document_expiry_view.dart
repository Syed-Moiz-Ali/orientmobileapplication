import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';

class DocumentExpiryView extends ConsumerStatefulWidget {
  const DocumentExpiryView({super.key});
  @override
  ConsumerState<DocumentExpiryView> createState() => _DocumentExpiryViewState();
}

class _DocumentExpiryViewState extends ConsumerState<DocumentExpiryView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(documentExpiryProvider);
    final badgeCount = state.criticalCount + state.urgentCount;

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
        title: Text(
          'Document Compliance & Expiry',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          if (badgeCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compliance alerts are up to date'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
                            .read(documentExpiryProvider.notifier)
                            .onSearch(q),
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search employee name, role or document type…',
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
                        _SummaryCard(
                          label: 'Critical (<7d)',
                          count: state.criticalCount,
                          color: const Color(0xFFEF4444),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(width: 8),
                        _SummaryCard(
                          label: 'Urgent (<30d)',
                          count: state.urgentCount,
                          color: const Color(0xFFF59E0B),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(width: 8),
                        _SummaryCard(
                          label: 'Upcoming (>30d)',
                          count: state.warningCount,
                          color: colorScheme.primary,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.filtered.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: colorScheme.outlineVariant),
                      itemBuilder: (_, i) => _DocumentItem(
                        doc: state.filtered[i],
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
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DocumentItem extends StatelessWidget {
  final DocumentExpiry doc;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _DocumentItem({
    required this.doc,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _urgencyColor(doc.urgency);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.r12),
            ),
            child: Icon(
              Icons.badge_outlined,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.employeeName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc.designation} • ${doc.documentType}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires on ${doc.expiryDate}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: urgencyColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.r8),
              border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              doc.daysLeft >= 0
                  ? '${doc.daysLeft}d left'
                  : '${-doc.daysLeft}d OVERDUE',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: urgencyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _urgencyColor(ExpiryUrgency u) => switch (u) {
    ExpiryUrgency.critical => const Color(0xFFEF4444),
    ExpiryUrgency.urgent => const Color(0xFFF59E0B),
    ExpiryUrgency.warning => const Color(0xFF3B82F6),
  };
}
