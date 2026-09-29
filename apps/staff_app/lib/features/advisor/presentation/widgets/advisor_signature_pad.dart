import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorSignaturePad extends StatefulWidget {
  final String title;

  const AdvisorSignaturePad({super.key, required this.title});

  @override
  State<AdvisorSignaturePad> createState() => _AdvisorSignaturePadState();
}

class _AdvisorSignaturePadState extends State<AdvisorSignaturePad> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _current = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onPanStart: (details) => _current = [details.localPosition],
              onPanUpdate: (details) =>
                  setState(() => _current.add(details.localPosition)),
              onPanEnd: (_) => setState(() {
                _strokes.add(List<Offset>.from(_current));
                _current = [];
              }),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomPaint(
                    painter: _AdvisorSignaturePainter(
                      strokes: _strokes,
                      current: _current,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _strokes.clear();
                      _current = [];
                    }),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _strokes.isEmpty
                        ? null
                        : () async {
                            final bytes = await _renderPng();
                            if (context.mounted) Navigator.pop(context, bytes);
                          },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Use Signature'),
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
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    _AdvisorSignaturePainter(
      strokes: _strokes,
      current: const [],
    ).paint(canvas, size);
    final image = await recorder.endRecording().toImage(800, 320);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List() ?? Uint8List(0);
  }
}

class _AdvisorSignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> current;

  const _AdvisorSignaturePainter({
    required this.strokes,
    required this.current,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
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
