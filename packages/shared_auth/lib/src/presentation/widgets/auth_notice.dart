import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Semantic tone for authentication feedback.
enum AuthNoticeTone { error, info, success }

/// Inline authentication feedback shared by every Orient auth screen.
///
/// Restyled onto the shared [AppInfoPanel] grammar (spec §7): errors, information
/// and success states share one silhouette and differ only by semantic tone.
/// Every notice is announced as a live region for assistive technology.
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
