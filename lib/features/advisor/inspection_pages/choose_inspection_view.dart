// lib/features/advisor/inspection_pages/choose_inspection_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:go_router/go_router.dart';
import 'package:orientmobileapplication/core/router/app_router.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/presentation/widgets/inspection_widgets.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/inspection_provider.dart';

class ChooseInspectionView extends ConsumerWidget {
  final VoidCallback onSelect;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const ChooseInspectionView({
    super.key,
    required this.onSelect,
    required this.onSkip,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: IC.canvas,

      // ── AppBar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: IC.navy,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        title: const Text(
          'Choose Inspection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  context.push(
                    AppRoutes.repairOrder,
                    extra: {
                      'onBack': () => context.pop(),
                      'fromInspection': true,
                    },
                  );
                },
                child: const Text(
                  'SKIP INSPECTION',
                  style: TextStyle(
                    color: IC.text3,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Body ──────────────────────────────────────────────
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: InfoCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: IC.tealBg,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.r8),
                  ),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: IC.accent,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Vehicle Inspection Sheet',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: IC.text1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '4 sections · 24 items',
                      style: TextStyle(fontSize: 11, color: IC.text2),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Button
              SolidBtn(
                label: 'SELECT AND CONTINUE',
                onTap: () {
                  ref.read(inspectionProvider.notifier).reset();
                  context.push(
                    AppRoutes.inspectionSheet,
                    extra: {
                      'onBack': () => context.pop(),
                      'onSaveDraft': () {
                        context.pop();
                        onSelect();
                      },
                      'onPreview': () {
                        context.push(
                          AppRoutes.inspectionPreview,
                          extra: {
                            'onBack': () => context.pop(),
                            'onSubmit': () {
                              context.pop();
                              onSelect();
                            },
                          },
                        );
                      },
                    },
                  );
                },
                color: IC.accent,
                small: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
