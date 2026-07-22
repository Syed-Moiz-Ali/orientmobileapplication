import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/role_config.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/role_selection_provider.dart';

class RoleCard extends ConsumerStatefulWidget {
  final RoleConfig config;

  const RoleCard({super.key, required this.config});

  @override
  ConsumerState<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends ConsumerState<RoleCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    setState(() => _isHovered = hovering);
    hovering ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roleSelectionNotifierProvider);
    final isLoading = state.isLoadingFor(widget.config.role);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: isLoading
            ? null
            : () async {
                await ref
                    .read(roleSelectionNotifierProvider.notifier)
                    .selectRole(widget.config.role);
                if (context.mounted) {
                  context.push('/login/${widget.config.role.name}');
                }
              },
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: _isHovered
                    ? Colors.white.withValues(alpha: 0.28)
                    : Colors.white.withValues(alpha: 0.14),
              ),
              borderRadius: BorderRadius.circular(AppDimensions.r14),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: widget.config.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                  child: Icon(
                    widget.config.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.config.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.config.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
