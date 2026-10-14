import 'package:flutter/material.dart';

enum ConceptDirection {
  conceptA('Concept A — Premium Minimal Automotive', 'Luxury, telemetry-driven, vehicle-as-hero, precision surfaces'),
  conceptB('Concept B — Modern Expressive Product', 'Tactile, vibrant, friendly, sculpted cards, floating action docks'),
  conceptC('Concept C — Advanced Operational SaaS', 'High-density, keyboard-first, split command center, structured data matrices');

  final String title;
  final String description;
  const ConceptDirection(this.title, this.description);
}

enum ShowcaseScreen {
  auth('Authentication', 'High-trust brand entry & recovery', Icons.lock_outline_rounded),
  staff('Staff: Advisor & Tech', 'Tactical intake, damage HUD & bay execution', Icons.directions_car_filled_rounded),
  owner('Owner: Executive Cockpit', 'Financial telemetry, revenue ticker & work register', Icons.analytics_rounded),
  customer('Customer: Digital Garage', 'Vehicle health, live service journey & approvals', Icons.garage_rounded),
  crm('CRM: Revenue Pipeline', 'Lead kanban, deal radar & omnichannel hub', Icons.hub_rounded),
  primitives('Shared Primitives', 'Buttons, inputs, status badges & metric pods', Icons.widgets_rounded);

  final String label;
  final String subtitle;
  final IconData icon;
  const ShowcaseScreen(this.label, this.subtitle, this.icon);
}

/// Visual Design Tokens for Concept A — Premium Minimal Automotive
class ConceptATokens {
  static const canvasLight = Color(0xFFFBFBFD);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardBgLight = Color(0xFFF4F6F9);
  static const borderLight = Color(0xFFE2E8F0);
  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF64748B);

  static const canvasDark = Color(0xFF090B10);
  static const surfaceDark = Color(0xFF11141D);
  static const cardBgDark = Color(0xFF181C28);
  static const borderDark = Color(0xFF262C3D);
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);

  static const hyperCobalt = Color(0xFF2563EB);
  static const electricAmber = Color(0xFFF59E0B);
  static const precisionEmerald = Color(0xFF10B981);
  static const bremboCrimson = Color(0xFFEF4444);
  static const iceBlue = Color(0xFF0284C7);

  static const radiusXs = 4.0;
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;
}

/// Visual Design Tokens for Concept B — Modern Expressive Product
class ConceptBTokens {
  static const canvasLight = Color(0xFFF8FAFC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardBgLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFEEF2F6);
  static const textPrimaryLight = Color(0xFF1E293B);
  static const textSecondaryLight = Color(0xFF64748B);

  static const canvasDark = Color(0xFF0B132B);
  static const surfaceDark = Color(0xFF1C2541);
  static const cardBgDark = Color(0xFF1E293B);
  static const borderDark = Color(0xFF334155);
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFF94A3B8);

  static const royalBlue = Color(0xFF3B82F6);
  static const sunsetCoral = Color(0xFFF97316);
  static const freshMint = Color(0xFF10B981);
  static const warmGold = Color(0xFFF59E0B);
  static const violetGlow = Color(0xFF8B5CF6);

  static const radiusXs = 6.0;
  static const radiusSm = 12.0;
  static const radiusMd = 18.0;
  static const radiusLg = 24.0;
  static const radiusPill = 999.0;
}

/// Visual Design Tokens for Concept C — Advanced Operational SaaS
class ConceptCTokens {
  static const canvasLight = Color(0xFFF1F5F9);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardBgLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFCBD5E1);
  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF475569);

  static const canvasDark = Color(0xFF030712);
  static const surfaceDark = Color(0xFF111827);
  static const cardBgDark = Color(0xFF1F2937);
  static const borderDark = Color(0xFF374151);
  static const textPrimaryDark = Color(0xFFF9FAFB);
  static const textSecondaryDark = Color(0xFF9CA3AF);

  static const commandIndigo = Color(0xFF4F46E5);
  static const signalEmerald = Color(0xFF059669);
  static const warningAmber = Color(0xFFD97706);
  static const criticalRed = Color(0xFFDC2626);
  static const cyanData = Color(0xFF0891B2);

  static const radiusXs = 2.0;
  static const radiusSm = 4.0;
  static const radiusMd = 6.0;
  static const radiusLg = 8.0;
}
