import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/section_card.dart';

class AttendanceSection extends ConsumerWidget {
  const AttendanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final status = state.attendanceStatus;
    final s = state.attendanceSummary;

    return SectionCard(
      title: 'Attendance',
      icon: Icons.access_time_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.s12,
                  vertical: AppDimensions.s6,
                ),
                decoration: BoxDecoration(
                  color: status.bgColor,
                  borderRadius: BorderRadius.circular(AppDimensions.r20),
                  border: Border.all(
                    color: status.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppDimensions.s6),
                    Text(
                      status.label,
                      style: AppTextStyles.bodyStrong(color: status.color),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (status == AttendanceStatus.notPunchedIn)
                _AttBtn(
                  label: 'Punch In',
                  icon: Icons.login_rounded,
                  color: AppColors.success,
                  onTap: notifier.punchIn,
                ),
              if (status == AttendanceStatus.working) ...[
                _AttBtn(
                  label: 'Break',
                  icon: Icons.coffee_rounded,
                  color: AppColors.warning,
                  onTap: notifier.startBreak,
                ),
                SizedBox(width: AppDimensions.s8),
                _AttBtn(
                  label: 'Punch Out',
                  icon: Icons.logout_rounded,
                  color: AppColors.danger,
                  onTap: notifier.punchOut,
                ),
              ],
              if (status == AttendanceStatus.onBreak)
                _AttBtn(
                  label: 'End Break',
                  icon: Icons.play_arrow_rounded,
                  color: AppColors.success,
                  onTap: notifier.endBreak,
                ),
              if (status == AttendanceStatus.punchedOut)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.s12,
                    vertical: AppDimensions.s6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                  ),
                  child: Text(
                    'Shift Ended',
                    style: AppTextStyles.bodyStrong(color: AppColors.text3),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppDimensions.s16),
          Row(
            children: [
              _AttCell(
                label: 'Punch In',
                value: s.punchIn,
                icon: Icons.login_rounded,
                color: AppColors.success,
              ),
              _vDivider(),
              _AttCell(
                label: 'Punch Out',
                value: s.punchOut,
                icon: Icons.logout_rounded,
                color: AppColors.danger,
              ),
              _vDivider(),
              _AttCell(
                label: 'Break',
                value: s.breakTime,
                icon: Icons.coffee_rounded,
                color: AppColors.warning,
              ),
              _vDivider(),
              _AttCell(
                label: 'Work Hrs',
                value: s.workHours,
                icon: Icons.timer_rounded,
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
    width: 1,
    height: 40,
    color: AppColors.border,
    margin: EdgeInsets.symmetric(horizontal: AppDimensions.s4),
  );
}

class _AttBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AttBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.s12,
          vertical: AppDimensions.s8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimensions.r10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            SizedBox(width: AppDimensions.s4),
            Text(label, style: AppTextStyles.bodyStrong(color: color)),
          ],
        ),
      ),
    );
  }
}

class _AttCell extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _AttCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(height: AppDimensions.s4),
          Text(
            value,
            style: AppTextStyles.label(color: AppColors.textPrimary),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall(color: AppColors.text3),
          ),
        ],
      ),
    );
  }
}
