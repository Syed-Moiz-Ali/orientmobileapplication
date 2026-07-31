import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/data/datasources/crm_remote_datasource.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

abstract class CrmDataSource {
  List<CrmKpiEntity> get kpis;
  List<CrmChannelEntity> get channels;
  List<CrmTrendPoint> get conversionTrend;
  List<SalespersonPerf> get salespersonPerf;
  List<ResponseTimeBucket> get responseTimeBuckets;
  List<LeadSourceSlice> get leadSources;
  List<CrmKeyMetric> get keyMetrics;
  List<IntegrationEntity> get integrations;
  List<SalesTeamMember> get salesTeam;
  List<ConversationEntity> get conversations;
  List<CrmLeadEntity> getLeads();
  List<CrmTaskEntity> getTasks();
  Future<void> refreshLeads();
  Future<void> refreshTasks();
  Future<CrmTaskEntity> createTask(Map<String, dynamic> data);
  Future<CrmTaskEntity> updateTask(String id, Map<String, dynamic> data);
  Future<void> deleteTask(String id);
  Future<CrmLeadEntity> createLead(Map<String, dynamic> data);
  Future<CrmLeadEntity> updateLead(String id, Map<String, dynamic> data);
  Future<void> deleteLead(String id);
  Future<IntegrationEntity> connectIntegration(String name, Map<String, String> credentials);
  Future<IntegrationEntity> disconnectIntegration(String name);
  Future<IntegrationEntity> syncIntegration(String name);
  Future<List<TeamMemberEntity>> getTeamMembers();
  Future<List<LeadActivityEntity>> getLeadActivities(String id);
  Future<LeadStatsEntity> getLeadStats();
  Future<List<FollowUpEntity>> getFollowUps();
  Future<List<ActivityFeedEntity>> getActivityFeed();
}

class CrmRemoteAdapter implements CrmDataSource {
  final CrmRemoteDataSource _remote;
  CrmRemoteAdapter(this._remote);

  List<CrmKpiEntity> _kpis = [];
  List<CrmChannelEntity> _channels = [];
  List<CrmTrendPoint> _conversionTrend = [];
  List<SalespersonPerf> _salespersonPerf = [];
  List<ResponseTimeBucket> _responseTimeBuckets = [];
  List<LeadSourceSlice> _leadSources = [];
  List<CrmKeyMetric> _keyMetrics = [];
  List<IntegrationEntity> _integrations = [];
  List<SalesTeamMember> _salesTeam = [];
  List<ConversationEntity> _conversations = [];
  List<CrmLeadEntity> _leads = [];
  List<CrmTaskEntity> _tasks = [];

  @override List<CrmKpiEntity> get kpis => _kpis;
  @override List<CrmChannelEntity> get channels => _channels;
  @override List<CrmTrendPoint> get conversionTrend => _conversionTrend;
  @override List<SalespersonPerf> get salespersonPerf => _salespersonPerf;
  @override List<ResponseTimeBucket> get responseTimeBuckets => _responseTimeBuckets;
  @override List<LeadSourceSlice> get leadSources => _leadSources;
  @override List<CrmKeyMetric> get keyMetrics => _keyMetrics;
  @override List<IntegrationEntity> get integrations => _integrations;
  @override List<SalesTeamMember> get salesTeam => _salesTeam;
  @override List<ConversationEntity> get conversations => _conversations;
  @override List<CrmLeadEntity> getLeads() => _leads;
  @override List<CrmTaskEntity> getTasks() => _tasks;

  Future<void> loadAll() async {
    final kpiIcons = [Icons.chat_bubble_outline_rounded, Icons.person_search_outlined, Icons.mark_chat_unread_outlined, Icons.emoji_events_outlined, Icons.trending_down_rounded, Icons.notifications_off_outlined];
    final kpiColors = [AppColors.cyanBright, AppColors.purpleAccent, AppColors.warning, AppColors.greenAccent, AppColors.red500, const Color(0xFF8B5CF6)];
    final kpiBgs = [const Color(0xFF001F2E), const Color(0xFF1A0A2E), const Color(0xFF2A1A00), const Color(0xFF002A1E), const Color(0xFF2A0A0A), const Color(0xFF1A0A2E)];
    final sourceColors = [const Color(0xFF25D366), const Color(0xFFE1306C), AppColors.purpleAccent, AppColors.amber500, AppColors.cyanBright, AppColors.text3];

    final results = await Future.wait([
      _remote.getKpis(), _remote.getChannels(), _remote.getConversionTrend(),
      _remote.getSalespersonPerformance(), _remote.getResponseTimes(),
      _remote.getLeadSources(), _remote.getKeyMetrics(), _remote.getIntegrations(),
      _remote.getSalesTeam(), _remote.getConversations(), _remote.getLeads(),
      _remote.getTasks(),
    ]);

    _kpis = _mapKpis(results[0] as List, kpiIcons, kpiColors, kpiBgs);
    _channels = _mapChannels(results[1] as List);
    _conversionTrend = (results[2] as List).map((e) => CrmTrendPoint(
      (e as ConversionTrendResponse).month,
      e.active.toDouble(), e.won.toDouble(), e.lost.toDouble(),
    )).toList();
    _salespersonPerf = (results[3] as List).map((e) => SalespersonPerf(
      (e as SalespersonPerfResponse).name,
      e.leads.toDouble(), e.won.toDouble(),
    )).toList();
    _responseTimeBuckets = (results[4] as List).map((e) => ResponseTimeBucket(
      (e as ResponseTimeResponse).label, e.count.toDouble(),
    )).toList();
    _leadSources = (results[5] as List).asMap().entries.map((e) => LeadSourceSlice(
      (e.value as LeadSourceResponse).label, e.value.percent.toDouble(),
      sourceColors[e.key < sourceColors.length ? e.key : sourceColors.length - 1],
    )).toList();
    _keyMetrics = _mapKeyMetrics(results[6] as KeyMetricResponse);
    _integrations = _mapIntegrations(results[7] as List);
    _salesTeam = _mapSalesTeam(results[8] as List);
    _conversations = _mapConversations(results[9] as List);
    _leads = _mapLeads(results[10] as List);
    _tasks = _mapTasks(results[11] as List);
  }

  Future<void> reloadIntegrations() async {
    _integrations = _mapIntegrations(await _remote.getIntegrations());
  }

  Future<void> reloadLeads() async {
    _leads = _mapLeads(await _remote.getLeads());
  }

  @override
  Future<void> refreshLeads() => reloadLeads();

  Future<void> reloadTasks() async {
    _tasks = _mapTasks(await _remote.getTasks());
  }

  @override
  Future<void> refreshTasks() => reloadTasks();

  @override
  Future<CrmTaskEntity> createTask(Map<String, dynamic> data) async {
    final r = await _remote.createTask(data);
    await reloadTasks();
    return _mapTasks([r]).first;
  }

  @override
  Future<CrmTaskEntity> updateTask(String id, Map<String, dynamic> data) async {
    final r = await _remote.updateTaskFull(id, data);
    await reloadTasks();
    return _mapTasks([r]).first;
  }

  @override
  Future<void> deleteTask(String id) async {
    await _remote.deleteTask(id);
    await reloadTasks();
  }

  @override
  Future<CrmLeadEntity> createLead(Map<String, dynamic> data) async {
    final r = await _remote.createLead(data);
    await reloadLeads();
    return _mapLeads([r]).first;
  }

  @override
  Future<CrmLeadEntity> updateLead(String id, Map<String, dynamic> data) async {
    final r = await _remote.updateLead(id, data);
    await reloadLeads();
    return _mapLeads([r]).first;
  }

  @override
  Future<void> deleteLead(String id) async {
    await _remote.deleteLead(id);
    await reloadLeads();
  }

  @override
  Future<IntegrationEntity> connectIntegration(String name, Map<String, String> credentials) async {
    final r = await _remote.connectIntegration(name, credentials);
    await reloadIntegrations();
    return _toIntegrationEntity(r);
  }

  @override
  Future<IntegrationEntity> disconnectIntegration(String name) async {
    final r = await _remote.disconnectIntegration(name);
    await reloadIntegrations();
    return _toIntegrationEntity(r);
  }

  @override
  Future<IntegrationEntity> syncIntegration(String name) async {
    final r = await _remote.syncIntegration(name);
    await Future.wait([reloadIntegrations(), reloadLeads()]);
    return _toIntegrationEntity(r);
  }

  List<CrmKpiEntity> _mapKpis(List l, List<IconData> icons, List<Color> colors, List<Color> bgs) {
    return l.asMap().entries.map((e) => CrmKpiEntity(
      label: (e.value as CrmKpiResponse).label, value: (e.value as CrmKpiResponse).value,
      icon: icons[e.key < icons.length ? e.key : 0],
      color: colors[e.key < colors.length ? e.key : 0],
      bgColor: bgs[e.key < bgs.length ? e.key : 0],
      trend: (e.value as CrmKpiResponse).change, trendUp: true,
    )).toList();
  }

  List<CrmChannelEntity> _mapChannels(List l) {
    return l.asMap().entries.map((e) => CrmChannelEntity(
      label: (e.value as ChannelResponse).name, value: (e.value as ChannelResponse).count.toString(),
      icon: Icons.chat_rounded, color: Colors.grey, trend: '', trendUp: true,
    )).toList();
  }

  List<CrmKeyMetric> _mapKeyMetrics(KeyMetricResponse km) {
    return [
      CrmKeyMetric(label: 'Win Rate', value: '${km.winRate.toStringAsFixed(1)}%', sub: '', up: true, color: AppColors.greenAccent),
      CrmKeyMetric(label: 'Avg Response Time', value: km.avgResponseTime.isEmpty ? '--' : km.avgResponseTime, sub: '', up: true, color: AppColors.cyanBright),
      CrmKeyMetric(label: 'Customer Satisfaction', value: km.satisfaction > 0 ? km.satisfaction.toStringAsFixed(1) : '--', sub: '', up: true, color: const Color(0xFF8B5CF6)),
      CrmKeyMetric(label: 'ROI from Ads', value: km.roi > 0 ? '${km.roi}%' : '--', sub: '', up: true, color: AppColors.warning),
    ];
  }

  List<IntegrationEntity> _mapIntegrations(List l) {
    return l.map((e) => _toIntegrationEntity(e as IntegrationResponse)).toList();
  }

  IntegrationEntity _toIntegrationEntity(IntegrationResponse e) {
    return IntegrationEntity(
      name: e.name, icon: Icons.link_rounded,
      color: const Color(0xFF25D366), connected: e.connected,
      lastSyncAt: e.lastSyncAt, syncStatus: e.syncStatus, leadCount: e.leadCount,
    );
  }

  List<SalesTeamMember> _mapSalesTeam(List l) {
    return l.map((e) => SalesTeamMember(
      name: (e as SalesTeamResponse).name, role: e.role,
      leadsHandled: e.leadsHandled, wonDeals: e.wonDeals,
      revenue: e.revenue, winRate: e.winRate,
    )).toList();
  }

  List<ConversationEntity> _mapConversations(List l) {
    return l.map((e) => ConversationEntity(
      id: (e as ConversationResponse).id, customerName: e.customerName,
      lastMessage: e.lastMessage, time: e.time, channel: e.channel,
      channelColor: _channelColor(e.channel), unread: e.unread, status: e.status,
    )).toList();
  }

  List<CrmLeadEntity> _mapLeads(List l) {
    return l.asMap().entries.map((e) {
      final ld = e.value as LeadResponse;
      return CrmLeadEntity(
        id: ld.id, sno: e.key + 1, leadNumber: ld.leadNumber, customerName: ld.customerName,
        phone: ld.phone, email: ld.email, source: ld.source,
        sourceColor: _sourceColor(ld.source), assignedTo: ld.assignedTo,
        status: ld.status, statusColor: _statusColor(ld.status),
        lastActivity: ld.lastActivity, notes: ld.notes,
        leadValue: ld.leadValue, followUpDate: ld.followUpDate,
      );
    }).toList();
  }

  List<TeamMemberEntity> _mapTeamMembers(List l) {
    return l.map((e) => TeamMemberEntity(
      name: (e as TeamMemberResponse).name, role: e.role,
      designation: e.designation, leadsHandled: e.leadsHandled, wonDeals: e.wonDeals,
    )).toList();
  }

  List<LeadActivityEntity> _mapActivities(List l) {
    return l.map((e) => LeadActivityEntity(
      id: (e as LeadActivityResponse).id, action: e.action,
      detail: e.detail, createdAt: e.createdAt,
    )).toList();
  }

  @override
  Future<List<TeamMemberEntity>> getTeamMembers() async {
    return _mapTeamMembers(await _remote.getTeamMembers());
  }

  @override
  Future<List<LeadActivityEntity>> getLeadActivities(String id) async {
    return _mapActivities(await _remote.getLeadActivities(id));
  }

  @override
  Future<LeadStatsEntity> getLeadStats() async {
    final s = await _remote.getLeadStats();
    return LeadStatsEntity(
      total: s.total, active: s.active, won: s.won, lost: s.lost, unanswered: s.unanswered,
      totalValue: s.totalValue, wonValue: s.wonValue, conversionRate: s.conversionRate,
      pipeline: s.pipeline.map((p) => PipelineStageEntity(status: p.status, count: p.count, value: p.value)).toList(),
    );
  }

  @override
  Future<List<FollowUpEntity>> getFollowUps() async {
    final items = await _remote.getFollowUps();
    return items.map((f) => FollowUpEntity(
      leadId: f.leadId, leadNumber: f.leadNumber, customerName: f.customerName,
      phone: f.phone, source: f.source, assignedTo: f.assignedTo,
      status: f.status, followUpDate: f.followUpDate,
      leadValue: double.tryParse(f.leadValue) ?? 0,
    )).toList();
  }

  @override
  Future<List<ActivityFeedEntity>> getActivityFeed() async {
    final items = await _remote.getActivityFeed();
    return items.map((a) => ActivityFeedEntity(
      id: a.id, leadId: a.leadId, customerName: a.customerName,
      action: a.action, detail: a.detail, createdAt: a.createdAt,
    )).toList();
  }

  List<CrmTaskEntity> _mapTasks(List l) {
    return l.map((e) => CrmTaskEntity(
      id: (e as CrmTaskResponse).id, title: e.title, assignedTo: e.assignedTo,
      dueDate: e.dueDate, priority: e.priority,
      priorityColor: _priorityColor(e.priority),
    )).toList();
  }

  Color _channelColor(String c) => switch (c) { 'WhatsApp' => const Color(0xFF25D366), 'Instagram' => const Color(0xFFE1306C), 'SMS' => AppColors.purpleAccent, 'Website' => AppColors.cyanBright, _ => AppColors.amber500 };
  Color _sourceColor(String s) => _channelColor(s);
  Color _statusColor(String s) => switch (s) { 'WON' => AppColors.greenAccent, 'ACTIVE' => AppColors.greenAccent, 'UNANSWERED' => AppColors.warning, _ => AppColors.red500 };
  Color _priorityColor(String p) => switch (p) { 'HIGH' => AppColors.red500, 'MEDIUM' => AppColors.warning, _ => AppColors.greenAccent };
}
