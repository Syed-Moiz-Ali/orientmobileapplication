import 'package:flutter/material.dart';

class CrmKpiEntity {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String trend;
  final bool trendUp;

  const CrmKpiEntity({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.trend,
    required this.trendUp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrmKpiEntity &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value &&
          icon == other.icon &&
          color == other.color &&
          bgColor == other.bgColor &&
          trend == other.trend &&
          trendUp == other.trendUp;

  @override
  int get hashCode => Object.hash(runtimeType, label, value, icon, color, bgColor, trend, trendUp);

  @override
  String toString() =>
      'CrmKpiEntity(label: $label, value: $value, icon: $icon, color: $color, bgColor: $bgColor, trend: $trend, trendUp: $trendUp)';
}

class CrmChannelEntity {
  final String label;
  final IconData icon;
  final Color color;
  final String value;
  final String trend;
  final bool trendUp;

  const CrmChannelEntity({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.trend,
    required this.trendUp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrmChannelEntity &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          icon == other.icon &&
          color == other.color &&
          value == other.value &&
          trend == other.trend &&
          trendUp == other.trendUp;

  @override
  int get hashCode => Object.hash(runtimeType, label, icon, color, value, trend, trendUp);

  @override
  String toString() =>
      'CrmChannelEntity(label: $label, icon: $icon, color: $color, value: $value, trend: $trend, trendUp: $trendUp)';
}

class CrmLeadEntity {
  final String id;
  final int sno;
  final String leadNumber;
  final String customerName;
  final String phone;
  final String email;
  final String source;
  final Color sourceColor;
  final String assignedTo;
  final String status;
  final Color statusColor;
  final String lastActivity;
  final String notes;
  final double leadValue;
  final String followUpDate;

  const CrmLeadEntity({
    this.id = '',
    required this.sno,
    required this.leadNumber,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.source,
    required this.sourceColor,
    required this.assignedTo,
    required this.status,
    required this.statusColor,
    required this.lastActivity,
    this.notes = '',
    this.leadValue = 0,
    this.followUpDate = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrmLeadEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sno == other.sno &&
          leadNumber == other.leadNumber &&
          customerName == other.customerName &&
          phone == other.phone &&
          email == other.email &&
          source == other.source &&
          sourceColor == other.sourceColor &&
          assignedTo == other.assignedTo &&
          status == other.status &&
          statusColor == other.statusColor &&
          lastActivity == other.lastActivity;

  @override
  int get hashCode => Object.hash(runtimeType, id, sno, leadNumber, customerName, phone, email, source,
      sourceColor, assignedTo, status, statusColor, lastActivity);

  @override
  String toString() =>
      'CrmLeadEntity(sno: $sno, leadNumber: $leadNumber, customerName: $customerName, phone: $phone, email: $email, source: $source, sourceColor: $sourceColor, assignedTo: $assignedTo, status: $status, statusColor: $statusColor, lastActivity: $lastActivity)';
}

class CrmTaskEntity {
  final String id;
  final String title;
  final String assignedTo;
  final String dueDate;
  final String priority;
  final Color priorityColor;
  final bool isDone;

  const CrmTaskEntity({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.dueDate,
    required this.priority,
    required this.priorityColor,
    this.isDone = false,
  });

  CrmTaskEntity copyWith({
    String? id,
    String? title,
    String? assignedTo,
    String? dueDate,
    String? priority,
    Color? priorityColor,
    bool? isDone,
  }) {
    return CrmTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      priorityColor: priorityColor ?? this.priorityColor,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrmTaskEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          assignedTo == other.assignedTo &&
          dueDate == other.dueDate &&
          priority == other.priority &&
          priorityColor == other.priorityColor &&
          isDone == other.isDone;

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, assignedTo, dueDate, priority, priorityColor, isDone);

  @override
  String toString() =>
      'CrmTaskEntity(id: $id, title: $title, assignedTo: $assignedTo, dueDate: $dueDate, priority: $priority, priorityColor: $priorityColor, isDone: $isDone)';
}

class CrmTrendPoint {
  final String month;
  final double won;
  final double lost;
  final double active;

  const CrmTrendPoint(this.month, this.won, this.lost, this.active);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrmTrendPoint &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          won == other.won &&
          lost == other.lost &&
          active == other.active;

  @override
  int get hashCode => Object.hash(runtimeType, month, won, lost, active);

  @override
  String toString() => 'CrmTrendPoint(month: $month, won: $won, lost: $lost, active: $active)';
}

class SalespersonPerf {
  final String name;
  final double leads;
  final double won;

  const SalespersonPerf(this.name, this.leads, this.won);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalespersonPerf &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          leads == other.leads &&
          won == other.won;

  @override
  int get hashCode => Object.hash(runtimeType, name, leads, won);

  @override
  String toString() => 'SalespersonPerf(name: $name, leads: $leads, won: $won)';
}

class ResponseTimeBucket {
  final String label;
  final double count;

  const ResponseTimeBucket(this.label, this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseTimeBucket &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          count == other.count;

  @override
  int get hashCode => Object.hash(runtimeType, label, count);

  @override
  String toString() => 'ResponseTimeBucket(label: $label, count: $count)';
}

class LeadSourceSlice {
  final String label;
  final double percent;
  final Color color;

  const LeadSourceSlice(this.label, this.percent, this.color);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadSourceSlice &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          percent == other.percent &&
          color == other.color;

  @override
  int get hashCode => Object.hash(runtimeType, label, percent, color);

  @override
  String toString() => 'LeadSourceSlice(label: $label, percent: $percent, color: $color)';
}

class CrmKeyMetric {
  final String label;
  final String value;
  final String sub;
  final bool up;
  final Color color;

  const CrmKeyMetric({
    required this.label,
    required this.value,
    required this.sub,
    required this.up,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrmKeyMetric &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value &&
          sub == other.sub &&
          up == other.up &&
          color == other.color;

  @override
  int get hashCode => Object.hash(runtimeType, label, value, sub, up, color);

  @override
  String toString() =>
      'CrmKeyMetric(label: $label, value: $value, sub: $sub, up: $up, color: $color)';
}

class IntegrationEntity {
  final String name;
  final IconData icon;
  final Color color;
  final bool connected;
  final String? lastSyncAt;
  final String syncStatus;
  final int leadCount;

  const IntegrationEntity({
    required this.name,
    required this.icon,
    required this.color,
    required this.connected,
    this.lastSyncAt,
    this.syncStatus = 'IDLE',
    this.leadCount = 0,
  });

  bool get isSyncing => syncStatus == 'SYNCING';
  bool get hasError => syncStatus == 'ERROR';
  bool get isMeta => name.toUpperCase() == 'META';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntegrationEntity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          icon == other.icon &&
          color == other.color &&
          connected == other.connected &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hash(runtimeType, name, icon, color, connected, syncStatus);

  @override
  String toString() =>
      'IntegrationEntity(name: $name, connected: $connected, syncStatus: $syncStatus)';
}

class SalesTeamMember {
  final String name;
  final String role;
  final int leadsHandled;
  final int wonDeals;
  final String revenue;
  final double winRate;

  const SalesTeamMember({
    required this.name,
    required this.role,
    required this.leadsHandled,
    required this.wonDeals,
    required this.revenue,
    required this.winRate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesTeamMember &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          role == other.role &&
          leadsHandled == other.leadsHandled &&
          wonDeals == other.wonDeals &&
          revenue == other.revenue &&
          winRate == other.winRate;

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, role, leadsHandled, wonDeals, revenue, winRate);

  @override
  String toString() =>
      'SalesTeamMember(name: $name, role: $role, leadsHandled: $leadsHandled, wonDeals: $wonDeals, revenue: $revenue, winRate: $winRate)';
}

class ConversationEntity {
  final String id;
  final String customerName;
  final String lastMessage;
  final String time;
  final String channel;
  final Color channelColor;
  final int unread;
  final String status;

  const ConversationEntity({
    required this.id,
    required this.customerName,
    required this.lastMessage,
    required this.time,
    required this.channel,
    required this.channelColor,
    required this.unread,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerName == other.customerName &&
          lastMessage == other.lastMessage &&
          time == other.time &&
          channel == other.channel &&
          channelColor == other.channelColor &&
          unread == other.unread &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
      runtimeType, id, customerName, lastMessage, time, channel, channelColor, unread, status);

  @override
  String toString() =>
      'ConversationEntity(id: $id, customerName: $customerName, lastMessage: $lastMessage, time: $time, channel: $channel, channelColor: $channelColor, unread: $unread, status: $status)';
}

class CrmNotificationEntity {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type;
  final bool isRead;

  const CrmNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class TeamMemberEntity {
  final String name;
  final String role;
  final String designation;
  final int leadsHandled;
  final int wonDeals;

  const TeamMemberEntity({
    required this.name,
    required this.role,
    required this.designation,
    required this.leadsHandled,
    required this.wonDeals,
  });
}

class LeadActivityEntity {
  final String id;
  final String action;
  final String detail;
  final String createdAt;

  const LeadActivityEntity({
    required this.id,
    required this.action,
    required this.detail,
    required this.createdAt,
  });

  String get actionLabel {
    switch (action) {
      case 'CREATED': return 'Lead created';
      case 'IMPORTED': return 'Lead imported';
      case 'STATUS': return 'Status changed';
      case 'ASSIGNED': return 'Assigned to';
      case 'UPDATED': return 'Lead updated';
      default: return action;
    }
  }
}

class PipelineStageEntity {
  final String status;
  final int count;
  final double value;

  const PipelineStageEntity({
    required this.status,
    required this.count,
    required this.value,
  });
}

class LeadStatsEntity {
  final int total;
  final int active;
  final int won;
  final int lost;
  final int unanswered;
  final double totalValue;
  final double wonValue;
  final double conversionRate;
  final List<PipelineStageEntity> pipeline;

  const LeadStatsEntity({
    this.total = 0,
    this.active = 0,
    this.won = 0,
    this.lost = 0,
    this.unanswered = 0,
    this.totalValue = 0,
    this.wonValue = 0,
    this.conversionRate = 0,
    this.pipeline = const [],
  });
}

class FollowUpEntity {
  final String leadId;
  final String leadNumber;
  final String customerName;
  final String phone;
  final String source;
  final String assignedTo;
  final String status;
  final String followUpDate;
  final double leadValue;

  const FollowUpEntity({
    required this.leadId,
    required this.leadNumber,
    required this.customerName,
    required this.phone,
    required this.source,
    required this.assignedTo,
    required this.status,
    required this.followUpDate,
    required this.leadValue,
  });
}

class ActivityFeedEntity {
  final String id;
  final String leadId;
  final String customerName;
  final String action;
  final String detail;
  final String createdAt;

  const ActivityFeedEntity({
    required this.id,
    required this.leadId,
    required this.customerName,
    required this.action,
    required this.detail,
    required this.createdAt,
  });

  String get actionLabel {
    switch (action) {
      case 'CREATED': return 'Lead created';
      case 'IMPORTED': return 'Lead imported';
      case 'STATUS': return 'Status changed';
      case 'ASSIGNED': return 'Assigned to';
      case 'UPDATED': return 'Lead updated';
      default: return action;
    }
  }
}
