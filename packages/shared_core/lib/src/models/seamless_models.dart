// Models for the seamless flow plan: booking/breakdown routing,
// per-item work tracking, customer approvals, staff notifications.

class AdvisorTechnicianResponse {
  final int id;
  final String name;
  final String empId;

  const AdvisorTechnicianResponse({
    this.id = 0,
    this.name = '',
    this.empId = '',
  });

  factory AdvisorTechnicianResponse.fromJson(Map<String, dynamic> j) =>
      AdvisorTechnicianResponse(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        empId: j['empId'] as String? ?? '',
      );
}

class AdvisorBookingResponse {
  final int id;
  final String bookingRef;
  final String customerName;
  final String phone;
  final String vehicleName;
  final String plateNumber;
  final String serviceType;
  final String bookingDate;
  final String notes;
  final String status;

  const AdvisorBookingResponse({
    this.id = 0,
    this.bookingRef = '',
    this.customerName = '',
    this.phone = '',
    this.vehicleName = '',
    this.plateNumber = '',
    this.serviceType = '',
    this.bookingDate = '',
    this.notes = '',
    this.status = 'pending',
  });

  factory AdvisorBookingResponse.fromJson(Map<String, dynamic> j) =>
      AdvisorBookingResponse(
        id: (j['id'] as num?)?.toInt() ?? 0,
        bookingRef: j['bookingRef'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        vehicleName: j['vehicleName'] as String? ?? '',
        plateNumber: j['plateNumber'] as String? ?? '',
        serviceType: j['serviceType'] as String? ?? '',
        bookingDate: j['bookingDate'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
      );
}

class BookingQueueResponse {
  final int id;
  final String bookingRef;
  final String customerName;
  final String phone;
  final String vehicleName;
  final String plateNumber;
  final String serviceType;
  final String bookingDate;
  final String notes;
  final String status;

  const BookingQueueResponse({
    this.id = 0,
    this.bookingRef = '',
    this.customerName = '',
    this.phone = '',
    this.vehicleName = '',
    this.plateNumber = '',
    this.serviceType = '',
    this.bookingDate = '',
    this.notes = '',
    this.status = 'pending',
  });

  factory BookingQueueResponse.fromJson(Map<String, dynamic> j) =>
      BookingQueueResponse(
        id: (j['id'] as num?)?.toInt() ?? 0,
        bookingRef: j['bookingRef'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        vehicleName: j['vehicleName'] as String? ?? '',
        plateNumber: j['plateNumber'] as String? ?? '',
        serviceType: j['serviceType'] as String? ?? '',
        bookingDate: j['bookingDate'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
      );
}

class BreakdownQueueResponse {
  final int id;
  final String breakdownRef;
  final String customerName;
  final String phone;
  final String issue;
  final String vehicleName;
  final String vehiclePlate;
  final String location;
  final String status;

  const BreakdownQueueResponse({
    this.id = 0,
    this.breakdownRef = '',
    this.customerName = '',
    this.phone = '',
    this.issue = '',
    this.vehicleName = '',
    this.vehiclePlate = '',
    this.location = '',
    this.status = 'pending',
  });

  factory BreakdownQueueResponse.fromJson(Map<String, dynamic> j) =>
      BreakdownQueueResponse(
        id: (j['id'] as num?)?.toInt() ?? 0,
        breakdownRef: j['breakdownRef'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        issue: j['issue'] as String? ?? '',
        vehicleName: j['vehicleName'] as String? ?? '',
        vehiclePlate: j['vehiclePlate'] as String? ?? '',
        location: j['location'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
      );
}

class AssignableStaffResponse {
  final int id;
  final String name;
  final String empId;
  final String role;

  const AssignableStaffResponse({
    this.id = 0,
    this.name = '',
    this.empId = '',
    this.role = '',
  });

  factory AssignableStaffResponse.fromJson(Map<String, dynamic> j) =>
      AssignableStaffResponse(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        empId: j['empId'] as String? ?? '',
        role: j['role'] as String? ?? '',
      );
}

class WorkItemResponse {
  final int id;
  final String taskRef;
  final String jobCardRef;
  final String description;
  final String itemType;
  final String status;
  final String empId;
  final String empName;
  final String startTime;
  final String endTime;
  final int qty;
  final double rate;
  final String rejectReason;

  const WorkItemResponse({
    this.id = 0,
    this.taskRef = '',
    this.jobCardRef = '',
    this.description = '',
    this.itemType = 'WORK',
    this.status = 'pending',
    this.empId = '',
    this.empName = '',
    this.startTime = '',
    this.endTime = '',
    this.qty = 1,
    this.rate = 0,
    this.rejectReason = '',
  });

  factory WorkItemResponse.fromJson(Map<String, dynamic> j) => WorkItemResponse(
        id: (j['id'] as num?)?.toInt() ?? 0,
        taskRef: j['taskRef'] as String? ?? '',
        jobCardRef: j['jobCardRef'] as String? ?? '',
        description: j['description'] as String? ?? '',
        itemType: j['itemType'] as String? ?? 'WORK',
        status: j['status'] as String? ?? 'pending',
        empId: j['empId'] as String? ?? '',
        empName: j['empName'] as String? ?? '',
        startTime: j['startTime'] as String? ?? '',
        endTime: j['endTime'] as String? ?? '',
        qty: (j['qty'] as num?)?.toInt() ?? 1,
        rate: (j['rate'] as num?)?.toDouble() ?? 0,
        rejectReason: j['rejectReason'] as String? ?? '',
      );
}

class WorkItemDetail {
  final int id;
  final String taskRef;
  final String description;
  final String itemType;
  final String status;
  final String empId;
  final String empName;
  final String startTime;
  final String endTime;
  final int qty;
  final double rate;
  final String rejectReason;

  const WorkItemDetail({
    this.id = 0,
    this.taskRef = '',
    this.description = '',
    this.itemType = 'WORK',
    this.status = 'pending',
    this.empId = '',
    this.empName = '',
    this.startTime = '',
    this.endTime = '',
    this.qty = 1,
    this.rate = 0,
    this.rejectReason = '',
  });

  factory WorkItemDetail.fromJson(Map<String, dynamic> j) => WorkItemDetail(
        id: (j['id'] as num?)?.toInt() ?? 0,
        taskRef: j['taskRef'] as String? ?? '',
        description: j['description'] as String? ?? '',
        itemType: j['itemType'] as String? ?? 'WORK',
        status: j['status'] as String? ?? 'pending',
        empId: j['empId'] as String? ?? '',
        empName: j['empName'] as String? ?? '',
        startTime: j['startTime'] as String? ?? '',
        endTime: j['endTime'] as String? ?? '',
        qty: (j['qty'] as num?)?.toInt() ?? 1,
        rate: (j['rate'] as num?)?.toDouble() ?? 0,
        rejectReason: j['rejectReason'] as String? ?? '',
      );
}

class AwaitingCompletionResponse {
  final int jobCardId;
  final String jobCardRef;
  final String customerName;
  final String vehicleInfo;
  final String technician;
  final int done;
  final int total;
  final String updatedAt;
  final List<WorkItemDetail> items;

  const AwaitingCompletionResponse({
    this.jobCardId = 0,
    this.jobCardRef = '',
    this.customerName = '',
    this.vehicleInfo = '',
    this.technician = '',
    this.done = 0,
    this.total = 0,
    this.updatedAt = '',
    this.items = const [],
  });

  factory AwaitingCompletionResponse.fromJson(Map<String, dynamic> j) =>
      AwaitingCompletionResponse(
        jobCardId: (j['jobCardId'] as num?)?.toInt() ?? 0,
        jobCardRef: j['jobCardRef'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        vehicleInfo: j['vehicleInfo'] as String? ?? '',
        technician: j['technician'] as String? ?? '',
        done: (j['done'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        updatedAt: j['updatedAt'] as String? ?? '',
        items: (j['items'] as List<dynamic>?)
                ?.map((e) => WorkItemDetail.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class StaffNotificationResponse {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type;
  final bool isRead;

  const StaffNotificationResponse({
    this.id = '',
    this.title = '',
    this.body = '',
    this.time = '',
    this.type = 'reminder',
    this.isRead = false,
  });

  factory StaffNotificationResponse.fromJson(Map<String, dynamic> j) =>
      StaffNotificationResponse(
        id: j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        time: j['time'] as String? ?? '',
        type: j['type'] as String? ?? 'reminder',
        isRead: j['isRead'] as bool? ?? false,
      );
}

class CustomerApprovalSummaryResponse {
  final String estimateId;
  final String customerName;
  final double amount;
  final String status;
  final String createdAt;

  const CustomerApprovalSummaryResponse({
    this.estimateId = '',
    this.customerName = '',
    this.amount = 0,
    this.status = 'pending',
    this.createdAt = '',
  });

  factory CustomerApprovalSummaryResponse.fromJson(Map<String, dynamic> j) =>
      CustomerApprovalSummaryResponse(
        estimateId: j['estimateId'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        status: j['status'] as String? ?? 'pending',
        createdAt: j['createdAt'] as String? ?? '',
      );
}

class ApprovalLineItem {
  final String name;
  final int qty;
  final double rate;
  final double discountPercent;
  final double discountAmount;

  const ApprovalLineItem({
    this.name = '',
    this.qty = 1,
    this.rate = 0,
    this.discountPercent = 0,
    this.discountAmount = 0,
  });

  factory ApprovalLineItem.fromJson(Map<String, dynamic> j) => ApprovalLineItem(
        name: j['name'] as String? ?? '',
        qty: (j['qty'] as num?)?.toInt() ?? 1,
        rate: (j['rate'] as num?)?.toDouble() ?? 0,
        discountPercent: (j['discountPercent'] as num?)?.toDouble() ?? 0,
        discountAmount: (j['discountAmount'] as num?)?.toDouble() ?? 0,
      );
}

class CustomerApprovalDetailResponse {
  final String estimateId;
  final String customerName;
  final String vehicleInfo;
  final double servicesTotal;
  final double partsTotal;
  final double grandTotal;
  final String status;
  final String createdAt;
  final List<ApprovalLineItem> services;
  final List<ApprovalLineItem> parts;

  const CustomerApprovalDetailResponse({
    this.estimateId = '',
    this.customerName = '',
    this.vehicleInfo = '',
    this.servicesTotal = 0,
    this.partsTotal = 0,
    this.grandTotal = 0,
    this.status = 'pending',
    this.createdAt = '',
    this.services = const [],
    this.parts = const [],
  });

  factory CustomerApprovalDetailResponse.fromJson(Map<String, dynamic> j) =>
      CustomerApprovalDetailResponse(
        estimateId: j['estimateId'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        vehicleInfo: j['vehicleInfo'] as String? ?? '',
        servicesTotal: (j['servicesTotal'] as num?)?.toDouble() ?? 0,
        partsTotal: (j['partsTotal'] as num?)?.toDouble() ?? 0,
        grandTotal: (j['grandTotal'] as num?)?.toDouble() ?? 0,
        status: j['status'] as String? ?? 'pending',
        createdAt: j['createdAt'] as String? ?? '',
        services: (j['services'] as List<dynamic>?)
                ?.map((e) => ApprovalLineItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        parts: (j['parts'] as List<dynamic>?)
                ?.map((e) => ApprovalLineItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
