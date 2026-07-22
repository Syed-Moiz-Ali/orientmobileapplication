import 'package:orientmobileapplication/features/job_cards/domain/entities/job_card.dart';

abstract class JobCardDatasource {
  Future<List<JobCard>> getJobCards();
}

class MockJobCardDatasource implements JobCardDatasource {
  @override
  Future<List<JobCard>> getJobCards() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return const [
      JobCard(id: 'JC-2024-001', customerName: 'Ahmed Al Mansouri', vehicle: 'Toyota Camry', plateNumber: 'AA-12345', services: ['Oil Change', 'Brake Inspection'], technician: 'Mohammed Hassan', estCompletion: '2024-04-01', amount: 850, status: JobCardStatus.inProgress),
      JobCard(id: 'JC-2024-002', customerName: 'Fatima Ali', vehicle: 'Honda Accord', plateNumber: 'BB-67890', services: ['Transmission Repair'], technician: 'Ali Ahmed', estCompletion: '2024-04-02', amount: 3200, status: JobCardStatus.waitingParts),
      JobCard(id: 'JC-2024-003', customerName: 'Khalid Rashid', vehicle: 'Nissan Patrol', plateNumber: 'CC-11223', services: ['AC Repair', 'Battery Replacement'], technician: 'Hassan Ibrahim', estCompletion: '2024-04-01', amount: 1450, status: JobCardStatus.inProgress),
      JobCard(id: 'JC-2024-004', customerName: 'Mariam Salem', vehicle: 'BMW X5', plateNumber: 'DD-44556', services: ['Engine Diagnostics', 'Spark Plug Change'], technician: 'Omar Khalid', estCompletion: '2024-03-31', amount: 2100, status: JobCardStatus.qualityCheck),
      JobCard(id: 'JC-2024-005', customerName: 'Saeed Mohammed', vehicle: 'Mercedes C-Class', plateNumber: 'EE-77889', services: ['Brake Pad Replacement', 'Wheel Alignment'], technician: 'Yousef Ali', estCompletion: '2024-04-02', amount: 1750, status: JobCardStatus.inProgress),
      JobCard(id: 'JC-2024-006', customerName: 'Noura Al Zaabi', vehicle: 'Audi Q7', plateNumber: 'FF-33210', services: ['Full Service', 'Tire Rotation'], technician: 'Bilal Khan', estCompletion: '2024-04-03', amount: 2800, status: JobCardStatus.completed),
    ];
  }
}
