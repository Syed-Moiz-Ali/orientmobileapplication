class AdvisorStatsResponse {
  final int newJobCardsToday;final int inspectionsToday;final int pendingApprovals;
  final int vehiclesWaiting;final int readyForDelivery;final int totalOpenJobCards;
  const AdvisorStatsResponse({this.newJobCardsToday=0,this.inspectionsToday=0,this.pendingApprovals=0,
    this.vehiclesWaiting=0,this.readyForDelivery=0,this.totalOpenJobCards=0});
  factory AdvisorStatsResponse.fromJson(Map<String,dynamic> j) => AdvisorStatsResponse(
    newJobCardsToday: j['newJobCardsToday']as int? ?? 0,inspectionsToday: j['inspectionsToday']as int? ?? 0,
    pendingApprovals: j['pendingApprovals']as int? ?? 0,vehiclesWaiting: j['vehiclesWaiting']as int? ?? 0,
    readyForDelivery: j['readyForDelivery']as int? ?? 0,totalOpenJobCards: j['totalOpenJobCards']as int? ?? 0);
}

class JobCardResponse {
  final String id;final String customerName;final String vehicleInfo;final String time;
  final String createdDate;final String lastUpdated;final String status;final String technician;
  const JobCardResponse({this.id='',this.customerName='',this.vehicleInfo='',this.time='',
    this.createdDate='',this.lastUpdated='',this.status='pending',this.technician=''});
  factory JobCardResponse.fromJson(Map<String,dynamic> j) => JobCardResponse(
    id: j['id']as String? ?? '',customerName: j['customerName']as String? ?? '',
    vehicleInfo: j['vehicleInfo']as String? ?? '',time: j['time']as String? ?? '',
    createdDate: j['createdDate']as String? ?? '',lastUpdated: j['lastUpdated']as String? ?? '',
    status: j['status']as String? ?? 'pending',technician: j['technician']as String? ?? '');
}

class JobCardDetailResponse {
  final String id;final String customerName;final String vehicleInfo;final String time;
  final String createdDate;final String lastUpdated;final String status;final String technician;
  final String notes;final String tag;final String customerRequests;final String garageRecommendations;final String estimatedDelivery;
  const JobCardDetailResponse({this.id='',this.customerName='',this.vehicleInfo='',this.time='',
    this.createdDate='',this.lastUpdated='',this.status='pending',this.technician='',this.notes='',
    this.tag='',this.customerRequests='',this.garageRecommendations='',this.estimatedDelivery=''});
  factory JobCardDetailResponse.fromJson(Map<String,dynamic> j) => JobCardDetailResponse(
    id: j['id']as String? ?? '',customerName: j['customerName']as String? ?? '',
    vehicleInfo: j['vehicleInfo']as String? ?? '',time: j['time']as String? ?? '',
    createdDate: j['createdDate']as String? ?? '',lastUpdated: j['lastUpdated']as String? ?? '',
    status: j['status']as String? ?? 'pending',technician: j['technician']as String? ?? '',
    notes: j['notes']as String? ?? '',tag: j['tag']as String? ?? '',
    customerRequests: j['customerRequests']as String? ?? '',garageRecommendations: j['garageRecommendations']as String? ?? '',
    estimatedDelivery: j['estimatedDelivery']as String? ?? '');
}

class InspectionResponse {
  final String id;
  const InspectionResponse({this.id=''});
  factory InspectionResponse.fromJson(Map<String,dynamic> j) => InspectionResponse(id: j['id']as String? ?? '');
}

class InspectionDraftResponse {
  final String id;final String jobCardId;final String referenceNumber;final String placeOfSupply;
  final String customerRequests;final String garageRecommendations;final String estimatedDelivery;
  final bool? notifyOwnerSmsEmail;final String tag;final bool? isDraft;final Map<String,Map<String,dynamic>>? sections;
  const InspectionDraftResponse({this.id='',this.jobCardId='',this.referenceNumber='',this.placeOfSupply='',
    this.customerRequests='',this.garageRecommendations='',this.estimatedDelivery='',
    this.notifyOwnerSmsEmail,this.tag='',this.isDraft,this.sections});
  factory InspectionDraftResponse.fromJson(Map<String,dynamic> j) => InspectionDraftResponse(
    id: (j['id']??'').toString(),jobCardId: (j['jobCardId']??'').toString(),
    referenceNumber: j['referenceNumber']as String? ?? '',placeOfSupply: j['placeOfSupply']as String? ?? '',
    customerRequests: j['customerRequests']as String? ?? '',garageRecommendations: j['garageRecommendations']as String? ?? '',
    estimatedDelivery: j['estimatedDelivery']as String? ?? '',
    notifyOwnerSmsEmail: j['notifyOwnerSmsEmail']as bool?,tag: j['tag']as String? ?? '',
    isDraft: j['isDraft']as bool?,sections: j['sections']as Map<String,Map<String,dynamic>>?);
}

class PendingApprovalResponse {
  final String estimateId;final String customerName;final String vehicleId;final double amount;final String timeAgo;
  const PendingApprovalResponse({this.estimateId='',this.customerName='',this.vehicleId='',this.amount=0,this.timeAgo=''});
  factory PendingApprovalResponse.fromJson(Map<String,dynamic> j) => PendingApprovalResponse(
    estimateId: j['estimateId']as String? ?? '',customerName: j['customerName']as String? ?? '',
    vehicleId: j['vehicleId']as String? ?? '',amount: (j['amount']as num?)?.toDouble()??0,
    timeAgo: j['timeAgo']as String? ?? '');
}

class ReminderResponse {
  final String id;final String customerName;final String vehicleId;final String task;
  final String dueDate;final String priority;
  const ReminderResponse({this.id='',this.customerName='',this.vehicleId='',this.task='',this.dueDate='',this.priority='medium'});
  factory ReminderResponse.fromJson(Map<String,dynamic> j) => ReminderResponse(
    id: j['id']as String? ?? '',customerName: j['customerName']as String? ?? '',
    vehicleId: j['vehicleId']as String? ?? '',task: j['task']as String? ?? '',
    dueDate: j['dueDate']as String? ?? '',priority: j['priority']as String? ?? 'medium');
}

class ReportResponse {
  final int totalJobs;final int completedJobs;final int inProgressJobs;final int cancelledJobs;
  const ReportResponse({this.totalJobs=0,this.completedJobs=0,this.inProgressJobs=0,this.cancelledJobs=0});
  factory ReportResponse.fromJson(Map<String,dynamic> j) => ReportResponse(
    totalJobs: j['totalJobs']as int? ?? 0,completedJobs: j['completedJobs']as int? ?? 0,
    inProgressJobs: j['inProgressJobs']as int? ?? 0,cancelledJobs: j['cancelledJobs']as int? ?? 0);
}

class RepairOrderResponse {
  final String id;
  const RepairOrderResponse({this.id=''});
  factory RepairOrderResponse.fromJson(Map<String,dynamic> j) => RepairOrderResponse(id: j['id']as String? ?? '');
}

class CustomerSearchResponse {
  final String customerName;final String phone;final String email;
  const CustomerSearchResponse({this.customerName='',this.phone='',this.email=''});
  factory CustomerSearchResponse.fromJson(Map<String,dynamic> j) => CustomerSearchResponse(
    customerName: j['customerName']as String? ?? '',phone: j['phone']as String? ?? '',
    email: j['email']as String? ?? '');
}

class VehicleSearchResponse {
  final String regNo;final String vin;final String make;final String model;final String plateNumber;
  const VehicleSearchResponse({this.regNo='',this.vin='',this.make='',this.model='',this.plateNumber=''});
  factory VehicleSearchResponse.fromJson(Map<String,dynamic> j) => VehicleSearchResponse(
    regNo: j['regNo']as String? ?? '',vin: j['vin']as String? ?? '',
    make: j['make']as String? ?? '',model: j['model']as String? ?? '',
    plateNumber: j['plateNumber']as String? ?? '');
}
