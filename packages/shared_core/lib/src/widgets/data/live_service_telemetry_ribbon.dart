import 'package:flutter/material.dart';
import 'package:shared_core/src/domain/job_card_status.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// The six progressive stages of the Concept A workshop journey:
/// Intake → Inspection → Parts → Labour → Quality Check → Ready.
enum ServiceStage { intake, inspection, parts, labor, quality, ready }

/// **Live service telemetry ribbon (Phase 03, Concept A).**
///
/// A 6-stage progressive journey indicator wired to the live [JobCardStatus]
/// enum. It is a *presentation* widget — it never mutates status; it resolves
/// the active stage from the status the caller already holds.
///
/// Colours, connectors and typography resolve entirely through the active
/// theme (`context.colors` / `context.semanticColors`). The ribbon flows along
/// the ambient reading direction: in Arabic RTL the first stage (Intake) sits
/// at the reading-start (right) edge. Physical stage *order* is never
/// semantically mirrored — only the layout direction changes.
class LiveServiceTelemetryRibbon extends StatelessWidget {
  /// The live job status driving the active stage.
  final JobCardStatus status;

  /// Compact density for dense cards / list rows (smaller nodes, hide labels).
  final bool compact;

  /// When false the stage labels are hidden (node + connector only).
  final bool showLabels;

  const LiveServiceTelemetryRibbon({
    super.key,
    required this.status,
    this.compact = false,
    this.showLabels = true,
  });

  /// All stages in canonical order.
  static const List<ServiceStage> stages = ServiceStage.values;

  /// Resolves the active [ServiceStage] for a live [status], or null when the job
  /// was [JobCardStatus.cancelled].
  static ServiceStage? stageFor(JobCardStatus status) => switch (status) {
    JobCardStatus.pending ||
    JobCardStatus.pendingApproval ||
    JobCardStatus.awaitingSupervisor ||
    JobCardStatus.vehicleReceived => ServiceStage.intake,
    JobCardStatus.inspected => ServiceStage.inspection,
    JobCardStatus.waitingParts => ServiceStage.parts,
    JobCardStatus.approved ||
    JobCardStatus.workAssigned ||
    JobCardStatus.inProgress ||
    JobCardStatus.waitingCustomerApproval => ServiceStage.labor,
    JobCardStatus.qualityCheck ||
    JobCardStatus.qualityCheckPassed => ServiceStage.quality,
    JobCardStatus.completed || JobCardStatus.delivered => ServiceStage.ready,
    JobCardStatus.cancelled => null,
  };

  /// Localized label for a stage.
  static String labelFor(BuildContext context, ServiceStage stage) {
    final t = SharedCoreL10n.of(context);
    return switch (stage) {
      ServiceStage.intake => t.jobStageIntake,
      ServiceStage.inspection => t.jobStageInspection,
      ServiceStage.parts => t.jobStageParts,
      ServiceStage.labor => t.jobStageLabor,
      ServiceStage.quality => t.jobStageQuality,
      ServiceStage.ready => t.jobStageReady,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = SharedCoreL10n.of(context);
    final colors = context.colors;
    final semantic = context.semanticColors;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));

    final currentIndex = stageFor(status);
    final cancelled = status == JobCardStatus.cancelled;

    final activeIndex = currentIndex == null ? -1 : stages.indexOf(currentIndex);
    final ordered = rtl ? stages.reversed.toList() : stages;

    final nodeSize = compact ? 24.0 : 30.0;
    final completedColor = semantic.success.base;
    final activeColor = colors.primary;
    final upcomingColor = colors.outline;

    Widget buildNode(ServiceStage stage) {
      final index = stages.indexOf(stage);
      final isComplete = !cancelled && activeIndex > index;
      final isActive = !cancelled && activeIndex == index;

      final Color fill;
      final Color ink;
      final Color border;
      if (isComplete) {
        fill = completedColor;
        ink = semantic.onPrimary;
        border = completedColor;
      } else if (isActive) {
        fill = activeColor;
        ink = semantic.onPrimary;
        border = activeColor;
      } else {
        fill = colors.surface;
        ink = colors.onSurfaceVariant;
        border = upcomingColor;
      }

      final Widget marker = Container(
        width: nodeSize,
        height: nodeSize,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 1.5),
        ),
        child: Center(
          child: isComplete
              ? Icon(Icons.check_rounded, size: nodeSize * 0.5, color: ink)
              : isActive
              ? Icon(Icons.circle, size: nodeSize * 0.32, color: ink)
              : Text(
                  '${index + 1}',
                  style: AppTextStyles.metadata(color: ink, arabic: arabic)
                      .copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                ),
        ),
      );

      final label = showLabels && !compact
          ? Padding(
              padding: const EdgeInsets.only(top: AppDimensions.s6),
              child: Text(
                labelFor(context, stage),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.metadata(
                  color: isActive || isComplete
                      ? colors.onSurface
                      : colors.onSurfaceVariant,
                  arabic: arabic,
                ).copyWith(fontWeight: isActive ? FontWeight.w700 : null),
              ),
            )
          : const SizedBox.shrink();

      return Semantics(
        label: '${index + 1} / ${stages.length}: ${labelFor(context, stage)}',
        selected: isActive,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [marker, label],
        ),
      );
    }

    Widget buildConnector(ServiceStage stage) {
      final index = stages.indexOf(stage);
      final isComplete = !cancelled && activeIndex > index;
      return Padding(
        padding: EdgeInsets.only(top: nodeSize / 2 - 1),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: isComplete ? completedColor : upcomingColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
          ),
        ),
      );
    }

    if (cancelled) {
      return Semantics(
        label: t.jobStageCancelled,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s12,
            vertical: AppDimensions.s10,
          ),
          decoration: BoxDecoration(
            color: semantic.danger.subtle,
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            border: Border.all(color: semantic.danger.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel_outlined,
                size: AppDimensions.iconSm,
                color: semantic.danger.base,
              ),
              const SizedBox(width: AppDimensions.s8),
              Flexible(
                child: Text(
                  t.jobStageCancelled,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyRegular(
                    color: semantic.danger.ink,
                    arabic: AppTypography.isArabic(
                      Localizations.maybeLocaleOf(context),
                    ),
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < ordered.length; i++) {
      children.add(buildNode(ordered[i]));
      if (i != ordered.length - 1) {
        children.add(
          Expanded(child: buildConnector(ordered[i])),
        );
      }
    }

    return Semantics(
      label:
          '${labelFor(context, currentIndex ?? ServiceStage.intake)} '
          '(stage ${activeIndex + 1} of ${stages.length})',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
