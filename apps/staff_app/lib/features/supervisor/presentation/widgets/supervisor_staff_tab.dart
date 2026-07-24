import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class SupervisorStaffTab extends StatelessWidget {
  const SupervisorStaffTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_rounded, size: 48, color: AppColors.text3),
          SizedBox(height: AppDimensions.s12),
          Text(
            'Staff Management',
            style: TextStyle(color: AppColors.text3, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
