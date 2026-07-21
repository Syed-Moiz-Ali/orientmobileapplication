import 'package:orientmobileapplication/features/dashboard/domain/entities/accounts_receivable.dart';

class MockARDatasource {
  Future<ARSummary> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const ARSummary(
      totalOutstanding: 566000,
      days0to30: 230000,
      days31to60: 241000,
      days61to90: 95000,
      days90plus: 0,
    );
  }

  Future<List<ARRecord>> getRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const ARRecord(
        arId: 'AR-2024-001',
        customer: 'Al Fahim Motors',
        invoiceDate: '2024-02-15',
        dueDate: '2024-03-15',
        amount: 125000,
        outstanding: 125000,
        aging: AgingBucket.days0to30,
        contactPerson: 'Ahmed Ali',
        phone: '+971 50 123 4567',
      ),
      const ARRecord(
        arId: 'AR-2024-002',
        customer: 'Emirates Trading Co.',
        invoiceDate: '2024-01-28',
        dueDate: '2024-02-28',
        amount: 65000,
        outstanding: 85000,
        aging: AgingBucket.days31to60,
        contactPerson: 'Sara Mohammed',
        phone: '+971 50 234 5678',
      ),
      const ARRecord(
        arId: 'AR-2024-003',
        customer: 'Dubai Fleet Services',
        invoiceDate: '2024-02-20',
        dueDate: '2024-03-20',
        amount: 210000,
        outstanding: 105000,
        aging: AgingBucket.days0to30,
        contactPerson: 'Khalid Hassan',
        phone: '+971 50 345 6789',
      ),
      const ARRecord(
        arId: 'AR-2024-004',
        customer: 'Abu Dhabi Transport',
        invoiceDate: '2024-01-10',
        dueDate: '2024-02-10',
        amount: 156000,
        outstanding: 156000,
        aging: AgingBucket.days31to60,
        contactPerson: 'Fatima Ali',
        phone: '+971 50 456 7890',
      ),
      const ARRecord(
        arId: 'AR-2024-005',
        customer: 'Sharjah Auto Group',
        invoiceDate: '2023-12-15',
        dueDate: '2024-01-15',
        amount: 95000,
        outstanding: 95000,
        aging: AgingBucket.days61to90,
        contactPerson: 'Mohammed Rashid',
        phone: '+971 50 567 8901',
      ),
    ];
  }
}
