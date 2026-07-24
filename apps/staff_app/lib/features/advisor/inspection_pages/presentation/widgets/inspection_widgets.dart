import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';

class IC {
  static const navy     = AppColors.navy;
  static const accent   = AppColors.primary;
  static const accentBg = AppColors.primaryBg;
  static const surface  = AppColors.surface;
  static const canvas   = AppColors.canvas;
  static const line     = AppColors.line;
  static const stroke   = AppColors.stroke;
  static const text1    = AppColors.textPrimary;
  static const text2    = AppColors.text2;
  static const text3    = AppColors.text3;
  static const green    = AppColors.primary;
  static const greenBg  = AppColors.primaryBg;
  static const amber    = AppColors.warning;
  static const amberBg  = AppColors.warningBg;
  static const red      = AppColors.danger;
  static const redBg    = AppColors.dangerBg;
  static const purple   = AppColors.info;
  static const purpleBg = AppColors.infoBg;
  static const tealBg   = Color(0xFFE0F5F3);
}

({Color color, Color bg, String label}) statusColors(ItemStatus s) {
  switch (s) {
    case ItemStatus.good: return (color: AppColors.primary, bg: AppColors.primaryBg, label: 'Good');
    case ItemStatus.fair: return (color: AppColors.warning, bg: AppColors.warningBg, label: 'Fair');
    case ItemStatus.poor: return (color: AppColors.danger, bg: AppColors.dangerBg, label: 'Poor');
  }
}

class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final bool small;
  const AppBadge({super.key, required this.label, required this.color, required this.bg, this.small = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: small ? 7 : 9, vertical: small ? 2 : 3),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6)),
      border: Border.all(color: color.withValues(alpha: 0.14)),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: small ? 10 : 11, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
  );
}

class SolidBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool small;
  final bool loading;
  const SolidBtn({super.key, required this.label, required this.onTap, this.color = AppColors.primary, this.small = false, this.loading = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      padding: small ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8) : const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10))),
      alignment: small ? null : Alignment.center,
      child: loading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.1)),
    ),
  );
}

class OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const OutlineBtn({super.key, required this.label, required this.onTap, this.color = AppColors.text2});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: -0.1)),
    ),
  );
}

class StatusBoxes extends StatelessWidget {
  final String itemId;
  final Map<String, ItemStatus> statuses;
  final void Function(String, ItemStatus?) setStatus;
  const StatusBoxes({super.key, required this.itemId, required this.statuses, required this.setStatus});

  @override
  Widget build(BuildContext context) {
    final boxes = [
      (key: ItemStatus.good, bg: AppColors.primaryBg, border: AppColors.primary, fill: AppColors.primary),
      (key: ItemStatus.fair, bg: AppColors.warningBg, border: AppColors.warning, fill: AppColors.warning),
      (key: ItemStatus.poor, bg: AppColors.dangerBg, border: AppColors.danger, fill: AppColors.danger),
    ];
    return Row(
      children: boxes.map((b) {
        final sel = statuses[itemId] == b.key;
        return GestureDetector(
          onTap: () => setStatus(itemId, sel ? null : b.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28, height: 28,
            margin: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: sel ? b.fill : b.bg,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r7)),
              border: Border.all(color: b.border, width: 2),
            ),
            child: sel ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        );
      }).toList(),
    );
  }
}

class ActionIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool active;
  const ActionIconBtn({super.key, required this.icon, required this.label, this.color = AppColors.text3, this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r7)),
            border: Border.all(color: active ? AppColors.primary : color.withValues(alpha: 0.6), width: 1.5),
            color: active ? const Color(0xFFE0F5F3) : Colors.transparent,
          ),
          child: Icon(icon, size: 13, color: active ? AppColors.primary : color),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: active ? AppColors.primary : color, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

class TealSwitch extends StatelessWidget {
  final bool value;
  final VoidCallback onToggle;
  const TealSwitch({super.key, required this.value, required this.onToggle});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onToggle,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 42, height: 24,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? AppColors.primary : AppColors.stroke,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12)),
      ),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(width: 18, height: 18,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
    ),
  );
}

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.canvas, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
      border: Border.all(color: AppColors.line, width: 1.5),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(children: [
      const Icon(Icons.search, color: AppColors.text3, size: 16),
      const SizedBox(width: 8),
      Expanded(child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.text3),
          isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero,
        ),
      )),
    ]),
  );
}

class InfoCard extends StatelessWidget {
  final Widget child;
  const InfoCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12)),
      border: Border.all(color: AppColors.line, width: 1.5),
    ),
    child: child,
  );
}

class SmallTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const SmallTag({super.key, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6))),
    child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
  );
}

