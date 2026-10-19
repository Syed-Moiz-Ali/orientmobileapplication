import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

/// Omnichannel console: channel list with unread badges, the active thread
/// and a customer dossier rail on desktop; two panes on tablet; a sliding
/// drilldown on phones.
///
/// The thread shows the conversation's real latest message — there is no
/// message-thread API, no send endpoint, no template or quote contract, so
/// there is no composer, no template chips and no quote button. The honesty
/// note says exactly that instead of faking a chat app.
class CrmConversationsPage extends ConsumerStatefulWidget {
  const CrmConversationsPage({super.key});

  @override
  ConsumerState<CrmConversationsPage> createState() =>
      _CrmConversationsPageState();
}

class _CrmConversationsPageState extends ConsumerState<CrmConversationsPage> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    ref.watch(crmUiProvider.select((state) => state.revision));
    final conversations = ref.read(crmUiProvider.notifier).conversations;
    final adaptive = context.adaptive;

    ConversationEntity? selected;
    if (_selectedId != null) {
      for (final c in conversations) {
        if (c.id == _selectedId) selected = c;
      }
      // The selected thread vanished (sync) — fall back to the list.
      if (selected == null) _selectedId = null;
    }
    final current = selected ?? (conversations.isNotEmpty ? conversations.first : null);

    return AppResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            eyebrow: t.cvInbox,
            title: t.cvTitle,
            subtitle: conversations.isEmpty
                ? t.cvEmptySub
                : conversations.length == 1
                    ? t.cvThreadsOne
                    : t.cvThreadsMany(conversations.length),
            leading: const Icon(Icons.forum_outlined),
          ),
          SizedBox(height: adaptive.sectionSpacing),
          if (conversations.isEmpty)
            EmptyState(
              icon: Icons.mark_chat_unread_outlined,
              title: t.cvEmpty,
              message: t.cvEmptyBody,
            )
          else if (adaptive.isCompact)
            _buildDrilldown(context, conversations, current)
          else if (adaptive.isMedium)
            _buildTwoPane(context, conversations, current)
          else
            _buildThreePane(context, conversations, current),
        ],
      ),
    );
  }

  void _select(String id) => setState(() => _selectedId = id);

  Widget _buildDrilldown(
    BuildContext context,
    List<ConversationEntity> conversations,
    ConversationEntity? current,
  ) {
    final t = context.cx;
    // Phones drill list → thread; the dossier rides inside the thread scroll.
    if (_selectedId != null && current != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => setState(() => _selectedId = null),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(t.cvBack),
            ),
          ),
          _ThreadPane(conversation: current),
          const SizedBox(height: AppDimensions.s16),
          _DossierRail(conversation: current),
        ],
      );
    }
    return _ChannelList(
      conversations: conversations,
      selectedId: _selectedId,
      onSelect: _select,
    );
  }

  Widget _buildTwoPane(
    BuildContext context,
    List<ConversationEntity> conversations,
    ConversationEntity? current,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _ChannelList(
            conversations: conversations,
            selectedId: current?.id,
            onSelect: _select,
          ),
        ),
        const SizedBox(width: AppDimensions.s16),
        Expanded(
          flex: 3,
          child: current == null
              ? _ThreadPlaceholder()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ThreadPane(conversation: current),
                      const SizedBox(height: AppDimensions.s16),
                      _DossierRail(conversation: current),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildThreePane(
    BuildContext context,
    List<ConversationEntity> conversations,
    ConversationEntity? current,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _ChannelList(
            conversations: conversations,
            selectedId: current?.id,
            onSelect: _select,
          ),
        ),
        const SizedBox(width: AppDimensions.s16),
        Expanded(
          flex: 5,
          child: current == null
              ? _ThreadPlaceholder()
              : _ThreadPane(conversation: current),
        ),
        const SizedBox(width: AppDimensions.s16),
        Expanded(
          flex: 3,
          child: current == null
              ? const SizedBox.shrink()
              : _DossierRail(conversation: current),
        ),
      ],
    );
  }
}

class _ChannelList extends StatelessWidget {
  final List<ConversationEntity> conversations;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _ChannelList({
    required this.conversations,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < conversations.length; i++) ...[
          _ConversationRow(
            conversation: conversations[i],
            selected: conversations[i].id == selectedId,
            onSelect: onSelect,
          ),
          if (i < conversations.length - 1)
            const SizedBox(height: AppDimensions.s10),
        ],
      ],
    );
  }
}

class _ConversationRow extends StatelessWidget {
  final ConversationEntity conversation;
  final bool selected;
  final ValueChanged<String> onSelect;

  const _ConversationRow({
    required this.conversation,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.cx;
    final unread = conversation.unread > 0;

    return AppRecordRow(
      emphasized: selected || unread,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: conversation.channelColor.withValues(alpha: 0.12),
        foregroundColor: conversation.channelColor,
        child: Text(
          conversation.customerName.isEmpty
              ? '?'
              : conversation.customerName.characters.first.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: conversation.channelColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: conversation.customerName,
      subtitle: conversation.lastMessage,
      metadata: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppDimensions.s8,
        runSpacing: AppDimensions.s4,
        children: [
          StatusPill(
            label: conversation.channel,
            bg: conversation.channelColor.withValues(alpha: 0.10),
            fg: conversation.channelColor,
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              conversation.time,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      trailing: unread
          ? Semantics(
              label: t.cvUnread(conversation.unread),
              child: Badge(label: Text('${conversation.unread}')),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
      onTap: () => onSelect(conversation.id),
    );
  }
}

/// The active thread: header + the real latest message as an incoming
/// bubble + the honesty note. No composer exists because no send endpoint
/// does; typing into a dead box would be the fake.
class _ThreadPane extends StatelessWidget {
  final ConversationEntity conversation;

  const _ThreadPane({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: conversation.channelColor.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  conversation.customerName.isEmpty
                      ? '?'
                      : conversation.customerName.characters.first.toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: conversation.channelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StatusPill(
                      label: conversation.channel,
                      bg: conversation.channelColor.withValues(alpha: 0.10),
                      fg: conversation.channelColor,
                    ),
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  conversation.time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s14,
                vertical: AppDimensions.s10,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.cvLatest,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.s6),
              Expanded(
                child: Text(
                  t.cvHistoryNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThreadPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    return EmptyState(
      icon: Icons.forum_outlined,
      title: t.cvNoThread,
      message: t.cvNoThreadBody,
    );
  }
}

/// Customer dossier rail: every real field the thread record carries.
/// There is no phone field on the record, so no call action is offered.
class _DossierRail extends StatelessWidget {
  final ConversationEntity conversation;

  const _DossierRail({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.cvDossier,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          _DossierRow(
            icon: Icons.person_outline_rounded,
            value: conversation.customerName,
          ),
          _DossierRow(
            icon: Icons.forum_outlined,
            value: '${t.cvChannel}: ${conversation.channel}',
          ),
          _DossierRow(
            icon: Icons.flag_outlined,
            value: '${t.cvStatus}: ${conversation.status}',
          ),
          _DossierRow(
            icon: Icons.schedule_rounded,
            value: '${t.cvTime}: ${conversation.time}',
            ltr: true,
          ),
        ],
      ),
    );
  }
}

class _DossierRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool ltr;

  const _DossierRow({
    required this.icon,
    required this.value,
    this.ltr = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final text = Text(
      value.trim(),
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: ltr
                ? Directionality(
                    textDirection: TextDirection.ltr,
                    child: text,
                  )
                : text,
          ),
        ],
      ),
    );
  }
}
