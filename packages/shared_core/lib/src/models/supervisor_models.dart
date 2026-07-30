class KpiResponse {
  final String value;final String label;final String sub;
  const KpiResponse({this.value='',this.label='',this.sub=''});
  factory KpiResponse.fromJson(Map<String,dynamic> j) => KpiResponse(
    value: j['value']as String? ?? '',label: j['label']as String? ?? '',sub: j['sub']as String? ?? '');
}

class AdvisorJobCountResponse {
  final String name;final int count;
  const AdvisorJobCountResponse({this.name='',this.count=0});
  factory AdvisorJobCountResponse.fromJson(Map<String,dynamic> j) => AdvisorJobCountResponse(
    name: j['name']as String? ?? '',count: j['count']as int? ?? 0);
}

class JobTypeResponse {
  final String label;final int count;
  const JobTypeResponse({this.label='',this.count=0});
  factory JobTypeResponse.fromJson(Map<String,dynamic> j) => JobTypeResponse(
    label: j['label']as String? ?? '',count: j['count']as int? ?? 0);
}

class RevenueMetricResponse {
  final String amount;final String label;final String change;
  const RevenueMetricResponse({this.amount='',this.label='',this.change=''});
  factory RevenueMetricResponse.fromJson(Map<String,dynamic> j) => RevenueMetricResponse(
    amount: j['amount']as String? ?? '',label: j['label']as String? ?? '',change: j['change']as String? ?? '');
}

class PendingStatusResponse {
  final String count;final String label;
  const PendingStatusResponse({this.count='',this.label=''});
  factory PendingStatusResponse.fromJson(Map<String,dynamic> j) => PendingStatusResponse(
    count: j['count']as String? ?? '',label: j['label']as String? ?? '');
}

class SupervisorAssignedJob {
  final String jobCard;final String customer;final String vehicle;final String dateAssigned;
  final int done;final int total;final String status;
  const SupervisorAssignedJob({this.jobCard='',this.customer='',this.vehicle='',this.dateAssigned='',
    this.done=0,this.total=0,this.status=''});
  factory SupervisorAssignedJob.fromJson(Map<String,dynamic> j) => SupervisorAssignedJob(
    jobCard: j['jobCard']as String? ?? '',customer: j['customer']as String? ?? '',
    vehicle: j['vehicle']as String? ?? '',dateAssigned: j['dateAssigned']as String? ?? '',
    done: j['done']as int? ?? 0,total: j['total']as int? ?? 0,status: j['status']as String? ?? '');
}
