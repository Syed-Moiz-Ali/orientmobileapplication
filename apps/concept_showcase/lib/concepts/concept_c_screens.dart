import 'package:flutter/material.dart';
import 'concept_tokens.dart';

/// Screen views for Concept C — Advanced Operational SaaS
class ConceptCScreens {
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

  // --- 1. AUTHENTICATION (Concept C) ---
  static Widget _buildAuth(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptCTokens.canvasDark : ConceptCTokens.canvasLight;
    final cardBg = isDark ? ConceptCTokens.surfaceDark : ConceptCTokens.surfaceLight;
    final textPrimary = isDark ? ConceptCTokens.textPrimaryDark : ConceptCTokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptCTokens.textSecondaryDark : ConceptCTokens.textSecondaryLight;
    final border = isDark ? ConceptCTokens.borderDark : ConceptCTokens.borderLight;

    return Container(
      color: bg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Terminal Status Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111827) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(ConceptCTokens.radiusSm),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'SYS: CLUSTER-DXB-01 [ONLINE]',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: ConceptCTokens.signalEmerald,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'LATENCY: 14ms • UAE',
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Main Command Auth Matrix
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(ConceptCTokens.radiusSm),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'TERMINAL AUTHENTICATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: ConceptCTokens.commandIndigo,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? 'بوابة التحقق السريع من الهوية' : 'Operator Credential Access',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary),
                      ),
                      const SizedBox(height: 20),

                      // Quick Role Shortcuts
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildRoleTag('ADV', true),
                            const SizedBox(width: 6),
                            _buildRoleTag('TECH', false),
                            const SizedBox(width: 6),
                            _buildRoleTag('SUPV', false),
                            const SizedBox(width: 6),
                            _buildRoleTag('OWNER', false),
                            const SizedBox(width: 6),
                            _buildRoleTag('CRM', false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dense Field 1
                      Text(
                        'OPERATOR USERNAME / ID',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textSecondary, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(ConceptCTokens.radiusXs),
                          border: Border.all(color: border),
                        ),
                        child: Text(
                          'adv_omar.almansoori@orient.ae',
                          style: TextStyle(fontSize: 13, fontFamily: 'monospace', color: textPrimary),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Dense Field 2
                      Text(
                        'ENCRYPTED SECURITY TOKEN / PASSWORD',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textSecondary, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(ConceptCTokens.radiusXs),
                          border: Border.all(color: border),
                        ),
                        child: Text(
                          '••••••••••••',
                          style: TextStyle(fontSize: 13, letterSpacing: 2, fontFamily: 'monospace', color: textPrimary),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Command Button
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: ConceptCTokens.commandIndigo,
                          borderRadius: BorderRadius.circular(ConceptCTokens.radiusXs),
                        ),
                        child: const Center(
                          child: Text(
                            '[ ENTER ] EXECUTE LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              letterSpacing: 0.8,
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

  // --- 2. STAFF: OPERATIONAL CONSOLE (Concept C) ---
  static Widget _buildStaff(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptCTokens.canvasDark : ConceptCTokens.canvasLight;
    final cardBg = isDark ? ConceptCTokens.surfaceDark : ConceptCTokens.surfaceLight;
    final textPrimary = isDark ? ConceptCTokens.textPrimaryDark : ConceptCTokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptCTokens.textSecondaryDark : ConceptCTokens.textSecondaryLight;
    final border = isDark ? ConceptCTokens.borderDark : ConceptCTokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Command Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptCTokens.radiusSm),
                border: Border.all(color: border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('TRIAGE: 4 QUEUED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: ConceptCTokens.warningAmber)),
                    const SizedBox(width: 16),
                    Text('INSPECTION: 2 ACTIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: ConceptCTokens.commandIndigo)),
                    const SizedBox(width: 16),
                    Text('BAYS: 14/16 OCCUPIED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: ConceptCTokens.signalEmerald)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // High-Density Work Order Table
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptCTokens.radiusSm),
                border: Border.all(color: border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 500,
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          border: Border(bottom: BorderSide(color: border)),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('JOB ID', style: _tableHeadStyle(textSecondary))),
                            Expanded(flex: 3, child: Text('VEHICLE & PLATE', style: _tableHeadStyle(textSecondary))),
                            Expanded(flex: 2, child: Text('STAGE', style: _tableHeadStyle(textSecondary))),
                            Expanded(flex: 2, child: Text('ELAPSED', style: _tableHeadStyle(textSecondary))),
                            Expanded(flex: 2, child: Text('ACTION', style: _tableHeadStyle(textSecondary))),
                          ],
                        ),
                      ),

                      // Row 1
                      _buildDenseTableRow(
                        'RO-8940',
                        'Porsche 911 [DXB A 4410]',
                        'INSPECTION',
                        '22m',
                        ConceptCTokens.warningAmber,
                        border,
                        textPrimary,
                      ),
                      // Row 2
                      _buildDenseTableRow(
                        'RO-8941',
                        'G-Wagon G63 [AUH 12 88]',
                        'ACTIVE REPAIR',
                        '1h 45m',
                        ConceptCTokens.commandIndigo,
                        border,
                        textPrimary,
                      ),
                      // Row 3
                      _buildDenseTableRow(
                        'RO-8942',
                        'Lexus LX600 [SHJ 9 2011]',
                        'QC COMPLETED',
                        '04m',
                        ConceptCTokens.signalEmerald,
                        border,
                        textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. OWNER: BLOOMBERG COMMAND DESK (Concept C) ---
  static Widget _buildOwner(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptCTokens.canvasDark : ConceptCTokens.canvasLight;
    final cardBg = isDark ? ConceptCTokens.surfaceDark : ConceptCTokens.surfaceLight;
    final textPrimary = isDark ? ConceptCTokens.textPrimaryDark : ConceptCTokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptCTokens.textSecondaryDark : ConceptCTokens.textSecondaryLight;
    final border = isDark ? ConceptCTokens.borderDark : ConceptCTokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Operations Ticker Strip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptCTokens.radiusSm),
                border: Border.all(color: border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTickerPod('NET REVENUE', 'AED 64,810.00', '+14.2%', ConceptCTokens.signalEmerald, textPrimary, textSecondary),
                    const SizedBox(width: 24),
                    _buildTickerPod('GROSS MARGIN', '46.8%', '+1.4%', ConceptCTokens.signalEmerald, textPrimary, textSecondary),
                    const SizedBox(width: 24),
                    _buildTickerPod('WIP ACCRUAL', 'AED 142,500', '16 JOBS', ConceptCTokens.commandIndigo, textPrimary, textSecondary),
                    const SizedBox(width: 24),
                    _buildTickerPod('UNINVOICED', 'AED 18,240', '3 DUE', ConceptCTokens.warningAmber, textPrimary, textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Dense Work Register Table
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptCTokens.radiusSm),
                border: Border.all(color: border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('LIVE WORK REGISTER [ALL BAYS]', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: textSecondary)),
                      ),
                      _buildDenseTableRow('RO-7721', 'Ferrari F8 Tributo', 'AED 18,400', 'PAID', ConceptCTokens.signalEmerald, border, textPrimary),
                      _buildDenseTableRow('RO-7722', 'Bentley Continental GT', 'AED 9,250', 'ESTIMATE PENDING', ConceptCTokens.warningAmber, border, textPrimary),
                      _buildDenseTableRow('RO-7723', 'Aston Martin DB11', 'AED 34,100', 'PARTS ON ORDER', ConceptCTokens.commandIndigo, border, textPrimary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. CUSTOMER: TRANSPARENT PORTAL (Concept C) ---
  static Widget _buildCustomer(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptCTokens.canvasDark : ConceptCTokens.canvasLight;
    final cardBg = isDark ? ConceptCTokens.surfaceDark : ConceptCTokens.surfaceLight;
    final textPrimary = isDark ? ConceptCTokens.textPrimaryDark : ConceptCTokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptCTokens.textSecondaryDark : ConceptCTokens.textSecondaryLight;
    final border = isDark ? ConceptCTokens.borderDark : ConceptCTokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('CUSTOMER SERVICE LEDGER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: ConceptCTokens.commandIndigo)),
            const SizedBox(height: 4),
            Text('Vehicle Audit & Invoice Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary)),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptCTokens.radiusSm),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ACTIVE WORK CARD: #RO-9021', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: textSecondary)),
                  const SizedBox(height: 8),
                  Text('Land Rover Defender 110 (2024)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textPrimary)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildEstimateLine('Engine Oil & Synthetic Filter', 'AED 850.00', true),
                  _buildEstimateLine('Front Ceramic Brake Discs (Pair)', 'AED 3,400.00', true),
                  _buildEstimateLine('Brake Sensor Caliper Kit', 'AED 420.00', true),
                  _buildEstimateLine('VAT 5.0% (UAE Statutory)', 'AED 233.50', false),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'TOTAL AUTHORIZED',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('AED 4,903.50', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ConceptCTokens.commandIndigo)),
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

  // --- 5. CRM: DATA MATRIX (Concept C) ---
  static Widget _buildCrm(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptCTokens.canvasDark : ConceptCTokens.canvasLight;
    final cardBg = isDark ? ConceptCTokens.surfaceDark : ConceptCTokens.surfaceLight;
    final textPrimary = isDark ? ConceptCTokens.textPrimaryDark : ConceptCTokens.textPrimaryLight;
    final border = isDark ? ConceptCTokens.borderDark : ConceptCTokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('LEAD CONVERSION MATRIX', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: ConceptCTokens.commandIndigo)),
            const SizedBox(height: 4),
            Text('High-Density Deal Pipeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary)),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptCTokens.radiusSm),
                border: Border.all(color: border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 500,
                  child: Column(
                    children: [
                      _buildDenseTableRow('LEAD-101', 'Faisal Al-Otaiba [Audi R8]', 'AED 42,000', 'QUALIFIED', ConceptCTokens.signalEmerald, border, textPrimary),
                      _buildDenseTableRow('LEAD-102', 'Tariq Mansoor [Mercedes S500]', 'AED 14,800', 'CONTACTED', ConceptCTokens.commandIndigo, border, textPrimary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. PRIMITIVES (Concept C) ---
  static Widget _buildPrimitives(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptCTokens.canvasDark : ConceptCTokens.canvasLight;
    final textPrimary = isDark ? ConceptCTokens.textPrimaryDark : ConceptCTokens.textPrimaryLight;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONCEPT C: SHARED PRIMITIVES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textPrimary)),
          const SizedBox(height: 6),
          const Text('Sharp 4px corners, dense tabular indicators, monospace identifiers.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: ConceptCTokens.commandIndigo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ConceptCTokens.radiusSm)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('[ CMD ] EXECUTE ACTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontFamily: 'monospace', fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  static Widget _buildRoleTag(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? ConceptCTokens.commandIndigo : Colors.transparent,
        borderRadius: BorderRadius.circular(ConceptCTokens.radiusXs),
        border: Border.all(color: active ? ConceptCTokens.commandIndigo : Colors.grey.shade600),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          fontFamily: 'monospace',
          color: active ? Colors.white : Colors.grey.shade400,
        ),
      ),
    );
  }

  static TextStyle _tableHeadStyle(Color color) {
    return TextStyle(fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: color);
  }

  static Widget _buildDenseTableRow(
    String col1,
    String col2,
    String col3,
    String col4,
    Color statusColor,
    Color border,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(col1, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w700, color: textPrimary))),
          const SizedBox(width: 4),
          Expanded(flex: 3, child: Text(col2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textPrimary))),
          const SizedBox(width: 4),
          Expanded(flex: 2, child: Text(col3, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w800, color: statusColor))),
          const SizedBox(width: 4),
          Expanded(flex: 2, child: Text(col4, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: textPrimary))),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: ConceptCTokens.commandIndigo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text('OPEN', maxLines: 1, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: ConceptCTokens.commandIndigo, fontFamily: 'monospace')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTickerPod(
    String title,
    String value,
    String delta,
    Color deltaColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: textPrimary)),
        const SizedBox(height: 2),
        Text(delta, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: deltaColor)),
      ],
    );
  }

  static Widget _buildEstimateLine(String name, String price, bool isItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: isItem ? FontWeight.w600 : FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Text(price, style: TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: isItem ? FontWeight.w700 : FontWeight.w800)),
        ],
      ),
    );
  }
}
