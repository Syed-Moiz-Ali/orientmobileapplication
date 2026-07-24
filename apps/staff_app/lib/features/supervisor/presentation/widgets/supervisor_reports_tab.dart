import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class SupervisorReportsTab extends StatelessWidget {
  const SupervisorReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.text3),
          SizedBox(height: AppDimensions.s12),
          Text(
            'Reports & Charts',
            style: TextStyle(color: AppColors.text3, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
