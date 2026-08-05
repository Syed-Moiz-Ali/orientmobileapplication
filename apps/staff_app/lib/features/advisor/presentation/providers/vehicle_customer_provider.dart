import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:staff_app/features/advisor/data/models/vehicle_customer_model.dart';

/// A previously saved vehicle/customer record matching a search query.
class VehicleMatch {
  final String customerName;
  final String phoneNumber;
  final String email;
  final String vin;
  final String make;
  final String model;
  final String registrationNumber;

  const VehicleMatch({
    required this.customerName,
    required this.phoneNumber,
    required this.email,
    required this.vin,
    required this.make,
    required this.model,
    required this.registrationNumber,
  });
}

/// Client-side search over locally saved vehicle/customer records.
final advisorVehicleMatchesProvider = Provider<List<VehicleMatch>>((ref) {
  final form = ref.watch(vehicleCustomerFormProvider);
  final q = form.customerSearch.trim().toLowerCase();
  if (q.isEmpty) return const [];
  try {
    final box = Hive.box<dynamic>('inspections');
    return box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .where((m) => m['type'] == 'vehicle_customer')
        .where((m) {
          final name = (m['customerName'] ?? '').toString().toLowerCase();
          final phone = (m['phoneNumber'] ?? '').toString().toLowerCase();
          final reg = (m['registrationNumber'] ?? '').toString().toLowerCase();
          final vin = (m['vin'] ?? '').toString().toLowerCase();
          return form.searchMode == SearchMode.byVehicleReg
              ? reg.contains(q) || vin.contains(q)
              : name.contains(q) || phone.contains(q);
        })
        .take(5)
        .map(
          (m) => VehicleMatch(
            customerName: (m['customerName'] ?? '').toString(),
            phoneNumber: (m['phoneNumber'] ?? '').toString(),
            email: (m['email'] ?? '').toString(),
            vin: (m['vin'] ?? '').toString(),
            make: (m['make'] ?? '').toString(),
            model: (m['model'] ?? '').toString(),
            registrationNumber: (m['registrationNumber'] ?? '').toString(),
          ),
        )
        .toList();
  } catch (_) {
    return const [];
  }
});

class VehicleCustomerFormState {
  final SearchMode searchMode;
  final String customerSearch;
  final bool isB2B;
  final String customerName;
  final String phoneNumber;
  final String email;
  final String customerGroup;
  final List<String> selectedTags;
  final String gender;
  final String address;
  final String taxNumber;
  final String groupTaxNumber;
  final String occupation;
  final String organisation;
  final String source;
  final String registrationNumber;
  final String vin;
  final String make;
  final String model;
  final String modelYear;
  final String purchaseDate;
  final String cylinders;
  final String engineCapacity;
  final String vehicleColor;
  final String engineNumber;
  final String insuranceProvider;
  final String insuranceTaxNumber;
  final String insuranceAddress;
  final String policyNumber;
  final String insuranceExpiryDate;
  final String odometerReading;
  final int fuelLevel;
  final bool customerConsent;
  final bool showMoreCustomer;
  final bool showMoreVehicle;

  const VehicleCustomerFormState({
    this.searchMode = SearchMode.byCustomer,
    this.customerSearch = '',
    this.isB2B = false,
    this.customerName = '',
    this.phoneNumber = '',
    this.email = '',
    this.customerGroup = '',
    this.selectedTags = const [],
    this.gender = '',
    this.address = '',
    this.taxNumber = '',
    this.groupTaxNumber = '',
    this.occupation = '',
    this.organisation = '',
    this.source = '',
    this.registrationNumber = '',
    this.vin = '',
    this.make = '',
    this.model = '',
    this.modelYear = '',
    this.purchaseDate = '',
    this.cylinders = '',
    this.engineCapacity = '',
    this.vehicleColor = '',
    this.engineNumber = '',
    this.insuranceProvider = '',
    this.insuranceTaxNumber = '',
    this.insuranceAddress = '',
    this.policyNumber = '',
    this.insuranceExpiryDate = '',
    this.odometerReading = '',
    this.fuelLevel = 5,
    this.customerConsent = false,
    this.showMoreCustomer = false,
    this.showMoreVehicle = false,
  });

  VehicleCustomerFormState copyWith({
    SearchMode? searchMode,
    String? customerSearch,
    bool? isB2B,
    String? customerName,
    String? phoneNumber,
    String? email,
    String? customerGroup,
    List<String>? selectedTags,
    String? gender,
    String? address,
    String? taxNumber,
    String? groupTaxNumber,
    String? occupation,
    String? organisation,
    String? source,
    String? registrationNumber,
    String? vin,
    String? make,
    String? model,
    String? modelYear,
    String? purchaseDate,
    String? cylinders,
    String? engineCapacity,
    String? vehicleColor,
    String? engineNumber,
    String? insuranceProvider,
    String? insuranceTaxNumber,
    String? insuranceAddress,
    String? policyNumber,
    String? insuranceExpiryDate,
    String? odometerReading,
    int? fuelLevel,
    bool? customerConsent,
    bool? showMoreCustomer,
    bool? showMoreVehicle,
  }) {
    return VehicleCustomerFormState(
      searchMode: searchMode ?? this.searchMode,
      customerSearch: customerSearch ?? this.customerSearch,
      isB2B: isB2B ?? this.isB2B,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      customerGroup: customerGroup ?? this.customerGroup,
      selectedTags: selectedTags ?? this.selectedTags,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      groupTaxNumber: groupTaxNumber ?? this.groupTaxNumber,
      occupation: occupation ?? this.occupation,
      organisation: organisation ?? this.organisation,
      source: source ?? this.source,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      vin: vin ?? this.vin,
      make: make ?? this.make,
      model: model ?? this.model,
      modelYear: modelYear ?? this.modelYear,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      cylinders: cylinders ?? this.cylinders,
      engineCapacity: engineCapacity ?? this.engineCapacity,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      engineNumber: engineNumber ?? this.engineNumber,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceTaxNumber: insuranceTaxNumber ?? this.insuranceTaxNumber,
      insuranceAddress: insuranceAddress ?? this.insuranceAddress,
      policyNumber: policyNumber ?? this.policyNumber,
      insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
      odometerReading: odometerReading ?? this.odometerReading,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      customerConsent: customerConsent ?? this.customerConsent,
      showMoreCustomer: showMoreCustomer ?? this.showMoreCustomer,
      showMoreVehicle: showMoreVehicle ?? this.showMoreVehicle,
    );
  }

  bool get isValid => registrationNumber.isNotEmpty;
}

class VehicleCustomerFormNotifier extends Notifier<VehicleCustomerFormState> {
  @override
  VehicleCustomerFormState build() => const VehicleCustomerFormState();

  void setSearchMode(SearchMode v) => state = state.copyWith(searchMode: v);
  void setCustomerSearch(String v) => state = state.copyWith(customerSearch: v);
  void setB2B(bool v) => state = state.copyWith(isB2B: v);
  void setCustomerName(String v) => state = state.copyWith(customerName: v);
  void setPhone(String v) => state = state.copyWith(phoneNumber: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setCustomerGroup(String? v) =>
      state = state.copyWith(customerGroup: v ?? '');
  void setGender(String? v) => state = state.copyWith(gender: v ?? '');
  void setAddress(String? v) => state = state.copyWith(address: v ?? '');
  void setTaxNumber(String v) => state = state.copyWith(taxNumber: v);
  void setGroupTaxNumber(String v) => state = state.copyWith(groupTaxNumber: v);
  void setOccupation(String v) => state = state.copyWith(occupation: v);
  void setOrganisation(String v) => state = state.copyWith(organisation: v);
  void setSource(String v) => state = state.copyWith(source: v);

  void toggleTag(String tag) {
    final tags = List<String>.from(state.selectedTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(selectedTags: tags);
  }

  void setRegistrationNumber(String v) =>
      state = state.copyWith(registrationNumber: v);
  void setVin(String v) => state = state.copyWith(vin: v);
  void setMake(String? v) => state = state.copyWith(make: v ?? '', model: '');
  void setModel(String? v) => state = state.copyWith(model: v ?? '');
  void setModelYear(String? v) => state = state.copyWith(modelYear: v ?? '');
  void setPurchaseDate(String v) => state = state.copyWith(purchaseDate: v);
  void setCylinders(String? v) => state = state.copyWith(cylinders: v ?? '');
  void setEngineCapacity(String v) => state = state.copyWith(engineCapacity: v);
  void setVehicleColor(String v) => state = state.copyWith(vehicleColor: v);
  void setEngineNumber(String v) => state = state.copyWith(engineNumber: v);
  void setInsuranceProvider(String? v) =>
      state = state.copyWith(insuranceProvider: v ?? '');
  void setInsuranceTaxNumber(String v) =>
      state = state.copyWith(insuranceTaxNumber: v);
  void setInsuranceAddress(String v) =>
      state = state.copyWith(insuranceAddress: v);
  void setPolicyNumber(String v) => state = state.copyWith(policyNumber: v);
  void setInsuranceExpiry(String v) =>
      state = state.copyWith(insuranceExpiryDate: v);
  void setOdometer(String v) => state = state.copyWith(odometerReading: v);
  void setFuelLevel(int v) => state = state.copyWith(fuelLevel: v);
  void setConsent(bool v) => state = state.copyWith(customerConsent: v);
  void toggleCustomerMore() =>
      state = state.copyWith(showMoreCustomer: !state.showMoreCustomer);
  void toggleVehicleMore() =>
      state = state.copyWith(showMoreVehicle: !state.showMoreVehicle);
}

final vehicleCustomerFormProvider =
    NotifierProvider<VehicleCustomerFormNotifier, VehicleCustomerFormState>(
      VehicleCustomerFormNotifier.new,
    );
