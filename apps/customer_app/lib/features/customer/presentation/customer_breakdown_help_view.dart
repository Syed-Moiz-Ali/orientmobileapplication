import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

class CustomerBreakdownHelpView extends ConsumerStatefulWidget {
  const CustomerBreakdownHelpView({super.key});
  @override
  ConsumerState<CustomerBreakdownHelpView> createState() =>
      _CustomerBreakdownHelpViewState();
}

class _CustomerBreakdownHelpViewState
    extends ConsumerState<CustomerBreakdownHelpView> {
  CustomerVehicleEntity? _selectedVehicle;
  String? _selectedIssue;
  final _locationCtrl = TextEditingController();
  bool _requestSent = false;

  static const _issues = [
    ('\u{1f50b}', 'Battery Dead'),
    ('\u{1f534}', 'Flat Tyre'),
    ('\u{1f321}\ufe0f', 'Overheating'),
    ('\u26fd', 'Fuel Empty'),
    ('\u{1f511}', 'Key Locked'),
    ('\u{1f4a5}', 'Accident'),
  ];

  static const _tips = [
    'Turn on hazard lights and move to a safe location.',
    'Stay inside your vehicle in high-traffic areas.',
    'Share your live location with emergency contacts.',
    'Don\'t accept help from strangers.',
    'Keep your phone charged for emergencies.',
  ];

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'Breakdown Help',
              trailing: StatusPill(
                label: 'SOS',
                bg: AppColors.dangerBg,
                fg: AppColors.danger,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s18,
                  AppDimensions.s18,
                  AppDimensions.s18,
                  AppDimensions.s32,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.s18),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                        border: Border.all(color: AppColors.dangerBorder),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: .12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sos_rounded,
                              color: AppColors.danger,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s10),
                          const Text(
                            'Emergency Support',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s4),
                          const Text(
                            "We're here to help 24/7",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.text3,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          Row(
                            children: [
                              Expanded(
                                child: _CallBtn(
                                  icon: Icons.call_rounded,
                                  label: 'Call Now',
                                  color: AppColors.success,
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: AppDimensions.s12),
                              Expanded(
                                child: _CallBtn(
                                  icon: Icons.chat_bubble_rounded,
                                  label: 'WhatsApp',
                                  color: AppColors.success,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s18),

                    const SectionHeader(title: 'What happened?'),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.4,
                      children: _issues.map((pair) {
                        final (emoji, label) = pair;
                        final isSel = _selectedIssue == label;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIssue = label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 130),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.dangerBg
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r12,
                              ),
                              border: Border.all(
                                color: isSel
                                    ? AppColors.danger
                                    : AppColors.border,
                                width: isSel ? 1.5 : 0.8,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(height: AppDimensions.s6),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSel
                                        ? AppColors.danger
                                        : AppColors.text2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.s18),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Breakdown details',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s14),

                          const Text(
                            'Select vehicle',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text2,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.s12,
                              vertical: AppDimensions.s4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r10,
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<CustomerVehicleEntity>(
                                value: _selectedVehicle,
                                isExpanded: true,
                                hint: const Text(
                                  'Choose vehicle',
                                  style: TextStyle(
                                    color: AppColors.text4,
                                    fontSize: 13,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.text4,
                                ),
                                items: CustomerVehicleEntity.mock
                                    .map(
                                      (v) => DropdownMenuItem(
                                        value: v,
                                        child: Text(
                                          v.shortLabel,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedVehicle = v),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s14),

                          const Text(
                            'Your location',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text2,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s6),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _locationCtrl,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.bg,
                                    hintText: 'Enter your location',
                                    hintStyle: const TextStyle(
                                      color: AppColors.text4,
                                      fontSize: 13,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.r10,
                                      ),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.r10,
                                      ),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.location_on_outlined,
                                      color: AppColors.text3,
                                      size: 18,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.s12,
                                      vertical: AppDimensions.s12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.s8),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppDimensions.s12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBg,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.r10,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primaryBorder,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.my_location_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s16),

                          SizedBox(
                            width: double.infinity,
                            child: _requestSent
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppDimensions.s14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.successBg,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.r10,
                                      ),
                                      border: Border.all(
                                        color: AppColors.successBorder,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.success,
                                          size: 18,
                                        ),
                                        SizedBox(width: AppDimensions.s8),
                                        Text(
                                          'Help is on the way!',
                                          style: TextStyle(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () =>
                                        setState(() => _requestSent = true),
                                    icon: const Icon(
                                      Icons.warning_amber_outlined,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Request Emergency Support',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.danger,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppDimensions.s14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.r10,
                                        ),
                                      ),
                                      textStyle: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.local_shipping_rounded,
                            color: AppColors.primary,
                            title: 'Towing',
                            sub: 'Free within 40km',
                          ),
                        ),
                        SizedBox(width: AppDimensions.s10),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.bolt_rounded,
                            color: AppColors.warning,
                            title: '30 min',
                            sub: 'Avg response Dubai',
                          ),
                        ),
                        SizedBox(width: AppDimensions.s10),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.access_time_filled_rounded,
                            color: AppColors.success,
                            title: '24 / 7',
                            sub: 'Always available',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.s18),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: AppColors.warning,
                                size: 17,
                              ),
                              SizedBox(width: AppDimensions.s8),
                              Text(
                                'Safety tips',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          ..._tips.map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.s8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 14,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.s8),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.text2,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}

class _CallBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _CallBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.s12),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: AppColors.successBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppDimensions.s6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, sub;
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppDimensions.s12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(AppDimensions.r13),
      border: Border.all(color: color.withValues(alpha: .2)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: AppDimensions.s8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          sub,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.text3,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
