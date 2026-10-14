import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Concept A search input: 8 px chamfer, recessed neutral fill, leading search
/// glyph, instant clear affordance, and an optional desktop keyboard-shortcut
/// badge (e.g. `⌘K`).
class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;

  /// Hint text. When null it resolves to the localized "Search".
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  /// Optional keyboard-shortcut hint rendered as a trailing badge on wide
  /// layouts (e.g. `⌘K`, `Ctrl K`). Hidden when the field has text.
  final String? shortcutLabel;

  const AppSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.shortcutLabel,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(
      oldWidget.controller == widget.controller,
      'Changing AppSearchField.controller after creation is not supported.',
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = SharedCoreL10n.of(context);
    final hasText = _controller.text.isNotEmpty;

    Widget? suffix;
    if (hasText) {
      suffix = IconButton(
        tooltip: t.commonClearSearch,
        onPressed: _clear,
        icon: const Icon(Icons.close_rounded),
      );
    } else if (widget.shortcutLabel != null) {
      suffix = Padding(
        padding: const EdgeInsetsDirectional.only(end: AppDimensions.s10),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            border: Border.all(color: semantic.borderDefault),
          ),
          child: Text(
            widget.shortcutLabel!,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText ?? t.commonSearchHint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: suffix,
        constraints: const BoxConstraints(minHeight: AppDimensions.touchTarget),
        fillColor: semantic.surfaceSunken,
      ),
    );
  }
}
