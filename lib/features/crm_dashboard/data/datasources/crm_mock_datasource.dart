import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/features/crm_dashboard/domain/entities/crm_entities.dart';

class CrmMockDataSource {
  List<CrmKpiEntity> get kpis => const [
    CrmKpiEntity(label: 'Total Messages', value: '1247', icon: Icons.chat_bubble_outline_rounded, color: AppColors.cyanBright, bgColor: Color(0xFF001F2E), trend: '12%', trendUp: true),
    CrmKpiEntity(label: 'Active Leads', value: '3', icon: Icons.person_search_outlined, color: AppColors.purpleAccent, bgColor: Color(0xFF1A0A2E), trend: '8%', trendUp: true),
    CrmKpiEntity(label: 'Unanswered', value: '2', icon: Icons.mark_chat_unread_outlined, color: AppColors.warning, bgColor: Color(0xFF2A1A00), trend: '5%', trendUp: false),
    CrmKpiEntity(label: 'Won Leads', value: '3', icon: Icons.emoji_events_outlined, color: AppColors.greenAccent, bgColor: Color(0xFF002A1E), trend: '15%', trendUp: true),
    CrmKpiEntity(label: 'Lost Leads', value: '2', icon: Icons.trending_down_rounded, color: AppColors.red500, bgColor: Color(0xFF2A0A0A), trend: '3%', trendUp: false),
    CrmKpiEntity(label: 'No Response', value: '2', icon: Icons.notifications_off_outlined, color: Color(0xFF8B5CF6), bgColor: Color(0xFF1A0A2E), trend: '2%', trendUp: true),
  ];

  List<CrmChannelEntity> get channels => const [
    CrmChannelEntity(label: 'WhatsApp Lite', icon: Icons.chat_rounded, color: Color(0xFF25D366), value: '487', trend: '15%', trendUp: true),
    CrmChannelEntity(label: 'WhatsApp Cloud', icon: Icons.cloud_queue_rounded, color: AppColors.cyanBright, value: '324', trend: '22%', trendUp: true),
    CrmChannelEntity(label: 'Instagram', icon: Icons.camera_alt_outlined, color: Color(0xFFE1306C), value: '156', trend: '8%', trendUp: true),
    CrmChannelEntity(label: 'SMS', icon: Icons.sms_outlined, color: AppColors.purpleAccent, value: '98', trend: '3%', trendUp: false),
    CrmChannelEntity(label: 'Live Chat', icon: Icons.support_agent_rounded, color: AppColors.greenAccent, value: '82', trend: '12%', trendUp: true),
    CrmChannelEntity(label: 'Google Ads', icon: Icons.ads_click_rounded, color: AppColors.amber500, value: '54', trend: '18%', trendUp: true),
    CrmChannelEntity(label: 'Website', icon: Icons.language_rounded, color: AppColors.cyanBright, value: '36', trend: '5%', trendUp: true),
    CrmChannelEntity(label: 'Email', icon: Icons.email_outlined, color: AppColors.red500, value: '10', trend: '2%', trendUp: false),
  ];

  List<CrmTrendPoint> get conversionTrend => const [
    CrmTrendPoint('Jan', 20, 10, 40),
    CrmTrendPoint('Feb', 28, 8, 45),
    CrmTrendPoint('Mar', 25, 12, 38),
    CrmTrendPoint('Apr', 35, 9, 50),
    CrmTrendPoint('May', 30, 7, 42),
    CrmTrendPoint('Jun', 45, 11, 55),
    CrmTrendPoint('Jul', 40, 8, 48),
  ];

  List<SalespersonPerf> get salespersonPerf => const [
    SalespersonPerf('John Doe', 125, 85),
    SalespersonPerf('Sarah Smith', 98, 62),
    SalespersonPerf('Mike Johnson', 110, 74),
    SalespersonPerf('Joe Brown', 75, 48),
  ];

  List<ResponseTimeBucket> get responseTimeBuckets => const [
    ResponseTimeBucket('0-5 min', 340),
    ResponseTimeBucket('5-15 min', 280),
    ResponseTimeBucket('15-30 min', 180),
    ResponseTimeBucket('30-60 min', 95),
    ResponseTimeBucket('> 1hr', 110),
  ];

  List<LeadSourceSlice> get leadSources => const [
    LeadSourceSlice('WhatsApp', 51, Color(0xFF25D366)),
    LeadSourceSlice('Instagram', 17, Color(0xFFE1306C)),
    LeadSourceSlice('SMS', 10, AppColors.purpleAccent),
    LeadSourceSlice('Google Ads', 8, AppColors.amber500),
    LeadSourceSlice('Website', 6, AppColors.cyanBright),
    LeadSourceSlice('Other', 8, AppColors.text3),
  ];

  List<CrmKeyMetric> get keyMetrics => const [
    CrmKeyMetric(label: 'Win Rate', value: '63.8%', sub: '\u2191 0.3% from last month', up: true, color: AppColors.greenAccent),
    CrmKeyMetric(label: 'Avg Response Time', value: '8.4m', sub: '\u2193 2.1m from last month', up: false, color: AppColors.cyanBright),
    CrmKeyMetric(label: 'Customer Satisfaction', value: '4.7/5', sub: '\u2191 0.3 from last month', up: true, color: Color(0xFF8B5CF6)),
    CrmKeyMetric(label: 'ROI from Ads', value: '342%', sub: '\u2191 28% from last month', up: true, color: AppColors.warning),
  ];

  List<IntegrationEntity> get integrations => const [
    IntegrationEntity(name: 'WhatsApp Business API', icon: Icons.chat_rounded, color: Color(0xFF25D366), connected: true),
    IntegrationEntity(name: 'Instagram', icon: Icons.camera_alt_outlined, color: Color(0xFFE1306C), connected: false),
    IntegrationEntity(name: 'Facebook Messenger', icon: Icons.facebook_rounded, color: Color(0xFF1877F2), connected: true),
    IntegrationEntity(name: 'Google Ads', icon: Icons.ads_click_rounded, color: AppColors.amber500, connected: true),
    IntegrationEntity(name: 'Website Chat', icon: Icons.language_rounded, color: AppColors.cyanBright, connected: false),
    IntegrationEntity(name: 'SMS Provider', icon: Icons.sms_outlined, color: AppColors.purpleAccent, connected: true),
  ];

  List<SalesTeamMember> get salesTeam => const [
    SalesTeamMember(name: 'John Doe', role: 'Senior Sales Rep', leadsHandled: 125, wonDeals: 85, revenue: 'AED 95,800', winRate: 0.68),
    SalesTeamMember(name: 'Sarah Smith', role: 'Sales Representative', leadsHandled: 98, wonDeals: 62, revenue: 'AED 72,400', winRate: 0.63),
    SalesTeamMember(name: 'Mike Johnson', role: 'Sales Representative', leadsHandled: 110, wonDeals: 74, revenue: 'AED 68,200', winRate: 0.67),
    SalesTeamMember(name: 'Joe Brown', role: 'Junior Sales Rep', leadsHandled: 75, wonDeals: 48, revenue: 'AED 44,300', winRate: 0.64),
  ];

  List<ConversationEntity> get conversations => const [
    ConversationEntity(id: '1', customerName: 'James Anderson', lastMessage: 'I am interested in your services, can we schedule a call?', time: '14:23', channel: 'WhatsApp', channelColor: Color(0xFF25D366), unread: 2, status: 'ACTIVE'),
    ConversationEntity(id: '2', customerName: 'Emily Chen', lastMessage: 'Thank you for the quick response!', time: '13:45', channel: 'Instagram', channelColor: Color(0xFFE1306C), unread: 0, status: 'WON'),
    ConversationEntity(id: '3', customerName: 'Michael Roberts', lastMessage: 'Please send me the quotation as soon as possible.', time: '12:15', channel: 'Google Ads', channelColor: AppColors.amber500, unread: 1, status: 'ACTIVE'),
    ConversationEntity(id: '4', customerName: 'Sarah Williams', lastMessage: 'No reply yet on the proposal.', time: 'Yesterday', channel: 'Website', channelColor: AppColors.cyanBright, unread: 0, status: 'UNANSWERED'),
    ConversationEntity(id: '5', customerName: 'David Martinez', lastMessage: 'Going with a competitor unfortunately.', time: '2 days ago', channel: 'SMS', channelColor: AppColors.purpleAccent, unread: 0, status: 'LOST'),
  ];
}
