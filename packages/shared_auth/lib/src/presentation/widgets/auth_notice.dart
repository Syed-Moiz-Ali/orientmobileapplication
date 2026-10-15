import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Semantic tone for authentication feedback.
enum AuthNoticeTone { error, info, success }

/// Inline authentication feedback shared by every Orient auth screen.
///
/// One silhouette for every tone ([AppInfoPanel] grammar): error, info and
/// success differ only by semantic tone, so a failure never looks like a new
/// component. Every notice is announced as a live region — a backend or
/// validation failure must be decidable within seconds by sighted and
/// screen-reader users alike.
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
    final variant = switch (tone) {
      AuthNoticeTone.error => AppInfoPanelVariant.danger,
      AuthNoticeTone.info => AppInfoPanelVariant.primary,
      AuthNoticeTone.success => AppInfoPanelVariant.success,
    };

    return Semantics(
      liveRegion: true,
      child: AppInfoPanel(variant: variant, icon: icon, message: text),
    );
  }
}

/// Reserves no space when there is no message and animates the notice in, so a
/// failure does not make the whole screen jump. Null/empty renders an empty
/// sliver — the slot owns the spacing, callers never conditionally pad.
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
      duration: AppMotion.resolve(context, AppMotion.standard),
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
