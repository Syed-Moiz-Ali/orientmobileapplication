import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Semantic tone for authentication feedback.
enum AuthNoticeTone { error, info, success }

/// Inline authentication feedback shared by every Orient auth screen.
///
/// Errors, information and success states share one silhouette so feedback
/// stays predictable across sign-in, recovery and reset, and differ only by
/// accent colour. Every notice is announced as a live region for assistive
/// technology.
class AuthNotice extends StatelessWidget {
  final IconData icon;
  final String text;
  final AuthNoticeTone tone;

  const AuthNotice({
    super.key,
    required this.icon,
    required this.text,
    this.tone = AuthNoticeTone.info,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = switch (tone) {
      AuthNoticeTone.error => colors.error,
      AuthNoticeTone.info => colors.primary,
      AuthNoticeTone.success => colors.tertiary,
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            accent.withValues(alpha: 0.08),
            colors.surface,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface,
                  height: 1.4,
                  fontWeight: tone == AuthNoticeTone.error
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reserves no space when there is no message and animates the notice in, so a
/// failure does not make the whole screen jump.
class AuthNoticeSlot extends StatelessWidget {
  final String? message;
  final IconData icon;
  final AuthNoticeTone tone;

  const AuthNoticeSlot({
    super.key,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.tone = AuthNoticeTone.error,
  });

  @override
  Widget build(BuildContext context) {
    final text = message;
    return AnimatedSize(
      duration: AppMotion.standard,
      curve: AppMotion.standardCurve,
      alignment: Alignment.topCenter,
      child: text == null || text.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.s16),
              child: AuthNotice(icon: icon, text: text, tone: tone),
            ),
    );
  }
}
