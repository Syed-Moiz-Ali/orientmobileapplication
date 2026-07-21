import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';

class SupervisorScheduleTab extends StatelessWidget {
  const SupervisorScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_rounded, size: 48, color: AppColors.text3),
          SizedBox(height: AppDimensions.s12),
          Text(
            'Schedule / Calendar',
            style: TextStyle(color: AppColors.text3, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
