// lib/features/advisor/inspection_pages/inspection_sheet_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/presentation/widgets/inspection_widgets.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/inspection_provider.dart';

class InspectionSheetView extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onSaveDraft;
  final VoidCallback onPreview;

  const InspectionSheetView({
    super.key,
    required this.onBack,
    required this.onSaveDraft,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);

    return Scaffold(
      backgroundColor: IC.canvas,
      appBar: AppBar(
        backgroundColor: IC.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        title: const Text('Vehicle Inspection Sheet (Insp…',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis),
      ),
      body: Column(children: [
        // ── Sticky top controls ────────────────────────────────────────────
        const _ControlsStrip(),
        // ── Column header ─────────────────────────────────────────────────
        Container(
          color: IC.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('# Inspection Item',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: IC.text2)),
              Text('Actions',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: IC.text2)),
            ],
          ),
        ),
        // ── Sections list ─────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            children: [
              ...state.filteredSections.map((sec) => _SectionCard(section: sec)),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // ── Footer ────────────────────────────────────────────────────────
        _Footer(onSaveDraft: onSaveDraft, onPreview: onPreview),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONTROLS STRIP
// ─────────────────────────────────────────────────────────────────────────────
class _ControlsStrip extends ConsumerWidget {
  const _ControlsStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);

    return Container(
      color: IC.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(children: [
        // SHOW / COLLAPSE row
        Row(children: [
          _ToggleBtn(label: 'SHOW', icon: Icons.visibility_outlined,
              active: state.showAll,
              onTap: () => notifier.setShowAll()),
          const SizedBox(width: 8),
          _ToggleBtn(label: 'COLLAPSE', icon: Icons.unfold_less_rounded,
              active: !state.showAll,
              onTap: () => notifier.setCollapseAll()),
        ]),
        const SizedBox(height: 10),
        SearchField(hint: 'Search',
            onChanged: (q) => notifier.setGlobalSearch(q)),
        const SizedBox(height: 10),
        // Progress
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${state.completedCount} / ${state.totalItems} items rated',
              style: const TextStyle(fontSize: 10, color: IC.text2)),
          Text('${(state.progressPercent * 100).round()}%',
              style: const TextStyle(fontSize: 10, color: IC.accent, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r3)),
          child: LinearProgressIndicator(
            value: state.progressPercent,
            minHeight: 4,
            backgroundColor: IC.line,
            valueColor: const AlwaysStoppedAnimation<Color>(IC.accent),
          ),
        ),
      ]),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? IC.accent : IC.canvas,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r7)),
        border: Border.all(color: active ? IC.accent : IC.stroke, width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: active ? Colors.white : IC.text2),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
            color: active ? Colors.white : IC.text2,
            fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends ConsumerStatefulWidget {
  final InspectionSection section;
  const _SectionCard({required this.section});

  @override
  ConsumerState<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends ConsumerState<_SectionCard> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final sec = widget.section;
    final isCollapsed = state.collapsed[sec.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(children: [
        // Header
        GestureDetector(
          onTap: () => notifier.toggleCollapse(sec.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: IC.surface,
              borderRadius: isCollapsed
                  ? BorderRadius.all(Radius.circular(AppDimensions.r10))
                  : const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border.all(color: IC.line, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(sec.label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: IC.text1)),
                AnimatedRotation(
                  turns: isCollapsed ? -0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down, color: IC.text2, size: 18),
                ),
              ],
            ),
          ),
        ),
        // Items
        if (!isCollapsed)
          Container(
            decoration: BoxDecoration(
              color: IC.surface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              border: Border.all(color: IC.line, width: 1.5),
            ),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Column(children: [
              const SizedBox(height: 8),
              // Section search
              Container(
                decoration: BoxDecoration(
                  color: IC.canvas, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
                  border: Border.all(color: IC.line, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(children: [
                  const Icon(Icons.search, color: IC.text3, size: 14),
                  const SizedBox(width: 6),
                  Expanded(child: TextField(
                    controller: _searchCtrl,
                    onChanged: (q) => notifier.setSectionSearch(sec.id, q),
                    style: const TextStyle(fontSize: 11, color: IC.text1),
                    decoration: InputDecoration(
                      hintText: 'Search ${sec.label}',
                      hintStyle: const TextStyle(fontSize: 11, color: IC.text3),
                      isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero,
                    ),
                  )),
                ]),
              ),
              const SizedBox(height: 4),
              // Items
              ...sec.items.asMap().entries.map((e) {
                final index = e.key;
                final itemName = e.value;
                final itemId = '${sec.id}_$index';
                final isLast = index == sec.items.length - 1;
                return _ItemRow(
                  itemId: itemId,
                  itemName: itemName,
                  index: index,
                  isLast: isLast,
                );
              }),
            ]),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ITEM ROW
// ─────────────────────────────────────────────────────────────────────────────
class _ItemRow extends ConsumerWidget {
  final String itemId;
  final String itemName;
  final int index;
  final bool isLast;
  const _ItemRow({required this.itemId, required this.itemName, required this.index, required this.isLast});

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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: IC.line, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                color: sc?.bg ?? IC.canvas,
                shape: BoxShape.circle,
                border: Border.all(color: sc?.color ?? IC.stroke, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text('${index + 1}',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                      color: sc?.color ?? IC.text3)),
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(itemName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: IC.text1))),
            if (sc != null) ...[
              const SizedBox(width: 6),
              AppBadge(label: sc.label, color: sc.color, bg: sc.bg, small: true),
            ],
          ]),
          const SizedBox(height: 8),
          // Action icons row
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              ActionIconBtn(
                icon: Icons.camera_alt_outlined,
                label: 'Photo',
                active: hasPhotos,
                onTap: () => _pickPhoto(context, notifier, itemId, fromCamera: true),
              ),
              const SizedBox(width: 6),
              ActionIconBtn(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                active: hasPhotos,
                onTap: () => _pickPhoto(context, notifier, itemId, fromCamera: false),
              ),
              const SizedBox(width: 6),
              ActionIconBtn(
                icon: Icons.videocam_outlined,
                label: 'Video',
                active: hasVideos,
                onTap: () => _pickVideo(context, notifier, itemId),
              ),
              const SizedBox(width: 6),
              ActionIconBtn(
                icon: Icons.mic_outlined,
                label: 'Audio',
                active: hasAudio,
                onTap: () => _showAudioDialog(context, state, notifier, itemId),
              ),
              const SizedBox(width: 6),
              ActionIconBtn(
                icon: Icons.edit_outlined,
                label: 'Note',
                active: hasNote,
                onTap: () => _showNoteDialog(context, notifier, itemId, itemMedia?.note ?? ''),
              ),
            ]),
            // Also show SERVICES and PARTS buttons if status is selected (like screenshot image 3)
            if (status != null)
              Row(children: [
                GestureDetector(
                  onTap: () => _showServicesInspectionLink(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: IC.accent, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6)),
                    ),
                    child: Row(children: const [
                      Icon(Icons.add, color: Colors.white, size: 11),
                      SizedBox(width: 3),
                      Text('SERVICES', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => _showPartsInspectionLink(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: IC.accent, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6)),
                    ),
                    child: Row(children: const [
                      Icon(Icons.add, color: Colors.white, size: 11),
                      SizedBox(width: 3),
                      Text('PARTS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            if (status == null)
              StatusBoxes(
                itemId: itemId,
                statuses: state.statuses,
                setStatus: (id, s) {
                  HapticFeedback.selectionClick();
                  notifier.setStatus(id, s);
                },
              ),
          ]),
          // Show status boxes BELOW action row when status selected (like screenshot)
          if (status != null) ...[
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              StatusBoxes(
                itemId: itemId,
                statuses: state.statuses,
                setStatus: (id, s) {
                  HapticFeedback.selectionClick();
                  notifier.setStatus(id, s);
                },
              ),
            ]),
          ],
          // Photo thumbnails
          if (hasPhotos) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemMedia!.photoPaths.length,
                itemBuilder: (_, i) => Stack(
                  children: [
                    Container(
                      width: 52, height: 52,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
                        border: Border.all(color: IC.line),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r7)),
                        child: Image.file(File(itemMedia.photoPaths[i]), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(top: 2, right: 8,
                      child: GestureDetector(
                        onTap: () => notifier.removePhoto(itemId, i),
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(color: IC.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Note preview
          if (hasNote) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: IC.canvas, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6)),
                border: Border.all(color: IC.line),
              ),
              child: Row(children: [
                const Icon(Icons.notes_rounded, size: 12, color: IC.text3),
                const SizedBox(width: 4),
                Expanded(child: Text(itemMedia!.note,
                    style: const TextStyle(fontSize: 11, color: IC.text2),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context, InspectionNotifier notifier, String itemId, {required bool fromCamera}) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (file != null) {
        notifier.addPhoto(itemId, file.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open ${fromCamera ? "camera" : "gallery"}: $e'),
          backgroundColor: IC.red,
        ));
      }
    }
  }

  Future<void> _pickVideo(BuildContext context, InspectionNotifier notifier, String itemId) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickVideo(source: ImageSource.camera);
      if (file != null) {
        notifier.addVideo(itemId, file.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open camera: $e'), backgroundColor: IC.red),
        );
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

  void _showNoteDialog(BuildContext context, InspectionNotifier notifier, String itemId, String existing) {
    final ctrl = TextEditingController(text: existing);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: IC.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r16))),
        title: Text(itemName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: IC.text1)),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          autofocus: true,
          style: const TextStyle(fontSize: 13, color: IC.text1),
          decoration: InputDecoration(
            hintText: 'Add a note…',
            hintStyle: const TextStyle(color: IC.text3),
            filled: true, fillColor: IC.canvas,
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)), borderSide: const BorderSide(color: IC.line)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)), borderSide: const BorderSide(color: IC.accent, width: 1.5)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: IC.text2))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: IC.navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)))),
            onPressed: () {
              notifier.setNote(itemId, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showServicesInspectionLink(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Go to Repair Order to add services'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }

  void _showPartsInspectionLink(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Go to Repair Order to add parts'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AUDIO DIALOG (simulated recorder)
// ─────────────────────────────────────────────────────────────────────────────
class _AudioDialog extends StatefulWidget {
  final String itemId;
  final String existing;
  final void Function(String) onSave;
  const _AudioDialog({required this.itemId, required this.existing, required this.onSave});

  @override
  State<_AudioDialog> createState() => _AudioDialogState();
}

class _AudioDialogState extends State<_AudioDialog> {
  bool _recording = false;
  int _seconds = 0;
  late final String _existingPath;

  @override
  void initState() {
    super.initState();
    _existingPath = widget.existing;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: IC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r16))),
      title: const Text('Audio Note', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: IC.text1)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_existingPath.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: IC.tealBg, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8))),
            child: const Row(children: [
              Icon(Icons.audio_file, color: IC.accent, size: 16),
              SizedBox(width: 8),
              Text('Audio recorded', style: TextStyle(color: IC.accent, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        const Text('Tap the button to record audio', style: TextStyle(fontSize: 12, color: IC.text2)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            if (_recording) {
              setState(() => _recording = false);
              // Simulate saved path
              widget.onSave('audio_${widget.itemId}_${DateTime.now().millisecondsSinceEpoch}.m4a');
              Navigator.pop(context);
            } else {
              setState(() { _recording = true; _seconds = 0; });
              // Simulate seconds counter
              Future.doWhile(() async {
                await Future.delayed(const Duration(seconds: 1));
                if (!mounted || !_recording) return false;
                setState(() => _seconds++);
                return _seconds < 60;
              });
            }
          },
          child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: _recording ? IC.red : IC.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(_recording ? Icons.stop : Icons.mic, color: Colors.white, size: 28),
          ),
        ),
        if (_recording) ...[
          const SizedBox(height: 8),
          Text('$_seconds s', style: const TextStyle(fontSize: 14, color: IC.red, fontWeight: FontWeight.w700)),
        ],
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: IC.text2))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FOOTER
// ─────────────────────────────────────────────────────────────────────────────
class _Footer extends ConsumerWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback onPreview;

  const _Footer({
    required this.onSaveDraft,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: IC.surface,
        border: Border(top: BorderSide(color: IC.line)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Notify Owner?"),
              Switch(
                value: state.notifyOwner,
                onChanged: (_) => notifier.toggleNotifyOwner(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSaveDraft,
                  child: const Text("SAVE DRAFT"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPreview,
                  child: const Text("PREVIEW"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
