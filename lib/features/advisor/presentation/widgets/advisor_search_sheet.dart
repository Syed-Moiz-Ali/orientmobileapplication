import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'advisor_sheet.dart';
import 'advisor_handle.dart';
import 'advisor_solid_action.dart';

class AdvisorSearchSheet extends StatefulWidget {
  final VoidCallback onScan;
  const AdvisorSearchSheet({super.key, required this.onScan});

  @override
  State<AdvisorSearchSheet> createState() => _AdvisorSearchSheetState();
}

class _AdvisorSearchSheetState extends State<AdvisorSearchSheet> {
  final _ctrl = TextEditingController();
  final _filters = <String>{};

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AdvisorSheet(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdvisorHandle(),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Search',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Name, plate, phone, email…',
              hintStyle: const TextStyle(color: AppColors.text3, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.text3, size: 20),
              suffixIcon: GestureDetector(
                onTap: widget.onScan,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.navy, AppColors.accent]),
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 16),
                ),
              ),
              filled: true,
              fillColor: AppColors.canvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Filter by status',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            children: ['In Progress', 'Pending Approval', 'Ready', 'Today Only']
                .map((f) {
                  final sel = _filters.contains(f);
                  return GestureDetector(
                    onTap: () => setState(
                      () => sel ? _filters.remove(f) : _filters.add(f),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.accent : AppColors.canvas,
                        borderRadius: BorderRadius.circular(AppDimensions.r20),
                        border: Border.all(color: sel ? AppColors.accent : AppColors.stroke),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : AppColors.text2,
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          ),
          const SizedBox(height: 14),
          AdvisorSolidAction(
            label: 'Search',
            icon: Icons.search_rounded,
            gradient: const [AppColors.navy, AppColors.accent],
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
