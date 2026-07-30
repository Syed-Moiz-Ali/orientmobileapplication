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

    _kpis = (results[0] as List).asMap().entries.map((e) => CrmKpiEntity(
      label: (e.value as CrmKpiResponse).label, value: (e.value as CrmKpiResponse).value,
      icon: kpiIcons[e.key < kpiIcons.length ? e.key : 0],
      color: kpiColors[e.key < kpiColors.length ? e.key : 0],
      bgColor: kpiBgs[e.key < kpiBgs.length ? e.key : 0],
      trend: (e.value as CrmKpiResponse).change, trendUp: true,
    )).toList();

    _channels = (results[1] as List).asMap().entries.map((e) => CrmChannelEntity(
      label: (e.value as ChannelResponse).name, value: (e.value as ChannelResponse).count.toString(),
      icon: Icons.chat_rounded, color: Colors.grey, trend: '', trendUp: true,
    )).toList();

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
      (e.value as LeadSourceResponse).label, e.value.percent,
      sourceColors[e.key < sourceColors.length ? e.key : sourceColors.length - 1],
    )).toList();

    final km = results[6] as KeyMetricResponse;
    _keyMetrics = [
      CrmKeyMetric(label: 'Win Rate', value: '${(km.winRate * 100).toStringAsFixed(1)}%', sub: '', up: true, color: AppColors.greenAccent),
      CrmKeyMetric(label: 'Avg Response Time', value: km.avgResponseTime, sub: '', up: true, color: AppColors.cyanBright),
      CrmKeyMetric(label: 'Customer Satisfaction', value: km.satisfaction.toStringAsFixed(1), sub: '', up: true, color: const Color(0xFF8B5CF6)),
      CrmKeyMetric(label: 'ROI from Ads', value: '${km.roi}%', sub: '', up: true, color: AppColors.warning),
    ];

    _integrations = (results[7] as List).map((e) => IntegrationEntity(
      name: (e as IntegrationResponse).name, icon: Icons.link_rounded,
      color: const Color(0xFF25D366), connected: e.connected,
    )).toList();

    _salesTeam = (results[8] as List).map((e) => SalesTeamMember(
      name: (e as SalesTeamResponse).name, role: e.role,
      leadsHandled: e.leadsHandled, wonDeals: e.wonDeals,
      revenue: e.revenue, winRate: e.winRate,
    )).toList();

    _conversations = (results[9] as List).map((e) => ConversationEntity(
      id: (e as ConversationResponse).id, customerName: e.customerName,
      lastMessage: e.lastMessage, time: e.time, channel: e.channel,
      channelColor: _channelColor(e.channel), unread: e.unread, status: e.status,
    )).toList();

    _leads = (results[10] as List).asMap().entries.map((e) {
      final l = e.value as LeadResponse;
      return CrmLeadEntity(
        sno: e.key + 1, leadNumber: l.leadNumber, customerName: l.customerName,
        phone: l.phone, email: l.email, source: l.source,
        sourceColor: _sourceColor(l.source), assignedTo: l.assignedTo,
        status: l.status, statusColor: _statusColor(l.status),
        lastActivity: l.lastActivity,
      );
    }).toList();

    _tasks = (results[11] as List).map((e) => CrmTaskEntity(
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
