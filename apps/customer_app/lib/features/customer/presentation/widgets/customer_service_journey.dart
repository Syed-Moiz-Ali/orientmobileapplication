import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';

/// The real workshop stage list for the active job, as a trip timeline.
///
/// Rendered only when the backend actually supplies stages — nothing is
/// synthesised, never padded to five. Each entry carries a single, complete
/// semantic label so screen readers announce `"<stage>, <state>[, <time>]"`.
/// Done stages resolve the success tone, the current one the info tone,
/// upcoming ones the neutral tone.
class CustomerServiceJourney extends StatelessWidget {
  final List<ServiceStageEntity> stages;

  const CustomerServiceJourney({super.key, required this.stages});

  @override
  Widget build(BuildContext context) {
    if (stages.isEmpty) return const SizedBox.shrink();
    final t = context.cx;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: t.stJourneyTitle),
        AppTimeline(
          entries: [
            for (final stage in stages) _entry(t, stage),
          ],
        ),
      ],
    );
  }

  AppTimelineEntry _entry(
    CustomerLocalizations t,
    ServiceStageEntity stage,
  ) {
    final label = CustomerServiceTracking.humanize(stage.name);
    final title = label.isEmpty ? t.stStageFallback : label;
    final time = stage.time?.trim() ?? '';
    final (stateLabel, tone, icon) = switch (stage.status) {
      StageStatus.done => (
        t.stDone,
        StatusColorRole.success,
        Icons.check_circle_rounded,
      ),
      StageStatus.inProgress => (
        t.stCurrent,
        StatusColorRole.info,
        Icons.loop_rounded,
      ),
      StageStatus.pending => (
        t.stUpcoming,
        StatusColorRole.neutral,
        Icons.circle_outlined,
      ),
    };
    return AppTimelineEntry(
      title: title,
      subtitle: stateLabel,
      time: time.isEmpty ? null : time,
      tone: tone,
      icon: icon,
    );
  }
}
