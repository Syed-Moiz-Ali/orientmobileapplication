import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';

class JobSearchBar extends ConsumerWidget {
  final VoidCallback? onJobFound;

  const JobSearchBar({super.key, this.onJobFound});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);

    void submit() {
      notifier.searchJobCard();
      if (ref.read(technicianDashboardProvider).selectedJob != null) {
        onJobFound?.call();
      }
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: notifier.jobCardController,
            onChanged: (_) => notifier.clearQuickJobError(),
            onSubmitted: (_) => submit(),
            textInputAction: TextInputAction.search,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter job card number',
              prefixIcon: const Icon(Icons.search_rounded),
              errorText: state.quickJobError.isNotEmpty ? state.quickJobError : null,
            ),
          ),
        ),
        SizedBox(width: AppDimensions.s10),
        FilledButton(
          onPressed: submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 52),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('Find'),
        ),
      ],
    );
  }
}
