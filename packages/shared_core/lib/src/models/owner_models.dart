class KpiCardResponse {
  final String label;final String value;final String sub;
  const KpiCardResponse({this.label='',this.value='',this.sub=''});
  factory KpiCardResponse.fromJson(Map<String,dynamic> j) => KpiCardResponse(
    label: j['label']as String? ?? '',value: j['value']as String? ?? '',sub: j['sub']as String? ?? '');
}

class TrendPointResponse {
  final String month;final int value;
  const TrendPointResponse({this.month='',this.value=0});
  factory TrendPointResponse.fromJson(Map<String,dynamic> j) => TrendPointResponse(
    month: j['month']as String? ?? '',value: (j['value']as num?)?.toInt()??0);
}

class JobCardRegisterResponse {
  final String label;final int open;final int completed;final int total;
  const JobCardRegisterResponse({this.label='',this.open=0,this.completed=0,this.total=0});
  factory JobCardRegisterResponse.fromJson(Map<String,dynamic> j) => JobCardRegisterResponse(
    label: j['label']as String? ?? '',open: j['open']as int? ?? 0,
    completed: j['completed']as int? ?? 0,total: j['total']as int? ?? 0);
}

class TopSalesCategoryResponse {
  final String title;final List<TopSalesItemDto> items;
  const TopSalesCategoryResponse({this.title='',this.items=const[]});
  factory TopSalesCategoryResponse.fromJson(Map<String,dynamic> j) => TopSalesCategoryResponse(
    title: j['title']as String? ?? '',
    items: (j['items']as List<dynamic>?)?.map((e)=>TopSalesItemDto.fromJson(e)).toList()??[]);
}

class TopSalesItemDto {
  final int sno;final String description;final String value;
  const TopSalesItemDto({this.sno=0,this.description='',this.value=''});
  factory TopSalesItemDto.fromJson(Map<String,dynamic> j) => TopSalesItemDto(
    sno: j['sno']as int? ?? 0,description: j['description']as String? ?? '',value: j['value']as String? ?? '');
}

class OwnerJobCardResponse {
  final String id;final String customerName;final String vehicle;final String plateNumber;
  final String services;final String technician;final String estCompletion;final double amount;final String status;
  const OwnerJobCardResponse({this.id='',this.customerName='',this.vehicle='',this.plateNumber='',
    this.services='',this.technician='',this.estCompletion='',this.amount=0,this.status='pending'});
  factory OwnerJobCardResponse.fromJson(Map<String,dynamic> j) => OwnerJobCardResponse(
    id: (j['id']??'').toString(),customerName: j['customerName']as String? ?? '',
    vehicle: j['vehicle']as String? ?? '',plateNumber: j['plateNumber']as String? ?? '',
    services: j['services']as String? ?? '',technician: j['technician']as String? ?? '',
    estCompletion: j['estCompletion']as String? ?? '',amount: (j['amount']as num?)?.toDouble()??0,
    status: j['status']as String? ?? 'pending');
}

class DocumentExpiryResponse {
  final String empId;final String employeeName;final String designation;final String documentType;
  final String expiryDate;final int daysLeft;final String urgency;
  const DocumentExpiryResponse({this.empId='',this.employeeName='',this.designation='',this.documentType='',
    this.expiryDate='',this.daysLeft=0,this.urgency='normal'});
  factory DocumentExpiryResponse.fromJson(Map<String,dynamic> j) => DocumentExpiryResponse(
    empId: j['empId']as String? ?? '',employeeName: j['employeeName']as String? ?? '',
    designation: j['designation']as String? ?? '',documentType: j['documentType']as String? ?? '',
    expiryDate: j['expiryDate']as String? ?? '',daysLeft: j['daysLeft']as int? ?? 0,
    urgency: j['urgency']as String? ?? 'normal');
}

class JobStatusResponse {
  final String jobCardId;final String customerName;final String vehicleInfo;final String assignedTo;
  final String createdDate;final String dueDate;final String stage;final double estimatedAmount;
  const JobStatusResponse({this.jobCardId='',this.customerName='',this.vehicleInfo='',this.assignedTo='',
    this.createdDate='',this.dueDate='',this.stage='',this.estimatedAmount=0});
  factory JobStatusResponse.fromJson(Map<String,dynamic> j) => JobStatusResponse(
    jobCardId: j['jobCardId']as String? ?? '',customerName: j['customerName']as String? ?? '',
    vehicleInfo: j['vehicleInfo']as String? ?? '',assignedTo: j['assignedTo']as String? ?? '',
    createdDate: j['createdDate']as String? ?? '',dueDate: j['dueDate']as String? ?? '',
    stage: j['stage']as String? ?? '',estimatedAmount: (j['estimatedAmount']as num?)?.toDouble()??0);
}

class ApprovalCategoryResponse {
  final String title;final String subtitle;final int count;
  const ApprovalCategoryResponse({this.title='',this.subtitle='',this.count=0});
  factory ApprovalCategoryResponse.fromJson(Map<String,dynamic> j) => ApprovalCategoryResponse(
    title: j['title']as String? ?? '',subtitle: j['subtitle']as String? ?? '',count: j['count']as int? ?? 0);
}

class PendingJobResponse {
  final String jobCardId;final String customerName;final String vehicleInfo;final String assignedTo;
  final String createdDate;final String dueDate;final int daysOverdue;final String status;final double estimatedAmount;
  const PendingJobResponse({this.jobCardId='',this.customerName='',this.vehicleInfo='',this.assignedTo='',
    this.createdDate='',this.dueDate='',this.daysOverdue=0,this.status='pending',this.estimatedAmount=0});
  factory PendingJobResponse.fromJson(Map<String,dynamic> j) => PendingJobResponse(
    jobCardId: j['jobCardId']as String? ?? '',customerName: j['customerName']as String? ?? '',
    vehicleInfo: j['vehicleInfo']as String? ?? '',assignedTo: j['assignedTo']as String? ?? '',
    createdDate: j['createdDate']as String? ?? '',dueDate: j['dueDate']as String? ?? '',
    daysOverdue: j['daysOverdue']as int? ?? 0,status: j['status']as String? ?? 'pending',
    estimatedAmount: (j['estimatedAmount']as num?)?.toDouble()??0);
}

class InvoiceResponse {
  final String id;
  final String customerName;
  final String date;
  final double amount;
  // P3: UAE VAT 5% — server-computed fields.
  final double taxRate;
  final double taxAmount;
  final double grandTotal;
  final String status;

  const InvoiceResponse({
    this.id = '',
    this.customerName = '',
    this.date = '',
    this.amount = 0,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.grandTotal = 0,
    this.status = 'unpaid',
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> j) => InvoiceResponse(
        id: j['id'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        date: j['date'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        taxRate: (j['taxRate'] as num?)?.toDouble() ?? 0,
        taxAmount: (j['taxAmount'] as num?)?.toDouble() ?? 0,
        grandTotal: (j['grandTotal'] as num?)?.toDouble() ?? 0,
        status: j['status'] as String? ?? 'unpaid');
}

class ArSummaryResponse {
  final int totalOutstanding;final int days0to30;final int days31to60;final int days61to90;final int days90plus;
  const ArSummaryResponse({this.totalOutstanding=0,this.days0to30=0,this.days31to60=0,this.days61to90=0,this.days90plus=0});
  factory ArSummaryResponse.fromJson(Map<String,dynamic> j) => ArSummaryResponse(
    totalOutstanding: (j['totalOutstanding']as num?)?.toInt()??0,
    days0to30: (j['days0to30']as num?)?.toInt()??0,
    days31to60: (j['days31to60']as num?)?.toInt()??0,
    days61to90: (j['days61to90']as num?)?.toInt()??0,
    days90plus: (j['days90plus']as num?)?.toInt()??0);
}

class ArRecordResponse {
  final String arId;final String customer;final String invoiceDate;final String dueDate;
  final double amount;final double outstanding;final String aging;final String contactPerson;final String phone;
  const ArRecordResponse({this.arId='',this.customer='',this.invoiceDate='',this.dueDate='',this.amount=0,
    this.outstanding=0,this.aging='days0to30',this.contactPerson='',this.phone=''});
  factory ArRecordResponse.fromJson(Map<String,dynamic> j) => ArRecordResponse(
    arId: j['arId']as String? ?? '',customer: j['customer']as String? ?? '',
    invoiceDate: j['invoiceDate']as String? ?? '',dueDate: j['dueDate']as String? ?? '',
    amount: (j['amount']as num?)?.toDouble()??0,outstanding: (j['outstanding']as num?)?.toDouble()??0,
    aging: j['aging']as String? ?? 'days0to30',contactPerson: j['contactPerson']as String? ?? '',
    phone: j['phone']as String? ?? '');
}

class MessageResponse {
  final String id;final String recipient;final String message;final String time;
  const MessageResponse({this.id='',this.recipient='',this.message='',this.time=''});
  factory MessageResponse.fromJson(Map<String,dynamic> j) => MessageResponse(
    id: j['id']as String? ?? '',recipient: j['recipient']as String? ?? '',
    message: j['message']as String? ?? '',time: j['time']as String? ?? '');
}

class ActivityResponse {
  final String id;final String type;final String title;final String description;final String timestamp;
  const ActivityResponse({this.id='',this.type='',this.title='',this.description='',this.timestamp=''});
  factory ActivityResponse.fromJson(Map<String,dynamic> j) => ActivityResponse(
    id: j['id']as String? ?? '',type: j['type']as String? ?? '',title: j['title']as String? ?? '',
    description: j['description']as String? ?? '',timestamp: j['timestamp']as String? ?? '');
}
