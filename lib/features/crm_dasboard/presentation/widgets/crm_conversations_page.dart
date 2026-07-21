import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/crm_constants.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/providers/crm_ui_provider.dart';
import 'package:orientmobileapplication/features/crm_dasboard/domain/entities/crm_entities.dart';

class CrmConversationsPage extends ConsumerWidget {
  const CrmConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.read(crmUiProvider.notifier);
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.s16),
      itemCount: ui.conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.s10),
      itemBuilder: (_, i) => _CrmConversationCard(conv: ui.conversations[i]),
    );
  }
}

class _CrmConversationCard extends StatelessWidget {
  final ConversationEntity conv;
  const _CrmConversationCard({required this.conv});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(
          color: conv.unread > 0
              ? CrmColors.accent.withValues(alpha: 0.3)
              : CrmColors.border,
          width: conv.unread > 0 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CrmColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [conv.channelColor.withValues(alpha: 0.8), conv.channelColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                conv.customerName[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      conv.customerName,
                      style: const TextStyle(
                        color: CrmColors.textH,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      conv.time,
                      style: const TextStyle(
                        color: CrmColors.textM,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  conv.lastMessage,
                  style: const TextStyle(
                    color: CrmColors.textM,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.s8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: conv.channelColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6)),
                      ),
                      child: Text(
                        conv.channel,
                        style: TextStyle(
                          color: conv.channelColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (conv.unread > 0)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: CrmColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${conv.unread}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
