enum AgingBucket { days0to30, days31to60, days61to90, days90plus }

class ARRecord {
  final String arId;
  final String customer;
  final String invoiceDate;
  final String dueDate;
  final double amount;
  final double outstanding;
  final AgingBucket aging;
  final String contactPerson;
  final String phone;

  const ARRecord({
    required this.arId,
    required this.customer,
    required this.invoiceDate,
    required this.dueDate,
    required this.amount,
    required this.outstanding,
    required this.aging,
    required this.contactPerson,
    required this.phone,
  });
}

class ARSummary {
  final double totalOutstanding;
  final double days0to30;
  final double days31to60;
  final double days61to90;
  final double days90plus;

  const ARSummary({
    required this.totalOutstanding,
    required this.days0to30,
    required this.days31to60,
    required this.days61to90,
    required this.days90plus,
  });
}
