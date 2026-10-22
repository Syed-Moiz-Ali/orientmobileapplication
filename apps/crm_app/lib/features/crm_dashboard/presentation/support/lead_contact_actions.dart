// Presentation-only lead contact intents (CRM leads list).
//
// Byte-identical URI behavior to the dossier sheet (`LeadDetailSheet`):
// dialer over the canonical digits, WhatsApp over wa.me with the full
// international number, 3s bounded launch, friendly notice on failure.
// The sheet keeps its own private copy untouched; the rebuilt list cards
// call these so the frequent Call action lives directly on the card.
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

void _notice(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
}

String _digitsOf(String phone) =>
    PhoneNumber.normalizeLoose(phone).replaceAll(RegExp(r'[^\d]'), '');

/// Dials [phone] over the canonical digits. No-op for undialable targets.
Future<void> callLeadPhone(BuildContext context, String phone) async {
  final digits = _digitsOf(phone);
  if (digits.isEmpty) return;
  bool opened = false;
  try {
    opened = await launchUrl(
      Uri(scheme: 'tel', path: digits),
    ).timeout(const Duration(seconds: 3), onTimeout: () => false);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) _notice(context, context.cx.dtCallFail);
}

/// Opens a WhatsApp chat for [phone]. No-op for undialable targets.
Future<void> whatsAppLeadPhone(BuildContext context, String phone) async {
  final digits = _digitsOf(phone);
  if (digits.isEmpty) return;
  bool opened = false;
  try {
    opened = await launchUrl(
      Uri.parse('https://wa.me/$digits'),
      mode: LaunchMode.externalApplication,
    ).timeout(const Duration(seconds: 3), onTimeout: () => false);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) _notice(context, context.cx.dtWaFail);
}
