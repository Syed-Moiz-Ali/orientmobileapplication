import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/widgets/app_shimmer_skeleton.dart';

/// Rounded remote image with shimmer + error placeholders (phase-1d-ii).
///
/// Built on the framework `Image` + an `ImageProvider` — the same foundation
/// the apps already use (`Image.file`/`Image.memory` for picker photos,
/// `CircleAvatar` for initials; zero `Image.network`/`cached_network_image`/
/// `FadeInImage` in `apps/` or `packages/`, so no cache dependency was
/// added). While loading, a shimmer block holds the exact size; on failure a
/// quiet surface block with a broken-image glyph shows instead of a grey box.
///
/// Name verified free in `packages/`; no rename needed.
///
/// ```dart
/// AppNetworkImage(
///   imageUrl: 'https://cdn.example.com/cover.jpg',
///   width: 120, height: 120, radius: AppRadius.image,
///   semanticLabel: 'Inspection photo',
/// )
/// ```
///
/// - Tokens only, caller text, Directional-safe (no sided insets), wraps at
///   1.3x (fixed box, internal label never clips). Tests pass [provider] to
///   stay deterministic (memory stub or undecodable bytes) — never real
///   network.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final ImageProvider? provider;
  final Map<String, String>? headers;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;
  final String? semanticLabel;
  final String? errorSemanticLabel;

  /// When true (default) the loading placeholder is a LIVE shimmer. It goes
  /// static automatically under reduced motion
  /// (`MediaQuery.disableAnimations`, same path as [AppShimmer]). Pass false
  /// to freeze it deterministically in tests.
  final bool shimmerEnabled;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.provider,
    this.headers,
    this.width,
    this.height,
    this.radius = AppRadius.image,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.errorSemanticLabel = 'Image failed to load',
    this.shimmerEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final placeholder = AppShimmerSkeleton(
      width: width,
      height: height ?? 120,
      radius: radius,
      enabled: shimmerEnabled,
      semanticLabel: 'Loading image',
    );
    final fallback = Container(
      width: width,
      height: height ?? 120,
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerHighest,
        shape: shape,
      ),
      alignment: Alignment.center,
      child: Semantics(
        label: errorSemanticLabel,
        image: true,
        child: ExcludeSemantics(
          child: Icon(
            Icons.broken_image_outlined,
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
    final image = Image(
      image: provider ?? NetworkImage(imageUrl, headers: headers),
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, _) =>
          frame == null ? placeholder : child,
      errorBuilder: (context, error, stackTrace) => fallback,
      excludeFromSemantics: semanticLabel == null,
      semanticLabel: semanticLabel,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image,
    );
  }
}
