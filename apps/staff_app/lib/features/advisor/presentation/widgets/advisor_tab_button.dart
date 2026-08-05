import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorTabButton extends StatefulWidget {
  final String label;
  final int index;
  final TabController ctrl;
  final String? badge;
  final Color badgeColor;
  const AdvisorTabButton({
    super.key,
    required this.label,
    required this.index,
    required this.ctrl,
    this.badge,
    this.badgeColor = AppColors.accent,
  });

  @override
  State<AdvisorTabButton> createState() => _AdvisorTabButtonState();
}

class _AdvisorTabButtonState extends State<AdvisorTabButton> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.ctrl.index == widget.index;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.ctrl.animateTo(widget.index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: on ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.r10),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                  color: on ? AppColors.textPrimary : AppColors.text3,
                  letterSpacing: on ? 0.3 : 0,
                ),
              ),
              if (widget.badge != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: on
                        ? widget.badgeColor
                        : widget.badgeColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                  ),
                  child: Text(
                    widget.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
