import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Camera scanning surface for VIN / plate / QR capture.
///
/// Return contract is unchanged: the screen pops with the scanned (or manually
/// entered) string so the caller can prefill the intake form.
class ScanVehicleView extends StatefulWidget {
  final String scanMode;
  const ScanVehicleView({super.key, this.scanMode = 'VIN'});

  @override
  State<ScanVehicleView> createState() => _ScanVehicleViewState();
}

class _ScanVehicleViewState extends State<ScanVehicleView>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineCtrl;
  late Animation<double> _scanLine;

  MobileScannerController? _cameraController;
  bool _torchOn = false;
  late String _scanMode;
  final TextEditingController _manualCtrl = TextEditingController();
  String? _scannedValue;
  bool _cameraReady = false;
  bool _permissionDenied = false;
  bool _manualError = false;

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
      if (!mounted) return;
      if (status.isGranted) {
        setState(() {
          _permissionDenied = false;
          _cameraController = MobileScannerController(
            detectionSpeed: DetectionSpeed.normal,
          );
          _cameraReady = true;
        });
      } else {
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        setState(() {
          _permissionDenied = true;
          _cameraReady = false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        _cameraController = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
        );
        _cameraReady = true;
      });
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
    if (_scannedValue != null) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    HapticFeedback.heavyImpact();
    setState(() => _scannedValue = value);
  }

  void _manualSearch() {
    final text = _manualCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _manualError = true);
      return;
    }
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

  String _hint(StaffLocalizations t) {
    switch (_scanMode) {
      case 'PLATE':
        return t.advisorScanHintPlate;
      case 'QR':
        return t.advisorScanHintQr;
      default:
        return t.advisorScanHintVin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _cameraReady && _cameraController != null
                ? MobileScanner(
                    controller: _cameraController!,
                    onDetect: _onDetect,
                    errorBuilder: (context, error, child) =>
                        const ColoredBox(color: Color(0xFF0A0A12)),
                  )
                : const ColoredBox(color: Color(0xFF0A0A12)),
          ),
          SafeArea(
            child: Column(
              children: [
                _topBar(t),
                const SizedBox(height: AppDimensions.s8),
                _modeSwitcher(t),
                const SizedBox(height: AppDimensions.s16),
                Text(
                  _hint(t),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: AppDimensions.s16),
                Expanded(
                  child: Center(
                    child: _permissionDenied
                        ? _permissionCard(t)
                        : _scannerFrame(t),
                  ),
                ),
                _manualEntry(t),
                const SizedBox(height: AppDimensions.s20),
              ],
            ),
          ),
          if (_scannedValue != null) _resultOverlay(t),
        ],
      ),
    );
  }

  Widget _topBar(StaffLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s16,
        vertical: AppDimensions.s8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: SharedCoreL10n.of(context).commonBack,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white12,
              minimumSize: const Size.square(AppDimensions.touchTarget),
            ),
            icon: const DirectionalIcon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Text(
              t.advisorScanTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: _toggleTorch,
            tooltip: t.advisorScanTorch,
            style: IconButton.styleFrom(
              backgroundColor: _torchOn
                  ? Colors.amber.withValues(alpha: 0.3)
                  : Colors.white12,
              minimumSize: const Size.square(AppDimensions.touchTarget),
            ),
            icon: Icon(
              _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
              color: _torchOn ? Colors.amber : Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeSwitcher(StaffLocalizations t) {
    const modes = <(String, String)>[
      ('PLATE', 'advisorScanModePlate'),
      ('VIN', 'advisorScanModeVin'),
      ('QR', 'advisorScanModeQr'),
    ];
    final labels = <String, String>{
      'PLATE': t.advisorScanModePlate,
      'VIN': t.advisorScanModeVin,
      'QR': t.advisorScanModeQr,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        ),
        child: Row(
          children: [
            for (final (value, _) in modes)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _scanMode = value;
                    _scannedValue = null;
                  }),
                  child: AnimatedContainer(
                    duration: AppMotion.resolve(context, AppMotion.fast),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.s10,
                    ),
                    decoration: BoxDecoration(
                      color: _scanMode == value
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusControl,
                      ),
                    ),
                    child: Text(
                      labels[value]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _scanMode == value
                            ? Colors.white
                            : Colors.white60,
                        fontSize: 13,
                        fontWeight: _scanMode == value
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _permissionCard(StaffLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_photography_outlined, color: Colors.white54, size: 48),
          const SizedBox(height: AppDimensions.s16),
          Text(
            t.advisorScanPermissionTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          Text(
            t.advisorScanPermissionBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: AppDimensions.s20),
          AppButton.primary(
            label: t.advisorScanOpenSettings,
            icon: Icons.settings_outlined,
            onPressed: openAppSettings,
          ),
          const SizedBox(height: AppDimensions.s8),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.touchTarget,
            child: OutlinedButton(
              onPressed: _initCamera,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
              ),
              child: Text(t.advisorScanGrant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scannerFrame(StaffLocalizations t) {
    const frameSize = 260.0;
    const cornerLen = 28.0;
    const cornerWidth = 4.0;

    return SizedBox(
      width: frameSize,
      height: _scanMode == 'PLATE' ? frameSize * 0.55 : frameSize,
      child: Stack(
        children: [
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
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _Corner(horizontal: false, vertical: false, len: cornerLen, width: cornerWidth),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _Corner(horizontal: true, vertical: false, len: cornerLen, width: cornerWidth),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _Corner(horizontal: false, vertical: true, len: cornerLen, width: cornerWidth),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _Corner(horizontal: true, vertical: true, len: cornerLen, width: cornerWidth),
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
                  size: 44,
                ),
                const SizedBox(height: AppDimensions.s8),
                Text(
                  _cameraReady ? t.advisorScanScanning : t.advisorScanCameraUnavailable,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _manualEntry(StaffLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s20),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12),
                child: Text(
                  t.advisorScanManual,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
              const Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(
                      color: _manualError ? AppColors.danger : Colors.white24,
                    ),
                  ),
                  child: TextField(
                    controller: _manualCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textCapitalization: TextCapitalization.characters,
                    textDirection: TextDirection.ltr,
                    onChanged: (_) {
                      if (_manualError) setState(() => _manualError = false);
                    },
                    onSubmitted: (_) => _manualSearch(),
                    decoration: InputDecoration(
                      hintText: t.advisorScanManualHint,
                      hintStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.s14,
                        vertical: AppDimensions.s12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              SizedBox(
                width: 52,
                height: 52,
                child: FilledButton(
                  onPressed: _manualSearch,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          if (_manualError) ...[
            const SizedBox(height: AppDimensions.s6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                t.advisorScanEnterValue,
                style: const TextStyle(color: AppDarkColors.danger, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultOverlay(StaffLocalizations t) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s24),
          child: AppCard.standard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppDimensions.s16),
                Text(
                  t.advisorScanResultTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.s8),
                Text(
                  _scannedValue!,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mono(color: colors.onSurface),
                ),
                const SizedBox(height: AppDimensions.s20),
                AppButton.primary(
                  label: t.advisorScanResultUse,
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.of(context).pop(_scannedValue),
                ),
                const SizedBox(height: AppDimensions.s8),
                AppButton.secondary(
                  label: t.advisorScanScanning,
                  leadingIcon: Icons.refresh_rounded,
                  onPressed: () => setState(() => _scannedValue = null),
                ),
              ],
            ),
          ),
        ),
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
