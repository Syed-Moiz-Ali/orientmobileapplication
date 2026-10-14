import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Focused signature capture surface used by the intake flow.
///
/// Returns the rendered PNG bytes via `Navigator.pop(context, bytes)` exactly as
/// before (the caller persists them through `saveSignatureFile`). The surface is
/// rebuilt on the shared modal grammar: instruction, full-width signing area,
/// clear + confirm actions.
class AdvisorSignaturePad extends StatefulWidget {
  final String title;

  const AdvisorSignaturePad({super.key, required this.title});

  @override
  State<AdvisorSignaturePad> createState() => _AdvisorSignaturePadState();
}

class _AdvisorSignaturePadState extends State<AdvisorSignaturePad> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _current = [];
  bool _drawing = false;

  bool get _hasInk => _strokes.isNotEmpty || _current.isNotEmpty;

  void _clear() => setState(() {
    _strokes.clear();
    _current = [];
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              t.advisorIntakeSignatureInstruction,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            Semantics(
              label: widget.title,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _drawing = true;
                    _current = [details.localPosition];
                  });
                },
                onPanUpdate: (details) =>
                    setState(() => _current.add(details.localPosition)),
                onPanEnd: (_) => setState(() {
                  _strokes.add(List<Offset>.from(_current));
                  _current = [];
                  _drawing = false;
                }),
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusCard,
                    ),
                    border: Border.all(
                      color: _drawing ? colors.primary : colors.outline,
                      width: _drawing ? 1.5 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (!_hasInk)
                        Center(
                          child: Text(
                            t.advisorIntakeSignatureInstruction,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusCard,
                        ),
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _AdvisorSignaturePainter(
                            strokes: _strokes,
                            current: _current,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: t.advisorIntakeSignatureClear,
                    leadingIcon: Icons.refresh_rounded,
                    onPressed: _hasInk ? _clear : null,
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: AppButton.primary(
                    label: t.advisorIntakeSignatureUse,
                    icon: Icons.check_rounded,
                    onPressed: _strokes.isEmpty
                        ? null
                        : () async {
                            final bytes = await _renderPng();
                            if (context.mounted) {
                              Navigator.pop(context, bytes);
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _renderPng() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(800, 320);
    // FIXED-INK: exported PNG document bytes (non-rendered), not UI.
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    _AdvisorSignaturePainter(
      strokes: _strokes,
      current: const [],
      // FIXED-INK: exported PNG document bytes (non-rendered), not UI.
      color: Colors.black,
    ).paint(canvas, size);
    final image = await recorder.endRecording().toImage(800, 320);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List() ?? Uint8List(0);
  }
}

class _AdvisorSignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> current;
  final Color color;

  const _AdvisorSignaturePainter({
    required this.strokes,
    required this.current,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in [...strokes, current]) {
      if (stroke.isEmpty) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AdvisorSignaturePainter oldDelegate) => true;
}
