class TechnicianProfileResponse {
  final String name;final String empId;final String role;final String branch;final String shift;final String avatarInitials;
  const TechnicianProfileResponse({this.name='',this.empId='',this.role='',this.branch='',this.shift='',this.avatarInitials=''});
  factory TechnicianProfileResponse.fromJson(Map<String,dynamic> j) => TechnicianProfileResponse(
    name: j['name']as String? ?? '',empId: j['empId']as String? ?? '',role: j['role']as String? ?? '',
    branch: j['branch']as String? ?? '',shift: j['shift']as String? ?? '',
    avatarInitials: j['avatarInitials']as String? ?? '');
}

class AttendanceResponse {
  final String status;final String punchIn;final String punchOut;final String breakTime;final String workHours;
  const AttendanceResponse({this.status='notPunchedIn',this.punchIn='',this.punchOut='',this.breakTime='',this.workHours=''});
  factory AttendanceResponse.fromJson(Map<String,dynamic> j) => AttendanceResponse(
    status: j['status']as String? ?? 'notPunchedIn',punchIn: j['punchIn']as String? ?? '',
    punchOut: j['punchOut']as String? ?? '',breakTime: j['breakTime']as String? ?? '',
    workHours: j['workHours']as String? ?? '');
}

class AssignedJobResponse {
  final String id;final String customerName;final String vehicle;final String service;final String amount;final String status;
  const AssignedJobResponse({this.id='',this.customerName='',this.vehicle='',this.service='',this.amount='',this.status='pending'});
  factory AssignedJobResponse.fromJson(Map<String,dynamic> j) => AssignedJobResponse(
    id: (j['id']??'').toString(),customerName: j['customerName']as String? ?? '',
    vehicle: j['vehicle']as String? ?? '',service: j['service']as String? ?? '',
    amount: j['amount']as String? ?? '',status: j['status']as String? ?? 'pending');
}

class TechnicianJobResponse {
  final String jobCardNo;final String dateOfWork;final String startTime;final String vehicleBrand;
  final String vehicleModel;final String plateNumber;final String status;
  final List<TaskResponse> tasks;final String notes;
  const TechnicianJobResponse({this.jobCardNo='',this.dateOfWork='',this.startTime='',this.vehicleBrand='',
    this.vehicleModel='',this.plateNumber='',this.status='pending',this.tasks=const[],this.notes=''});
  factory TechnicianJobResponse.fromJson(Map<String,dynamic> j) => TechnicianJobResponse(
    jobCardNo: j['jobCardNo']as String? ?? '',dateOfWork: j['dateOfWork']as String? ?? '',
    startTime: j['startTime']as String? ?? '',vehicleBrand: j['vehicleBrand']as String? ?? '',
    vehicleModel: j['vehicleModel']as String? ?? '',plateNumber: j['plateNumber']as String? ?? '',
    status: j['status']as String? ?? 'pending',
    tasks: (j['tasks']as List<dynamic>?)?.map((e)=>TaskResponse.fromJson(e)).toList()??[],notes: j['notes']as String? ?? '');
}

class TaskResponse {
  final String id;final String description;final String status;final String startTime;final String endTime;
  const TaskResponse({this.id='',this.description='',this.status='pending',this.startTime='',this.endTime=''});
  factory TaskResponse.fromJson(Map<String,dynamic> j) => TaskResponse(
    id: (j['id']??'').toString(),description: j['description']as String? ?? '',
    status: j['status']as String? ?? 'pending',startTime: j['startTime']as String? ?? '',
    endTime: j['endTime']as String? ?? '');
}

class ProductivityResponse {
  final int assignedJobs;final int inProgress;final int completedToday;final int efficiency;
  final String avgTimePerJob;final String totalHoursWorked;
  const ProductivityResponse({this.assignedJobs=0,this.inProgress=0,this.completedToday=0,this.efficiency=0,
    this.avgTimePerJob='',this.totalHoursWorked=''});
  factory ProductivityResponse.fromJson(Map<String,dynamic> j) => ProductivityResponse(
    assignedJobs: j['assignedJobs']as int? ?? 0,inProgress: j['inProgress']as int? ?? 0,
    completedToday: j['completedToday']as int? ?? 0,efficiency: j['efficiency']as int? ?? 0,
    avgTimePerJob: j['avgTimePerJob']as String? ?? '',totalHoursWorked: j['totalHoursWorked']as String? ?? '');
}

class TaskActionResponse {
  final String? startTime;final String? endTime;final String? status;
  const TaskActionResponse({this.startTime,this.endTime,this.status});
  factory TaskActionResponse.fromJson(Map<String,dynamic> j) => TaskActionResponse(
    startTime: j['startTime']as String?,endTime: j['endTime']as String?,status: j['status']as String?);
}
