import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:staff_app/features/advisor/data/models/vehicle_customer_model.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';

/// A previously saved vehicle/customer record matching a search query.
class VehicleMatch {
  final String customerName;
  final String phoneNumber;
  final String email;
  final String vin;
  final String make;
  final String model;
  final String registrationNumber;
  final String emirate;
  final String plateCode;
  final String plateNumber;

  const VehicleMatch({
    required this.customerName,
    required this.phoneNumber,
    required this.email,
    required this.vin,
    required this.make,
    required this.model,
    required this.registrationNumber,
    this.emirate = '',
    this.plateCode = '',
    this.plateNumber = '',
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
          return reg.contains(q) ||
              vin.contains(q) ||
              name.contains(q) ||
              phone.contains(q);
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
            emirate: (m['emirate'] ?? '').toString(),
            plateCode: (m['plateCode'] ?? '').toString(),
            plateNumber: (m['plateNumber'] ?? '').toString(),
          ),
        )
        .toList();
  } catch (_) {
    return const [];
  }
});

/// Uses the workshop database for intake search, with the existing local
/// records as an offline fallback.
final advisorRemoteVehicleMatchesProvider =
    FutureProvider.autoDispose<List<VehicleMatch>>((ref) async {
      final form = ref.watch(vehicleCustomerFormProvider);
      final q = form.customerSearch.trim();
      if (q.length < 2) return const [];

      try {
        final remote = ref.read(advisorRemoteDataSourceProvider);
        final customersRequest = remote.searchCustomers(q);
        final vehiclesRequest = remote.searchVehicles(q);
        final customers = await customersRequest;
        final vehicles = await vehiclesRequest;
        return <VehicleMatch>[
          ...vehicles.map(
            (v) => VehicleMatch(
              customerName: v.customerName,
              phoneNumber: v.phone,
              email: v.email,
              vin: v.vin,
              make: v.make,
              model: v.model,
              registrationNumber: v.regNo,
              emirate: v.emirate,
              plateCode: v.plateCode,
              plateNumber: v.plateNumber,
            ),
          ),
          ...customers.map(
            (c) => VehicleMatch(
              customerName: c.customerName,
              phoneNumber: c.phone,
              email: c.email,
              vin: '',
              make: '',
              model: '',
              registrationNumber: '',
            ),
          ),
        ].take(10).toList();
      } catch (_) {
        return ref.read(advisorVehicleMatchesProvider);
      }
    });

/// Default priority label; mirrors the client's reference mock-up.
const String kDefaultJobPriority = 'Green: Normal / Low priority';

/// Priority options for a job-description row.
const List<String> kJobPriorities = [
  kDefaultJobPriority,
  'Yellow: Medium priority',
  'Red: High priority',
];

/// One numbered job-description row: free text + a priority.
class JobDescriptionEntry {
  final String description;
  final String priority;
  final List<String> photoPaths;
  final List<String> videoPaths;
  final String audioPath;

  const JobDescriptionEntry({
    this.description = '',
    this.priority = kDefaultJobPriority,
    this.photoPaths = const [],
    this.videoPaths = const [],
    this.audioPath = '',
  });

  JobDescriptionEntry copyWith({
    String? description,
    String? priority,
    List<String>? photoPaths,
    List<String>? videoPaths,
    String? audioPath,
  }) => JobDescriptionEntry(
    description: description ?? this.description,
    priority: priority ?? this.priority,
    photoPaths: photoPaths ?? this.photoPaths,
    videoPaths: videoPaths ?? this.videoPaths,
    audioPath: audioPath ?? this.audioPath,
  );

  Map<String, dynamic> toJson() => {
    'description': description,
    'priority': priority,
  };

  factory JobDescriptionEntry.fromJson(Map<String, dynamic> json) =>
      JobDescriptionEntry(
        description: json['description']?.toString() ?? '',
        priority: json['priority']?.toString() ?? kDefaultJobPriority,
        photoPaths: (json['photoPaths'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        videoPaths: (json['videoPaths'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        audioPath: json['audioPath']?.toString() ?? '',
      );
}

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
  final String emirate;
  final String plateCode;
  final String plateNumber;
  final String registrationNumber;
  final String vin;
  final String make;
  final String model;
  final String modelYear;
  final String purchaseDate;
  final String cylinders;
  final String engineCapacity;
  final String vehicleColor;
  final String fuelType;
  final String engineNumber;
  final String jobCategory;
  final String markupType;
  final String orderType;
  final String jobDescription;
  final List<JobDescriptionEntry> jobDescriptions;
  final String insuranceProvider;
  final String insuranceTaxNumber;
  final String insuranceAddress;
  final String policyNumber;
  final String lpoNumber;
  final String accidentNumber;
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
    this.emirate = '',
    this.plateCode = '',
    this.plateNumber = '',
    this.registrationNumber = '',
    this.vin = '',
    this.make = '',
    this.model = '',
    this.modelYear = '',
    this.purchaseDate = '',
    this.cylinders = '',
    this.engineCapacity = '',
    this.vehicleColor = '',
    this.fuelType = '',
    this.engineNumber = '',
    this.jobCategory = 'Regular',
    this.markupType = '',
    this.orderType = '',
    this.jobDescription = '',
    this.jobDescriptions = const [JobDescriptionEntry()],
    this.insuranceProvider = '',
    this.insuranceTaxNumber = '',
    this.insuranceAddress = '',
    this.policyNumber = '',
    this.lpoNumber = '',
    this.accidentNumber = '',
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
    String? emirate,
    String? plateCode,
    String? plateNumber,
    String? registrationNumber,
    String? vin,
    String? make,
    String? model,
    String? modelYear,
    String? purchaseDate,
    String? cylinders,
    String? engineCapacity,
    String? vehicleColor,
    String? fuelType,
    String? engineNumber,
    String? jobCategory,
    String? markupType,
    String? orderType,
    String? jobDescription,
    List<JobDescriptionEntry>? jobDescriptions,
    String? insuranceProvider,
    String? insuranceTaxNumber,
    String? insuranceAddress,
    String? policyNumber,
    String? lpoNumber,
    String? accidentNumber,
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
      emirate: emirate ?? this.emirate,
      plateCode: plateCode ?? this.plateCode,
      plateNumber: plateNumber ?? this.plateNumber,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      vin: vin ?? this.vin,
      make: make ?? this.make,
      model: model ?? this.model,
      modelYear: modelYear ?? this.modelYear,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      cylinders: cylinders ?? this.cylinders,
      engineCapacity: engineCapacity ?? this.engineCapacity,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      fuelType: fuelType ?? this.fuelType,
      engineNumber: engineNumber ?? this.engineNumber,
      jobCategory: jobCategory ?? this.jobCategory,
      markupType: markupType ?? this.markupType,
      orderType: orderType ?? this.orderType,
      jobDescription: jobDescription ?? this.jobDescription,
      jobDescriptions: jobDescriptions ?? this.jobDescriptions,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceTaxNumber: insuranceTaxNumber ?? this.insuranceTaxNumber,
      insuranceAddress: insuranceAddress ?? this.insuranceAddress,
      policyNumber: policyNumber ?? this.policyNumber,
      lpoNumber: lpoNumber ?? this.lpoNumber,
      accidentNumber: accidentNumber ?? this.accidentNumber,
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
  void setEmirate(String? v) => _setPlateParts(emirate: v ?? '');
  void setPlateCode(String v) => _setPlateParts(plateCode: v);
  void setPlateNumber(String v) => _setPlateParts(plateNumber: v);

  void _setPlateParts({
    String? emirate,
    String? plateCode,
    String? plateNumber,
  }) {
    final next = state.copyWith(
      emirate: emirate,
      plateCode: plateCode,
      plateNumber: plateNumber,
    );
    final display = [
      next.emirate,
      next.plateCode,
      next.plateNumber,
    ].where((part) => part.trim().isNotEmpty).join(' ');
    state = next.copyWith(registrationNumber: display);
  }

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
  void setFuelType(String? v) => state = state.copyWith(fuelType: v ?? '');
  void setEngineNumber(String v) => state = state.copyWith(engineNumber: v);
  void setJobCategory(String? v) =>
      state = state.copyWith(jobCategory: v ?? 'Regular');
  void setMarkupType(String v) => state = state.copyWith(markupType: v);
  void setOrderType(String v) => state = state.copyWith(orderType: v);
  void setJobDescription(String v) => state = state.copyWith(jobDescription: v);

  String _composeDescription(List<JobDescriptionEntry> rows) => rows
      .map((row) => row.description.trim())
      .where((text) => text.isNotEmpty)
      .join('\n');

  /// Adds a new numbered job-description row.
  void addJobDescriptionRow() {
    state = state.copyWith(
      jobDescriptions: [...state.jobDescriptions, const JobDescriptionEntry()],
    );
  }

  void removeJobDescriptionRow(int index) {
    if (index < 0 || index >= state.jobDescriptions.length) return;
    final rows = List<JobDescriptionEntry>.from(state.jobDescriptions)
      ..removeAt(index);
    if (rows.isEmpty) rows.add(const JobDescriptionEntry());
    state = state.copyWith(
      jobDescriptions: rows,
      jobDescription: _composeDescription(rows),
    );
  }

  void updateJobDescriptionRow(
    int index, {
    String? description,
    String? priority,
  }) {
    if (index < 0 || index >= state.jobDescriptions.length) return;
    final rows = List<JobDescriptionEntry>.from(state.jobDescriptions);
    rows[index] = rows[index].copyWith(
      description: description,
      priority: priority,
    );
    state = state.copyWith(
      jobDescriptions: rows,
      jobDescription: _composeDescription(rows),
    );
  }

  void addJobDescriptionPhotos(int index, List<String> paths) {
    if (index < 0 || index >= state.jobDescriptions.length || paths.isEmpty) {
      return;
    }
    final row = state.jobDescriptions[index];
    _replaceJobDescriptionRow(
      index,
      row.copyWith(photoPaths: [...row.photoPaths, ...paths]),
    );
  }

  void addJobDescriptionVideo(int index, String path) {
    if (index < 0 || index >= state.jobDescriptions.length || path.isEmpty) {
      return;
    }
    final row = state.jobDescriptions[index];
    _replaceJobDescriptionRow(
      index,
      row.copyWith(videoPaths: [...row.videoPaths, path]),
    );
  }

  void setJobDescriptionAudio(int index, String path) {
    if (index < 0 || index >= state.jobDescriptions.length) return;
    _replaceJobDescriptionRow(
      index,
      state.jobDescriptions[index].copyWith(audioPath: path),
    );
  }

  void removeJobDescriptionMedia(int index, String type, int mediaIndex) {
    if (index < 0 || index >= state.jobDescriptions.length) return;
    final row = state.jobDescriptions[index];
    if (type == 'audio') {
      _replaceJobDescriptionRow(index, row.copyWith(audioPath: ''));
      return;
    }
    final paths = List<String>.from(
      type == 'photo' ? row.photoPaths : row.videoPaths,
    );
    if (mediaIndex < 0 || mediaIndex >= paths.length) return;
    paths.removeAt(mediaIndex);
    _replaceJobDescriptionRow(
      index,
      type == 'photo'
          ? row.copyWith(photoPaths: paths)
          : row.copyWith(videoPaths: paths),
    );
  }

  void _replaceJobDescriptionRow(int index, JobDescriptionEntry row) {
    final rows = List<JobDescriptionEntry>.from(state.jobDescriptions);
    rows[index] = row;
    state = state.copyWith(jobDescriptions: rows);
  }

  void setInsuranceProvider(String? v) =>
      state = state.copyWith(insuranceProvider: v ?? '');
  void setInsuranceTaxNumber(String v) =>
      state = state.copyWith(insuranceTaxNumber: v);
  void setInsuranceAddress(String v) =>
      state = state.copyWith(insuranceAddress: v);
  void setPolicyNumber(String v) => state = state.copyWith(policyNumber: v);
  void setLpoNumber(String v) => state = state.copyWith(lpoNumber: v);
  void setAccidentNumber(String v) => state = state.copyWith(accidentNumber: v);
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
