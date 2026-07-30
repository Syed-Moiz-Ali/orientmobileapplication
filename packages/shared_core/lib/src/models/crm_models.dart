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
  const IntegrationResponse({this.name='',this.connected=false});
  factory IntegrationResponse.fromJson(Map<String,dynamic> j) => IntegrationResponse(
    name: j['name']as String? ?? '',connected: j['connected']as bool? ?? false);
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
  final int sno;final String leadNumber;final String customerName;final String phone;
  final String email;final String source;final String assignedTo;final String status;final String lastActivity;
  const LeadResponse({this.sno=0,this.leadNumber='',this.customerName='',this.phone='',this.email='',
    this.source='',this.assignedTo='',this.status='ACTIVE',this.lastActivity=''});
  factory LeadResponse.fromJson(Map<String,dynamic> j) => LeadResponse(
    sno: j['sno']as int? ?? 0,leadNumber: j['leadNumber']as String? ?? '',
    customerName: j['customerName']as String? ?? '',phone: j['phone']as String? ?? '',
    email: j['email']as String? ?? '',source: j['source']as String? ?? '',
    assignedTo: j['assignedTo']as String? ?? '',status: j['status']as String? ?? 'ACTIVE',
    lastActivity: j['lastActivity']as String? ?? '');
}

class CrmTaskResponse {
  final String id;final String title;final String assignedTo;final String dueDate;final String priority;final bool isDone;
  const CrmTaskResponse({this.id='',this.title='',this.assignedTo='',this.dueDate='',this.priority='Medium',this.isDone=false});
  factory CrmTaskResponse.fromJson(Map<String,dynamic> j) => CrmTaskResponse(
    id: (j['id']??'').toString(),title: j['title']as String? ?? '',
    assignedTo: j['assignedTo']as String? ?? '',dueDate: j['dueDate']as String? ?? '',
    priority: j['priority']as String? ?? 'Medium',isDone: j['isDone']as bool? ?? false);
}
