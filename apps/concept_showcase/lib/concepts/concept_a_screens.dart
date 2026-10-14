import 'package:flutter/material.dart';
import 'concept_tokens.dart';

/// Screen views for Concept A — Premium Minimal Automotive
class ConceptAScreens {
  static Widget buildScreen(ShowcaseScreen screen, bool isDark, bool isArabic) {
    switch (screen) {
      case ShowcaseScreen.auth:
        return _buildAuth(isDark, isArabic);
      case ShowcaseScreen.staff:
        return _buildStaff(isDark, isArabic);
      case ShowcaseScreen.owner:
        return _buildOwner(isDark, isArabic);
      case ShowcaseScreen.customer:
        return _buildCustomer(isDark, isArabic);
      case ShowcaseScreen.crm:
        return _buildCrm(isDark, isArabic);
      case ShowcaseScreen.primitives:
        return _buildPrimitives(isDark, isArabic);
    }
  }

  // --- 1. AUTHENTICATION (Concept A) ---
  static Widget _buildAuth(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptATokens.canvasDark : ConceptATokens.canvasLight;
    final cardBg = isDark ? ConceptATokens.surfaceDark : ConceptATokens.surfaceLight;
    final textPrimary = isDark ? ConceptATokens.textPrimaryDark : ConceptATokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptATokens.textSecondaryDark : ConceptATokens.textSecondaryLight;
    final border = isDark ? ConceptATokens.borderDark : ConceptATokens.borderLight;

    return Container(
      color: bg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Telemetry Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B26) : const Color(0xFFEEF2F6),
                      borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: ConceptATokens.precisionEmerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isArabic ? 'بوابة ورشة أورينت • آمنة' : 'ORIENT SUITE • TLS 1.3',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Brand Heading
                Text(
                  isArabic ? 'تسجيل الدخول للمنظومة' : 'Workshop Command Access',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'أدخل بيانات الاعتماد أو استخدم الهوية الحيوية'
                      : 'Enter verified staff or customer credentials to proceed',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
                const SizedBox(height: 32),

                // Main Precision Auth Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(ConceptATokens.radiusMd),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Role Selector Pills
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: ConceptATokens.hyperCobalt,
                                borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                              ),
                              child: Text(
                                isArabic ? 'مستشار الخدمة' : 'Service Advisor',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                              ),
                              child: Text(
                                isArabic ? 'العميل' : 'Customer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Input 1: ID / Phone
                      Text(
                        isArabic ? 'رقم الهاتف أو المعرّف' : 'Staff Identifier / UAE Mobile',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F131D) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.badge_outlined, size: 18, color: textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isArabic ? '+971 50 847 2910' : 'ADV-9482 (Omar Al-Hassan)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Input 2: Password / PIN
                      Text(
                        isArabic ? 'كلمة المرور المشفرة' : 'Security PIN / Passcode',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F131D) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock_clock_outlined, size: 18, color: textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '••••••••',
                                style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isArabic ? 'نسيت الرمز؟' : 'Reset',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ConceptATokens.hyperCobalt,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Primary Action Button
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: ConceptATokens.hyperCobalt,
                          borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isArabic ? 'دخول آمن للمنظومة' : 'Authorize Session',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Biometric Tap
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          icon: const Icon(Icons.fingerprint_rounded, color: ConceptATokens.hyperCobalt),
                          label: Text(
                            isArabic ? 'الدخول السريع ببصمة الوجه / الإصبع' : 'Fast Pass via FaceID / Biometrics',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 2. STAFF: ADVISOR & INSPECTION HUD (Concept A) ---
  static Widget _buildStaff(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptATokens.canvasDark : ConceptATokens.canvasLight;
    final cardBg = isDark ? ConceptATokens.surfaceDark : ConceptATokens.surfaceLight;
    final textPrimary = isDark ? ConceptATokens.textPrimaryDark : ConceptATokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptATokens.textSecondaryDark : ConceptATokens.textSecondaryLight;
    final border = isDark ? ConceptATokens.borderDark : ConceptATokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Workshop Radar Header Bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'مستشار الورشة • صالة الفحص' : 'Advisor Station • Active Intake HUD',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: ConceptATokens.hyperCobalt,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? 'فحص واستلام المركبة' : 'Vehicle Inspection & Telemetry',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ConceptATokens.electricAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                    border: Border.all(color: ConceptATokens.electricAmber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: ConceptATokens.electricAmber),
                      const SizedBox(width: 6),
                      Text(
                        isArabic ? '18 دقيقة' : 'BAY 04 • 18M',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ConceptATokens.electricAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Vehicle Identity & Telemetry Strip
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptATokens.radiusMd),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2232) : const Color(0xFFEDF2F7),
                      borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                    ),
                    child: const Icon(Icons.directions_car_filled_rounded, color: ConceptATokens.hyperCobalt, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Porsche Cayenne Turbo GT',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF263045) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'DXB • M 84920',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic ? 'العميل: راشد المنصوري • 42,850 كم' : 'Owner: Rashid Al-Mansoori • ODO: 42,850 KM',
                          style: TextStyle(fontSize: 13, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Spatial Damage Canvas (Vehicle as Hero)
            Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptATokens.radiusMd),
                border: Border.all(color: border),
              ),
              child: Stack(
                children: [
                  // Spatial Grid Lines
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPainter(isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  // Stylized Vehicle Outline Box
                  Center(
                    child: Container(
                      width: 220,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        color: isDark ? const Color(0xFF141923).withOpacity(0.8) : const Color(0xFFF1F5F9).withOpacity(0.8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_car_rounded, size: 48, color: textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 4),
                            Text(
                              isArabic ? 'خريطة الأضرار التفاعلية' : 'SPATIAL DAMAGE HUD',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Damage Pinpoint 1: Front Right Scratch
                  Positioned(
                    top: 50,
                    right: 80,
                    child: _buildDamagePin('Dent (Front Fender)', ConceptATokens.electricAmber, isDark),
                  ),

                  // Damage Pinpoint 2: Windshield Chip
                  Positioned(
                    bottom: 40,
                    left: 70,
                    child: _buildDamagePin('Crack (Windshield)', ConceptATokens.bremboCrimson, isDark),
                  ),

                  // Canvas Controls Overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2536) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                      ),
                      child: Text(
                        isArabic ? 'المس لتحديد نقطة فحص' : 'Tap to drop damage pin',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tactile Checkpoint Toggles
            Text(
              isArabic ? 'نقاط الفحص السريع (3/18 مكتمل)' : 'RAPID CHECKPOINTS (3 / 18 RECORDED)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildCheckpointRing(
                    isArabic ? 'الفرامل' : 'Brake Pads',
                    '7.2 mm',
                    ConceptATokens.precisionEmerald,
                    Icons.check_circle_rounded,
                    cardBg,
                    border,
                    textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCheckpointRing(
                    isArabic ? 'حالة الإطارات' : 'Tire Depth',
                    '2.8 mm',
                    ConceptATokens.electricAmber,
                    Icons.warning_amber_rounded,
                    cardBg,
                    border,
                    textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCheckpointRing(
                    isArabic ? 'زيت المحرك' : 'Engine Oil',
                    'Degraded',
                    ConceptATokens.bremboCrimson,
                    Icons.error_outline_rounded,
                    cardBg,
                    border,
                    textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. OWNER: EXECUTIVE COCKPIT (Concept A) ---
  static Widget _buildOwner(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptATokens.canvasDark : ConceptATokens.canvasLight;
    final cardBg = isDark ? ConceptATokens.surfaceDark : ConceptATokens.surfaceLight;
    final textPrimary = isDark ? ConceptATokens.textPrimaryDark : ConceptATokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptATokens.textSecondaryDark : ConceptATokens.textSecondaryLight;
    final border = isDark ? ConceptATokens.borderDark : ConceptATokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Executive Title Bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'القيادة التشغيلية • مجموعة دبي' : 'EXECUTIVE COCKPIT • DUBAI FLAGSHIP',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: ConceptATokens.hyperCobalt,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? 'نبض الورشة والمالية' : 'Workshop Velocity & Margins',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isArabic ? 'اليوم • مباشر' : 'TODAY • LIVE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textPrimary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Live Revenue Telemetry Ticker
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptATokens.radiusMd),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isArabic ? 'الإيراد المحقق اليوم' : 'DAILY BILLED REVENUE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ConceptATokens.precisionEmerald.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '+18.4% vs Target',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: ConceptATokens.precisionEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AED 48,250.00',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Single-Stroke Sparkline Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F131D) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                    ),
                    child: CustomPaint(
                      painter: _SparklinePainter(ConceptATokens.hyperCobalt),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3-Metric Executive Pods
            Row(
              children: [
                Expanded(
                  child: _buildMetricPod(
                    isArabic ? 'هامش الربح' : 'Gross Margin',
                    '44.2%',
                    isArabic ? '+2.1% إيجابي' : '+2.1% Ahead',
                    ConceptATokens.precisionEmerald,
                    cardBg,
                    border,
                    textPrimary,
                    textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricPod(
                    isArabic ? 'إشغال الورشة' : 'Floor Occupancy',
                    '88.5%',
                    isArabic ? '14 من 16 رافعة' : '14/16 Active Bays',
                    ConceptATokens.hyperCobalt,
                    cardBg,
                    border,
                    textPrimary,
                    textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricPod(
                    isArabic ? 'في الانتظار' : 'Approvals WIP',
                    'AED 18.4K',
                    isArabic ? '6 طلبات معلقة' : '6 Estimates Due',
                    ConceptATokens.electricAmber,
                    cardBg,
                    border,
                    textPrimary,
                    textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. CUSTOMER: LUXURY DIGITAL GARAGE (Concept A) ---
  static Widget _buildCustomer(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptATokens.canvasDark : ConceptATokens.canvasLight;
    final cardBg = isDark ? ConceptATokens.surfaceDark : ConceptATokens.surfaceLight;
    final textPrimary = isDark ? ConceptATokens.textPrimaryDark : ConceptATokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptATokens.textSecondaryDark : ConceptATokens.textSecondaryLight;
    final border = isDark ? ConceptATokens.borderDark : ConceptATokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Customer Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'المرآب الرقمي الذكي' : 'DIGITAL GARAGE CONCIERGE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: ConceptATokens.hyperCobalt,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mercedes-AMG GT 63 S',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ConceptATokens.precisionEmerald.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
                    border: Border.all(color: ConceptATokens.precisionEmerald.withOpacity(0.3)),
                  ),
                  child: Text(
                    isArabic ? '96% ممتازة' : '96% HEALTH',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: ConceptATokens.precisionEmerald,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hero Vehicle Studio Showcase
            Container(
              height: 180,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptATokens.radiusMd),
                border: Border.all(color: border),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cardBg,
                    isDark ? const Color(0xFF131926) : const Color(0xFFEEF2F6),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car_filled, size: 68, color: ConceptATokens.hyperCobalt),
                    const SizedBox(height: 8),
                    Text(
                      'DUBAI • CODE K • 77492',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Live Workshop Journey Ribbon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptATokens.radiusMd),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isArabic ? 'متابعة الخدمة الحية' : 'LIVE SERVICE TELEMETRY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'مكتمل بنسبة 65%' : 'STAGE 4 OF 6',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ConceptATokens.hyperCobalt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Chrono Step Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.65,
                      minHeight: 6,
                      backgroundColor: isDark ? const Color(0xFF1E2536) : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation(ConceptATokens.hyperCobalt),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(Icons.build_circle_outlined, size: 18, color: ConceptATokens.hyperCobalt),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isArabic
                              ? 'الآن: فحص ميزان العجلات الإلكتروني • المتبقي 25 دقيقة'
                              : 'Current: Computerized Wheel Balancing • 25m ETA',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. CRM: REVENUE PIPELINE (Concept A) ---
  static Widget _buildCrm(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptATokens.canvasDark : ConceptATokens.canvasLight;
    final cardBg = isDark ? ConceptATokens.surfaceDark : ConceptATokens.surfaceLight;
    final textPrimary = isDark ? ConceptATokens.textPrimaryDark : ConceptATokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptATokens.textSecondaryDark : ConceptATokens.textSecondaryLight;
    final border = isDark ? ConceptATokens.borderDark : ConceptATokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'إدارة العملاء والصفقات' : 'REVENUE PIPELINE & DEALS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: ConceptATokens.hyperCobalt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? 'رادار الصفقات النشطة' : 'Active Lead Radar',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConceptATokens.hyperCobalt,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ConceptATokens.radiusSm)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: Text(
                    isArabic ? 'إضافة عميل' : 'New Lead',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildLeadRow(
              'Khalid Al-Nuaimi',
              'BMW M5 Competition • Engine Overhaul Inquiry',
              'AED 24,500',
              '85% Probability',
              ConceptATokens.precisionEmerald,
              cardBg,
              border,
              textPrimary,
              textSecondary,
            ),
            const SizedBox(height: 12),
            _buildLeadRow(
              'Sarah Jenkins',
              'Range Rover Sport • Ceramic Protection Package',
              'AED 8,200',
              'Follow-up Due',
              ConceptATokens.electricAmber,
              cardBg,
              border,
              textPrimary,
              textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. SHARED PRIMITIVES (Concept A) ---
  static Widget _buildPrimitives(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptATokens.canvasDark : ConceptATokens.canvasLight;
    final textPrimary = isDark ? ConceptATokens.textPrimaryDark : ConceptATokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptATokens.textSecondaryDark : ConceptATokens.textSecondaryLight;
    final border = isDark ? ConceptATokens.borderDark : ConceptATokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONCEPT A: SHARED PRIMITIVE SYSTEM',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Precision-milled corners (8px/12px), instrument telemetry pills, tabular numerals.',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 24),

            // Buttons Row
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConceptATokens.hyperCobalt,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ConceptATokens.radiusSm)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Primary Trigger', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ConceptATokens.radiusSm)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Secondary Outline', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Badges
            Wrap(
              spacing: 8,
              children: [
                _buildStatusPill('PASS / VERIFIED', ConceptATokens.precisionEmerald),
                _buildStatusPill('ATTENTION REQUIRED', ConceptATokens.electricAmber),
                _buildStatusPill('CRITICAL DEFECT', ConceptATokens.bremboCrimson),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  static Widget _buildDamagePin(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161C28) : Colors.white,
        borderRadius: BorderRadius.circular(ConceptATokens.radiusSm),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  static Widget _buildCheckpointRing(
    String label,
    String value,
    Color color,
    IconData icon,
    Color cardBg,
    Color border,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(ConceptATokens.radiusMd),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  static Widget _buildMetricPod(
    String title,
    String value,
    String subtitle,
    Color accent,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(ConceptATokens.radiusMd),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textSecondary)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: accent)),
        ],
      ),
    );
  }

  static Widget _buildLeadRow(
    String name,
    String subtitle,
    String amount,
    String status,
    Color statusColor,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(ConceptATokens.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textPrimary)),
              const SizedBox(height: 4),
              Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 24) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += 24) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9, size.width * 0.45, size.height * 0.35);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.65, size.width, size.height * 0.15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
