import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/platform/file_ops.dart';
import 'package:staff_app/core/services/audio_recorder_service.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'inspection_provider.dart';

class InspectionSheetView extends ConsumerStatefulWidget {
  final InspectionCallbacks callbacks;
  const InspectionSheetView({super.key, required this.callbacks});

  @override
  ConsumerState<InspectionSheetView> createState() => _InspectionSheetViewState();
}

class _InspectionSheetViewState extends ConsumerState<InspectionSheetView> {
  String _selectedSectionId = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final pct = state.progressPercent;
    final sections = state.filteredSections;

    if (_selectedSectionId.isEmpty && sections.isNotEmpty) {
      _selectedSectionId = sections.first.id;
    }

    final activeSection = sections.firstWhere(
      (s) => s.id == _selectedSectionId,
      orElse: () => sections.isNotEmpty ? sections.first : const InspectionSection(id: '', label: '', items: []),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _PressScale(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.callbacks.onBack();
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface, size: 20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inspection Sheet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '${state.completedCount} of ${state.totalItems} checkpoints evaluated',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11.5),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
            ),
            child: Text(
              '${(pct * 100).round()}%',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 1. REAL-TIME PROGRESS & SEARCH ───────────────────────────────
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: TextField(
                    onChanged: (q) => notifier.setGlobalSearch(q),
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Quick find checkpoint...',
                      hintStyle: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. QUICK SECTION SWITCHER PILLS ──────────────────────────────
          Container(
            height: 48,
            color: colorScheme.surface,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final sec = sections[i];
                final isSelected = sec.id == _selectedSectionId;
                final rated = sec.items
                    .asMap()
                    .entries
                    .where((e) => state.statuses.containsKey('${sec.id}_${e.key}'))
                    .length;
                final isDone = rated == sec.items.length && sec.items.isNotEmpty;

                return _PressScale(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSectionId = sec.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : isDone
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : isDone
                            ? const Color(0xFF10B981).withValues(alpha: 0.3)
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDone && !isSelected) ...[
                          const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          sec.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : isDone
                                ? const Color(0xFF10B981)
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$rated/${sec.items.length}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                : colorScheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),

          // ── 3. INTUITIVE CHECKPOINT CARDS LIST ───────────────────────────
          Expanded(
            child: activeSection.items.isEmpty
                ? const Center(
                    child: EmptyState(icon: Icons.search_off_rounded, message: 'No matching checkpoints found'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                    itemCount: activeSection.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      final itemName = activeSection.items[idx];
                      final itemId = '${activeSection.id}_$idx';
                      return _IntuitiveCheckpointCard(itemId: itemId, itemName: itemName, index: idx + 1);
                    },
                  ),
          ),

          // ── 4. STICKY FOOTER ─────────────────────────────────────────────
          _StickyFooter(callbacks: widget.callbacks),
        ],
      ),
    );
  }
}

// ─── INTUITIVE CHECKPOINT CARD ───────────────────────────────────────────────
class _IntuitiveCheckpointCard extends ConsumerStatefulWidget {
  final String itemId;
  final String itemName;
  final int index;

  const _IntuitiveCheckpointCard({required this.itemId, required this.itemName, required this.index});

  @override
  ConsumerState<_IntuitiveCheckpointCard> createState() => _IntuitiveCheckpointCardState();
}

class _IntuitiveCheckpointCardState extends ConsumerState<_IntuitiveCheckpointCard> {
  bool _showMediaDrawer = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final status = state.statuses[widget.itemId];
    final media = state.media[widget.itemId];

    final hasAudio = (media?.audioPath.isNotEmpty ?? false);
    final hasNote = (media?.note.isNotEmpty ?? false);
    final totalFiles =
        (media?.photoPaths.length ?? 0) + (media?.videoPaths.length ?? 0) + (hasAudio ? 1 : 0) + (hasNote ? 1 : 0);

    final statusColor = status == ItemStatus.good
        ? const Color(0xFF10B981)
        : status == ItemStatus.fair
        ? colorScheme.secondary
        : status == ItemStatus.poor
        ? colorScheme.error
        : Colors.transparent;

    final isRated = status != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRated ? statusColor.withValues(alpha: 0.4) : colorScheme.outlineVariant,
          width: isRated ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isRated ? statusColor.withValues(alpha: 0.04) : colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isRated ? statusColor.withValues(alpha: 0.14) : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.index}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isRated ? statusColor : colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.itemName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    height: 1.25,
                  ),
                ),
              ),
              if (totalFiles > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attachment_rounded, size: 12, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '$totalFiles',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // ── 3-WAY LARGE SEGMENTED CONDITION SELECTOR ─────────────────────
          Row(
            children: [
              _ConditionSegmentBtn(
                label: 'Good',
                icon: Icons.check_circle_outline_rounded,
                isSelected: status == ItemStatus.good,
                activeColor: const Color(0xFF10B981),
                onTap: () => notifier.setStatus(widget.itemId, status == ItemStatus.good ? null : ItemStatus.good),
              ),
              const SizedBox(width: 8),
              _ConditionSegmentBtn(
                label: 'Fair',
                icon: Icons.error_outline_rounded,
                isSelected: status == ItemStatus.fair,
                activeColor: colorScheme.secondary,
                onTap: () => notifier.setStatus(widget.itemId, status == ItemStatus.fair ? null : ItemStatus.fair),
              ),
              const SizedBox(width: 8),
              _ConditionSegmentBtn(
                label: 'Poor',
                icon: Icons.cancel_outlined,
                isSelected: status == ItemStatus.poor,
                activeColor: colorScheme.error,
                onTap: () => notifier.setStatus(widget.itemId, status == ItemStatus.poor ? null : ItemStatus.poor),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── TOGGLE EVIDENCE DRAWER BUTTON ────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showMediaDrawer = !_showMediaDrawer);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: totalFiles > 0
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: totalFiles > 0 ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        totalFiles > 0 ? Icons.inventory_2_rounded : Icons.add_photo_alternate_outlined,
                        size: 14,
                        color: totalFiles > 0 ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        totalFiles > 0 ? 'Manage Evidence ($totalFiles)' : '+ Add Photo / Voice Note',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: totalFiles > 0 ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showMediaDrawer ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: totalFiles > 0 ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              if (isRated) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.setStatus(widget.itemId, null);
                  },
                  child: Text(
                    'Clear Rating',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ── EVIDENCE DRAWER EXPANSION ────────────────────────────────────
          if (_showMediaDrawer) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MediaPickerSquare(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: () => _pickPhoto(context, notifier, widget.itemId, fromCamera: true),
                      ),
                      const SizedBox(width: 8),
                      _MediaPickerSquare(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: () => _pickPhoto(context, notifier, widget.itemId, fromCamera: false),
                      ),
                      const SizedBox(width: 8),
                      _MediaPickerSquare(
                        icon: Icons.videocam_outlined,
                        label: 'Video',
                        onTap: () => _pickVideo(context, notifier, widget.itemId),
                      ),
                      const SizedBox(width: 8),
                      _MediaPickerSquare(
                        icon: Icons.mic_rounded,
                        label: 'Audio',
                        active: hasAudio,
                        onTap: () => _showAudioDialog(context, state, notifier, widget.itemId),
                      ),
                      const SizedBox(width: 8),
                      _MediaPickerSquare(
                        icon: Icons.edit_note_rounded,
                        label: 'Note',
                        active: hasNote,
                        onTap: () =>
                            _showNoteDialog(context, notifier, widget.itemId, widget.itemName, media?.note ?? ''),
                      ),
                    ],
                  ),
                  if (totalFiles > 0) ...[
                    const SizedBox(height: 12),
                    _AttachmentsThumbnailRow(itemId: widget.itemId, media: media!),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickPhoto(
    BuildContext context,
    InspectionNotifier notifier,
    String itemId, {
    required bool fromCamera,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (file != null) {
        final dir = await getApplicationDocumentsDirectory();
        final ext = file.path.split('.').last;
        final destPath = '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final saved = await persistMediaFile(file.path, destPath);
        notifier.addPhoto(itemId, saved);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Camera error: $e'), backgroundColor: colorScheme.error));
      }
    }
  }

  Future<void> _pickVideo(BuildContext context, InspectionNotifier notifier, String itemId) async {
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickVideo(source: ImageSource.camera);
      if (file != null) {
        final dir = await getApplicationDocumentsDirectory();
        final ext = file.path.split('.').last;
        final destPath = '${dir.path}/video_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final saved = await persistMediaFile(file.path, destPath);
        notifier.addVideo(itemId, saved);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Video recording error: $e'), backgroundColor: colorScheme.error));
      }
    }
  }

  void _showAudioDialog(BuildContext context, InspectionState state, InspectionNotifier notifier, String itemId) {
    showDialog(
      context: context,
      builder: (_) => _AudioDialog(
        itemId: itemId,
        existing: state.media[itemId]?.audioPath ?? '',
        onSave: (path) => notifier.setAudio(itemId, path),
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    InspectionNotifier notifier,
    String itemId,
    String itemName,
    String existing,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final ctrl = TextEditingController(text: existing);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.edit_note_rounded, color: colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                itemName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          autofocus: true,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Add checkpoint notes...',
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              notifier.setNote(itemId, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }
}

// ─── LARGE CONDITION SEGMENT BUTTON ──────────────────────────────────────────
class _ConditionSegmentBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ConditionSegmentBtn({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: _PressScale(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.transparent : colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── MEDIA PICKER ICON BUTTON ────────────────────────────────────────────────
class _MediaPickerSquare extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _MediaPickerSquare({required this.icon, required this.label, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: _PressScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? colorScheme.primary.withValues(alpha: 0.15) : colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? colorScheme.primary : colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: active ? colorScheme.primary : colorScheme.onSurface),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: active ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ATTACHMENTS THUMBNAIL ROW ───────────────────────────────────────────────
class _AttachmentsThumbnailRow extends ConsumerWidget {
  final String itemId;
  final ItemMedia media;

  const _AttachmentsThumbnailRow({required this.itemId, required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.read(inspectionProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (media.photoPaths.isNotEmpty)
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: media.photoPaths.length,
              itemBuilder: (_, i) => Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: localImage(media.photoPaths[i], fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        notifier.removePhoto(itemId, i);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (media.audioPath.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.audiotrack_rounded, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  media.audioPath.split('/').last,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => notifier.setAudio(itemId, ''),
                child: Icon(Icons.delete_outline_rounded, size: 16, color: colorScheme.error),
              ),
            ],
          ),
        ],
        if (media.note.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Note: "${media.note}"',
            style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: colorScheme.onSurface),
          ),
        ],
      ],
    );
  }
}

// ─── AUDIO DIALOG ────────────────────────────────────────────────────────────
class _AudioDialog extends StatefulWidget {
  final String itemId;
  final String existing;
  final void Function(String) onSave;
  const _AudioDialog({required this.itemId, required this.existing, required this.onSave});

  @override
  State<_AudioDialog> createState() => _AudioDialogState();
}

class _AudioDialogState extends State<_AudioDialog> with SingleTickerProviderStateMixin {
  bool _recording = false;
  int _seconds = 0;
  Timer? _timer;
  final AudioRecorderService _recorder = AudioRecorderService();
  String? _recordedPath;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final hasMic = await Permission.microphone.request();
    if (!hasMic.isGranted) return;

    final dir = await getApplicationDocumentsDirectory();
    _recordedPath = '${dir.path}/audio_${widget.itemId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.startRecording(_recordedPath!);

    setState(() {
      _recording = true;
      _seconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !_recording) return;
      setState(() => _seconds++);
      if (_seconds >= 60) _stop();
    });
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final path = await _recorder.stopRecording();
    setState(() => _recording = false);
    if (path != null && mounted) {
      widget.onSave(path);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Voice Log', style: TextStyle(fontWeight: FontWeight.w900)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_recording ? 'Recording... $_seconds s' : 'Tap to start recording note'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _recording ? _stop : _start,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _recording ? colorScheme.error : colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(_recording ? Icons.stop : Icons.mic, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STICKY FOOTER ───────────────────────────────────────────────────────────
class _StickyFooter extends ConsumerWidget {
  final InspectionCallbacks callbacks;
  const _StickyFooter({required this.callbacks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              const Text('Notify Owner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Switch.adaptive(
                value: state.notifyOwner,
                activeTrackColor: colorScheme.primary,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  notifier.toggleNotifyOwner();
                },
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              callbacks.onPreview();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Review Sheet', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

// ─── SPRING INTERACTION HELPER ───────────────────────────────────────────────
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
