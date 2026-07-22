import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'crm_entities.freezed.dart';

@freezed
class CrmKpiEntity with _$CrmKpiEntity {
  const factory CrmKpiEntity({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String trend,
    required bool trendUp,
  }) = _CrmKpiEntity;
}

@freezed
class CrmChannelEntity with _$CrmChannelEntity {
  const factory CrmChannelEntity({
    required String label,
    required IconData icon,
    required Color color,
    required String value,
    required String trend,
    required bool trendUp,
  }) = _CrmChannelEntity;
}

@freezed
class CrmLeadEntity with _$CrmLeadEntity {
  const factory CrmLeadEntity({
    required int sno,
    required String leadNumber,
    required String customerName,
    required String phone,
    required String email,
    required String source,
    required Color sourceColor,
    required String assignedTo,
    required String status,
    required Color statusColor,
    required String lastActivity,
  }) = _CrmLeadEntity;
}

@freezed
class CrmTaskEntity with _$CrmTaskEntity {
  const factory CrmTaskEntity({
    required String id,
    required String title,
    required String assignedTo,
    required String dueDate,
    required String priority,
    required Color priorityColor,
    @Default(false) bool isDone,
  }) = _CrmTaskEntity;
}

@freezed
class CrmTrendPoint with _$CrmTrendPoint {
  const factory CrmTrendPoint(String month, double won, double lost, double active) = _CrmTrendPoint;
}

@freezed
class SalespersonPerf with _$SalespersonPerf {
  const factory SalespersonPerf(String name, double leads, double won) = _SalespersonPerf;
}

@freezed
class ResponseTimeBucket with _$ResponseTimeBucket {
  const factory ResponseTimeBucket(String label, double count) = _ResponseTimeBucket;
}

@freezed
class LeadSourceSlice with _$LeadSourceSlice {
  const factory LeadSourceSlice(String label, double percent, Color color) = _LeadSourceSlice;
}

@freezed
class CrmKeyMetric with _$CrmKeyMetric {
  const factory CrmKeyMetric({
    required String label,
    required String value,
    required String sub,
    required bool up,
    required Color color,
  }) = _CrmKeyMetric;
}

@freezed
class IntegrationEntity with _$IntegrationEntity {
  const factory IntegrationEntity({
    required String name,
    required IconData icon,
    required Color color,
    required bool connected,
  }) = _IntegrationEntity;
}

@freezed
class SalesTeamMember with _$SalesTeamMember {
  const factory SalesTeamMember({
    required String name,
    required String role,
    required int leadsHandled,
    required int wonDeals,
    required String revenue,
    required double winRate,
  }) = _SalesTeamMember;
}

@freezed
class ConversationEntity with _$ConversationEntity {
  const factory ConversationEntity({
    required String id,
    required String customerName,
    required String lastMessage,
    required String time,
    required String channel,
    required Color channelColor,
    required int unread,
    required String status,
  }) = _ConversationEntity;
}

@freezed
class CrmNotificationEntity with _$CrmNotificationEntity {
  const factory CrmNotificationEntity({
    required String id,
    required String title,
    required String body,
    required String time,
    required String type,
    @Default(false) bool isRead,
  }) = _CrmNotificationEntity;
}
