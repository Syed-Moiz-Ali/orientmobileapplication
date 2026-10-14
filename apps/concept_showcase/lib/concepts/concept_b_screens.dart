import 'package:flutter/material.dart';
import 'concept_tokens.dart';

/// Screen views for Concept B — Modern Expressive Product
class ConceptBScreens {
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

  // --- 1. AUTHENTICATION (Concept B) ---
  static Widget _buildAuth(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptBTokens.canvasDark : ConceptBTokens.canvasLight;
    final cardBg = isDark ? ConceptBTokens.surfaceDark : ConceptBTokens.surfaceLight;
    final textPrimary = isDark ? ConceptBTokens.textPrimaryDark : ConceptBTokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptBTokens.textSecondaryDark : ConceptBTokens.textSecondaryLight;
    final border = isDark ? ConceptBTokens.borderDark : ConceptBTokens.borderLight;

    return Container(
      color: bg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Welcoming Friendly Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ConceptBTokens.royalBlue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: ConceptBTokens.royalBlue, size: 36),
                ),
                const SizedBox(height: 16),

                Text(
                  isArabic ? 'صباح الخير، مرحباً بك مجدداً!' : 'Welcome to Orient Workshop',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  isArabic ? 'سجّل دخولك لمتابعة عملياتك بسهولة' : 'Sign in to access your vehicles and service desk',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
                const SizedBox(height: 28),

                // Sculpted Soft Auth Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(ConceptBTokens.radiusLg),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: ConceptBTokens.royalBlue.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Role Selector Tabs (Pill Style)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(ConceptBTokens.radiusPill),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: ConceptBTokens.royalBlue,
                                  borderRadius: BorderRadius.circular(ConceptBTokens.radiusPill),
                                ),
                                child: Text(
                                  isArabic ? 'طاقم العمل' : 'Staff Portal',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                isArabic ? 'أصحاب السيارات' : 'Vehicle Owner',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: textSecondary, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input 1
                      Text(
                        isArabic ? 'رقم الهاتف الإماراتي' : 'UAE Phone Number',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(ConceptBTokens.radiusMd),
                          border: Border.all(color: ConceptBTokens.royalBlue.withOpacity(0.4), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Text('🇦🇪 +971', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '50 829 1948',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Input 2: OTP boxes
                      Text(
                        isArabic ? 'رمز التحقق (OTP)' : 'Verification Code',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          final chars = ['4', '9', '2', ''];
                          final filled = chars[index].isNotEmpty;
                          return Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(ConceptBTokens.radiusSm),
                              border: Border.all(
                                color: filled ? ConceptBTokens.royalBlue : border,
                                width: filled ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                chars[index],
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Pill Submit Button
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [ConceptBTokens.royalBlue, Color(0xFF4F46E5)],
                          ),
                          borderRadius: BorderRadius.circular(ConceptBTokens.radiusPill),
                          boxShadow: [
                            BoxShadow(
                              color: ConceptBTokens.royalBlue.withOpacity(0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isArabic ? 'دخول فوري للمنظومة' : 'Continue into Workspace',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
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

  // --- 2. STAFF: EXPRESSIVE ADVISOR & TECH DECK (Concept B) ---
  static Widget _buildStaff(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptBTokens.canvasDark : ConceptBTokens.canvasLight;
    final cardBg = isDark ? ConceptBTokens.surfaceDark : ConceptBTokens.surfaceLight;
    final textPrimary = isDark ? ConceptBTokens.textPrimaryDark : ConceptBTokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptBTokens.textSecondaryDark : ConceptBTokens.textSecondaryLight;
    final border = isDark ? ConceptBTokens.borderDark : ConceptBTokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active Shift Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ConceptBTokens.royalBlue, Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(ConceptBTokens.radiusLg),
                boxShadow: [
                  BoxShadow(color: ConceptBTokens.royalBlue.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'الوردية النشطة • ورشة القوز' : 'ACTIVE SHIFT • AL QUOZ HUB',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '05h 42m Clocked • 4 Jobs Finished',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              isArabic ? 'المركبة الحالية قيد الإنجاز' : 'HERO WORK ORDER',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),

            // Expressive Job Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptBTokens.radiusLg),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ConceptBTokens.sunsetCoral.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(ConceptBTokens.radiusPill),
                          ),
                          child: const Text(
                            'URGENT • VIP CUSTOMER',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ConceptBTokens.sunsetCoral),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'JOB #9281',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Audi RS7 Sportback (2023)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Major 60,000 KM Service + Ceramic Brake Inspection',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 18),

                  // Tactile Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ConceptBTokens.radiusPill),
                    child: const LinearProgressIndicator(
                      value: 0.75,
                      minHeight: 10,
                      backgroundColor: Color(0xFFEEF2F6),
                      valueColor: AlwaysStoppedAnimation(ConceptBTokens.freshMint),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Step 3 of 4: Brake Fluid Flush',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '75% Complete',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: ConceptBTokens.freshMint),
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

  // --- 3. OWNER: VIBRANT EXECUTIVE PULSE (Concept B) ---
  static Widget _buildOwner(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptBTokens.canvasDark : ConceptBTokens.canvasLight;
    final cardBg = isDark ? ConceptBTokens.surfaceDark : ConceptBTokens.surfaceLight;
    final textPrimary = isDark ? ConceptBTokens.textPrimaryDark : ConceptBTokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptBTokens.textSecondaryDark : ConceptBTokens.textSecondaryLight;
    final border = isDark ? ConceptBTokens.borderDark : ConceptBTokens.borderLight;

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
                        isArabic ? 'لوحة القيادة الذكية' : 'WORKSHOP PULSE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: ConceptBTokens.royalBlue),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isArabic ? 'أداء الورشة اليوم' : 'Daily Revenue Velocity',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: border),
                  ),
                  child: const Icon(Icons.notifications_active_outlined, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Expressive Metric Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptBTokens.radiusLg),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Today Billed Revenue',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ConceptBTokens.freshMint.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(ConceptBTokens.radiusPill),
                        ),
                        child: const Text(
                          '🚀 +24.8% WOW',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: ConceptBTokens.freshMint),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AED 54,920.00',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: textPrimary),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ConceptBTokens.radiusPill),
                    child: const LinearProgressIndicator(
                      value: 0.88,
                      minHeight: 8,
                      backgroundColor: Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation(ConceptBTokens.royalBlue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Target: AED 62,000 (88% Achieved)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. CUSTOMER: REASSURING CONCIERGE (Concept B) ---
  static Widget _buildCustomer(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptBTokens.canvasDark : ConceptBTokens.canvasLight;
    final textPrimary = isDark ? ConceptBTokens.textPrimaryDark : ConceptBTokens.textPrimaryLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('MY GARAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: ConceptBTokens.royalBlue)),
            const SizedBox(height: 4),
            Text('Tesla Model S Plaid', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary)),
            const SizedBox(height: 20),

            // Friendly Vehicle Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(ConceptBTokens.radiusLg),
              ),
              child: Column(
                children: [
                  const Icon(Icons.electric_car_rounded, size: 64, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text('Vehicle In Great Shape', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Next Scheduled Maintenance: 3,200 KM', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. CRM: VISUAL PIPELINE (Concept B) ---
  static Widget _buildCrm(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptBTokens.canvasDark : ConceptBTokens.canvasLight;
    final cardBg = isDark ? ConceptBTokens.surfaceDark : ConceptBTokens.surfaceLight;
    final textPrimary = isDark ? ConceptBTokens.textPrimaryDark : ConceptBTokens.textPrimaryLight;
    final textSecondary = isDark ? ConceptBTokens.textSecondaryDark : ConceptBTokens.textSecondaryLight;
    final border = isDark ? ConceptBTokens.borderDark : ConceptBTokens.borderLight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('SALES PIPELINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: ConceptBTokens.royalBlue)),
            const SizedBox(height: 4),
            Text('Kanban Leads Board', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary)),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(ConceptBTokens.radiusLg),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: ConceptBTokens.royalBlue.withOpacity(0.15), child: const Text('HA')),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hassan Al-Zahrani', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textPrimary)),
                        Text('Porsche Macan GTS • Ceramic Tint', style: TextStyle(fontSize: 12, color: textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ConceptBTokens.freshMint.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(ConceptBTokens.radiusPill),
                    ),
                    child: const Text('AED 6,400', style: TextStyle(fontWeight: FontWeight.w900, color: ConceptBTokens.freshMint, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. PRIMITIVES (Concept B) ---
  static Widget _buildPrimitives(bool isDark, bool isArabic) {
    final bg = isDark ? ConceptBTokens.canvasDark : ConceptBTokens.canvasLight;
    final textPrimary = isDark ? ConceptBTokens.textPrimaryDark : ConceptBTokens.textPrimaryLight;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONCEPT B: SHARED PRIMITIVES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textPrimary)),
          const SizedBox(height: 6),
          const Text('Sculpted capsules, pill buttons, soft gradient shadows.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: ConceptBTokens.royalBlue,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text('Expressive Pill Button', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
