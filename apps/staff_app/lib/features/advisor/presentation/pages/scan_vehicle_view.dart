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
///
/// Composition is a precision optical instrument: a shared [WorkspaceAppBar]
/// for navigation and torch, a black optical stage with targeting brackets
/// and a live status readout, a fallback manual-entry dock that is always
/// reachable (no dead-ends), and a themed result sheet. On desktop the stage
/// is center-constrained with a guidance rail instead of a stretched phone
/// view.
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
  bool _motionResolved = false;
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
    );
    _scanLine = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut));
    _initCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: hold a static sweep position instead of looping. This
    // must live here (not initState): reading MediaQuery registers an
    // inherited dependency, which initState forbids.
    if (!_motionResolved) {
      _motionResolved = true;
      if (MediaQuery.disableAnimationsOf(context)) {
        _scanLineCtrl.value = 0.5;
      } else {
        _scanLineCtrl.repeat(reverse: true);
      }
    }
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // OPTICAL-HUD: the scanner stage is a fixed-black optical instrument
      // (camera preview legibility), identical in both themes by design.
      backgroundColor: Colors.black,
      appBar: WorkspaceAppBar(
        title: t.advisorScanTitle,
        subtitle: _modeLabel(t, _scanMode),
        showBack: true,
        frosted: !context.isCompact,
        actions: [
          IconButton(
            onPressed: _cameraReady ? _toggleTorch : null,
            tooltip: t.advisorScanTorch,
            icon: Icon(
              _torchOn ? Icons.flashlight_on : Icons.flashlight_off_rounded,
              color: _torchOn ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1024;
            if (!wide) return _hudColumn(t);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: _hudColumn(t),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      0,
                      AppDimensions.s16,
                      AppDimensions.s24,
                      AppDimensions.s24,
                    ),
                    child: _guidanceRail(t),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _modeLabel(StaffLocalizations t, String mode) {
    switch (mode) {
      case 'PLATE':
        return t.advisorScanModePlate;
      case 'QR':
        return t.advisorScanModeQr;
      default:
        return t.advisorScanModeVin;
    }
  }

  Widget _hudColumn(StaffLocalizations t) {
    return Stack(
      children: [
        // Live preview fills the optical stage behind the HUD chrome.
        Positioned.fill(
          child: _cameraReady && _cameraController != null
              ? MobileScanner(
                  controller: _cameraController!,
                  onDetect: _onDetect,
                  errorBuilder: (context, error, child) =>
                      // OPTICAL-HUD: fixed-black stage, see Scaffold note.
                      const ColoredBox(color: Colors.black),
                )
              // OPTICAL-HUD: fixed-black stage, see Scaffold note.
              : const ColoredBox(color: Colors.black),
        ),
        Column(
          children: [
            const SizedBox(height: AppDimensions.s12),
            _modeSwitcher(t),
            const SizedBox(height: AppDimensions.s12),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s20,
                  ),
                  child: _permissionDenied
                      ? _permissionCard(t)
                      : _scannerFrame(t),
                ),
              ),
            ),
            _readoutStrip(t),
            _manualDock(t),
            const SizedBox(height: AppDimensions.s16),
          ],
        ),
        if (_scannedValue != null) _resultOverlay(t),
      ],
    );
  }

  Widget _modeSwitcher(StaffLocalizations t) {
    const modes = <String>['PLATE', 'VIN', 'QR'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s20),
      child: Semantics(
        container: true,
        label: t.advisorScanTitle,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            // OPTICAL-HUD: translucent white track over the black stage.
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
          child: Row(
            children: [
              for (final value in modes)
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
                        _modeLabel(t, value),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // OPTICAL-HUD: fixed white ink on the black stage.
                          color: _scanMode == value
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
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
      ),
    );
  }

  Widget _permissionCard(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard.standard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.no_photography_outlined,
              color: colors.error,
              size: 26,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Text(
            t.advisorScanPermissionTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            t.advisorScanPermissionBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppButton.primary(
            label: t.advisorScanOpenSettings,
            icon: Icons.settings_outlined,
            onPressed: openAppSettings,
          ),
          const SizedBox(height: AppDimensions.s8),
          AppButton.secondary(
            label: t.advisorScanGrant,
            leadingIcon: Icons.photo_camera_outlined,
            onPressed: _initCamera,
          ),
        ],
      ),
    );
  }

  Widget _scannerFrame(StaffLocalizations t) {
    final colors = Theme.of(context).colorScheme;
    const frameWidth = 280.0;
    final frameHeight = _scanMode == 'PLATE' ? 150.0 : 280.0;
    const cornerLen = 30.0;
    const cornerWidth = 4.0;

    return Semantics(
      container: true,
      label: t.advisorScanViewfinderLabel,
      liveRegion: true,
      value: _cameraReady ? t.advisorScanScanning : t.advisorScanStarting,
      child: SizedBox(
        width: frameWidth,
        height: frameHeight,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _scanLine,
              builder: (_, __) {
                return Positioned(
                  top: _scanLine.value * (frameHeight - 4),
                  left: 8,
                  right: 8,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          // OPTICAL-HUD: theme primary beam over black stage.
                          colors.primary.withValues(alpha: 0.8),
                          colors.primary,
                          colors.primary.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Targeting reticle: brackets + center crosshair.
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
                  // OPTICAL-HUD: fixed crosshair ink on the black stage.
                  const Icon(
                    Icons.add_rounded,
                    color: Colors.white24,
                    size: 28,
                  ),
                  const SizedBox(height: AppDimensions.s6),
                  Icon(
                    _scanMode == 'QR'
                        ? Icons.qr_code_scanner
                        : _scanMode == 'VIN'
                        ? Icons.view_week_outlined
                        : Icons.credit_card,
                    // OPTICAL-HUD: fixed dim-white glyph on the black stage.
                    color: Colors.white.withValues(alpha: 0.25),
                    size: 40,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Live status readout directly under the viewfinder: current mode hint plus
  /// the idle guidance line. Values that must not mirror (VIN/plate formats)
  /// render LTR.
  Widget _readoutStrip(StaffLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s20,
        AppDimensions.s12,
        AppDimensions.s20,
        AppDimensions.s4,
      ),
      child: Column(
        children: [
          Text(
            _hint(t),
            textAlign: TextAlign.center,
            // OPTICAL-HUD: fixed white ink on the black stage.
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            _permissionDenied
                ? t.advisorScanPermissionTitle
                : _cameraReady
                ? t.advisorScanDecodeIdle
                : t.advisorScanStarting,
            textAlign: TextAlign.center,
            // OPTICAL-HUD: fixed dim-white ink on the black stage.
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _manualDock(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s20,
        AppDimensions.s8,
        AppDimensions.s20,
        0,
      ),
      child: AppCard.standard(
        padding: const EdgeInsets.all(AppDimensions.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.advisorScanManual,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _manualCtrl,
                    hint: t.advisorScanManualHint,
                    textCapitalization: TextCapitalization.characters,
                    isIdentifier: true,
                    onChanged: (_) {
                      if (_manualError) setState(() => _manualError = false);
                    },
                    onSubmitted: (_) => _manualSearch(),
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: FilledButton(
                    onPressed: _manualSearch,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.search, size: 22),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _resultOverlay(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    return ColoredBox(
      // OPTICAL-HUD: fixed-black scrim over the camera stage.
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.s24),
          child: AppCard.standard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: semantic.success.subtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: semantic.success.base,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
                Text(
                  t.advisorScanResultTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
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
                const SizedBox(height: AppDimensions.s16),
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

  /// Desktop guidance rail: scanning tips on a themed card next to the
  /// constrained optical stage.
  Widget _guidanceRail(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tips = <(IconData, String)>[
      (Icons.straighten_outlined, t.advisorScanTipAlign),
      (Icons.flashlight_on_outlined, t.advisorScanTipLight),
      (Icons.keyboard_outlined, t.advisorScanTipManual),
    ];
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.advisorScanTipsTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          for (final tip in tips) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(tip.$1, size: 18, color: colors.primary),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Text(
                    tip.$2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s10),
          ],
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
          color: Theme.of(context).colorScheme.primary,
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
