import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

const kBlue = AppColors.primary;
const kTealLight = AppColors.cyanLight;
const kFieldBg = AppColors.canvas;
const kLabelColor = AppColors.text2;
const kHintColor = AppColors.text4;
const kTextColor = AppColors.textPrimary;
const kBorderColor = AppColors.border;

class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final Widget? trailing;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r16)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(AppDimensions.r10),
                    ),
                    child: Icon(icon, size: 19, color: AppColors.primary),
                  ),
                  const SizedBox(width: 11),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle(
                          color: kTextColor,
                        ).copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.text3, height: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.surfaceAlt),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const FieldLabel(this.label, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.label(
                color: kLabelColor,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          if (required)
            Text(' *', style: AppTextStyles.label(color: Colors.red)),
        ],
      ),
    );
  }
}

class AdvisorTextField extends StatelessWidget {
  final String hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? prefix;
  final Widget? suffix;

  /// Inline prefix rendered on the text baseline (e.g. a country code or the
  /// fixed registration prefix). Unlike [prefix], this aligns with the input.
  final Widget? inlinePrefix;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final bool filled;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsets scrollPadding;
  final String? errorText;

  const AdvisorTextField({
    super.key,
    required this.hint,
    this.initialValue,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.inlinePrefix,
    this.prefixText,
    this.inputFormatters,
    this.filled = false,
    this.readOnly = false,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.scrollPadding = const EdgeInsets.only(bottom: 140),
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      focusNode: focusNode,
      textInputAction:
          textInputAction ??
          (maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
      textCapitalization: textCapitalization,
      scrollPadding: scrollPadding,
      onFieldSubmitted: onFieldSubmitted,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: kTextColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        errorText: errorText,
        errorMaxLines: 2,
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: kHintColor,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefix,
        prefix: inlinePrefix,
        prefixText: prefixText,
        prefixStyle: theme.textTheme.bodyMedium?.copyWith(
          color: kTextColor,
          fontWeight: FontWeight.w600,
        ),
        suffixIcon: suffix,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: filled ? kTealLight : kFieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          borderSide: errorText == null
              ? BorderSide.none
              : BorderSide(color: theme.colorScheme.error, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          borderSide: const BorderSide(color: kBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

class AdvisorDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool filled;

  const AdvisorDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? kTealLight : kFieldBg,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value?.isEmpty ?? true ? null : value,
          isExpanded: true,
          hint: Text(
            hint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: kHintColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: kHintColor,
            size: 20,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: kTextColor,
            fontWeight: FontWeight.w600,
          ),
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    i,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: kTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          menuMaxHeight: 360,
          selectedItemBuilder: (context) => items
              .map(
                (item) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: kTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (selection) {
            FocusManager.instance.primaryFocus?.unfocus();
            onChanged(selection);
          },
        ),
      ),
    );
  }
}

/// A normal platform switch with a tappable label and deliberately distinct
/// thumb/track colours. This avoids the solid-filled appearance of the old
/// intake toggles while retaining their existing state callbacks.
class AdvisorToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AdvisorToggleTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      enabled: enabled,
      button: true,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(AppDimensions.r10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.label(
                    color: enabled ? kLabelColor : kHintColor,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 12),
              IgnorePointer(
                child: Switch.adaptive(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.border,
                  trackOutlineColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.primary
                        : AppColors.text4,
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

class MoreLessLink extends StatelessWidget {
  final bool showMore;
  final VoidCallback onTap;

  const MoreLessLink({super.key, required this.showMore, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          showMore ? 'LESS' : 'MORE',
          style: AppTextStyles.metadata(
            color: kBlue,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

const Widget kGap12 = SizedBox(height: 12);
const Widget kGap16 = SizedBox(height: 16);
