import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_core/shared_core.dart';

class ScanVehicleView extends StatefulWidget {
  final String scanMode;
  const ScanVehicleView({super.key, this.scanMode = 'VIN'});

  @override
  State<ScanVehicleView> createState() => _ScanVehicleViewState();
}

class _ScanVehicleViewState extends State<ScanVehicleView>
    with TickerProviderStateMixin {
  late AnimationController _scanLineCtrl;
  late Animation<double> _scanLine;

  MobileScannerController? _cameraController;
  bool _torchOn = false;
  late String _scanMode;
  final TextEditingController _manualCtrl = TextEditingController();
  bool _hasScanned = false;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _scanMode = widget.scanMode;
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLine = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut));
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (!kIsWeb) {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        if (mounted) {
          setState(() {
            _cameraController = MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
            );
            _cameraReady = true;
          });
        }
      } else {
        // FIX (audit QA BUG-026): after a permanent denial Android never shows
        // the permission dialog again — request() returns permanentlyDenied.
        // Send the user to the app settings screen instead of leaving a dead
        // "Grant Permission" button.
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        if (mounted) {
          setState(() => _cameraReady = false);
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _cameraController = MobileScannerController(
            detectionSpeed: DetectionSpeed.normal,
          );
          _cameraReady = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _cameraController?.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() => _hasScanned = true);
    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.of(context).pop(value);
    });
  }

  void _manualSearch() {
    final text = _manualCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(text);
  }

  Future<void> _toggleTorch() async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.toggleTorch();
      setState(() => _torchOn = !_torchOn);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_cameraReady && _cameraController != null)
            MobileScanner(
              controller: _cameraController!,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0A0A0A),
                        Color(0xFF1A1A2E),
                        Color(0xFF0A0A0A),
                      ],
                    ),
                  ),
                  child: child,
                );
              },
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xFF1A1A2E),
                    Color(0xFF0A0A0A),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_cameraReady) ...[
                      const Icon(
                        Icons.camera_alt,
                        color: Colors.white38,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Camera permission required',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initCamera,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Grant Permission'),
                      ),
                    ] else ...[
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 12),
                      const Text(
                        'Starting camera...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppDimensions.r10),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Scan Vehicle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleTorch,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _torchOn
                                ? Colors.amber.withValues(alpha: 0.3)
                                : Colors.white12,
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppDimensions.r10),
                            ),
                          ),
                          child: Icon(
                            _torchOn
                                ? Icons.flashlight_on
                                : Icons.flashlight_off,
                            color: _torchOn ? Colors.amber : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r12),
                      ),
                    ),
                    child: Row(
                      children: ['PLATE', 'VIN', 'QR'].map((mode) {
                        final isActive = _scanMode == mode;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _scanMode = mode;
                              _hasScanned = false;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(AppDimensions.r10),
                                ),
                              ),
                              child: Text(
                                mode,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white60,
                                  fontSize: 13,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                Text(
                  _scanMode == 'PLATE'
                      ? 'Point camera at license plate'
                      : _scanMode == 'VIN'
                      ? 'Scan the VIN barcode on dashboard'
                      : 'Scan the vehicle QR code',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),

                Expanded(child: Center(child: _buildScannerFrame())),

                _buildManualEntry(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          if (_hasScanned)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerFrame() {
    const frameSize = 280.0;
    const cornerLen = 28.0;
    const cornerWidth = 4.0;

    return SizedBox(
      width: frameSize,
      height: _scanMode == 'PLATE' ? frameSize * 0.55 : frameSize,
      child: Stack(
        children: [
          Container(color: Colors.black38),
          AnimatedBuilder(
            animation: _scanLine,
            builder: (_, __) {
              final h = _scanMode == 'PLATE' ? frameSize * 0.55 : frameSize;
              return Positioned(
                top: _scanLine.value * (h - 4),
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.8),
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _Corner(
              horizontal: false,
              vertical: false,
              len: cornerLen,
              width: cornerWidth,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _Corner(
              horizontal: true,
              vertical: false,
              len: cornerLen,
              width: cornerWidth,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _Corner(
              horizontal: false,
              vertical: true,
              len: cornerLen,
              width: cornerWidth,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _Corner(
              horizontal: true,
              vertical: true,
              len: cornerLen,
              width: cornerWidth,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _scanMode == 'QR'
                      ? Icons.qr_code_scanner
                      : _scanMode == 'VIN'
                      ? Icons.view_week_outlined
                      : Icons.credit_card,
                  color: Colors.white24,
                  size: 48,
                ),
                const SizedBox(height: 8),
                if (_cameraReady)
                  const Text(
                    'Scanning...',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  )
                else
                  const Text(
                    'Camera not available',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntry() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR ENTER MANUALLY',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppDimensions.r12),
                    ),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: _manualCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _manualSearch(),
                    decoration: const InputDecoration(
                      hintText: 'Plate / VIN / Customer name...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _manualSearch,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppDimensions.r12),
                    ),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 24,
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

class _Corner extends StatelessWidget {
  final bool horizontal;
  final bool vertical;
  final double len;
  final double width;

  const _Corner({
    required this.horizontal,
    required this.vertical,
    required this.len,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
        painter: _CornerPainter(
          horizontal: horizontal,
          vertical: vertical,
          color: AppColors.primary,
          strokeWidth: width,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool horizontal;
  final bool vertical;
  final Color color;
  final double strokeWidth;

  const _CornerPainter({
    required this.horizontal,
    required this.vertical,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double x = horizontal ? size.width : 0;
    final double y = vertical ? size.height : 0;
    final double dx = horizontal ? -size.width : size.width;
    final double dy = vertical ? -size.height : size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
