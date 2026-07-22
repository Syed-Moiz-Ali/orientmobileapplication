import 'package:freezed_annotation/freezed_annotation.dart';

part 'accounts_receivable.freezed.dart';

enum AgingBucket { days0to30, days31to60, days61to90, days90plus }

@freezed
class ARRecord with _$ARRecord {
  const factory ARRecord({
    required String arId,
    required String customer,
    required String invoiceDate,
    required String dueDate,
    required double amount,
    required double outstanding,
    required AgingBucket aging,
    required String contactPerson,
    required String phone,
  }) = _ARRecord;
}

@freezed
class ARSummary with _$ARSummary {
  const factory ARSummary({
    required double totalOutstanding,
    required double days0to30,
    required double days31to60,
    required double days61to90,
    required double days90plus,
  }) = _ARSummary;
}
