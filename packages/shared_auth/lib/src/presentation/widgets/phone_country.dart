import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Country dial-code metadata for phone-entry fields across the suite.
///
/// Extracted from the retired `PhoneInputField` widget so the advisor intake
/// form (owned by Phase 07A) can keep using the canonical UAE +971 default
/// without depending on a legacy auth widget.
class PhoneCountry {
  final String flag;
  final String name;
  final String code;
  final int expectedLength;

  const PhoneCountry({required this.flag, required this.name, required this.code, required this.expectedLength});
}

/// Supported dial codes. UAE (+971) is the first entry and the default.
const List<PhoneCountry> phoneCountries = [
  PhoneCountry(flag: '🇦🇪', name: 'UAE', code: '+971', expectedLength: 9),
  PhoneCountry(flag: '🇸🇦', name: 'KSA', code: '+966', expectedLength: 9),
  PhoneCountry(flag: '🇶🇦', name: 'Qatar', code: '+974', expectedLength: 8),
  PhoneCountry(flag: '🇴🇲', name: 'Oman', code: '+968', expectedLength: 8),
  PhoneCountry(flag: '🇧🇭', name: 'Bahrain', code: '+973', expectedLength: 8),
  PhoneCountry(flag: '🇰🇼', name: 'Kuwait', code: '+965', expectedLength: 8),
  PhoneCountry(flag: '🇬🇧', name: 'UK', code: '+44', expectedLength: 10),
  PhoneCountry(flag: '🇺🇸', name: 'USA', code: '+1', expectedLength: 10),
  PhoneCountry(flag: '🇮🇳', name: 'India', code: '+91', expectedLength: 10),
];

/// Looks up a country by dial code, falling back to the UAE default.
PhoneCountry phoneCountryFor(String code) {
  for (final country in phoneCountries) {
    if (country.code == code) return country;
  }
  return phoneCountries.first;
}

/// Compact dial-code selector used beside phone identifier fields.
///
/// Opens the shared searchable [AppSelectionSheet] (bottom sheet on compact,
/// centered dialog on wider classes via [showAppSelectionSheet]), so search,
/// empty-state, 48dp rows and dialog/sheet placement all come from the single
/// centralized primitive — no per-screen picker duplicate. The dial code keeps
/// an LTR direction so `+971` never mirrors inside RTL layouts.
class AuthCountryCodeButton extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const AuthCountryCodeButton({super.key, required this.value, required this.onChanged, this.enabled = true});

  Future<void> _pick(BuildContext context) async {
    final selected = await showAppSelectionSheet<String>(
      context: context,
      selected: value,
      options: [
        for (final country in phoneCountries)
          AppSelectionOption<String>(
            value: country.code,
            // Flag + name + code are caller data ( Fase 07A intake reuses the
            // same list); chrome (title/search/empty) stays localized inside
            // the shared sheet, so no new ARB keys are introduced here.
            label: '${country.flag}  ${country.name}  ${country.code}',
          ),
      ],
    );
    if (selected != null && selected != value) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final current = phoneCountryFor(value);

    return Semantics(
      button: true,
      enabled: enabled,
      label: current.code,
      value: current.name,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: InkWell(
          onTap: enabled ? () => _pick(context) : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s10),
            decoration: BoxDecoration(
              color: enabled
                  ? colors.surfaceContainerLow
                  : context.semanticColors.disabledFill,
              border: Border.all(
                color: enabled
                    ? colors.outlineVariant
                    : context.semanticColors.disabledBorder,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.call_outlined,
                  size: AppDimensions.iconSm,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s6),
                Text(
                  current.code,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: enabled ? colors.onSurface : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: AppDimensions.s4),
                Icon(Icons.arrow_drop_down_rounded, size: AppDimensions.iconMd, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
