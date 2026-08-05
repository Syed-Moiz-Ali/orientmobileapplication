import 'package:shared_core/shared_core.dart';
export 'package:shared_core/shared_core.dart' show JobCardStatus;

class JobCard {
  final String id;
  final String customerName;
  final String vehicle;
  final String plateNumber;
  final List<String> services;
  final String technician;
  final String estCompletion;
  final double amount;
  final JobCardStatus status;

  const JobCard({
    required this.id,
    required this.customerName,
    required this.vehicle,
    required this.plateNumber,
    required this.services,
    required this.technician,
    required this.estCompletion,
    required this.amount,
    required this.status,
  });

  String get vehicleDisplay => '$vehicle - $plateNumber';

  JobCard copyWith({JobCardStatus? status}) {
    return JobCard(
      id: id,
      customerName: customerName,
      vehicle: vehicle,
      plateNumber: plateNumber,
      services: services,
      technician: technician,
      estCompletion: estCompletion,
      amount: amount,
      status: status ?? this.status,
    );
  }
}
