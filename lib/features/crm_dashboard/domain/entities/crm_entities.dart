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
}

class CrmLeadEntity {
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

  const CrmLeadEntity({
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
  });
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
}

class CrmTrendPoint {
  final String month;
  final double won;
  final double lost;
  final double active;

  const CrmTrendPoint(this.month, this.won, this.lost, this.active);
}

class SalespersonPerf {
  final String name;
  final double leads;
  final double won;

  const SalespersonPerf(this.name, this.leads, this.won);
}

class ResponseTimeBucket {
  final String label;
  final double count;

  const ResponseTimeBucket(this.label, this.count);
}

class LeadSourceSlice {
  final String label;
  final double percent;
  final Color color;

  const LeadSourceSlice(this.label, this.percent, this.color);
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
}

class IntegrationEntity {
  final String name;
  final IconData icon;
  final Color color;
  final bool connected;

  const IntegrationEntity({
    required this.name,
    required this.icon,
    required this.color,
    required this.connected,
  });
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
