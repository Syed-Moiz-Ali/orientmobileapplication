import 'package:flutter/material.dart';
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
  final Widget child;
  final Widget? trailing;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text('– ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kTextColor)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.surfaceAlt),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
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
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kLabelColor)),
          if (required)
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 13)),
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
  final bool filled;

  const AdvisorTextField({
    super.key,
    required this.hint,
    this.initialValue,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 13,
        color: kTextColor,
        fontWeight: filled ? FontWeight.w600 : FontWeight.normal,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kHintColor, fontSize: 13),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: filled ? kTealLight : kFieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          borderSide: const BorderSide(color: kBlue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          hint: Text(hint,
              style: const TextStyle(color: kHintColor, fontSize: 13)),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: kHintColor, size: 20),
          style: TextStyle(
            fontSize: 13,
            color: kTextColor,
            fontWeight: filled ? FontWeight.w600 : FontWeight.normal,
          ),
          items: items
              .map((i) => DropdownMenuItem(
                    value: i,
                    child: Text(i,
                        style: const TextStyle(
                            fontSize: 13, color: kTextColor)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class MoreLessLink extends StatelessWidget {
  final bool showMore;
  final VoidCallback onTap;

  const MoreLessLink(
      {super.key, required this.showMore, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          showMore ? 'LESS' : 'MORE',
          style: const TextStyle(
            color: kBlue,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

const Widget kGap12 = SizedBox(height: 12);
const Widget kGap16 = SizedBox(height: 16);

