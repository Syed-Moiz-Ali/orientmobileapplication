import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/advisor/vehicle_customer/data/models/vehicle_customer_model.dart';
import 'package:orientmobileapplication/features/advisor/vehicle_customer/presentation/widgets/shared_widgets.dart';

class SelectBrandSheet extends StatefulWidget {
  final String? selected;
  const SelectBrandSheet({super.key, this.selected});

  @override
  State<SelectBrandSheet> createState() => _SelectBrandSheetState();
}

class _SelectBrandSheetState extends State<SelectBrandSheet> {
  String _query = '';
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  List<String> get _filtered => kCarBrands
      .where((b) => b.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('Select Brand',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: kHintColor, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: kHintColor, size: 18),
                filled: true,
                fillColor: kFieldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (_, i) {
                final brand = _filtered[i];
                final isSelected = brand == _selected;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected ? AppColors.primary : const Color(0xFFCDD2D8),
                    size: 20,
                  ),
                  title: Text(brand,
                      style: const TextStyle(
                          fontSize: 14, color: kTextColor)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 20)
                      : const Icon(Icons.radio_button_unchecked,
                          color: Color(0xFFCDD2D8), size: 20),
                  onTap: () => Navigator.of(context).pop(brand),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SelectModelSheet extends StatefulWidget {
  final String brand;
  final String? selected;

  const SelectModelSheet(
      {super.key, required this.brand, this.selected});

  @override
  State<SelectModelSheet> createState() => _SelectModelSheetState();
}

class _SelectModelSheetState extends State<SelectModelSheet> {
  String _query = '';
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  List<String> get _models => modelsForBrand(widget.brand);

  List<String> get _filtered => _models
      .where((m) => m.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('Models',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: kHintColor, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: kHintColor, size: 18),
                filled: true,
                fillColor: kFieldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (_, i) {
                final model = _filtered[i];
                final isSelected = model == _selected;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected ? AppColors.primary : const Color(0xFFCDD2D8),
                    size: 20,
                  ),
                  title: Text(model,
                      style: const TextStyle(
                          fontSize: 14, color: kTextColor)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 20)
                      : const Icon(Icons.radio_button_unchecked,
                          color: Color(0xFFCDD2D8), size: 20),
                  onTap: () => Navigator.of(context).pop(model),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerTagSheet extends StatefulWidget {
  final List<String> selected;
  const CustomerTagSheet({super.key, required this.selected});

  @override
  State<CustomerTagSheet> createState() => _CustomerTagSheetState();
}

class _CustomerTagSheetState extends State<CustomerTagSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Select Customer Tag',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextColor)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(_selected),
                child: const Icon(Icons.close, color: kLabelColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...kCustomerTags.map((tag) {
            final isSelected = _selected.contains(tag.label);
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: tag.color),
                      borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6)),
                    ),
                    child: Text(tag.label,
                        style: TextStyle(
                            color: tag.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(tag.label);
                        } else {
                          _selected.add(tag.label);
                        }
                      });
                    },
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primary : const Color(0xFFCDD2D8),
                    ),
                  ),
                ),
                const Divider(height: 1),
              ],
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

Future<String?> showModelYearDialog(
    BuildContext context, String? current) async {
  String? selected = current;
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12))),
            title: const Text('Select Model Year',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColor)),
            content: SizedBox(
              width: 280,
              height: 280,
              child: RadioGroup<String>(
                groupValue: selected,
                onChanged: (v) => setState(() => selected = v),
                child: ListView(
                  children: kModelYears.map((y) {
                    return RadioListTile<String>(
                      value: y,
                      activeColor: AppColors.primary,
                      title: Text(y,
                          style: const TextStyle(
                              fontSize: 14, color: kTextColor)),
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(selected),
                child: const Text('OK',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      );
    },
  );
}
