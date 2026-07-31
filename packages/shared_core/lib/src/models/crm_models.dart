class CrmKpiResponse {
  final String label;final String value;final String change;
  const CrmKpiResponse({this.label='',this.value='',this.change=''});
  factory CrmKpiResponse.fromJson(Map<String,dynamic> j) => CrmKpiResponse(
    label: j['label']as String? ?? '',value: j['value']as String? ?? '',change: j['change']as String? ?? '');
}

class ChannelResponse {
  final String name;final int count;
  const ChannelResponse({this.name='',this.count=0});
  factory ChannelResponse.fromJson(Map<String,dynamic> j) => ChannelResponse(
    name: j['name']as String? ?? '',count: j['count']as int? ?? 0);
}

class ConversionTrendResponse {
  final String month;final int won;final int lost;final int active;
  const ConversionTrendResponse({this.month='',this.won=0,this.lost=0,this.active=0});
  factory ConversionTrendResponse.fromJson(Map<String,dynamic> j) => ConversionTrendResponse(
    month: j['month']as String? ?? '',won: j['won']as int? ?? 0,
    lost: j['lost']as int? ?? 0,active: j['active']as int? ?? 0);
}

class SalespersonPerfResponse {
  final String name;final int leads;final int won;
  const SalespersonPerfResponse({this.name='',this.leads=0,this.won=0});
  factory SalespersonPerfResponse.fromJson(Map<String,dynamic> j) => SalespersonPerfResponse(
    name: j['name']as String? ?? '',leads: j['leads']as int? ?? 0,won: j['won']as int? ?? 0);
}

class ResponseTimeResponse {
  final String label;final int count;
  const ResponseTimeResponse({this.label='',this.count=0});
  factory ResponseTimeResponse.fromJson(Map<String,dynamic> j) => ResponseTimeResponse(
    label: j['label']as String? ?? '',count: j['count']as int? ?? 0);
}

class LeadSourceResponse {
  final String label;final int percent;
  const LeadSourceResponse({this.label='',this.percent=0});
  factory LeadSourceResponse.fromJson(Map<String,dynamic> j) => LeadSourceResponse(
    label: j['label']as String? ?? '',percent: j['percent']as int? ?? 0);
}

class KeyMetricResponse {
  final double winRate;final String avgResponseTime;final double satisfaction;final int roi;
  const KeyMetricResponse({this.winRate=0,this.avgResponseTime='',this.satisfaction=0,this.roi=0});
  factory KeyMetricResponse.fromJson(Map<String,dynamic> j) => KeyMetricResponse(
    winRate: (j['winRate']as num?)?.toDouble()??0,avgResponseTime: j['avgResponseTime']as String? ?? '',
    satisfaction: (j['satisfaction']as num?)?.toDouble()??0,roi: j['roi']as int? ?? 0);
}

class IntegrationResponse {
  final String name;final bool connected;
  final String? lastSyncAt;final String syncStatus;final int leadCount;
  const IntegrationResponse({this.name='',this.connected=false,this.lastSyncAt,this.syncStatus='IDLE',this.leadCount=0});
  factory IntegrationResponse.fromJson(Map<String,dynamic> j) => IntegrationResponse(
    name: j['name']as String? ?? '',connected: j['connected']as bool? ?? false,
    lastSyncAt: j['lastSyncAt']as String?,syncStatus: j['syncStatus']as String? ?? 'IDLE',
    leadCount: j['leadCount']as int? ?? 0);
}

class SalesTeamResponse {
  final String name;final String role;final int leadsHandled;final int wonDeals;
  final String revenue;final double winRate;
  const SalesTeamResponse({this.name='',this.role='',this.leadsHandled=0,this.wonDeals=0,this.revenue='',this.winRate=0});
  factory SalesTeamResponse.fromJson(Map<String,dynamic> j) => SalesTeamResponse(
    name: j['name']as String? ?? '',role: j['role']as String? ?? '',
    leadsHandled: j['leadsHandled']as int? ?? 0,wonDeals: j['wonDeals']as int? ?? 0,
    revenue: j['revenue']as String? ?? '',winRate: (j['winRate']as num?)?.toDouble()??0);
}

class ConversationResponse {
  final String id;final String customerName;final String lastMessage;final String time;
  final String channel;final int unread;final String status;
  const ConversationResponse({this.id='',this.customerName='',this.lastMessage='',this.time='',
    this.channel='',this.unread=0,this.status='active'});
  factory ConversationResponse.fromJson(Map<String,dynamic> j) => ConversationResponse(
    id: (j['id']??'').toString(),customerName: j['customerName']as String? ?? '',
    lastMessage: j['lastMessage']as String? ?? '',time: j['time']as String? ?? '',
    channel: j['channel']as String? ?? '',unread: j['unread']as int? ?? 0,
    status: j['status']as String? ?? 'active');
}

class LeadResponse {
  final String id;final int sno;final String leadNumber;final String customerName;final String phone;
  final String email;final String source;final String assignedTo;final String status;final String lastActivity;
  final String notes;final double leadValue;final String followUpDate;
  const LeadResponse({this.id='',this.sno=0,this.leadNumber='',this.customerName='',this.phone='',this.email='',
    this.source='',this.assignedTo='',this.status='ACTIVE',this.lastActivity='',this.notes='',this.leadValue=0,this.followUpDate=''});
  factory LeadResponse.fromJson(Map<String,dynamic> j) => LeadResponse(
    id: (j['id']??'').toString(),sno: j['sno']as int? ?? 0,leadNumber: j['leadNumber']as String? ?? '',
    customerName: j['customerName']as String? ?? '',phone: j['phone']as String? ?? '',
    email: j['email']as String? ?? '',source: j['source']as String? ?? '',
    assignedTo: j['assignedTo']as String? ?? '',status: j['status']as String? ?? 'ACTIVE',
    lastActivity: j['lastActivity']as String? ?? '',notes: j['notes']as String? ?? '',
    leadValue: (j['leadValue']as num?)?.toDouble()??0,followUpDate: j['followUpDate']as String? ?? '');
}

class TeamMemberResponse {
  final String name;final String role;final String designation;final int leadsHandled;final int wonDeals;
  const TeamMemberResponse({this.name='',this.role='',this.designation='',this.leadsHandled=0,this.wonDeals=0});
  factory TeamMemberResponse.fromJson(Map<String,dynamic> j) => TeamMemberResponse(
    name: j['name']as String? ?? '',role: j['role']as String? ?? '',designation: j['designation']as String? ?? '',
    leadsHandled: j['leadsHandled']as int? ?? 0,wonDeals: j['wonDeals']as int? ?? 0);
}

class LeadActivityResponse {
  final String id;final String action;final String detail;final String createdAt;
  const LeadActivityResponse({this.id='',this.action='',this.detail='',this.createdAt=''});
  factory LeadActivityResponse.fromJson(Map<String,dynamic> j) => LeadActivityResponse(
    id: (j['id']??'').toString(),action: j['action']as String? ?? '',
    detail: j['detail']as String? ?? '',createdAt: j['createdAt']as String? ?? '');
}

class LeadStatsResponse {
  final int total;final int active;final int won;final int lost;final int unanswered;
  final double totalValue;final double wonValue;final double conversionRate;
  final List<PipelineStage> pipeline;
  const LeadStatsResponse({this.total=0,this.active=0,this.won=0,this.lost=0,this.unanswered=0,
    this.totalValue=0,this.wonValue=0,this.conversionRate=0,this.pipeline=const[]});
  factory LeadStatsResponse.fromJson(Map<String,dynamic> j) => LeadStatsResponse(
    total: j['total']as int? ?? 0,active: j['active']as int? ?? 0,won: j['won']as int? ?? 0,
    lost: j['lost']as int? ?? 0,unanswered: j['unanswered']as int? ?? 0,
    totalValue: (j['totalValue']as num?)?.toDouble()??0,wonValue: (j['wonValue']as num?)?.toDouble()??0,
    conversionRate: (j['conversionRate']as num?)?.toDouble()??0,
    pipeline: (j['pipeline']as List?)?.map((e)=>PipelineStage.fromJson(e)).toList()??[]);
}

class PipelineStage {
  final String status;final int count;final double value;
  const PipelineStage({this.status='',this.count=0,this.value=0});
  factory PipelineStage.fromJson(Map<String,dynamic> j) => PipelineStage(
    status: j['status']as String? ?? '',count: j['count']as int? ?? 0,
    value: (j['value']as num?)?.toDouble()??0);
}

class FollowUpResponse {
  final String leadId;final String leadNumber;final String customerName;final String phone;
  final String source;final String assignedTo;final String status;final String followUpDate;
  final String leadValue;
  const FollowUpResponse({this.leadId='',this.leadNumber='',this.customerName='',this.phone='',
    this.source='',this.assignedTo='',this.status='',this.followUpDate='',this.leadValue='0'});
  factory FollowUpResponse.fromJson(Map<String,dynamic> j) => FollowUpResponse(
    leadId: (j['leadId']??'').toString(),leadNumber: j['leadNumber']as String? ?? '',
    customerName: j['customerName']as String? ?? '',phone: j['phone']as String? ?? '',
    source: j['source']as String? ?? '',assignedTo: j['assignedTo']as String? ?? '',
    status: j['status']as String? ?? '',followUpDate: j['followUpDate']as String? ?? '',
    leadValue: (j['leadValue']??'0').toString());
}

class ActivityFeedItem {
  final String id;final String leadId;final String customerName;final String action;
  final String detail;final String createdAt;
  const ActivityFeedItem({this.id='',this.leadId='',this.customerName='',this.action='',
    this.detail='',this.createdAt=''});
  factory ActivityFeedItem.fromJson(Map<String,dynamic> j) => ActivityFeedItem(
    id: (j['id']??'').toString(),leadId: (j['leadId']??'').toString(),
    customerName: j['customerName']as String? ?? '',action: j['action']as String? ?? '',
    detail: j['detail']as String? ?? '',createdAt: j['createdAt']as String? ?? '');
}

class CrmTaskResponse {
  final String id;final String title;final String assignedTo;final String dueDate;final String priority;final bool isDone;
  const CrmTaskResponse({this.id='',this.title='',this.assignedTo='',this.dueDate='',this.priority='Medium',this.isDone=false});
  factory CrmTaskResponse.fromJson(Map<String,dynamic> j) => CrmTaskResponse(
    id: (j['id']??'').toString(),title: j['title']as String? ?? '',
    assignedTo: j['assignedTo']as String? ?? '',dueDate: j['dueDate']as String? ?? '',
    priority: j['priority']as String? ?? 'Medium',isDone: j['isDone']as bool? ?? false);
}
