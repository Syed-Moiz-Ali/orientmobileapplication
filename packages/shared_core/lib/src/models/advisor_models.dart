class AdvisorStatsResponse {
  final int newJobCardsToday;
  final int inspectionsToday;
  final int pendingApprovals;
  final int vehiclesWaiting;
  final int readyForDelivery;
  final int totalOpenJobCards;
  final int newAssignedBookings;
  final int newBreakdowns;
  const AdvisorStatsResponse({
    this.newJobCardsToday = 0,
    this.inspectionsToday = 0,
    this.pendingApprovals = 0,
    this.vehiclesWaiting = 0,
    this.readyForDelivery = 0,
    this.totalOpenJobCards = 0,
    this.newAssignedBookings = 0,
    this.newBreakdowns = 0,
  });
  factory AdvisorStatsResponse.fromJson(Map<String, dynamic> j) =>
      AdvisorStatsResponse(
        newJobCardsToday: j['newJobCardsToday'] as int? ?? 0,
        inspectionsToday: j['inspectionsToday'] as int? ?? 0,
        pendingApprovals: j['pendingApprovals'] as int? ?? 0,
        vehiclesWaiting: j['vehiclesWaiting'] as int? ?? 0,
        readyForDelivery: j['readyForDelivery'] as int? ?? 0,
        totalOpenJobCards: j['totalOpenJobCards'] as int? ?? 0,
        newAssignedBookings: j['newAssignedBookings'] as int? ?? 0,
        newBreakdowns: j['newBreakdowns'] as int? ?? 0,
      );
}

class JobCardResponse {
  final String id;
  final int dbId;
  final String customerName;
  final String vehicleInfo;
  final String time;
  final String createdDate;
  final String lastUpdated;
  final String status;
  final String technician;
  final int? odometer;
  final String fuelLevel;
  const JobCardResponse({
    this.id = '',
    this.dbId = 0,
    this.customerName = '',
    this.vehicleInfo = '',
    this.time = '',
    this.createdDate = '',
    this.lastUpdated = '',
    this.status = 'pending',
    this.technician = '',
    this.odometer,
    this.fuelLevel = '',
  });
  factory JobCardResponse.fromJson(Map<String, dynamic> j) => JobCardResponse(
    id: j['id'] as String? ?? '',
    dbId: (j['dbId'] as num?)?.toInt() ?? 0,
    customerName: j['customerName'] as String? ?? '',
    vehicleInfo: j['vehicleInfo'] as String? ?? '',
    time: j['time'] as String? ?? '',
    createdDate: j['createdDate'] as String? ?? '',
    lastUpdated: j['lastUpdated'] as String? ?? '',
    status: j['status'] as String? ?? 'pending',
    technician: j['technician'] as String? ?? '',
    odometer: (j['odometer'] as num?)?.toInt(),
    fuelLevel: _readString(j, const ['fuelLevel', 'fuel_level']),
  );
}

class JobCardDetailResponse {
  final String id;
  final int dbId;
  final String customerName;
  final String phoneNumber;
  final String email;
  final String customerGroup;
  final String vehicleInfo;
  final String registrationNumber;
  final String vin;
  final String make;
  final String model;
  final String modelYear;
  final String vehicleColor;
  final String mileage;
  final String time;
  final String createdDate;
  final String lastUpdated;
  final String status;
  final String technician;
  final String notes;
  final int? odometer;
  final String fuelLevel;
  final String tag;
  final String customerRequests;
  final String garageRecommendations;
  final String estimatedDelivery;
  final Map<String, dynamic>? vehicleBodyCondition;
  const JobCardDetailResponse({
    this.id = '',
    this.dbId = 0,
    this.customerName = '',
    this.phoneNumber = '',
    this.email = '',
    this.customerGroup = '',
    this.vehicleInfo = '',
    this.registrationNumber = '',
    this.vin = '',
    this.make = '',
    this.model = '',
    this.modelYear = '',
    this.vehicleColor = '',
    this.mileage = '',
    this.time = '',
    this.createdDate = '',
    this.lastUpdated = '',
    this.status = 'pending',
    this.technician = '',
    this.notes = '',
    this.odometer,
    this.fuelLevel = '',
    this.tag = '',
    this.customerRequests = '',
    this.garageRecommendations = '',
    this.estimatedDelivery = '',
    this.vehicleBodyCondition,
  });
  factory JobCardDetailResponse.fromJson(Map<String, dynamic> j) =>
      JobCardDetailResponse(
        id: j['id'] as String? ?? '',
        dbId: (j['dbId'] as num?)?.toInt() ?? 0,
        customerName: _readString(j, const [
          'customerName',
          'name',
          'customer',
        ]),
        phoneNumber: _readString(j, const [
          'phoneNumber',
          'phone',
          'customerPhone',
          'mobile',
          'mobileNumber',
        ]),
        email: _readString(j, const ['email', 'customerEmail']),
        customerGroup: j['customerGroup'] as String? ?? '',
        vehicleInfo: _readString(j, const [
          'vehicleInfo',
          'vehicleName',
          'vehicle',
        ]),
        registrationNumber: _readString(j, const [
          'registrationNumber',
          'plateNumber',
          'regNo',
          'vehiclePlate',
        ]),
        vin: _readString(j, const ['vin', 'chassisNumber']),
        make: _readString(j, const ['make', 'brand']),
        model: _readString(j, const ['model']),
        modelYear: _readString(j, const ['modelYear', 'year']),
        vehicleColor: _readString(j, const ['vehicleColor', 'color']),
        mileage: j['mileage'] as String? ?? '',
        time: j['time'] as String? ?? '',
        createdDate: j['createdDate'] as String? ?? '',
        lastUpdated: j['lastUpdated'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
        technician: j['technician'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        odometer: (j['odometer'] as num?)?.toInt(),
        fuelLevel: _readString(j, const ['fuelLevel', 'fuel_level']),
        tag: j['tag'] as String? ?? '',
        customerRequests: j['customerRequests'] as String? ?? '',
        garageRecommendations: j['garageRecommendations'] as String? ?? '',
        estimatedDelivery: j['estimatedDelivery'] as String? ?? '',
        vehicleBodyCondition: j['vehicleBodyCondition'] is Map
            ? Map<String, dynamic>.from(j['vehicleBodyCondition'] as Map)
            : null,
      );
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return '';
}

class InspectionResponse {
  final String id;
  final String jobCardId;
  final String jobCardRef;
  const InspectionResponse({
    this.id = '',
    this.jobCardId = '',
    this.jobCardRef = '',
  });
  factory InspectionResponse.fromJson(Map<String, dynamic> j) {
    final rawId =
        j['id'] ?? j['inspectionId'] ?? j['inspectionRef'] ?? j['ref'];
    return InspectionResponse(
      id: rawId?.toString() ?? '',
      jobCardId: j['jobCardId']?.toString() ?? '',
      jobCardRef: j['jobCardRef']?.toString() ?? '',
    );
  }
}

class InspectionDraftResponse {
  final String id;
  final String jobCardId;
  final String referenceNumber;
  final String placeOfSupply;
  final String customerRequests;
  final String garageRecommendations;
  final String estimatedDelivery;
  final bool? notifyOwnerSmsEmail;
  final String tag;
  final bool? isDraft;
  final Map<String, Map<String, dynamic>>? sections;
  final Map<String, dynamic>? vehicleBodyCondition;
  const InspectionDraftResponse({
    this.id = '',
    this.jobCardId = '',
    this.referenceNumber = '',
    this.placeOfSupply = '',
    this.customerRequests = '',
    this.garageRecommendations = '',
    this.estimatedDelivery = '',
    this.notifyOwnerSmsEmail,
    this.tag = '',
    this.isDraft,
    this.sections,
    this.vehicleBodyCondition,
  });
  factory InspectionDraftResponse.fromJson(Map<String, dynamic> j) =>
      InspectionDraftResponse(
        id: (j['id'] ?? '').toString(),
        jobCardId: (j['jobCardId'] ?? '').toString(),
        referenceNumber: j['referenceNumber'] as String? ?? '',
        placeOfSupply: j['placeOfSupply'] as String? ?? '',
        customerRequests: j['customerRequests'] as String? ?? '',
        garageRecommendations: j['garageRecommendations'] as String? ?? '',
        estimatedDelivery: j['estimatedDelivery'] as String? ?? '',
        notifyOwnerSmsEmail: j['notifyOwnerSmsEmail'] as bool?,
        tag: j['tag'] as String? ?? '',
        isDraft: j['isDraft'] as bool?,
        sections: j['sections'] as Map<String, Map<String, dynamic>>?,
        vehicleBodyCondition: j['vehicleBodyCondition'] is Map
            ? Map<String, dynamic>.from(j['vehicleBodyCondition'] as Map)
            : null,
      );
}

class PendingApprovalResponse {
  final String estimateId;
  final String approvalType;
  final String referenceId;
  final String customerName;
  final String vehicleId;
  final double amount;
  final String timeAgo;
  const PendingApprovalResponse({
    this.estimateId = '',
    this.approvalType = 'estimate',
    this.referenceId = '',
    this.customerName = '',
    this.vehicleId = '',
    this.amount = 0,
    this.timeAgo = '',
  });
  factory PendingApprovalResponse.fromJson(Map<String, dynamic> j) =>
      PendingApprovalResponse(
        estimateId: j['estimateId'] as String? ?? '',
        approvalType: j['approvalType'] as String? ?? 'estimate',
        referenceId: j['referenceId'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        vehicleId: j['vehicleId'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        timeAgo: j['timeAgo'] as String? ?? '',
      );
}

class ReminderResponse {
  final String id;
  final String customerName;
  final String vehicleId;
  final String task;
  final String dueDate;
  final String priority;
  const ReminderResponse({
    this.id = '',
    this.customerName = '',
    this.vehicleId = '',
    this.task = '',
    this.dueDate = '',
    this.priority = 'medium',
  });
  factory ReminderResponse.fromJson(Map<String, dynamic> j) => ReminderResponse(
    id: j['id'] as String? ?? '',
    customerName: j['customerName'] as String? ?? '',
    vehicleId: j['vehicleId'] as String? ?? '',
    task: j['task'] as String? ?? '',
    dueDate: j['dueDate'] as String? ?? '',
    priority: j['priority'] as String? ?? 'medium',
  );
}

class ReportActivityDto {
  final String day;
  final int count;
  const ReportActivityDto({this.day = '', this.count = 0});
  factory ReportActivityDto.fromJson(Map<String, dynamic> j) =>
      ReportActivityDto(
        day: j['day'] as String? ?? '',
        count: (j['count'] as num?)?.toInt() ?? 0,
      );
}

class ReportResponse {
  final int totalJobs;
  final int completedJobs;
  final int inProgressJobs;
  final int cancelledJobs;
  final List<ReportActivityDto> weeklyActivity;
  const ReportResponse({
    this.totalJobs = 0,
    this.completedJobs = 0,
    this.inProgressJobs = 0,
    this.cancelledJobs = 0,
    this.weeklyActivity = const [],
  });
  factory ReportResponse.fromJson(Map<String, dynamic> j) => ReportResponse(
    totalJobs: j['totalJobs'] as int? ?? 0,
    completedJobs: j['completedJobs'] as int? ?? 0,
    inProgressJobs: j['inProgressJobs'] as int? ?? 0,
    cancelledJobs: j['cancelledJobs'] as int? ?? 0,
    weeklyActivity:
        (j['weeklyActivity'] as List<dynamic>?)
            ?.map((e) => ReportActivityDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

class RepairOrderResponse {
  final String id;
  const RepairOrderResponse({this.id = ''});
  factory RepairOrderResponse.fromJson(Map<String, dynamic> j) =>
      RepairOrderResponse(id: j['id'] as String? ?? '');
}

class CustomerSearchResponse {
  final String customerName;
  final String phone;
  final String email;
  const CustomerSearchResponse({
    this.customerName = '',
    this.phone = '',
    this.email = '',
  });
  factory CustomerSearchResponse.fromJson(Map<String, dynamic> j) =>
      CustomerSearchResponse(
        customerName: j['customerName'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String? ?? '',
      );
}

class VehicleSearchResponse {
  final String regNo;
  final String vin;
  final String make;
  final String model;
  final String plateNumber;
  final String customerName;
  final String phone;
  final String email;
  final String emirate;
  final String plateCode;
  const VehicleSearchResponse({
    this.regNo = '',
    this.vin = '',
    this.make = '',
    this.model = '',
    this.plateNumber = '',
    this.customerName = '',
    this.phone = '',
    this.email = '',
    this.emirate = '',
    this.plateCode = '',
  });
  factory VehicleSearchResponse.fromJson(Map<String, dynamic> j) =>
      VehicleSearchResponse(
        regNo: j['regNo'] as String? ?? '',
        vin: j['vin'] as String? ?? '',
        make: j['make'] as String? ?? '',
        model: j['model'] as String? ?? '',
        plateNumber: j['plateNumber'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String? ?? '',
        emirate: j['emirate'] as String? ?? '',
        plateCode: j['plateCode'] as String? ?? '',
      );
}

class InspectionTemplateResponse {
  final String id;
  final String name;
  final String description;
  final int estimatedMinutes;
  final List<InspectionTemplateSectionResponse> sections;

  const InspectionTemplateResponse({
    this.id = '',
    this.name = '',
    this.description = '',
    this.estimatedMinutes = 0,
    this.sections = const [],
  });

  factory InspectionTemplateResponse.fromJson(Map<String, dynamic> json) =>
      InspectionTemplateResponse(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 0,
        sections: (json['sections'] as List? ?? const [])
            .whereType<Map>()
            .map(
              (section) => InspectionTemplateSectionResponse.fromJson(
                Map<String, dynamic>.from(section),
              ),
            )
            .toList(),
      );
}

/// Transparent summary of the latest inspection attached to a job card.
class InspectionSummaryResponse {
  final bool found;
  final String inspectionId;
  final String inspectionRef;
  final String summary;
  final int good;
  final int fair;
  final int poor;
  final int total;
  final List<String> issues;

  const InspectionSummaryResponse({
    this.found = false,
    this.inspectionId = '',
    this.inspectionRef = '',
    this.summary = '',
    this.good = 0,
    this.fair = 0,
    this.poor = 0,
    this.total = 0,
    this.issues = const [],
  });

  factory InspectionSummaryResponse.fromJson(Map<String, dynamic> j) {
    final counts = j['counts'] is Map
        ? Map<String, dynamic>.from(j['counts'] as Map)
        : const <String, dynamic>{};
    return InspectionSummaryResponse(
      found: j['found'] as bool? ?? false,
      inspectionId: j['inspectionId']?.toString() ?? '',
      inspectionRef: j['inspectionRef']?.toString() ?? '',
      summary: j['summary']?.toString() ?? '',
      good: (counts['good'] as num?)?.toInt() ?? 0,
      fair: (counts['fair'] as num?)?.toInt() ?? 0,
      poor: (counts['poor'] as num?)?.toInt() ?? 0,
      total: (counts['total'] as num?)?.toInt() ?? 0,
      issues:
          (j['issues'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

class InspectionTemplateSectionResponse {
  final String id;
  final String sectionKey;
  final String label;
  final int displayOrder;
  final List<String> items;

  const InspectionTemplateSectionResponse({
    this.id = '',
    this.sectionKey = '',
    this.label = '',
    this.displayOrder = 0,
    this.items = const [],
  });

  factory InspectionTemplateSectionResponse.fromJson(
    Map<String, dynamic> json,
  ) => InspectionTemplateSectionResponse(
    id: json['id']?.toString() ?? '',
    sectionKey: json['sectionKey']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    items: (json['items'] as List? ?? const [])
        .map((item) => item.toString())
        .toList(),
  );
}
