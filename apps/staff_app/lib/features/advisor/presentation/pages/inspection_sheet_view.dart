import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/services/audio_recorder_service.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/widgets/inspection_widgets.dart';
import 'inspection_provider.dart';
import 'inspection_preview_view.dart';

class InspectionSheetView extends ConsumerWidget {
  final InspectionCallbacks callbacks;
  const InspectionSheetView({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);
    final pct = state.progressPercent;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Inspection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${state.completedCount} of ${state.totalItems} items completed',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.rPill),
              ),
              child: Text(
                '${(pct * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const _ProgressHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                ...state.filteredSections.map(
                  (sec) => _SectionCard(section: sec),
                ),
              ],
            ),
          ),
          _Footer(callbacks: callbacks),
        ],
      ),
    );
  }
}

class _ProgressHeader extends ConsumerWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final pct = state.progressPercent;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _chip(
                          state.showAll ? 'Collapse All' : 'Expand All',
                          state.showAll ? AppColors.primary : AppColors.text3,
                          () {
                            if (state.showAll) {
                              notifier.setCollapseAll();
                            } else {
                              notifier.setShowAll();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _chip('Search', AppColors.text3, () {}),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                ),
                child: Text(
                  '${state.completedCount}/${state.totalItems}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _searchField(notifier),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE8ECF0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(pct * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.rPill),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _searchField(InspectionNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E7EE)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextField(
        onChanged: (q) => notifier.setGlobalSearch(q),
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Search inspection items...',
          hintStyle: TextStyle(fontSize: 13, color: AppColors.text3),
          prefixIcon: Icon(Icons.search, color: AppColors.text3, size: 18),
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _SectionCard extends ConsumerStatefulWidget {
  final InspectionSection section;
  const _SectionCard({required this.section});

  @override
  ConsumerState<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends ConsumerState<_SectionCard> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _ratedCount(Map<String, ItemStatus> statuses, InspectionSection sec) {
    return sec.items
        .asMap()
        .entries
        .where((e) => statuses.containsKey('${sec.id}_${e.key}'))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final sec = widget.section;
    final isCollapsed = state.collapsed[sec.id] ?? false;
    final rated = _ratedCount(state.statuses, sec);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => notifier.toggleCollapse(sec.id),
            borderRadius: BorderRadius.circular(AppDimensions.r14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sec.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${sec.items.length} items · $rated rated',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.text3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (rated > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.rPill,
                              ),
                            ),
                            child: Text(
                              '$rated/${sec.items.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: isCollapsed ? -0.25 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.text3,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isCollapsed)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  if (_searching) ...[
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE4E7EE)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (q) => notifier.setSectionSearch(sec.id, q),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search in section...',
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: AppColors.text3,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 16,
                            color: AppColors.text3,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _searching = false;
                                _searchCtrl.clear();
                              });
                              notifier.setSectionSearch(sec.id, '');
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.text3,
                            ),
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...sec.items.asMap().entries.map((e) {
                    final index = e.key;
                    final itemName = e.value;
                    final itemId = '${sec.id}_$index';
                    return _ItemRow(
                      itemId: itemId,
                      itemName: itemName,
                      index: index,
                      total: sec.items.length,
                      onSearchToggle: () =>
                          setState(() => _searching = !_searching),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemRow extends ConsumerWidget {
  final String itemId;
  final String itemName;
  final int index;
  final int total;
  final VoidCallback onSearchToggle;

  const _ItemRow({
    required this.itemId,
    required this.itemName,
    required this.index,
    required this.total,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final status = state.statuses[itemId];
    final sc = status != null ? statusColors(status) : null;
    final itemMedia = state.media[itemId];
    final hasPhotos = (itemMedia?.photoPaths.isNotEmpty ?? false);
    final hasVideos = (itemMedia?.videoPaths.isNotEmpty ?? false);
    final hasAudio = (itemMedia?.audioPath.isNotEmpty ?? false);
    final hasNote = (itemMedia?.note.isNotEmpty ?? false);
    final hasMedia = hasPhotos || hasVideos || hasAudio || hasNote;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status != null
            ? const Color(0xFFFAFCFE)
            : const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(
          color: status != null
              ? sc!.color.withValues(alpha: 0.15)
              : const Color(0xFFE8ECF0),
          width: status != null ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: sc?.bg ?? const Color(0xFFE8ECF0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: sc?.color ?? const Color(0xFFCDD1DB),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: sc?.color ?? AppColors.text3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: status != null
                        ? AppColors.textPrimary
                        : AppColors.text2,
                  ),
                ),
              ),
              if (sc != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: sc.bg,
                    borderRadius: BorderRadius.circular(AppDimensions.rPill),
                    border: Border.all(color: sc.color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: sc.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        sc.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: sc.color,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _mediaBtn(
                Icons.camera_alt_outlined,
                'Camera',
                hasPhotos,
                AppColors.primary,
                () => _pickPhoto(context, notifier, itemId, fromCamera: true),
              ),
              const SizedBox(width: 4),
              _mediaBtn(
                Icons.photo_library_outlined,
                'Gallery',
                hasPhotos,
                AppColors.primary,
                () => _pickPhoto(context, notifier, itemId, fromCamera: false),
              ),
              const SizedBox(width: 4),
              _mediaBtn(
                Icons.videocam_outlined,
                'Video',
                hasVideos,
                AppColors.primary,
                () => _pickVideo(context, notifier, itemId),
              ),
              const SizedBox(width: 4),
              _mediaBtn(
                Icons.mic_outlined,
                'Audio',
                hasAudio,
                AppColors.warning,
                () => _showAudioDialog(context, state, notifier, itemId),
              ),
              const SizedBox(width: 4),
              _mediaBtn(
                Icons.edit_outlined,
                'Note',
                hasNote,
                AppColors.info,
                () => _showNoteDialog(
                  context,
                  notifier,
                  itemId,
                  itemMedia?.note ?? '',
                ),
              ),
              const Spacer(),
              if (hasMedia)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(AppDimensions.rPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(itemMedia?.photoPaths.length ?? 0) + (itemMedia?.videoPaths.length ?? 0) + (itemMedia?.audioPath.isNotEmpty == true ? 1 : 0) + (itemMedia?.note.isNotEmpty == true ? 1 : 0)} files',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statusChip(
                'Good',
                ItemStatus.good,
                itemId,
                state.statuses,
                notifier,
                AppColors.primary,
                AppColors.primaryBg,
              ),
              const SizedBox(width: 6),
              _statusChip(
                'Fair',
                ItemStatus.fair,
                itemId,
                state.statuses,
                notifier,
                AppColors.warning,
                AppColors.warningBg,
              ),
              const SizedBox(width: 6),
              _statusChip(
                'Poor',
                ItemStatus.poor,
                itemId,
                state.statuses,
                notifier,
                AppColors.danger,
                AppColors.dangerBg,
              ),
              if (status != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => notifier.setStatus(itemId, null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(AppDimensions.rPill),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 10, color: AppColors.danger),
                        SizedBox(width: 3),
                        Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (hasMedia && itemMedia != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.r10),
                border: Border.all(color: const Color(0xFFE8ECF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attachment_rounded,
                          size: 14, color: AppColors.text2),
                      const SizedBox(width: 6),
                      const Text(
                        'Attachments',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text2,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _confirmClearAllMedia(
                            context, notifier, itemId, itemMedia),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.dangerBg,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.rPill),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_sweep_outlined,
                                  size: 12, color: AppColors.danger),
                              SizedBox(width: 3),
                              Text(
                                'Clear all',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Photos ──────────────────────────────────────────
                  if (itemMedia.photoPaths.isNotEmpty) ...[
                    _mediaLabel(Icons.image_outlined, 'Photos',
                        itemMedia.photoPaths.length),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 72,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: itemMedia.photoPaths.length,
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => _showFullScreenMedia(
                              context, itemMedia.photoPaths[i], isVideo: false),
                          child: Stack(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.r8),
                                  border: Border.all(
                                      color: const Color(0xFFE4E7EE)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.r7),
                                  child: Image.file(
                                    File(itemMedia.photoPaths[i]),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image,
                                            color: AppColors.text3, size: 24),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 3,
                                right: 11,
                                child: GestureDetector(
                                  onTap: () =>
                                      notifier.removePhoto(itemId, i),
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // ── Videos ──────────────────────────────────────────
                  if (itemMedia.videoPaths.isNotEmpty) ...[
                    _mediaLabel(Icons.videocam_outlined, 'Videos',
                        itemMedia.videoPaths.length),
                    const SizedBox(height: 6),
                    ...itemMedia.videoPaths.asMap().entries.map((e) {
                      final vi = e.key;
                      final vp = e.value;
                      final fileName = vp.split('/').last;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showFullScreenMedia(
                                  context, vp, isVideo: true),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBg,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.r8),
                                  border: Border.all(
                                      color: const Color(0xFFE4E7EE)),
                                ),
                                child: const Icon(Icons.play_circle_filled,
                                    color: AppColors.primary, size: 28),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  GestureDetector(
                                    onTap: () => _showFullScreenMedia(
                                        context, vp, isVideo: true),
                                    child: const Text(
                                      'Tap to play',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => notifier.removeVideo(itemId, vi),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.dangerBg,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.r8),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: AppColors.danger, size: 16),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],

                  // ── Audio ───────────────────────────────────────────
                  if (itemMedia.audioPath.isNotEmpty) ...[
                    _mediaLabel(
                        Icons.audiotrack, 'Audio Note', null),
                    const SizedBox(height: 4),
                    _AudioPlayerRow(audioPath: itemMedia.audioPath),
                    GestureDetector(
                      onTap: () {
                        notifier.setAudio(itemId, '');
                        try {
                          File(itemMedia.audioPath).deleteSync();
                        } catch (_) {}
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline,
                                size: 14, color: AppColors.text3),
                            SizedBox(width: 4),
                            Text(
                              'Remove audio',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.text3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // ── Note ────────────────────────────────────────────
                  if (itemMedia.note.isNotEmpty) ...[
                    _mediaLabel(Icons.notes_rounded, 'Note', null),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.r8),
                        border: Border.all(color: const Color(0xFFE4E7EE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              itemMedia.note,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.text2,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showNoteDialog(
                              context,
                              notifier,
                              itemId,
                              itemMedia.note,
                            ),
                            child: const Icon(Icons.edit_outlined,
                                size: 16, color: AppColors.text3),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => notifier.setNote(itemId, ''),
                            child: const Icon(Icons.delete_outline,
                                size: 16, color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mediaLabel(IconData icon, String label, int? count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.text2),
        const SizedBox(width: 6),
        Text(
          count != null ? '$label ($count)' : label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.text2,
          ),
        ),
      ],
    );
  }

  void _showFullScreenMedia(BuildContext context, String path,
      {required bool isVideo}) {
    if (isVideo) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _VideoPlayerPage(filePath: path),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: Center(
              child: InteractiveViewer(
                child: Image.file(File(path), fit: BoxFit.contain),
              ),
            ),
          ),
        ),
    );
    }
  }


  void _confirmClearAllMedia(BuildContext context, InspectionNotifier notifier,
      String itemId, ItemMedia media) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
        ),
        title: const Text(
          'Clear all attachments?',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will remove all photos, videos, audio and notes for this item.',
          style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppColors.text3,
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              for (final p in media.photoPaths) {
                try { File(p).deleteSync(); } catch (_) {}
              }
              for (final v in media.videoPaths) {
                try { File(v).deleteSync(); } catch (_) {}
              }
              if (media.audioPath.isNotEmpty) {
                try { File(media.audioPath).deleteSync(); } catch (_) {}
              }
              notifier.setMedia(itemId, const ItemMedia());
            },
            child: const Text('Clear All',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _mediaBtn(
    IconData icon,
    String tooltip,
    bool active,
    Color color,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active
                  ? color.withValues(alpha: 0.3)
                  : const Color(0xFFD4D9E6),
              width: 1.2,
            ),
          ),
          child: Icon(icon, size: 15, color: active ? color : AppColors.text3),
        ),
      ),
    );
  }

  Widget _statusChip(
    String label,
    ItemStatus value,
    String itemId,
    Map<String, ItemStatus> statuses,
    InspectionNotifier notifier,
    Color color,
    Color bg,
  ) {
    final sel = statuses[itemId] == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        notifier.setStatus(itemId, sel ? null : value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? color : bg,
          borderRadius: BorderRadius.circular(AppDimensions.rPill),
          border: Border.all(
            color: sel ? color : color.withValues(alpha: 0.2),
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sel) ...[
              const Icon(Icons.check, size: 12, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: sel ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _persistFile(String sourcePath, String prefix) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext = sourcePath.split('.').last;
      final fileName =
          '${prefix}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final destPath = '${dir.path}/$fileName';
      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (_) {
      return sourcePath;
    }
  }

  Future<void> _pickPhoto(
    BuildContext context,
    InspectionNotifier notifier,
    String itemId, {
    required bool fromCamera,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (file != null) {
        final persistedPath = await _persistFile(file.path, 'photo');
        notifier.addPhoto(itemId, persistedPath);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open ${fromCamera ? "camera" : "gallery"}: $e',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickVideo(
    BuildContext context,
    InspectionNotifier notifier,
    String itemId,
  ) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickVideo(source: ImageSource.camera);
      if (file != null) {
        final persistedPath = await _persistFile(file.path, 'video');
        notifier.addVideo(itemId, persistedPath);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open camera: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showAudioDialog(
    BuildContext context,
    InspectionState state,
    InspectionNotifier notifier,
    String itemId,
  ) {
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
    String existing,
  ) {
    final ctrl = TextEditingController(text: existing);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(AppDimensions.r8),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 15,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                itemName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: 'Add a note about this item...',
            hintStyle: const TextStyle(color: AppColors.text3),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r10),
              borderSide: const BorderSide(color: Color(0xFFE4E7EE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.text3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              notifier.setNote(itemId, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text(
              'Save Note',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConditionRequiredDialog(
      BuildContext context, Map<String, String> violations) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
        ),
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(AppDimensions.r8),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Conditions Required',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Items with attachments must have a condition selected (Good / Fair / Poor):',
                style: TextStyle(
                    fontSize: 13, color: AppColors.text2, height: 1.5),
              ),
              const SizedBox(height: 12),
              ...violations.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 12, height: 1.4,
                                color: AppColors.textPrimary),
                            children: [
                              TextSpan(
                                text: e.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: '  -  ${e.value}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.text3,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "OK, I'll Set Conditions",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioPlayerRow extends StatefulWidget {
  final String audioPath;
  const _AudioPlayerRow({required this.audioPath});

  @override
  State<_AudioPlayerRow> createState() => _AudioPlayerRowState();
}

class _AudioPlayerRowState extends State<_AudioPlayerRow> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_playing) {
        await _player.pause();
        setState(() => _playing = false);
      } else {
        await _player.play(DeviceFileSource(widget.audioPath));
        setState(() => _playing = true);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppDimensions.r8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _playing ? AppColors.warning : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _playing ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _playing ? 'Playing...' : 'Tap to listen',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _playing
                        ? AppColors.warning
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.audioPath.split('/').last,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.text3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioDialog extends StatefulWidget {
  final String itemId;
  final String existing;
  final void Function(String) onSave;
  const _AudioDialog({
    required this.itemId,
    required this.existing,
    required this.onSave,
  });

  @override
  State<_AudioDialog> createState() => _AudioDialogState();
}

class _AudioDialogState extends State<_AudioDialog>
    with SingleTickerProviderStateMixin {
  bool _recording = false;
  int _seconds = 0;
  late final String _existingPath;
  Timer? _timer;

  final AudioRecorderService _recorder = AudioRecorderService();
  String? _recordedPath;
  bool _permissionDenied = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _existingPath = widget.existing;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasMic = await Permission.microphone.request();
    if (!hasMic.isGranted) {
      setState(() => _permissionDenied = true);
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'audio_${widget.itemId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordedPath = '${dir.path}/$fileName';

      final started = await _recorder.startRecording(_recordedPath!);
      if (!started) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not start recording'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }

      setState(() {
        _recording = true;
        _seconds = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted || !_recording) {
          t.cancel();
          return;
        }
        setState(() => _seconds++);
        if (_seconds >= 60) {
          _stopRecording();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start recording: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    try {
      final path = await _recorder.stopRecording();
      setState(() => _recording = false);
      if (path != null &&
          path.isNotEmpty &&
          File(path).existsSync() &&
          mounted) {
        widget.onSave(path);
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording was empty, please try again'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      setState(() => _recording = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping recording: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _playExisting() async {
    if (_existingPath.isEmpty || !File(_existingPath).existsSync()) return;
    final player = AudioPlayer();
    try {
      await player.play(DeviceFileSource(_existingPath));
    } catch (_) {}
  }

  void _deleteExisting() {
    if (_existingPath.isNotEmpty) {
      final file = File(_existingPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    widget.onSave('');
    setState(() {
      _existingPath = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.r16),
      ),
      title: const Row(
        children: [
          Icon(Icons.mic_outlined, color: AppColors.primary, size: 22),
          SizedBox(width: 10),
          Text(
            'Audio Note',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_permissionDenied) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.mic_off, color: AppColors.danger, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Microphone permission denied. Please enable in settings.',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_existingPath.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.audio_file,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Audio recording saved',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _playExisting,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _deleteExisting,
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.danger, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            _recording
                ? 'Recording... tap stop when done'
                : 'Tap the microphone to start recording',
            style: const TextStyle(fontSize: 13, color: AppColors.text2),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              if (_recording) {
                await _stopRecording();
              } else if (!_permissionDenied) {
                await _startRecording();
              }
            },
            child: ScaleTransition(
              scale: _recording ? _pulse : const AlwaysStoppedAnimation(1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _recording ? AppColors.danger : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_recording ? AppColors.danger : AppColors.primary)
                              .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _recording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          if (_recording) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius:
                    BorderRadius.circular(AppDimensions.rPill),
              ),
              child: Text(
                '$_seconds s',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_recording) {
              _stopRecording();
            }
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.text3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoPlayerPage extends StatefulWidget {
  final String filePath;
  const _VideoPlayerPage({required this.filePath});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath));
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() => _initialized = true);
        _controller.play();
      }
    });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          widget.filePath.split('/').last,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: _initialized
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ],
              )
            : const CircularProgressIndicator(color: AppColors.primary),
      ),
      bottomNavigationBar: _initialized
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _controller.seekTo(
                        _controller.value.position -
                            const Duration(seconds: 10),
                      );
                    },
                    child: const Icon(Icons.replay_10,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                      setState(() {});
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      _controller.seekTo(
                        _controller.value.position +
                            const Duration(seconds: 10),
                      );
                    },
                    child: const Icon(Icons.forward_10,
                        color: Colors.white, size: 28),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _Footer extends ConsumerWidget {
  final InspectionCallbacks callbacks;
  const _Footer({required this.callbacks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);

    void handlePreview() {
      final violations = <String, String>{};
      for (final sec in kInspectionSections) {
        for (var i = 0; i < sec.items.length; i++) {
          final itemId = '${sec.id}_$i';
          final m = state.media[itemId];
          final hasStatus = state.statuses.containsKey(itemId);
          final hasMedia = m != null &&
              (m.photoPaths.isNotEmpty ||
                  m.videoPaths.isNotEmpty ||
                  m.audioPath.isNotEmpty ||
                  m.note.isNotEmpty);
          if (hasMedia && !hasStatus) {
            violations[sec.items[i]] =
                sec.label.replaceFirst(RegExp(r'^\d+\.\s*'), '');
  }

  void _showConditionRequiredDialog(
      BuildContext context, Map<String, String> violations) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
        ),
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(AppDimensions.r8),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Conditions Required',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Items with attachments must have a condition:',
                style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
              ),
              const SizedBox(height: 10),
              ...violations.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.danger, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 12, height: 1.4,
                                  color: AppColors.textPrimary),
                              children: [
                                TextSpan(
                                  text: e.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                                TextSpan(
                                  text: '  -  ${e.value}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.text3)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("OK, I'll Set Conditions",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
      }
      if (violations.isNotEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Conditions Required',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Items with attachments must have a condition (Good/Fair/Poor):',
                      style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5)),
                  const SizedBox(height: 10),
                  ...violations.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(margin: const EdgeInsets.only(top: 3), width: 6, height: 6,
                          decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary),
                              children: [
                                TextSpan(text: e.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text: '  -  ${e.value}', style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("OK, I'll Set Conditions",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        );
        return;
      }
      final jobId = state.jobCardId;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => InspectionPreviewView(
            onBack: () => Navigator.of(ctx).pop(),
            jobId: jobId,
          ),
        ),
      );
    }

    void handleSaveDraft() {
      Navigator.of(context).pop();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E7EE))),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: state.notifyOwner
                          ? AppColors.primaryBg
                          : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 16,
                      color: state.notifyOwner
                          ? AppColors.primary
                          : AppColors.text3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Notify Owner',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => notifier.toggleNotifyOwner(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: state.notifyOwner
                        ? AppColors.primary
                        : const Color(0xFFD4D9E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: state.notifyOwner
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: handleSaveDraft,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text2,
                    side: const BorderSide(color: Color(0xFFD4D9E6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Save Draft',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: handlePreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

