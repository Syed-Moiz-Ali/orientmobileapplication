import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/message_tile.dart';

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
      if (server.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);
    final team = ref.watch(teamProvider);
    final recipients = team.staff.where((member) => member.isActive).toList();
    final selectedValue = recipients.any((m) => m.name == state.selectedUser)
        ? state.selectedUser
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                StatusPill(
                  label: '${state.sentMessages.length} SENT MESSAGES',
                  bg: colorScheme.primary.withValues(alpha: 0.12),
                  fg: colorScheme.primary,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BROADCAST MESSAGE TO TEAM',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'RECIPIENT',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedValue,
                      hint: Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Choose a staff recipient...',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      dropdownColor: colorScheme.surface,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      isExpanded: true,
                      onChanged: recipients.isEmpty
                          ? null
                          : (v) => notifier.selectUser(v ?? ''),
                      items: recipients
                          .map(
                            (member) => DropdownMenuItem(
                              value: member.name,
                              child: Text('${member.name} · ${member.role.toUpperCase()}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'MESSAGE BODY',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _msgController,
                  onChanged: notifier.updateMessage,
                  maxLines: 4,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type internal instructions or workshop notes here...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final delivered = await notifier.sendMessage();
                      if (!context.mounted) return;
                      if (delivered) {
                        _msgController.clear();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            delivered
                                ? 'Message delivered to staff portal.'
                                : 'Message failed. Check recipient selection.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'SEND MESSAGE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (state.sentMessages.isNotEmpty) ...[
            const SizedBox(height: 28),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'DISPATCH HISTORY',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...state.sentMessages.map(
              (msg) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MessageTile(message: msg),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
