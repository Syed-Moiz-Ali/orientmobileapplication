// D2 · Job Cards listing prototype.
//
// Mirrors the production listing (job_cards_list_view.dart + job_card_tile.dart
// + filter_chip_bar.dart): toolbar = search + 5 filter chips
// (All / In Progress / Waiting Parts / Quality Check / Completed).
// Compact = record cards · medium = 2-column cards · expanded+ = true table
// (Ref, Vehicle, Customer, Service, Status, Promised, Amount, kebab).
// States: populated / loading / empty / no-match (distinct) / error.
import 'package:flutter/material.dart';

import '../../design/prototype_theme.dart';
import '../../design/provisional_tokens.dart';
import '../../fixtures/job_cards_fixtures.dart';
import '../../l10n/proto_format.dart';
import '../../l10n/provisional_strings.dart';
import '../../widgets/proto_primitives.dart';

class JobCardsPrototype extends StatefulWidget {
  final String variant;

  const JobCardsPrototype({super.key, required this.variant});

  @override
  State<JobCardsPrototype> createState() => _JobCardsPrototypeState();
}

class _JobCardsPrototypeState extends State<JobCardsPrototype> {
  late String _query;
  late int _filterIndex;
  bool _reloading = false;

  static const _filterKeys = [
    'jobs.filter.all',
    'jobs.filter.inProgress',
    'jobs.filter.waitingParts',
    'jobs.filter.qc',
    'jobs.filter.completed',
  ];

  static const _filterStatuses = <FixtureJobStatus?>[
    null,
    FixtureJobStatus.inProgress,
    FixtureJobStatus.waitingParts,
    FixtureJobStatus.qualityCheck,
    FixtureJobStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    switch (widget.variant) {
      case 'noMatch':
        _query = 'Range Rover';
        _filterIndex = 4; // Completed → no match with the search term
      default:
        _query = '';
        _filterIndex = 0;
    }
  }

  bool get _loading => widget.variant == 'loading' || _reloading;
  bool get _error => widget.variant == 'error';
  bool get _empty => widget.variant == 'empty';

  List<JobCardFixture> get _filtered {
    final status = _filterStatuses[_filterIndex];
    return jobCardFixtures.where((card) {
      final matchesStatus = status == null || card.status == status;
      if (!matchesStatus) return false;
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return card.id.toLowerCase().contains(q) ||
          card.customer.en.toLowerCase().contains(q) ||
          card.customer.ar.contains(_query.trim()) ||
          card.vehicle.toLowerCase().contains(q) ||
          card.plate.toLowerCase().contains(q) ||
          card.services.any((s) => s.en.toLowerCase().contains(q) || s.ar.contains(_query.trim()));
    }).toList();
  }

  void _simulateReload() {
    setState(() => _reloading = true);
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _reloading = false);
    });
  }

  void _showDetail(JobCardFixture card) {
    showProtoSheet<void>(
      context,
      child: _JobCardSheet(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cards = _empty ? <JobCardFixture>[] : _filtered;
    final total = _empty ? 0 : jobCardFixtures.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProtoTopBar(
          title: context.s('jobs.title'),
          subtitle: context.s('jobs.countLabel', {'shown': '${cards.length}', 'total': '$total'}),
          onBack: () {},
          actions: [
            IconButton(
              tooltip: context.s('common.retry'),
              onPressed: _simulateReload,
              icon: Icon(Icons.refresh_rounded, size: 20, color: p.textSecondary),
            ),
          ],
        ),
        Container(
          color: p.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(ProtoSpace.s16, ProtoSpace.s12, ProtoSpace.s16, ProtoSpace.s8),
                child: ProtoSearchField(
                  hint: context.s('jobs.search'),
                  value: _query,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s16, vertical: 2),
                  itemCount: _filterKeys.length,
                  separatorBuilder: (_, _) => const SizedBox(width: ProtoSpace.s8),
                  itemBuilder: (context, index) => ProtoFilterChip(
                    label: context.s(_filterKeys[index]),
                    selected: _filterIndex == index,
                    onTap: () => setState(() => _filterIndex = index),
                  ),
                ),
              ),
              Divider(height: 1, color: p.borderDefault),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const _ListSkeleton()
              : RefreshIndicator(
                  onRefresh: () async => _simulateReload(),
                  color: p.primary,
                  child: _buildContent(context, cards),
                ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<JobCardFixture> cards) {
    if (_error) {
      return ListView(
        padding: const EdgeInsets.all(ProtoSpace.s16),
        children: [
          ProtoErrorBanner(
            title: context.s('jobs.error.title'),
            body: context.s('jobs.error.body'),
            onRetry: _simulateReload,
          ),
        ],
      );
    }
    if (_empty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: ProtoSpace.s64),
          ProtoEmptyState(
            icon: Icons.assignment_outlined,
            title: context.s('jobs.empty.title'),
            body: context.s('jobs.empty.body'),
          ),
        ],
      );
    }
    if (cards.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: ProtoSpace.s64),
          ProtoEmptyState(
            icon: Icons.search_off_rounded,
            title: context.s('jobs.noMatch.title'),
            body: context.s('jobs.noMatch.body', {
              'query': _query,
              'filter': context.s(_filterKeys[_filterIndex]),
            }),
            actionLabel: context.s('jobs.noMatch.clear'),
            onAction: () => setState(() {
              _query = '';
              _filterIndex = 0;
            }),
          ),
        ],
      );
    }

    final windowClass = context.windowClass;
    if (windowClass.isExpanded || windowClass.isLarge) {
      return ListView(
        padding: const EdgeInsets.all(ProtoSpace.s16),
        children: [
          ProtoPageFrame(
            padding: EdgeInsets.zero,
            child: _JobCardsTable(cards: cards, onRowTap: _showDetail),
          ),
        ],
      );
    }

    final columns = windowClass.isCompact ? 1 : 2;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = ProtoSpace.s12;
        final available = constraints.maxWidth - ProtoSpace.s32;
        final cardWidth = (available - gap * (columns - 1)) / columns;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(ProtoSpace.s16),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final card in cards)
                SizedBox(
                  width: cardWidth,
                  child: _JobCardTile(card: card, onTap: () => _showDetail(card)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _JobCardTile extends StatelessWidget {
  final JobCardFixture card;
  final VoidCallback onTap;

  const _JobCardTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final tone = _toneOf(card.status);
    return ProtoCard(
      interactive: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.surfaceSunken,
                  borderRadius: BorderRadius.circular(ProtoRadius.sm),
                  border: Border.all(color: p.borderDefault),
                ),
                child: Text(card.id, style: types.mono.copyWith(color: p.textSecondary, fontSize: 11)),
              ),
              const Spacer(),
              ProtoStatusPill(label: context.s(card.status.labelKey), tone: tone, compact: true),
            ],
          ),
          const SizedBox(height: ProtoSpace.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProtoAvatar(initials: _initials(card), size: 34),
              const SizedBox(width: ProtoSpace.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.customer.of(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: types.cardTitle.copyWith(color: p.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${card.vehicle} · ${card.plate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: types.bodySmall.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ProtoSpace.s12),
          Divider(height: 1, color: p.borderSubtle),
          const SizedBox(height: ProtoSpace.s10),
          Text(
            card.services.map((s) => s.of(context)).join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: types.bodySmall.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: ProtoSpace.s6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.s('jobs.card.specialist')}: ${card.technician.of(context)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: types.metadata.copyWith(color: p.textMuted),
                ),
              ),
              ProtoDirIcon(Icons.schedule_rounded, size: 13, color: p.textDisabled),
              const SizedBox(width: ProtoSpace.s4),
              Text(
                card.promised.of(context),
                style: types.metadata.copyWith(color: p.textMuted),
              ),
            ],
          ),
          const SizedBox(height: ProtoSpace.s12),
          Divider(height: 1, color: p.borderSubtle),
          const SizedBox(height: ProtoSpace.s10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.s('jobs.card.total'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: types.metadata.copyWith(color: p.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ProtoFormat.money(context, card.amount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: types.monoStrong.copyWith(color: p.textPrimary, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ProtoSpace.s8),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.s('jobs.card.details')),
                    const SizedBox(width: ProtoSpace.s6),
                    const ProtoDirIcon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCardsTable extends StatelessWidget {
  final List<JobCardFixture> cards;
  final void Function(JobCardFixture) onRowTap;

  const _JobCardsTable({required this.cards, required this.onRowTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ProtoCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s16, vertical: ProtoSpace.s12),
            decoration: BoxDecoration(
              color: p.surfaceSubtle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(ProtoRadius.card)),
              border: Border(bottom: BorderSide(color: p.borderDefault)),
            ),
            child: Row(
              children: [
                _headerCell(context, 'jobs.col.ref', flex: 16),
                _headerCell(context, 'jobs.col.vehicle', flex: 26),
                _headerCell(context, 'jobs.col.customer', flex: 20),
                _headerCell(context, 'jobs.col.service', flex: 22),
                _headerCell(context, 'jobs.col.status', flex: 16),
                _headerCell(context, 'jobs.col.promised', flex: 16),
                _headerCell(context, 'jobs.col.amount', flex: 14, align: TextAlign.end),
                const SizedBox(width: 36),
              ],
            ),
          ),
          for (var i = 0; i < cards.length; i++)
            _JobCardTableRow(
              card: cards[i],
              last: i == cards.length - 1,
              onTap: () => onRowTap(cards[i]),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(
    BuildContext context,
    String key, {
    required int flex,
    TextAlign align = TextAlign.start,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        context.s(key),
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.types.tableHeader.copyWith(color: context.palette.textMuted),
      ),
    );
  }
}

class _JobCardTableRow extends StatelessWidget {
  final JobCardFixture card;
  final bool last;
  final VoidCallback onTap;

  const _JobCardTableRow({required this.card, required this.last, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: p.hover,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s16, vertical: ProtoSpace.s10),
          decoration: BoxDecoration(
            border: last ? null : Border(bottom: BorderSide(color: p.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 16,
                child: Text(
                  card.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: types.mono.copyWith(color: p.textSecondary, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 26,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: card.vehicle,
                        style: types.bodyStrong.copyWith(color: p.textPrimary, fontSize: 13),
                      ),
                      TextSpan(
                        text: '  ${card.plate}',
                        style: types.mono.copyWith(color: p.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 20,
                child: Text(
                  card.customer.of(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: types.body.copyWith(color: p.textSecondary, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 22,
                child: Text(
                  _serviceSummary(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: types.body.copyWith(color: p.textMuted, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 16,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ProtoStatusPill(
                    label: context.s(card.status.labelKey),
                    tone: _toneOf(card.status),
                    compact: true,
                  ),
                ),
              ),
              Expanded(
                flex: 16,
                child: Text(
                  card.promised.of(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: types.metadata.copyWith(color: p.textMuted),
                ),
              ),
              Expanded(
                flex: 14,
                child: Text(
                  ProtoFormat.money(context, card.amount),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: types.monoStrong.copyWith(color: p.textPrimary, fontSize: 12.5),
                ),
              ),
              SizedBox(
                width: 36,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: ProtoKebabMenu(
                    items: [
                      (
                        label: context.s('jobs.menu.view'),
                        icon: Icons.open_in_new_rounded,
                        onSelect: onTap,
                        destructive: false,
                      ),
                      (
                        label: context.s('jobs.menu.call'),
                        icon: Icons.call_rounded,
                        onSelect: onTap,
                        destructive: false,
                      ),
                      (
                        label: context.s('jobs.menu.complete'),
                        icon: Icons.check_circle_outline_rounded,
                        onSelect: onTap,
                        destructive: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _serviceSummary(BuildContext context) {
    final names = card.services.map((s) => s.of(context)).toList();
    if (names.length <= 1) return names.join();
    return '${names.first} +${names.length - 1}';
  }
}

class _JobCardSheet extends StatelessWidget {
  final JobCardFixture card;

  const _JobCardSheet({required this.card});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(ProtoSpace.s20, ProtoSpace.s8, ProtoSpace.s20, ProtoSpace.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.s('jobs.detail.title'),
                    style: types.sectionTitle.copyWith(color: p.textPrimary),
                  ),
                ),
                ProtoStatusPill(label: context.s(card.status.labelKey), tone: _toneOf(card.status)),
              ],
            ),
            const SizedBox(height: ProtoSpace.s16),
            ProtoKeyValueRow(label: context.s('jobs.col.ref'), value: card.id, valueStyle: types.monoStrong),
            ProtoKeyValueRow(
              label: context.s('jobs.col.vehicle'),
              value: '${card.vehicle} · ${card.plate}',
            ),
            ProtoKeyValueRow(label: context.s('jobs.col.customer'), value: card.customer.of(context)),
            ProtoKeyValueRow(label: context.s('jobs.card.specialist'), value: card.technician.of(context)),
            ProtoKeyValueRow(label: context.s('jobs.col.promised'), value: card.promised.of(context)),
            ProtoKeyValueRow(
              label: context.s('jobs.col.amount'),
              value: ProtoFormat.money(context, card.amount),
              valueStyle: types.monoStrong.copyWith(color: p.primary, fontSize: 14),
            ),
            const SizedBox(height: ProtoSpace.s8),
            Text(
              card.services.map((s) => s.of(context)).join(' · '),
              style: types.bodySmall.copyWith(color: p.textSecondary),
            ),
            const SizedBox(height: ProtoSpace.s16),
            Text(
              context.s('jobs.detail.sheetBody', {
                'customer': card.customer.of(context),
                'vehicle': card.vehicle,
                'tech': card.technician.of(context),
                'promised': card.promised.of(context),
              }),
              style: types.caption.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: ProtoSpace.s16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.call_rounded, size: 17),
                    label: Text(context.s('jobs.menu.call')),
                  ),
                ),
                const SizedBox(width: ProtoSpace.s10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
                    label: Text(context.s('jobs.menu.complete')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(ProtoSpace.s16),
      children: [
        for (var i = 0; i < 5; i++) ...[
          const ProtoSkeleton(height: 120, radius: ProtoRadius.card),
          const SizedBox(height: ProtoSpace.s12),
        ],
      ],
    );
  }
}

ProtoTone _toneOf(FixtureJobStatus status) => switch (status.tone) {
      'primary' => ProtoTone.primary,
      'success' => ProtoTone.success,
      'warning' => ProtoTone.warning,
      'danger' => ProtoTone.danger,
      'info' => ProtoTone.info,
      _ => ProtoTone.neutral,
    };

String _initials(JobCardFixture card) {
  final parts = card.customer.en.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return parts.first.isEmpty ? 'C' : parts.first[0].toUpperCase();
}
