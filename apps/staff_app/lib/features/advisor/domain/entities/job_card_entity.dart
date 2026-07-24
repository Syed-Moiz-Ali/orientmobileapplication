import 'package:shared_core/shared_core.dart';

class JobCardEntity {
  final String id;
  final String customerName;
  final String vehicleInfo;
  final String time;
  final String createdDate;
  final String lastUpdated;
  final JobCardStatus status;
  final String technician;

  const JobCardEntity({
    required this.id,
    required this.customerName,
    required this.vehicleInfo,
    required this.time,
    this.createdDate = '',
    this.lastUpdated = '',
    required this.status,
    this.technician = '',
  });

  JobCardEntity copyWith({
    String? id,
    String? customerName,
    String? vehicleInfo,
    String? time,
    String? createdDate,
    String? lastUpdated,
    JobCardStatus? status,
    String? technician,
  }) {
    return JobCardEntity(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      time: time ?? this.time,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      technician: technician ?? this.technician,
    );
  }
}
