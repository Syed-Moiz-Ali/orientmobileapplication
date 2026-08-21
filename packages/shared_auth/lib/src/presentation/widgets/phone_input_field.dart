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
  final Color accentColor;
  final String? error;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmitted;
  final TextEditingController? controller;
  final ValueChanged<String>? onCountryChanged;

  const PhoneInputField({
    super.key,
    required this.error,
    required this.onChanged,
    this.accentColor = AppColors.primary,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accentColor = widget.accentColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Divider(height: 1, color: colors.outlineVariant),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: PhoneInputField.countries.length,
                    itemBuilder: (_, index) {
                      final c = PhoneInputField.countries[index];
                      final isSelected = c.code == _selectedCountry.code;
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.public_rounded,
                          color: isSelected
                              ? accentColor
                              : colors.onSurfaceVariant,
                        ),
                        title: Text(
                          c.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: Text(
                          c.code,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? accentColor
                                : colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accentColor = widget.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile number',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.touchTarget,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(
              color: widget.error != null
                  ? colors.error
                  : (_isFocused ? accentColor : colors.outlineVariant),
              width: _isFocused ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => _showCountryPicker(context),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(AppDimensions.radiusInput),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.public_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountry.code,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: colors.outlineVariant),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
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
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.65),
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
                  color: colors.onSurfaceVariant,
                  tooltip: 'Clear mobile number',
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
