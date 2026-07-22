import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/widgets/app_card.dart';
import 'package:orientmobileapplication/core/widgets/app_top_bar.dart';
import 'package:orientmobileapplication/core/widgets/status_pill.dart';
import 'package:orientmobileapplication/features/customer/domain/entities/customer_entities.dart';

class CustomerServiceStatusView extends ConsumerWidget {
  const CustomerServiceStatusView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = CustomerServiceEntity.mock;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'Job Tracker',
              trailing: StatusPill(
                label: '\u25cf Live',
                bg: AppColors.successBg,
                fg: AppColors.success,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s18,
                  AppDimensions.s18,
                  AppDimensions.s18,
                  AppDimensions.s32,
                ),
                child: Column(
                  children: [
                    AppCard(
                      color: AppColors.primary,
                      borderColor: AppColors.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.r12,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.build_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.s12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      svc.jobCardId,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white60,
                                        letterSpacing: .3,
                                      ),
                                    ),
                                    Text(
                                      svc.service,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .18),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.rPill,
                                  ),
                                ),
                                child: const Text(
                                  'In Service',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s14),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: AppDimensions.s14),
                          Row(
                            children: [
                              _MetaItem(
                                label: 'Vehicle',
                                value: svc.vehicleName,
                              ),
                              _MetaItem(label: 'Plate', value: svc.plateNumber),
                              _MetaItem(label: 'Started', value: svc.started),
                              _MetaItem(
                                label: 'Est. Ready',
                                value: svc.estCompletion,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s14),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Overall Progress',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${svc.progressPercent}%',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.rPill,
                            ),
                            child: LinearProgressIndicator(
                              value: svc.progressPercent / 100,
                              minHeight: 9,
                              backgroundColor: AppColors.bg,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s8),
                          Row(
                            children: [
                              const Icon(
                                Icons.radio_button_checked,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppDimensions.s6),
                              Text(
                                'Current: ${svc.currentStage}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.text3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s14),

                    AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.infoBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.info,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Technician',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.text3,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.s4),
                                Text(
                                  svc.technicianName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _IconBtn(
                            icon: Icons.call_rounded,
                            color: AppColors.success,
                            bg: AppColors.successBg,
                            onTap: () {},
                          ),
                          const SizedBox(width: AppDimensions.s8),
                          _IconBtn(
                            icon: Icons.chat_bubble_outline_rounded,
                            color: AppColors.primary,
                            bg: AppColors.primaryBg,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s14),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service Stages',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          ...svc.stages.asMap().entries.map(
                            (e) => _StageItem(
                              stage: e.value,
                              isLast: e.key == svc.stages.length - 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s14),

                    Container(
                      padding: const EdgeInsets.all(AppDimensions.s14),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                        border: Border.all(color: AppColors.successBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            color: AppColors.success,
                            size: 17,
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Expanded(
                            child: Text(
                              'Auto-refreshes every 2 minutes. SMS alerts for major milestones.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54)),
        const SizedBox(height: AppDimensions.s4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.r10),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
  );
}

class _StageItem extends StatelessWidget {
  final ServiceStageEntity stage;
  final bool isLast;
  const _StageItem({required this.stage, required this.isLast});

  (Color, Color, IconData) get _props {
    switch (stage.status) {
      case StageStatus.done:
        return (AppColors.success, AppColors.successBg, Icons.check_rounded);
      case StageStatus.inProgress:
        return (
          AppColors.primary,
          AppColors.primaryBg,
          Icons.arrow_forward_rounded,
        );
      case StageStatus.pending:
        return (AppColors.text4, AppColors.bg, Icons.circle_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = _props;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: .3)),
                ),
                child: Icon(icon, color: color, size: 13),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: stage.status == StageStatus.done
                        ? AppColors.successBorder
                        : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.s14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: stage.status == StageStatus.pending
                                ? AppColors.text3
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (stage.time != null)
                          Text(
                            stage.time!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.text3,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (stage.status == StageStatus.inProgress)
                    StatusPill(label: 'Active')
                  else if (stage.status == StageStatus.done)
                    StatusPill(
                      label: 'Done',
                      bg: AppColors.successBg,
                      fg: AppColors.success,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
