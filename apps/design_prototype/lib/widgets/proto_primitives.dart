// Prototype-local renderings of the Phase 01 primitives named in
// `00_DESIGN_SYSTEM_SPEC.md` §7. These make the spec renderable today; the
// component checklist in README.md maps each one to its Phase 03A/03B target.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/prototype_theme.dart';
import '../design/provisional_tokens.dart';
import '../l10n/provisional_strings.dart';

/// Tone for pills, banners and badges - semantic, never decorative.
enum ProtoTone { neutral, primary, success, warning, danger, info, navy }

extension ProtoToneColors on ProtoTone {
  Color fg(ProtoPalette p) => switch (this) {
        ProtoTone.neutral => p.textSecondary,
        ProtoTone.primary => p.primary,
        ProtoTone.success => p.success,
        ProtoTone.warning => p.warning,
        ProtoTone.danger => p.danger,
        ProtoTone.info => p.info,
        ProtoTone.navy => p.textInverse,
      };

  Color bg(ProtoPalette p) => switch (this) {
        ProtoTone.neutral => p.surfaceSunken,
        ProtoTone.primary => p.primarySubtle,
        ProtoTone.success => p.successSubtle,
        ProtoTone.warning => p.warningSubtle,
        ProtoTone.danger => p.dangerSubtle,
        ProtoTone.info => p.infoSubtle,
        ProtoTone.navy => p.navy,
      };

  Color border(ProtoPalette p) => switch (this) {
        ProtoTone.neutral => p.borderDefault,
        ProtoTone.primary => p.primaryBorder,
        ProtoTone.success => p.successBorder,
        ProtoTone.warning => p.warningBorder,
        ProtoTone.danger => p.dangerBorder,
        ProtoTone.info => p.infoBorder,
        ProtoTone.navy => p.navyRaised,
      };
}

/// Icon that mirrors with reading direction (back, chevrons, arrows) while
/// non-directional icons never flip (spec §9.3).
class ProtoDirIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const ProtoDirIcon(this.icon, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: context.isRtl,
      child: Icon(icon, size: size, color: color),
    );
  }
}

/// Standard content card: white surface, 1px hairline border, whisper
/// elevation only (spec §2 / V1).
class ProtoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final ProtoTone? tone;
  final bool interactive;
  final VoidCallback? onTap;
  final double radius;

  const ProtoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ProtoSpace.s16),
    this.tone,
    this.interactive = false,
    this.onTap,
    this.radius = ProtoRadius.card,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = tone == null ? p.surface : tone!.bg(p);
    final border = tone == null ? p.borderDefault : tone!.border(p);

    final content = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      padding: padding,
      child: child,
    );

    if (!interactive && onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        hoverColor: p.hover,
        child: content,
      ),
    );
  }
}

/// Eyebrow → title → optional trailing action (spec §C hierarchy pillar).
class ProtoSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const ProtoSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow.isNotEmpty)
                Text(
                  context.isRtl ? eyebrow : eyebrow.toUpperCase(),
                  style: types.eyebrow.copyWith(color: p.primary),
                ),
              if (eyebrow.isNotEmpty) const SizedBox(height: ProtoSpace.s4),
              Text(title, style: types.sectionTitle.copyWith(color: p.textPrimary)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

/// Status pill - status is always encoded by text + color, never color alone.
class ProtoStatusPill extends StatelessWidget {
  final String label;
  final ProtoTone tone;
  final bool showDot;
  final bool compact;

  const ProtoStatusPill({
    super.key,
    required this.label,
    this.tone = ProtoTone.neutral,
    this.showDot = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = tone.fg(p);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? ProtoSpace.s8 : ProtoSpace.s10,
        vertical: compact ? 3 : ProtoSpace.s6,
      ),
      decoration: BoxDecoration(
        color: tone.bg(p),
        borderRadius: BorderRadius.circular(ProtoRadius.pill),
        border: Border.all(color: tone.border(p)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: ProtoSpace.s6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (compact ? context.types.metadata : context.types.label)
                  .copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: compact ? 11 : 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Registration plate chip - mono, tabular, Latin in both locales.
class ProtoPlateChip extends StatelessWidget {
  final String plate;
  final bool large;

  const ProtoPlateChip({super.key, required this.plate, this.large = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? ProtoSpace.s12 : ProtoSpace.s8,
        vertical: large ? ProtoSpace.s6 : 3,
      ),
      decoration: BoxDecoration(
        color: p.surfaceSunken,
        borderRadius: BorderRadius.circular(ProtoRadius.control),
        border: Border.all(color: p.borderStrong),
      ),
      child: Text(
        plate.trim().toUpperCase(),
        style: (large ? context.types.monoStrong : context.types.mono)
            .copyWith(color: p.textPrimary, letterSpacing: 0.6),
      ),
    );
  }
}

/// KPI tile (spec §7 `AppKpiCard`): tappable to its source list, never
/// decorative. One navy hero tile is allowed per screen (V2).
class ProtoKpiTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final bool hero;
  final VoidCallback? onTap;

  const ProtoKpiTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    this.hero = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final fg = hero ? p.textInverse : p.textPrimary;
    final subColor = hero ? p.onNavySecondary : p.textMuted;
    final iconFg = hero ? const Color(0xFF9DB4FF) : p.primary;

    return Material(
      color: hero ? p.navy : p.surface,
      borderRadius: BorderRadius.circular(ProtoRadius.panel),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProtoRadius.panel),
        hoverColor: hero ? p.navyRaised : p.hover,
        child: Container(
          padding: const EdgeInsets.all(ProtoSpace.s16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ProtoRadius.panel),
            border: Border.all(color: hero ? p.navyRaised : p.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: hero ? p.navyRaised : p.primarySubtle,
                      borderRadius: BorderRadius.circular(ProtoRadius.control),
                    ),
                    child: Icon(icon, size: 18, color: iconFg),
                  ),
                  const Spacer(),
                  Flexible(
                    child: ProtoDirIcon(
                      Icons.arrow_outward_rounded,
                      size: 15,
                      color: hero ? p.onNavySecondary : p.textDisabled,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ProtoSpace.s12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  maxLines: 1,
                  style: types.metric.copyWith(color: fg),
                ),
              ),
              const SizedBox(height: ProtoSpace.s4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: types.bodyStrong.copyWith(color: hero ? p.textInverse : p.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: types.caption.copyWith(color: subColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty / no-match / error states are distinct surfaces (spec §16
/// anti-pattern: never a spinner-only full page, never silent failure).
class ProtoEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ProtoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(ProtoSpace.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: p.surfaceSunken,
                  borderRadius: BorderRadius.circular(ProtoRadius.panel),
                  border: Border.all(color: p.borderDefault),
                ),
                child: Icon(icon, color: p.textMuted, size: 24),
              ),
              const SizedBox(height: ProtoSpace.s16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: types.cardTitle.copyWith(color: p.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: ProtoSpace.s6),
              Text(
                body,
                textAlign: TextAlign.center,
                style: types.bodySmall.copyWith(color: p.textMuted),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: ProtoSpace.s16),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline error banner with the retry actually wired (spec §7 `ErrorView`).
class ProtoErrorBanner extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onRetry;

  const ProtoErrorBanner({
    super.key,
    required this.title,
    required this.body,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Container(
      padding: const EdgeInsets.all(ProtoSpace.s14),
      decoration: BoxDecoration(
        color: p.dangerSubtle,
        borderRadius: BorderRadius.circular(ProtoRadius.card),
        border: Border.all(color: p.dangerBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_off_rounded, color: p.danger, size: 20),
          const SizedBox(width: ProtoSpace.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: types.bodyStrong.copyWith(color: p.textPrimary)),
                const SizedBox(height: 2),
                Text(body, style: types.bodySmall.copyWith(color: p.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: ProtoSpace.s8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: p.danger),
            child: Text(context.s('common.retry')),
          ),
        ],
      ),
    );
  }
}

/// Info panel for honest offline/queued copy (spec §7 `AppInfoPanel`).
class ProtoInfoPanel extends StatelessWidget {
  final ProtoTone tone;
  final IconData icon;
  final String text;
  final Widget? trailing;

  const ProtoInfoPanel({
    super.key,
    required this.tone,
    required this.icon,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s10),
      decoration: BoxDecoration(
        color: tone.bg(p),
        borderRadius: BorderRadius.circular(ProtoRadius.card),
        border: Border.all(color: tone.border(p)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: tone.fg(p)),
          const SizedBox(width: ProtoSpace.s10),
          Expanded(
            child: Text(
              text,
              style: context.types.bodySmall.copyWith(color: p.textSecondary),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Pulsing skeleton that mirrors the final layout; static under reduced motion.
class ProtoSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const ProtoSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = ProtoRadius.sm,
  });

  @override
  State<ProtoSkeleton> createState() => _ProtoSkeletonState();
}

class _ProtoSkeletonState extends State<ProtoSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = reduceMotion ? 0.4 : Curves.easeInOut.transform(_controller.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(p.surfaceSunken, p.borderDefault, 0.25 + 0.4 * t),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

/// Search field used by every listing (spec §7 `AppSearchField`).
class ProtoSearchField extends StatefulWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged; // ignore: avoid_positional_boolean_parameters
  final FocusNode? focusNode;

  const ProtoSearchField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.focusNode,
  });

  @override
  State<ProtoSearchField> createState() => _ProtoSearchFieldState();
}

class _ProtoSearchFieldState extends State<ProtoSearchField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(ProtoSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: context.s('common.close'),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: ProtoSpace.s12),
        ),
      ),
    );
  }
}

/// Filter chip with the shared selection language (cobalt tint + weight).
class ProtoFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  const ProtoFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: selected ? p.primary : p.surface,
      borderRadius: BorderRadius.circular(ProtoRadius.pill),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(ProtoRadius.pill),
        hoverColor: selected ? p.primaryHover : p.hover,
        child: AnimatedContainer(
          duration: ProtoMotion.fast,
          curve: ProtoMotion.enter,
          padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s16, vertical: ProtoSpace.s8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ProtoRadius.pill),
            border: Border.all(color: selected ? p.primary : p.borderDefault),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                const SizedBox(width: ProtoSpace.s6),
              ],
              Text(
                label,
                style: context.types.label.copyWith(
                  fontSize: 12,
                  color: selected ? Colors.white : (disabled ? p.textDisabled : p.textSecondary),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick-action tile: icon + label (+ subtitle), uniform hit area ≥48 px.
/// Labels wrap to two lines so long Arabic action names are never truncated
/// mid-word; the trailing chevron is a desktop hover affordance and is dropped
/// on compact grids where the text needs the room.
class ProtoActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  const ProtoActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(ProtoRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProtoRadius.card),
        hoverColor: p.hover,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s14, vertical: ProtoSpace.s12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ProtoRadius.card),
            border: Border.all(color: p.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: p.primarySubtle,
                  borderRadius: BorderRadius.circular(ProtoRadius.control),
                ),
                child: Icon(icon, size: 19, color: p.primary),
              ),
              const SizedBox(width: ProtoSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: types.cardTitle.copyWith(color: p.textPrimary, fontSize: 13.5, height: 1.25),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: types.metadata.copyWith(color: p.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: ProtoSpace.s6),
                ProtoDirIcon(Icons.chevron_right_rounded, size: 18, color: p.textDisabled),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Label/value row used in summaries and detail sidebars.
class ProtoKeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Widget? valueWidget;

  const ProtoKeyValueRow({
    super.key,
    required this.label,
    this.value = '',
    this.valueStyle,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ProtoSpace.s6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: types.bodySmall.copyWith(color: p.textMuted)),
          ),
          const SizedBox(width: ProtoSpace.s12),
          if (valueWidget != null)
            valueWidget!
          else
            Flexible(
              // Identifiers (VIN, plate, refs) must never wrap mid-string:
              // scale down instead of breaking across lines.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  value,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.end,
                  style: valueStyle ?? types.bodyStrong.copyWith(color: p.textPrimary, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Directional linear progress with the copy underneath (spec §7).
class ProtoProgress extends StatelessWidget {
  final double value;
  final String label;
  final double height;

  const ProtoProgress({
    super.key,
    required this.value,
    required this.label,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(ProtoRadius.pill),
          child: LinearProgressIndicator(
            value: value,
            minHeight: height,
            backgroundColor: p.surfaceSunken,
            valueColor: AlwaysStoppedAnimation(p.primary),
          ),
        ),
        const SizedBox(height: ProtoSpace.s6),
        Text(label, style: context.types.metadata.copyWith(color: p.textMuted)),
      ],
    );
  }
}

/// Kebab / overflow menu for dense rows (desktop tables).
class ProtoKebabMenu extends StatelessWidget {
  final List<({String label, IconData icon, VoidCallback onSelect, bool destructive})> items;

  const ProtoKebabMenu({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return PopupMenuButton<int>(
      tooltip: context.s('common.details'),
      icon: Icon(Icons.more_vert_rounded, size: 20, color: p.textMuted),
      offset: const Offset(0, 24),
      itemBuilder: (context) => [
        for (var i = 0; i < items.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                Icon(
                  items[i].icon,
                  size: 18,
                  color: items[i].destructive ? p.danger : p.textMuted,
                ),
                const SizedBox(width: ProtoSpace.s10),
                Text(
                  items[i].label,
                  style: context.types.body.copyWith(
                    color: items[i].destructive ? p.danger : p.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
      onSelected: (index) => items[index].onSelect(),
    );
  }
}

/// Notification bell with a count badge (spec §7 `NotificationBell`).
class ProtoNotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const ProtoNotificationBell({super.key, this.count = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: context.s('dashboard.notifications'),
      child: IconButton(
        onPressed: onTap,
        icon: SizedBox(
          width: 26,
          height: 26,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(Icons.notifications_none_rounded, size: 22, color: p.textSecondary),
              ),
              if (count > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: p.danger,
                      borderRadius: BorderRadius.circular(ProtoRadius.pill),
                      border: Border.all(color: p.surface, width: 1.5),
                    ),
                    child: Text(
                      '$count',
                      style: context.types.metadata.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Identity avatar - initials 28–72 (spec §7 `UserAvatar`).
class ProtoAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final VoidCallback? onTap;

  const ProtoAvatar({super.key, required this.initials, this.size = 36, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.primarySubtle,
      shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: p.primaryBorder),
          ),
          child: Text(
            initials,
            style: context.types.label.copyWith(
              color: p.primary,
              fontSize: math.min(14, size * 0.38),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// Page toolbar shared by pushed prototype screens: back + title (+subtitle)
/// + trailing actions (spec §7 `AppTopBar`).
class ProtoTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget? bottom;

  const ProtoTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions = const [],
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.borderDefault)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  if (onBack != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: ProtoSpace.s8, end: ProtoSpace.s4),
                      child: Tooltip(
                        message: context.s('common.back'),
                        child: IconButton(
                          onPressed: onBack,
                          icon: ProtoDirIcon(Icons.arrow_back_rounded, size: 22, color: p.textPrimary),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: ProtoSpace.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: types.pageTitle.copyWith(color: p.textPrimary),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: types.metadata.copyWith(color: p.textMuted),
                          ),
                      ],
                    ),
                  ),
                  ...actions,
                  const SizedBox(width: ProtoSpace.s8),
                ],
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}

/// Form field with the label-above pattern (spec §12): label row with a
/// single consistent marker, control, helper OR inline error below.
/// [ltrContent] enforces the identifier policy (plate/VIN/phone keep Latin
/// LTR content inside an Arabic layout - spec L6).
class ProtoField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final String? helperText;
  final String? errorText;
  final String? marker; // 'Required' / 'Optional' / null
  final bool ltrContent;
  final bool obscureText;
  final int maxLines;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final VoidCallback? onToggleObscure;

  const ProtoField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.helperText,
    this.errorText,
    this.marker,
    this.ltrContent = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.suffix,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: types.label.copyWith(
                  color: hasError ? p.danger : p.textSecondary,
                ),
              ),
            ),
            if (marker != null)
              Text(
                marker!,
                style: types.metadata.copyWith(
                  color: hasError ? p.danger : p.textDisabled,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(height: ProtoSpace.s6),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          textDirection: ltrContent ? TextDirection.ltr : null,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 19),
            suffix: suffix,
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    tooltip: obscureText ? context.s('login.showPassword') : context.s('login.hidePassword'),
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 19,
                    ),
                  ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: ProtoSpace.s6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded, size: 14, color: p.danger),
              const SizedBox(width: ProtoSpace.s6),
              Expanded(
                child: Text(
                  errorText!,
                  style: types.caption.copyWith(color: p.danger, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: ProtoSpace.s6),
          Text(helperText!, style: types.caption.copyWith(color: p.textMuted)),
        ],
      ],
    );
  }
}

/// Adaptive modal: bottom sheet on compact, centered bounded dialog ≥600 px
/// (spec §5 `showAppModalSheet` behavior). Returns the value the child pops
/// with.
Future<T?> showProtoSheet<T>(BuildContext context, {required Widget child}) {
  final wide = MediaQuery.sizeOf(context).width >= 600;
  if (wide) {
    return showDialog<T>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child,
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => child,
  );
}

/// Content column capped like `AppPageFrame` (spec §5): gutters by window
/// class, max width for desktop, form cap where supplied.
class ProtoPageFrame extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const ProtoPageFrame({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final windowClass = context.windowClass;
    final gutter = switch (windowClass) {
      ProtoWindowClass.compact => ProtoSpace.gutterCompact,
      ProtoWindowClass.medium => ProtoSpace.gutterMedium,
      _ => ProtoSpace.gutterExpanded,
    };
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? ProtoSpace.contentWide),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: gutter),
          child: child,
        ),
      ),
    );
  }
}
