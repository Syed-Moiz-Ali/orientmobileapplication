import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmConversationsPage extends ConsumerWidget {
  const CrmConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(crmUiProvider.select((state) => state.revision));
    final conversations = ref.read(crmUiProvider.notifier).conversations;

    return AppResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            eyebrow: 'Inbox',
            title: 'Conversations',
            subtitle: conversations.isEmpty
                ? 'Customer messages from connected channels will appear here.'
                : '${conversations.length} active customer threads across every channel.',
            leading: const Icon(Icons.forum_outlined),
          ),
          SizedBox(height: context.adaptive.sectionSpacing),
          if (conversations.isEmpty)
            const EmptyState(
              icon: Icons.mark_chat_unread_outlined,
              title: 'No conversations yet',
              message:
                  'Connect a messaging channel to bring customer conversations into one queue.',
            )
          else
            ...conversations.map(
              (conversation) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.s10),
                child: _ConversationRow(conversation: conversation),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  final ConversationEntity conversation;

  const _ConversationRow({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = conversation.unread > 0;

    return AppRecordRow(
      emphasized: unread,
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
          Text(
            conversation.time,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: unread
          ? Semantics(
              label: '${conversation.unread} unread messages',
              child: Badge(label: Text('${conversation.unread}')),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
      onTap: () {},
    );
  }
}
