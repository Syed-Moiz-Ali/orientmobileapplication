import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/platform/file_ops.dart';
import 'package:staff_app/core/services/audio_recorder_service.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/hud_pin_bridge.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 08 — detailed damage capture sheet (Archetype 6 capture flow).
///
/// Tap a body part → this bottom sheet collects the damage detail:
/// kind (5) + severity (auto-mapped from kind, manually overridable) +
/// size (optional coin/palm/span) + photo (REQUIRED for Moderate/Severe) +
/// optional note + voice-note slot. Confirm validates (kind required,
/// photo-required enforced inline) and returns the finding; the caller
/// persists it through the inspection provider with zero contract change.
class DamageDetailResult {
  final VehicleDamageFinding finding;
  final String voicePath;

  const DamageDetailResult({required this.finding, required this.voicePath});
}

Future<DamageDetailResult?> showDamageDetailSheet({
  required BuildContext context,
  required String partId,
  required VehiclePartCategory category,
  Offset? normalized,
  VehicleDamageFinding? existing,
  String existingVoice = '',
}) {
  final t = StaffLocalizations.of(context)!;
  return showAppModalSheet<DamageDetailResult>(
    context: context,
    title: damagePartLabel(t, partId),
    builder: (ctx) => _DamageDetailBody(
      partId: partId,
      category: category,
      normalized: normalized,
      existing: existing,
      existingVoice: existingVoice,
    ),
  );
}

class _DamageDetailBody extends StatefulWidget {
  final String partId;
  final VehiclePartCategory category;
  final Offset? normalized;
  final VehicleDamageFinding? existing;
  final String existingVoice;

  const _DamageDetailBody({
    required this.partId,
    required this.category,
    required this.normalized,
    required this.existing,
    required this.existingVoice,
  });

  @override
  State<_DamageDetailBody> createState() => _DamageDetailBodyState();
}

class _DamageDetailBodyState extends State<_DamageDetailBody> {
  late VehicleDamageType? _kind = widget.existing?.damageType;
  late VehicleDamageSeverity? _severity = widget.existing?.severity;
  late String? _size =
      damageDetailSizes.contains(widget.existing?.damageLocation)
      ? widget.existing!.damageLocation
      : null;
  late List<String> _photos = [...?widget.existing?.photos];
  late final TextEditingController _note = TextEditingController(
    text: widget.existing?.note ?? '',
  );

  bool _kindError = false;
  bool _photoError = false;
  bool _cameraDenied = false;
  bool _galleryDenied = false;

  // Voice slot state.
  late String _voicePath = widget.existingVoice;
  bool _recording = false;
  bool _playing = false;
  bool _micDenied = false;
  int _seconds = 0;
  Timer? _timer;
  final AudioRecorderService _recorder = AudioRecorderService();
  AudioPlayer? _player;

  @override
  void dispose() {
    _note.dispose();
    _timer?.cancel();
    _player?.dispose();
    super.dispose();
  }

  bool get _photoRequired =>
      _severity == VehicleDamageSeverity.moderate ||
      _severity == VehicleDamageSeverity.major;

  void _pickKind(VehicleDamageType kind) {
    HapticFeedback.selectionClick();
    setState(() {
      _kind = kind;
      // Auto-map severity; the segmented control below stays overridable.
      _severity = defaultSeverityForKind(kind);
      _kindError = false;
      if (!_photoRequired) _photoError = false;
    });
  }

  Future<void> _pickPhoto({required bool fromCamera}) async {
    final permission = await (fromCamera
        ? Permission.camera.request()
        : Permission.photos.request());
    if (!permission.isGranted) {
      setState(() {
        if (fromCamera) {
          _cameraDenied = true;
        } else {
          _galleryDenied = true;
        }
      });
      return;
    }
    if (mounted) {
      setState(() {
        if (fromCamera) {
          _cameraDenied = false;
        } else {
          _galleryDenied = false;
        }
      });
    }
    try {
      final file = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (file == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final ext = file.path.contains('.')
          ? '.${file.path.split('.').last}'
          : '';
      final saved = await persistMediaFile(
        file.path,
        '${dir.path}/damage_${DateTime.now().microsecondsSinceEpoch}$ext',
      );
      if (mounted) {
        setState(() {
          _photos = [..._photos, saved];
          _photoError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        final t = StaffLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.advisorHudPhotoError)));
      }
    }
  }

  Future<void> _toggleRecord() async {
    final t = StaffLocalizations.of(context)!;
    if (_recording) {
      _timer?.cancel();
      final path = await _recorder.stopRecording();
      if (mounted) {
        setState(() {
          _recording = false;
          if (path != null && path.isNotEmpty) _voicePath = path;
        });
      }
      return;
    }
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      if (mounted) setState(() => _micDenied = true);
      return;
    }
    if (mounted) setState(() => _micDenied = false);
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/damage_voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
    final started = await _recorder.startRecording(path);
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.advisorHudPhotoError)));
      }
      return;
    }
    setState(() {
      _recording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_recording) return;
      setState(() => _seconds++);
      if (_seconds >= 60) _toggleRecord();
    });
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player?.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    try {
      _player ??= AudioPlayer();
      await _player!.play(DeviceFileSource(_voicePath));
      if (mounted) setState(() => _playing = true);
      _player!.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _playing = false);
      });
    } catch (_) {
      if (mounted) setState(() => _playing = false);
    }
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    var valid = true;
    if (_kind == null) {
      setState(() => _kindError = true);
      valid = false;
    }
    final severity = _severity ?? defaultSeverityForKind(_kind!);
    if ((severity == VehicleDamageSeverity.moderate ||
            severity == VehicleDamageSeverity.major) &&
        _photos.isEmpty) {
      setState(() => _photoError = true);
      valid = false;
    }
    if (!valid) return;
    final point =
        widget.normalized ??
        Offset(
          widget.existing?.normalizedX ?? 0.5,
          widget.existing?.normalizedY ?? 0.5,
        );
    final finding = VehicleDamageFinding(
      id: widget.existing?.id ?? 'VDF-${DateTime.now().microsecondsSinceEpoch}',
      partId: widget.partId,
      damageType: _kind!,
      severity: severity,
      damageLocation: _size ?? '',
      note: _note.text.trim(),
      photos: _photos,
      recommendedAction:
          widget.existing?.recommendedAction ??
          VehicleRecommendedAction.noAction,
      normalizedX: point.dx.clamp(0, 1),
      normalizedY: point.dy.clamp(0, 1),
    );
    Navigator.pop(
      context,
      DamageDetailResult(finding: finding, voicePath: _voicePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;

    // Sticky confirm CTA: the detail form scrolls beneath it so the
    // primary action is never below the fold on small phones.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Part identity: localized label + category chip.
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MetaChip(
                      icon: Icons.directions_car_outlined,
                      label: damageCategoryLabel(t, widget.category),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionLabel(label: t.advisorDamageKindSection),
                const SizedBox(height: 8),
                for (final kind in damageDetailKinds)
                  _KindRow(
                    kind: kind,
                    selected: _kind == kind,
                    onTap: () => _pickKind(kind),
                  ),
                if (_kindError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      t.advisorDamageKindRequired,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                _SectionLabel(label: t.advisorDamageSeveritySection),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final severity in VehicleDamageSeverity.values) ...[
                      _SeverityPill(
                        severity: severity,
                        selected: _severity == severity,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _severity = severity;
                            if (!_photoRequired) _photoError = false;
                          });
                        },
                      ),
                      if (severity != VehicleDamageSeverity.major)
                        const SizedBox(width: 6),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _SectionLabel(label: t.advisorDamageSizeSection),
                    const SizedBox(width: 6),
                    Text(
                      '· ${t.advisorDamageSizeOptional}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final size in damageDetailSizes) ...[
                      _SizePill(
                        size: size,
                        selected: _size == size,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _size = _size == size ? null : size);
                        },
                      ),
                      if (size != damageDetailSizes.last)
                        const SizedBox(width: 6),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                _SectionLabel(label: t.advisorDamagePhotoSection),
                const SizedBox(height: 4),
                Text(
                  t.advisorDamagePhotoRequired,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _photoError ? colors.error : colors.onSurfaceVariant,
                    fontWeight: _photoError ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (_cameraDenied)
                  _DeniedCard(
                    title: t.advisorHudCameraDenied,
                    hint: t.advisorHudCameraDeniedHint,
                    onDismiss: () => setState(() => _cameraDenied = false),
                  )
                else if (_galleryDenied)
                  _DeniedCard(
                    title: t.advisorHudGalleryDenied,
                    hint: t.advisorHudGalleryDeniedHint,
                    onDismiss: () => setState(() => _galleryDenied = false),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PhotoTile(
                        icon: Icons.camera_alt_outlined,
                        label: t.advisorDamageAddPhoto,
                        onTap: () => _pickPhoto(fromCamera: true),
                      ),
                      _PhotoTile(
                        icon: Icons.photo_library_outlined,
                        label: t.advisorDamageAddPhoto,
                        onTap: () => _pickPhoto(fromCamera: false),
                      ),
                      for (var i = 0; i < _photos.length; i++)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.r8,
                                ),
                                border: Border.all(
                                  color: colors.outlineVariant,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.r8,
                                ),
                                child: localImage(
                                  _photos[i],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _photos = [..._photos]..removeAt(i),
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      // FIXED-INK: scrim + white glyph over user
                                      // photo content (non-theme media overlay).
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      // FIXED-INK: white glyph on the media scrim.
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                const SizedBox(height: 14),
                _SectionLabel(label: t.advisorHudAddNote),
                const SizedBox(height: 8),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  minLines: 2,
                  style: TextStyle(fontSize: 13, color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: t.advisorDamageNoteHint,
                    filled: true,
                    fillColor: colors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _SectionLabel(label: t.advisorDamageVoiceSection),
                const SizedBox(height: 8),
                _VoiceRow(
                  voicePath: _voicePath,
                  recording: _recording,
                  playing: _playing,
                  seconds: _seconds,
                  micDenied: _micDenied,
                  onRecord: _toggleRecord,
                  onPlay: _togglePlay,
                  onDelete: () => setState(() => _voicePath = ''),
                  onDismissDenied: () => setState(() => _micDenied = false),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: isEdit
                    ? t.advisorDamageSaveChanges
                    : t.advisorDamageAddPin,
                icon: isEdit ? Icons.check_rounded : Icons.push_pin_outlined,
                onPressed: _confirm,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.r8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _KindRow extends StatelessWidget {
  final VehicleDamageType kind;
  final bool selected;
  final VoidCallback onTap;

  const _KindRow({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final tone = damageSeverityTone(
      context.semanticColors,
      defaultSeverityForKind(kind),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          button: true,
          selected: selected,
          label:
              '${damageKindLabel(t, kind)} — ${damageSeverityLabel(t, defaultSeverityForKind(kind))}',
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? tone.base.withValues(alpha: 0.14)
                  : colors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.r12),
              border: Border.all(
                color: selected ? tone.base : colors.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tone.base,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    damageKindIcon(kind),
                    // FIXED-INK: white glyph on the saturated kind fill.
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        damageKindLabel(t, kind),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        damageSeverityLabel(t, defaultSeverityForKind(kind)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tone.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? tone.base : colors.onSurfaceVariant,
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

class _SeverityPill extends StatelessWidget {
  final VehicleDamageSeverity severity;
  final bool selected;
  final VoidCallback onTap;

  const _SeverityPill({
    required this.severity,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final tone = damageSeverityTone(context.semanticColors, severity);

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: damageSeverityLabel(t, severity),
        child: GestureDetector(
          onTap: onTap,
          // 48px segmented control, mirroring the checkpoint rings verdict.
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? tone.base : colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimensions.r8),
              border: Border.all(
                color: selected ? tone.base : colors.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              damageSeverityLabel(t, severity),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                // FIXED-INK: white label on the saturated severity fill.
                color: selected ? Colors.white : colors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _SizePill extends StatelessWidget {
  final String size;
  final bool selected;
  final VoidCallback onTap;

  const _SizePill({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: damageSizeLabel(t, size),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? colors.primary.withValues(alpha: 0.14)
                  : colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimensions.r8),
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              damageSizeLabel(t, size),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: selected ? colors.primary : colors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Semantics(
        button: true,
        label: label,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.r8),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Icon(icon, color: colors.onSurfaceVariant, size: 24),
        ),
      ),
    );
  }
}

class _DeniedCard extends StatelessWidget {
  final String title;
  final String hint;
  final VoidCallback onDismiss;

  const _DeniedCard({
    required this.title,
    required this.hint,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: colors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, color: colors.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  hint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              onDismiss();
            },
            child: Text(t.advisorHudOpenSettings),
          ),
        ],
      ),
    );
  }
}

class _VoiceRow extends StatelessWidget {
  final String voicePath;
  final bool recording;
  final bool playing;
  final int seconds;
  final bool micDenied;
  final VoidCallback onRecord;
  final VoidCallback onPlay;
  final VoidCallback onDelete;
  final VoidCallback onDismissDenied;

  const _VoiceRow({
    required this.voicePath,
    required this.recording,
    required this.playing,
    required this.seconds,
    required this.micDenied,
    required this.onRecord,
    required this.onPlay,
    required this.onDelete,
    required this.onDismissDenied,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    if (micDenied) {
      return _DeniedCard(
        title: t.advisorHudMicDenied,
        hint: t.advisorHudMicDeniedHint,
        onDismiss: onDismissDenied,
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Semantics(
              button: true,
              label: recording
                  ? t.advisorHudVoiceRecording(seconds)
                  : voicePath.isEmpty
                  ? t.advisorHudVoiceIdle
                  : t.advisorHudVoiceSaved,
              child: GestureDetector(
                onTap: onRecord,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: recording ? colors.error : colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    recording ? Icons.stop_rounded : Icons.mic_rounded,
                    // FIXED-INK: white glyph on saturated action fill.
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              recording
                  ? t.advisorHudVoiceRecording(seconds)
                  : voicePath.isEmpty
                  ? t.advisorHudVoiceIdle
                  : t.advisorHudVoiceSaved,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (voicePath.isNotEmpty && !recording) ...[
            SizedBox(
              height: 48,
              child: TextButton.icon(
                onPressed: onPlay,
                icon: Icon(
                  playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 20,
                ),
                label: Text(t.advisorHudVoicePlay),
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed: onDelete,
                tooltip: t.advisorHudVoiceDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colors.error,
                  size: 22,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
