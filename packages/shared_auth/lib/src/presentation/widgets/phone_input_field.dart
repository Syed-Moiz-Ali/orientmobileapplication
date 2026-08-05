import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

class CountryOption {
  final String flag;
  final String name;
  final String code;
  final int expectedLength;

  const CountryOption({
    required this.flag,
    required this.name,
    required this.code,
    required this.expectedLength,
  });
}

class PhoneInputField extends StatefulWidget {
  final BrandConfig brand;
  final String? error;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmitted;
  final TextEditingController? controller;
  final ValueChanged<String>? onCountryChanged;

  const PhoneInputField({
    super.key,
    required this.brand,
    required this.error,
    required this.onChanged,
    this.onSubmitted,
    this.controller,
    this.onCountryChanged,
  });

  static const List<CountryOption> countries = [
    CountryOption(flag: '🇦🇪', name: 'UAE', code: '+971', expectedLength: 9),
    CountryOption(flag: '🇸🇦', name: 'KSA', code: '+966', expectedLength: 9),
    CountryOption(flag: '🇶🇦', name: 'Qatar', code: '+974', expectedLength: 8),
    CountryOption(flag: '🇴🇲', name: 'Oman', code: '+968', expectedLength: 8),
    CountryOption(
      flag: '🇧🇭',
      name: 'Bahrain',
      code: '+973',
      expectedLength: 8,
    ),
    CountryOption(
      flag: '🇰🇼',
      name: 'Kuwait',
      code: '+965',
      expectedLength: 8,
    ),
    CountryOption(flag: '🇬🇧', name: 'UK', code: '+44', expectedLength: 10),
    CountryOption(flag: '🇺🇸', name: 'USA', code: '+1', expectedLength: 10),
    CountryOption(flag: '🇮🇳', name: 'India', code: '+91', expectedLength: 10),
  ];

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  CountryOption _selectedCountry =
      PhoneInputField.countries[0]; // Default UAE +971

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _showCountryPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = widget.brand.accentColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    'Select Country',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: PhoneInputField.countries.length,
                    itemBuilder: (_, index) {
                      final c = PhoneInputField.countries[index];
                      final isSelected = c.code == _selectedCountry.code;
                      return ListTile(
                        dense: true,
                        leading: Text(
                          c.flag,
                          style: const TextStyle(fontSize: 20),
                        ),
                        title: Text(
                          c.name,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        trailing: Text(
                          c.code,
                          style: TextStyle(
                            color: isSelected ? accentColor : AppColors.text4,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCountry = c;
                          });
                          widget.onCountryChanged?.call(c.code);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = widget.brand.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile number',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : AppColors.text2,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161E2E) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.error != null
                  ? AppColors.danger
                  : (_isFocused
                        ? accentColor
                        : (isDark
                              ? const Color(0xFF26334D)
                              : const Color(0xFFE2E8F0))),
              width: _isFocused ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showCountryPicker(context),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountry.flag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountry.code,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark ? Colors.white54 : AppColors.text4,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: isDark
                    ? const Color(0xFF26334D)
                    : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      _selectedCountry.expectedLength,
                    ),
                  ],
                  onChanged: (val) {
                    widget.onChanged(val);
                    setState(() {});
                  },
                  onSubmitted: (_) {
                    if (widget.onSubmitted != null) {
                      widget.onSubmitted!();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: _selectedCountry.code == '+971'
                        ? '50 123 4567'
                        : 'Phone number',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white30 : AppColors.text4,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.cancel, size: 18),
                  color: isDark ? Colors.white38 : AppColors.text4,
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.error!,
            style: const TextStyle(
              color: AppColors.danger,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
