import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// A single command offered by [AppCommandPalette].
class AppCommand {
  final String id;
  final String label;
  final String? hint;
  final IconData icon;
  final VoidCallback onSelected;

  const AppCommand({
    required this.id,
    required this.label,
    this.hint,
    this.icon = Icons.bolt_outlined,
    required this.onSelected,
  });
}

/// Omnichannel command palette (Phase 01.2 foundation primitive).
///
/// A searchable list of [commands] with live filtering, keyboard-first focus
/// and an empty state. Pair with `WorkspaceAppBar.onSearch` /
/// `WorkspaceSearchShortcuts` for the ⌘K / Ctrl+K entry point.
///
/// Use [showAppCommandPalette] to present it as a dialog on wide screens and
/// a bottom sheet on compact screens.
class AppCommandPalette extends StatefulWidget {
  final List<AppCommand> commands;
  final ValueChanged<AppCommand>? onSelected;
  final String? hint;

  const AppCommandPalette({
    super.key,
    required this.commands,
    this.onSelected,
    this.hint,
  });

  @override
  State<AppCommandPalette> createState() => _AppCommandPaletteState();
}

class _AppCommandPaletteState extends State<AppCommandPalette> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = SharedCoreL10n.of(context);

    final query = _query.trim().toLowerCase();
    final matches = query.isEmpty
        ? widget.commands
        : widget.commands
            .where((c) =>
                c.label.toLowerCase().contains(query) ||
                (c.hint?.toLowerCase().contains(query) ?? false))
            .toList();

    return Semantics(
      container: true,
      label: widget.hint ?? t.commandPaletteHint,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: widget.hint ?? t.commandPaletteHint,
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: semantic.surfaceSunken,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusControl),
                borderSide: BorderSide(color: semantic.borderDefault),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusControl),
                borderSide: BorderSide(color: semantic.borderDefault),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusControl),
                borderSide: BorderSide(
                  color: semantic.focusRing,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          if (matches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.s20),
              child: Text(
                t.commandPaletteEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: matches.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: colors.outline,
                ),
                itemBuilder: (context, i) {
                  final cmd = matches[i];
                  return ListTile(
                    leading: Icon(cmd.icon, color: colors.primary),
                    title: Text(
                      cmd.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: cmd.hint == null
                        ? null
                        : Text(
                            cmd.hint!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: () {
                      widget.onSelected?.call(cmd);
                      cmd.onSelected();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Presents [AppCommandPalette] as a dialog (wide) or bottom sheet (compact).
Future<void> showAppCommandPalette({
  required BuildContext context,
  required List<AppCommand> commands,
  ValueChanged<AppCommand>? onSelected,
  String? hint,
}) {
  final compact = MediaQuery.sizeOf(context).width < 600;
  final sheet = Padding(
    padding: const EdgeInsets.all(AppDimensions.s16),
    child: AppCommandPalette(
      commands: commands,
      onSelected: onSelected,
      hint: hint,
    ),
  );
  if (compact) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(child: sheet),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: sheet,
      ),
    ),
  );
}
