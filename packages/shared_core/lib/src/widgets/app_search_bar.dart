import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_tokens.dart';
import 'package:shared_core/src/widgets/app_icon_button.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Spec search bar, phase-1b name `AppSearchBar`.
///
/// Named `AppSearchBar` (not `AppSearchField`) because the legacy
/// `AppSearchField` owns the closest name and is off-limits in phase 1.
/// Rename path: same codemod story as `AppPillButton` (see `app_input_field`).
///
/// Pill radius, search icon prefix, clear button, height 48. Clear appears
/// only while text is present; tapping it empties the field and keeps focus.
/// LTR-locked query text with physical-left alignment (same rationale as
/// [AppInputField.forceLtr], always on for search).
///
/// ```dart
/// AppSearchBar(hint: 'Search bookings', onChanged: filter)
/// ```
class AppSearchBar extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onText);
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onText() {
    if (mounted) setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppTokens.of(context);
    final scheme = theme.colorScheme;

    final border = (Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: color, width: width),
        );

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.4,
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 12,
            ),
            border: border(tokens.inputBorder, 1),
            enabledBorder: border(tokens.inputBorder, 1),
            focusedBorder: border(scheme.primary, 1.5),
            disabledBorder: border(scheme.outline, 1),
            prefixIcon: DirectionalIcon(
              Icons.search_rounded,
              size: 20,
              color: scheme.onSurfaceVariant,
              mirrorInRtl: false,
            ),
            suffixIcon: _controller.text.isEmpty
                ? null
                : SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: AppIconButton(
                        icon: Icons.clear_rounded,
                        onPressed: widget.enabled
                            ? () {
                                _controller.clear();
                                widget.onChanged?.call('');
                              }
                            : null,
                        tooltip: 'Clear search',
                        mirrorInRtl: false,
                      ),
                    ),
                  ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
          keyboardType: TextInputType.text,
          textInputAction: widget.textInputAction ?? TextInputAction.search,
          onSubmitted: widget.onSubmitted,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          // Queries stay LTR with physical-left alignment (same rationale
          // as AppInputField.forceLtr — always on for search).
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
