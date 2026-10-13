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

  const PhoneCountry({
    required this.flag,
    required this.name,
    required this.code,
    required this.expectedLength,
  });
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
