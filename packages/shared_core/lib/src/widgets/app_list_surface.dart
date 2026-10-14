import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_density.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/app_skeleton.dart';
import 'package:shared_core/src/widgets/empty_state.dart';
import 'package:shared_core/src/widgets/error_view.dart';

/// **List-surface recipe (Phase 03B, spec §7 / §10).**
///
/// Every scrollable list surface presents the same four states in the same
/// order, using the same widgets — feature screens must not hand-roll these:
///
/// | State | Widget |
/// |---|---|
/// | First load | [AppSkeleton.listRows] (`skeletonRows`), or a caller [skeletonBuilder] mirroring the final layout |
/// | Empty (no data yet) | [EmptyState] (`emptyTitle` + `emptyMessage`) |
/// | No-match (search/filter) | [EmptyState.noMatch] (`noMatchMessage`) |
/// | Error | [ErrorView] (`errorMessage` + `errorDetails`) with a retry that **re-runs** the fetch |
/// | Loaded | the caller's `child` |
///
/// When [onRefresh] is supplied the whole surface is wrapped in a
/// [RefreshIndicator]; non-scrolling states (loading/empty/no-match/error) are
/// made pullable so refresh is always available.
///
/// Presentation only — it never performs I/O; the caller owns fetching.
class AppListSurface extends StatelessWidget {
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final String? errorDetails;
  final VoidCallback? onRetry;

  final bool isEmpty;
  final bool isNoMatch;
  final String? emptyTitle;
  final String? emptyMessage;
  final String? noMatchMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  /// The loaded content (expected to be scrollable when [onRefresh] is set).
  final Widget child;

  final Future<void> Function()? onRefresh;

  /// Optional custom first-load skeleton that mirrors the final layout.
  final Widget Function(BuildContext context)? skeletonBuilder;
  final int skeletonRows;
  final ScrollPhysics? physics;

  const AppListSurface({
    super.key,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.errorDetails,
    this.onRetry,
    this.isEmpty = false,
    this.isNoMatch = false,
    this.emptyTitle,
    this.emptyMessage,
    this.noMatchMessage,
    this.emptyActionLabel,
    this.onEmptyAction,
    required this.child,
    this.onRefresh,
    this.skeletonBuilder,
    this.skeletonRows = 6,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final t = SharedCoreL10n.of(context);
    // Phase 01.2 density: first-load skeleton padding follows the active mode.
    final density = context.density;
    final skeletonPadding = EdgeInsets.all(
      density.isCompact ? AppDimensions.s8 : AppDimensions.s12,
    );

    final Widget state;
    final bool contentIsScrollable;
    if (isLoading) {
      state = skeletonBuilder != null
          ? skeletonBuilder!(context)
          : Padding(
              padding: skeletonPadding,
              child: AppSkeleton.listRows(rows: skeletonRows),
            );
      contentIsScrollable = false;
    } else if (isError) {
      state = ErrorView(
        message: errorMessage ?? t.commonErrorTitle,
        details: errorDetails,
        onRetry: onRetry,
      );
      contentIsScrollable = false;
    } else if (isNoMatch) {
      state = EmptyState.noMatch(
        message: noMatchMessage ?? t.commonNoResults,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction,
      );
      contentIsScrollable = false;
    } else if (isEmpty) {
      state = EmptyState(
        title: emptyTitle,
        message: emptyMessage ?? t.commonNoData,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction,
      );
      contentIsScrollable = false;
    } else {
      state = child;
      contentIsScrollable = true;
    }

    if (onRefresh == null) return state;

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: contentIsScrollable ? state : _makePullable(state),
    );
  }

  /// Wraps a non-scrolling state so pull-to-refresh still works.
  Widget _makePullable(Widget state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: state),
          ),
        );
      },
    );
  }
}
