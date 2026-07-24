import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/router/app_router.dart';

/// Simulates a real-time camera scanner for VIN / Plate / QR.
/// In production replace the camera preview with mobile_scanner package.
class ScanVehicleView extends StatefulWidget {
  const ScanVehicleView({super.key});

  @override
  State<ScanVehicleView> createState() => _ScanVehicleViewState();
}

class _ScanVehicleViewState extends State<ScanVehicleView>
    with TickerProviderStateMixin {
  late AnimationController _scanLineCtrl;
  late Animation<double> _scanLine;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  bool _scanned = false;
  bool _torchOn = false;
  String _scanMode = 'PLATE'; // PLATE | VIN | QR
  final TextEditingController _manualCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLine = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut),
    );
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
    _scanLineCtrl.dispose();
    _pulseCtrl.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _simulateScan() async {
    HapticFeedback.heavyImpact();
    setState(() => _scanned = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    // Navigate to Vehicle/Customer details with pre-filled plate
    context.pushReplacement(AppRoutes.vehicleCustomer);
  }

  void _manualSearch() {
    if (_manualCtrl.text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.pushReplacement(AppRoutes.vehicleCustomer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera preview (simulated dark background) ─────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E), Color(0xFF0A0A0A)],
              ),
            ),
          ),

          // ── Top bar ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Scan Vehicle',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      // Torch toggle
                      GestureDetector(
                        onTap: () => setState(() => _torchOn = !_torchOn),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _torchOn
                                ? Colors.amber.withValues(alpha: 0.3)
                                : Colors.white12,
                            borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
                          ),
                          child: Icon(
                            _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
                            color: _torchOn ? Colors.amber : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Scan mode tabs ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12)),
                    ),
                    child: Row(
                      children: ['PLATE', 'VIN', 'QR'].map((mode) {
                        final isActive = _scanMode == mode;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _scanMode = mode;
                              _scanned = false;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
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

                const SizedBox(height: 24),

                // ── Hint text ──────────────────────────────────────────
                Text(
                  _scanMode == 'PLATE'
                      ? 'Point camera at license plate'
                      : _scanMode == 'VIN'
                          ? 'Scan the VIN barcode on dashboard'
                          : 'Scan the vehicle QR code',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Scanner frame ──────────────────────────────────────
                Expanded(
                  child: Center(
                    child: _buildScannerFrame(),
                  ),
                ),

                // ── Manual entry ───────────────────────────────────────
                _buildManualEntry(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ── Success overlay ───────────────────────────────────────────
          if (_scanned)
            Container(
              color: Colors.black54,
              child: Center(
                child: ScaleTransition(
                  scale: _pulse,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 48),
                  ),
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

    return GestureDetector(
      onTap: _simulateScan,
      child: SizedBox(
        width: frameSize,
        height: _scanMode == 'PLATE' ? frameSize * 0.55 : frameSize,
        child: Stack(
          children: [
            // Dimmed background outside frame
            Container(color: Colors.black38),

            // Scan line animation
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

            // Corner brackets
            // Top-left
            Positioned(
              top: 0, left: 0,
              child: _Corner(horizontal: false, vertical: false,
                  len: cornerLen, width: cornerWidth),
            ),
            // Top-right
            Positioned(
              top: 0, right: 0,
              child: _Corner(horizontal: true, vertical: false,
                  len: cornerLen, width: cornerWidth),
            ),
            // Bottom-left
            Positioned(
              bottom: 0, left: 0,
              child: _Corner(horizontal: false, vertical: true,
                  len: cornerLen, width: cornerWidth),
            ),
            // Bottom-right
            Positioned(
              bottom: 0, right: 0,
              child: _Corner(horizontal: true, vertical: true,
                  len: cornerLen, width: cornerWidth),
            ),

            // Tap to scan hint
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
                  const Text('Tap to simulate scan',
                      style: TextStyle(
                          color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
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
                child: Text('OR ENTER MANUALLY',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 11,
                        letterSpacing: 1)),
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
                    borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12)),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: _manualCtrl,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Plate / VIN / Customer name...',
                      hintStyle: TextStyle(
                          color: Colors.white38, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                    borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12)),
                  ),
                  child: const Icon(Icons.search,
                      color: Colors.white, size: 24),
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

