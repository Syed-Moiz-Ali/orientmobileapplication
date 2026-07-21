import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/providers/dashboard_providers.dart';

class PendingApprovalsView extends ConsumerStatefulWidget {
  const PendingApprovalsView({super.key});
  @override
  ConsumerState<PendingApprovalsView> createState() => _PendingApprovalsViewState();
}

class _PendingApprovalsViewState extends ConsumerState<PendingApprovalsView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingApprovalsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.gray700), onPressed: () => context.pop()),
        title: const Text('Pending Approvals', style: TextStyle(color: AppColors.gray900, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [Padding(padding: const EdgeInsets.only(right: 12), child: Stack(clipBehavior: Clip.none, children: [IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.gray700), onPressed: () {}), if (state.totalPending > 0) Positioned(right: 6, top: 6, child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle), child: Center(child: Text('${state.totalPending}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))))]))],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(children: [
              Container(width: double.infinity, padding: const EdgeInsets.all(16), color: AppColors.dangerBg, child: Column(children: [const Text('Total Pending', style: TextStyle(fontSize: 12, color: AppColors.danger)), const SizedBox(height: 4), Text('${state.totalPending}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.danger))])),
              const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 8), child: Align(alignment: Alignment.centerLeft, child: Text('CATEGORIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray400)))),
              Expanded(child: ListView.separated(itemCount: state.categories.length, separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.gray200), itemBuilder: (_, i) => _CategoryItem(category: state.categories[i]))),
            ]),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final ApprovalCategory category;
  const _CategoryItem({required this.category});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Row(children: [
    Container(width: 44, height: 44, decoration: BoxDecoration(color: category.iconBg, borderRadius: BorderRadius.circular(AppDimensions.r10)), child: Icon(category.icon, color: AppColors.gray700, size: 22)),
    const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(category.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)), Text(category.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.gray500))])), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primaryBg, borderRadius: BorderRadius.circular(AppDimensions.r8)), child: Text('${category.count}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))), const SizedBox(width: 4), const Icon(Icons.chevron_right, color: AppColors.gray400, size: 20),
  ]));
}
