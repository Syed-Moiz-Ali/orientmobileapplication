import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Workshop comms thread (O3): broadcast composer over the frozen
/// send/merge notifier plus the server-merged dispatch history. Recipients
/// come from the real team roster (active staff only); the send path,
/// validation (`false` when recipient/body missing) and Hive persistence are
/// untouched — only chrome, copy and states are new.
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  late TextEditingController _msgController;

  @override
  void initState() {
    super.initState();
    _msgController = TextEditingController(
      text: ref.read(dashboardUiProvider).messageText,
    );
    _msgController.addListener(_onMessageChanged);
    _loadServerHistory();
  }

  Future<void> _loadServerHistory() async {
    // FE-FIX (audit): getMessages() existed but was never called — the tab
    // only showed locally-sent notes. Merge server history on open.
    try {
      final remote = ref.read(ownerRemoteDataSourceProvider);
      final history = await remote.getMessages();
      final notifier = ref.read(dashboardUiProvider.notifier);
      final existing = notifier.sentMessages;
      final ids = existing.map((m) => m.id).toSet();
      final server = history
          .where((h) => !ids.contains(h.id))
          .map(
            (h) => Message(
              id: h.id,
              recipient: h.recipient,
              message: h.message,
              time: h.time,
            ),
          )
          .toList();
      if (server.isNotEmpty && mounted) {
        ref.read(dashboardUiProvider.notifier).mergeMessages(server);
      }
    } catch (_) {
      // offline — local notes still shown
    }
  }

  void _onMessageChanged() {
    ref.read(dashboardUiProvider.notifier).updateMessage(_msgController.text);
  }

  @override
  void dispose() {
    _msgController.removeListener(_onMessageChanged);
    _msgController.dispose();
    super.dispose();
  }

  void _toast(String msg, {required bool ok}) {
    final theme = Theme.of(context);
    final ink = context.semanticColors.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: ink,
              size: AppDimensions.iconSm,
            ),
            const SizedBox(width: AppDimensions.s8),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor:
            ok ? context.semanticColors.success.base : theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);
    final team = ref.watch(teamProvider);
    final recipients = team.staff.where((member) => member.isActive).toList();

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final composer = _Composer(
      controller: _msgController,
      recipients: [for (final m in recipients) m.name],
      selectedUser: state.selectedUser,
      hasTeam: recipients.isNotEmpty,
      onSelectUser: (v) {
        HapticFeedback.selectionClick();
        notifier.selectUser(v);
      },
      onSend: () async {
        HapticFeedback.lightImpact();
        final delivered = await notifier.sendMessage();
        if (!context.mounted) return;
        if (delivered) _msgController.clear();
        _toast(
          delivered ? t.ownerMsgSentToast : t.ownerMsgFailToast,
          ok: delivered,
        );
      },
    );

    final history = state.sentMessages.isEmpty
        ? EmptyState(
            icon: Icons.outgoing_mail,
            message: t.ownerMsgEmpty,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: SectionHeader(title: t.ownerMsgHistory),
              ),
              const SizedBox(height: AppDimensions.s8),
              for (final msg in state.sentMessages) ...[
                _MessageRow(message: msg),
                const SizedBox(height: AppDimensions.s8),
              ],
            ],
          );

    if (wide) {
      return ListView(
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s32,
        ),
        children: [
          _SentPill(count: state.sentMessages.length),
          const SizedBox(height: AppDimensions.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: composer),
              const SizedBox(width: AppDimensions.s24),
              Expanded(flex: 6, child: history),
            ],
          ),
        ],
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding.left,
        AppDimensions.s16,
        context.pagePadding.right,
        AppDimensions.s32,
      ),
      children: [
        _SentPill(count: state.sentMessages.length),
        const SizedBox(height: AppDimensions.s12),
        composer,
        const SizedBox(height: AppDimensions.s24),
        history,
      ],
    );
  }
}

class _SentPill extends StatelessWidget {
  final int count;

  const _SentPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        StatusPill(
          label: t.ownerMsgSent(count),
          bg: colors.primary.withValues(alpha: 0.12),
          fg: colors.primary,
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final List<String> recipients;
  final String selectedUser;
  final bool hasTeam;
  final ValueChanged<String> onSelectUser;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.recipients,
    required this.selectedUser,
    required this.hasTeam,
    required this.onSelectUser,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: SectionHeader(
              title: t.ownerMsgCompose,
              padding: const EdgeInsets.only(bottom: AppDimensions.s12),
            ),
          ),
          AppDropdownButton(
            value: selectedUser,
            items: recipients,
            label: t.ownerMsgRecipient,
            hint: t.ownerMsgRecipientHint,
            enabled: hasTeam,
            onChanged: onSelectUser,
          ),
          if (!hasTeam) ...[
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppDimensions.iconXs,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s6),
                Expanded(
                  child: Text(
                    t.ownerMsgNoTeam,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.s16),
          AppTextField(
            controller: controller,
            label: t.ownerMsgBody,
            hint: t.ownerMsgBodyHint,
            maxLines: 4,
            minLines: 3,
            textInputAction: TextInputAction.newline,
            onChanged: (_) {},
          ),
          const SizedBox(height: AppDimensions.s16),
          PrimaryButton(
            label: t.ownerMsgSend,
            icon: Icons.send_rounded,
            onPressed: onSend,
            height: 52,
          ),
        ],
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final Message message;

  const _MessageRow({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;

    return AppRecordRow(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: colors.primary.withValues(alpha: 0.12),
        child: Text(
          message.recipient.isEmpty
              ? '?'
              : message.recipient.characters.first.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: message.recipient,
      subtitle: message.message,
      metadata: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          message.time,
          style: AppTextStyles.mono(color: colors.onSurfaceVariant),
        ),
      ),
      status: Icon(
        message.delivered
            ? Icons.done_all_rounded
            : Icons.error_outline_rounded,
        size: AppDimensions.iconSm,
        color: message.delivered ? semantic.success.base : colors.error,
        semanticLabel: message.delivered ? 'delivered' : 'failed',
      ),
    );
  }
}
