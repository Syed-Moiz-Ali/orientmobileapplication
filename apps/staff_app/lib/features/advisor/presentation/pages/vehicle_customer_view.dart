import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:hive/hive.dart';
import 'inspection_provider.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/vehicle_customer_provider.dart';
import 'package:staff_app/features/advisor/presentation/widgets/vehicle_customer_shared_widgets.dart';
import 'package:staff_app/features/advisor/presentation/widgets/select_brand_sheet.dart';
import 'package:staff_app/features/advisor/data/models/vehicle_customer_model.dart';

class VehicleCustomerView extends ConsumerWidget {
  const VehicleCustomerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _Body();
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body();
  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  String? _savedJobId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleCustomerFormProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Vehicle/Customer Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: kTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hint text ───────────────────────────────────────────
                const Text(
                  'Type VIN/License Plate no./Customer Name If not found create new vehicle.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.text2,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Search mode (Image 1) ────────────────────────────────
                _SearchModeSection(state: state, ref: ref),
                const SizedBox(height: 16),

                // ── Customer Details (Images 3-5) ────────────────────────
                _CustomerDetailsSection(state: state, ref: ref),

                // ── Vehicle Details (Images 6-14) ────────────────────────
                _VehicleDetailsSection(state: state, ref: ref),

                // ── Additional Information (Image 15) ────────────────────
                _AdditionalInfoSection(state: state, ref: ref),
              ],
            ),
          ),

          // ── FAB (teal) ────────────────────────────────────────────────
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {},
              child: const Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),

          // ── NEXT button ────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
              child: ElevatedButton(
                onPressed: () async {
                  final formState = ref.read(vehicleCustomerFormProvider);
                  final local = GenericLocalDataSource(
                    Hive.box<dynamic>('inspections'),
                  );
                  final id = await IdGenerator.nextId('JC');
                  _savedJobId = id;
                  final now = DateTime.now();
                  final createdDate =
                      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                  final payload = {
                    'type': 'vehicle_customer',
                    'customerName': formState.customerName,
                    'phoneNumber': formState.phoneNumber,
                    'email': formState.email,
                    'vin': formState.vin,
                    'make': formState.make,
                    'model': formState.model,
                    'modelYear': formState.modelYear,
                    'registrationNumber': formState.registrationNumber,
                    'odometerReading': formState.odometerReading,
                    'fuelLevel': formState.fuelLevel,
                    'customerConsent': formState.customerConsent,
                    'status': 'inProgress',
                    'createdDate': createdDate,
                    'lastUpdated': createdDate,
                  };
                  await local.save(id, payload);
                  final queue = ref.read(syncQueueProvider);
                  await queue.enqueue(SyncOperation(
                    id: id,
                    entityType: 'inspection',
                    entityId: id,
                    changeType: ChangeType.create,
                    payload: payload,
                    timestamp: DateTime.now().millisecondsSinceEpoch,
                  ));
                  ref.read(syncEngineProvider).syncAll();
                  ref.read(advisorRefreshProvider.notifier).state++;
                  if (!context.mounted) return;
                  _showInspectionPrompt(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppDimensions.r10),
                    ),
                  ),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInspectionPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.line, borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 20),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.r16),
              ),
              child: const Icon(Icons.search_outlined, color: AppColors.accent, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Job Card Created!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Would you like to add an inspection?\nYou can add photos, videos, notes, and pricing.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.text2, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(inspectionProvider.notifier).reset();
                  final jobId = _savedJobId ?? '';
                  final callbacks = InspectionCallbacks(
                    onBack: () => context.pop(),
                    onSaveDraft: () {
                      context.pop();
                      context.pop();
                    },
                    onPreview: () {
                      context.push(AppRoutes.inspectionPreview, extra: {
                        'onBack': () => context.pop(),
                        'jobId': jobId,
                      });
                    },
                  );
                  context.push(AppRoutes.inspectionSheet, extra: callbacks);
                },
                icon: const Icon(Icons.search_outlined, size: 20),
                label: const Text('Add Inspection', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (context.mounted) context.pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text3,
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r14)),
                ),
                child: const Text('Skip', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SEARCH MODE SECTION (Image 1)
// ─────────────────────────────────────────────────────────────────────────────
class _SearchModeSection extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _SearchModeSection({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // By Vehicle Reg No.
          _RadioOption(
            label: 'By Vehicle Reg No.',
            value: SearchMode.byVehicleReg,
            groupValue: state.searchMode,
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setSearchMode(v),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'OR',
              style: TextStyle(
                color: AppColors.text3,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // By Customer Name / Phone
          _RadioOption(
            label: 'By Customer Name / Phone Number',
            value: SearchMode.byCustomer,
            groupValue: state.searchMode,
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setSearchMode(v),
          ),
          if (state.searchMode == SearchMode.byCustomer) ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setCustomerSearch(v),
              decoration: InputDecoration(
                hintText: 'Customer Search',
                hintStyle: const TextStyle(color: kHintColor, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search,
                  color: kHintColor,
                  size: 18,
                ),
                filled: true,
                fillColor: kFieldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.r10),
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'OR',
              style: TextStyle(
                color: AppColors.text3,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // SCAN VIN
          _OutlineButton(icon: Icons.qr_code, label: 'SCAN VIN', onTap: () {}),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'OR',
              style: TextStyle(
                color: AppColors.text3,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // SCAN VEHICLE QR CODE
          _OutlineButton(
            icon: Icons.qr_code_scanner,
            label: 'SCAN VEHICLE QR CODE',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final SearchMode value;
  final SearchMode groupValue;
  final ValueChanged<SearchMode> onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.stroke,
                width: 2,
              ),
              color: Colors.white,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 9,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? kTextColor : AppColors.text2,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOMER DETAILS (Images 3-5)
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerDetailsSection extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _CustomerDetailsSection({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Customer Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // B2B toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'B2B Customer',
                style: TextStyle(fontSize: 13, color: kLabelColor),
              ),
              const SizedBox(width: 8),
              Switch(
                value: state.isB2B,
                onChanged: (v) =>
                    ref.read(vehicleCustomerFormProvider.notifier).setB2B(v),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          kGap12,

          FieldLabel('Customer Name', required: true),
          AdvisorTextField(
            hint: 'Customer Name',
            onChanged: (v) => ref
                .read(vehicleCustomerFormProvider.notifier)
                .setCustomerName(v),
          ),
          kGap12,

          FieldLabel('Phone Number', required: true),
          AdvisorTextField(
            hint: 'Phone number',
            keyboardType: TextInputType.phone,
            prefix: const Padding(
              padding: EdgeInsets.only(left: 12, right: 4),
              child: Text(
                '+91',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextColor,
                ),
              ),
            ),
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setPhone(v),
          ),
          kGap12,

          const FieldLabel('Email Address'),
          AdvisorTextField(
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setEmail(v),
          ),
          kGap12,

          const FieldLabel('Customer Group'),
          AdvisorDropdown(
            hint: 'Select Customer Group',
            value: state.customerGroup,
            items: kCustomerGroups,
            onChanged: (v) => ref
                .read(vehicleCustomerFormProvider.notifier)
                .setCustomerGroup(v),
          ),
          kGap12,

          const FieldLabel('Customer Tag'),
          _TagRow(state: state, ref: ref),

          if (state.showMoreCustomer) ...[
            kGap12,
            const FieldLabel('Gender'),
            AdvisorDropdown(
              hint: 'Select Gender',
              value: state.gender,
              items: kGenders,
              onChanged: (v) =>
                  ref.read(vehicleCustomerFormProvider.notifier).setGender(v),
            ),
            kGap12,

            const FieldLabel('Address'),
            AdvisorDropdown(
              hint: 'Address',
              value: state.address,
              items: kAddresses,
              onChanged: (v) =>
                  ref.read(vehicleCustomerFormProvider.notifier).setAddress(v),
            ),
            kGap12,

            const FieldLabel('Tax Number'),
            AdvisorTextField(
              hint: 'Tax Number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setTaxNumber(v),
            ),
            kGap12,

            const FieldLabel('Group Tax Number'),
            AdvisorTextField(
              hint: 'Group Tax Number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setGroupTaxNumber(v),
            ),
            kGap12,

            const FieldLabel('Occupation'),
            AdvisorTextField(
              hint: 'Occupation',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setOccupation(v),
            ),
            kGap12,

            const FieldLabel('Organisation'),
            AdvisorTextField(
              hint: 'Organisation',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setOrganisation(v),
            ),
            kGap12,

            const FieldLabel('Source'),
            AdvisorTextField(
              hint: 'How did you come to know abo...',
              onChanged: (v) =>
                  ref.read(vehicleCustomerFormProvider.notifier).setSource(v),
            ),
          ],

          const SizedBox(height: 8),
          MoreLessLink(
            showMore: state.showMoreCustomer,
            onTap: () => ref
                .read(vehicleCustomerFormProvider.notifier)
                .toggleCustomerMore(),
          ),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _TagRow({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // selected tags
        ...state.selectedTags.map((tag) {
          final t = kCustomerTags.firstWhere(
            (t) => t.label == tag,
            orElse: () => CustomerTag(label: tag, color: AppColors.primary),
          );
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: t.color),
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6)),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: t.color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          );
        }),
        // Add tag button
        GestureDetector(
          onTap: () async {
            final result = await showModalBottomSheet<List<String>>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => CustomerTagSheet(selected: state.selectedTags),
            );
            if (result != null) {
              final notifier = ref.read(vehicleCustomerFormProvider.notifier);
              for (final tag in kCustomerTags.map((t) => t.label)) {
                if (result.contains(tag) && !state.selectedTags.contains(tag)) {
                  notifier.toggleTag(tag);
                } else if (!result.contains(tag) &&
                    state.selectedTags.contains(tag)) {
                  notifier.toggleTag(tag);
                }
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kFieldBg,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
              border: Border.all(color: kBorderColor),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 14, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Tag',
                  style: TextStyle(
                    fontSize: 12,
                    color: kLabelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  VEHICLE DETAILS (Images 6-14)
// ─────────────────────────────────────────────────────────────────────────────
class _VehicleDetailsSection extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _VehicleDetailsSection({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Vehicle Details',
      trailing: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.history, size: 14, color: AppColors.primary),
        label: const Text(
          'View History',
          style: TextStyle(fontSize: 12, color: AppColors.primary),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel('Registration Number', required: true),
          AdvisorTextField(
            hint: '',
            initialValue: state.registrationNumber,
            onChanged: (v) => ref
                .read(vehicleCustomerFormProvider.notifier)
                .setRegistrationNumber(v),
            filled: state.registrationNumber.isNotEmpty,
          ),
          kGap12,

          const FieldLabel('VIN (Chasis number)'),
          AdvisorTextField(
            hint: 'VIN(Chasis number)',
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setVin(v),
            suffix: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.qr_code_scanner, color: kHintColor, size: 18),
            ),
          ),
          kGap12,

          FieldLabel('Make', required: true),
          _BrandSelector(state: state, ref: ref),
          kGap12,

          FieldLabel('Model', required: true),
          _ModelSelector(state: state, ref: ref),
          kGap12,

          const FieldLabel('Model Year'),
          _ModelYearSelector(state: state, ref: ref),

          if (state.showMoreVehicle) ...[
            kGap12,
            const FieldLabel('Purchase Date'),
            AdvisorTextField(
              hint: 'MM/YYYY',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12, right: 4),
                child: Icon(Icons.calendar_today, color: kHintColor, size: 16),
              ),
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setPurchaseDate(v),
            ),
            kGap12,

            const FieldLabel('Number of Cylinders'),
            AdvisorDropdown(
              hint: 'Number of Cylinders',
              value: state.cylinders,
              items: kCylinders,
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setCylinders(v),
            ),
            kGap12,

            const FieldLabel('Engine Capacity'),
            AdvisorTextField(
              hint: 'Engine Capacity',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setEngineCapacity(v),
            ),
            kGap12,

            const FieldLabel('Vehicle Color'),
            AdvisorTextField(
              hint: 'Vehicle Color',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setVehicleColor(v),
            ),
            kGap12,

            const FieldLabel('Engine number'),
            AdvisorTextField(
              hint: 'Engine number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setEngineNumber(v),
            ),
            kGap12,

            const FieldLabel('Insurance Provider'),
            AdvisorDropdown(
              hint: 'Insurance Provider',
              value: state.insuranceProvider,
              items: kInsuranceProviders,
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setInsuranceProvider(v),
            ),
            kGap12,

            const FieldLabel('Insurance Tax number'),
            AdvisorTextField(
              hint: 'Enter Insurance Tax number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setInsuranceTaxNumber(v),
            ),
            kGap12,

            const FieldLabel('Insurance Address'),
            AdvisorTextField(
              hint: 'Insurance Address',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setInsuranceAddress(v),
            ),
            kGap12,

            const FieldLabel('Policy number'),
            AdvisorTextField(
              hint: 'Policy number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setPolicyNumber(v),
            ),
            kGap12,

            const FieldLabel('Insurance expiry date'),
            AdvisorTextField(
              hint: 'Click to select a date',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12, right: 4),
                child: Icon(Icons.calendar_today, color: kHintColor, size: 16),
              ),
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setInsuranceExpiry(v),
            ),
            kGap12,

            const FieldLabel('Registration Certificate'),
            _ImageUploadButton(label: 'Images', onTap: () {}),
            kGap12,

            const FieldLabel('Insurance'),
            _ImageUploadButton(label: 'Images', onTap: () {}),
          ],

          const SizedBox(height: 8),
          MoreLessLink(
            showMore: state.showMoreVehicle,
            onTap: () => ref
                .read(vehicleCustomerFormProvider.notifier)
                .toggleVehicleMore(),
          ),
        ],
      ),
    );
  }
}

class _BrandSelector extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _BrandSelector({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: SelectBrandSheet(selected: state.make),
          ),
        );
        if (result != null) {
          ref.read(vehicleCustomerFormProvider.notifier).setMake(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: state.make.isEmpty ? kFieldBg : kTealLight,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.make.isEmpty ? 'Select Brand' : state.make,
                style: TextStyle(
                  fontSize: 13,
                  color: state.make.isEmpty ? kHintColor : kTextColor,
                  fontWeight: state.make.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: kHintColor, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _ModelSelector({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (state.make.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a brand first')),
          );
          return;
        }
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: SelectModelSheet(brand: state.make, selected: state.model),
          ),
        );
        if (result != null) {
          ref.read(vehicleCustomerFormProvider.notifier).setModel(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: state.model.isEmpty ? kFieldBg : kTealLight,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.model.isEmpty ? 'Select Model' : state.model,
                style: TextStyle(
                  fontSize: 13,
                  color: state.model.isEmpty ? kHintColor : kTextColor,
                  fontWeight: state.model.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: kHintColor, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ModelYearSelector extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _ModelYearSelector({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModelYearDialog(context, state.modelYear);
        if (result != null) {
          ref.read(vehicleCustomerFormProvider.notifier).setModelYear(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: state.modelYear.isEmpty ? kFieldBg : kTealLight,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.modelYear.isEmpty ? 'Select Model Year' : state.modelYear,
                style: TextStyle(
                  fontSize: 13,
                  color: state.modelYear.isEmpty ? kHintColor : kTextColor,
                  fontWeight: state.modelYear.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: kHintColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ImageUploadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ImageUploadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: kFieldBg,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
          border: Border.all(color: kBorderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ADDITIONAL INFORMATION (Image 15)
// ─────────────────────────────────────────────────────────────────────────────
class _AdditionalInfoSection extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _AdditionalInfoSection({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Additional Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('Odometer Reading(in Kms)'),
          AdvisorTextField(
            hint: 'Odometer (in Kms)',
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setOdometer(v),
          ),
          kGap16,

          // Fuel level slider
          const Text(
            'Fuel level',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kLabelColor,
            ),
          ),
          const SizedBox(height: 8),
          _FuelLevelSlider(
            value: state.fuelLevel,
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setFuelLevel(v),
          ),
          kGap16,

          // Customer Consent toggle
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kFieldBg,
              borderRadius: BorderRadius.all(
                Radius.circular(AppDimensions.r10),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Customer\nConsent',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kLabelColor,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: state.customerConsent,
                  onChanged: (v) => ref
                      .read(vehicleCustomerFormProvider.notifier)
                      .setConsent(v),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelLevelSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _FuelLevelSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Ticks bar
        Expanded(
          child: Row(
            children: List.generate(10, (i) {
              final isFilled = i < value;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 16,
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppDimensions.r2),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.local_gas_station, color: kLabelColor, size: 20),
      ],
    );
  }
}

