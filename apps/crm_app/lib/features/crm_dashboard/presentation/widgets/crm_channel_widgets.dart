import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

class CrmChannelGrid extends StatelessWidget {
  final List<CrmChannelEntity> channels;
  const CrmChannelGrid({super.key, required this.channels});

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    return AppAdaptiveGrid(
      columns: adaptive.pick(compact: 2, medium: 2, expanded: 2, large: 2),
      minChildWidth: adaptive.isCompact ? 140 : 210,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      childAspectRatio: adaptive.pick(
        compact: 2.15,
        medium: 2.6,
        expanded: 2.8,
        large: 3.0,
      ),
      children: [
        for (final channel in channels) _CrmChannelCard(channel: channel),
      ],
    );
  }
}

class _CrmChannelCard extends StatelessWidget {
  final CrmChannelEntity channel;
  const _CrmChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: CrmColors.border),
        boxShadow: [
          BoxShadow(
            color: CrmColors.primary.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: channel.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Icon(channel.icon, color: channel.color, size: 17),
          ),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  channel.value,
                  style: const TextStyle(
                    color: CrmColors.textH,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  channel.label,
                  style: const TextStyle(
                    color: CrmColors.textM,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '\u2191 ${channel.trend}',
            style: TextStyle(
              color: channel.trendUp ? CrmColors.green : CrmColors.red,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
