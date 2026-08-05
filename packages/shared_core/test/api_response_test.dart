import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  group('ApiResponse', () {
    test('parses success envelope with typed data', () {
      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        {
          'code': 200,
          'message': 'OK',
          'data': {'id': 'JC-1', 'status': 'inProgress'},
          'timestamp': 12345,
        },
        (d) => d as Map<String, dynamic>,
      );
      expect(response.isSuccess, isTrue);
      expect(response.data?['id'], 'JC-1');
      expect(response.timestamp, 12345);
    });

    test('parses failure envelope', () {
      final response = ApiResponse<Object?>.fromJson(
        {'code': 400, 'message': 'Bad request', 'data': null},
        null,
      );
      expect(response.isSuccess, isFalse);
      expect(response.message, 'Bad request');
    });

    test('defaults when fields are missing', () {
      final response = ApiResponse<Object?>.fromJson({}, null);
      expect(response.code, 500);
      expect(response.message, '');
      expect(response.data, isNull);
    });
  });

  group('PageResponse', () {
    test('parses content list', () {
      final page = PageResponse<String>.fromJson(
        {
          'content': [
            {'name': 'a'},
            {'name': 'b'},
          ],
          'page': 1,
          'size': 20,
          'totalElements': 2,
          'totalPages': 1,
        },
        (d) => d['name'] as String,
      );
      expect(page.content, ['a', 'b']);
      expect(page.totalElements, 2);
    });

    test('empty content stays empty', () {
      final page = PageResponse<String>.fromJson({}, (d) => d as String);
      expect(page.content, isEmpty);
    });
  });

  group('Advisor models parsing', () {
    test('AdvisorStatsResponse defaults to zeros', () {
      final stats = AdvisorStatsResponse.fromJson({});
      expect(stats.newJobCardsToday, 0);
      expect(stats.totalOpenJobCards, 0);
    });

    test('JobCardResponse parses values', () {
      final jc = JobCardResponse.fromJson({
        'id': 'JC-1',
        'customerName': 'Ali',
        'vehicleInfo': 'Toyota Camry',
        'status': 'inProgress',
      });
      expect(jc.id, 'JC-1');
      expect(jc.customerName, 'Ali');
      expect(jc.status, 'inProgress');
    });

    test('ReportResponse parses weekly activity', () {
      final report = ReportResponse.fromJson({
        'totalJobs': 10,
        'weeklyActivity': [
          {'day': 'Mon', 'count': 2},
          {'day': 'Tue', 'count': 3},
        ],
      });
      expect(report.weeklyActivity.length, 2);
      expect(report.weeklyActivity.first.day, 'Mon');
      expect(report.weeklyActivity.last.count, 3);
    });
  });

  group('Technician models parsing', () {
    test('AssignedJobResponse handles numeric amounts', () {
      final job = AssignedJobResponse.fromJson({'id': 'AJ-1', 'amount': '1.5'});
      expect(job.id, 'AJ-1');
      expect(job.amount, '1.5');
    });

    test('TechnicianProfileResponse defaults', () {
      final profile = TechnicianProfileResponse.fromJson({});
      expect(profile.name, '');
      expect(profile.empId, '');
    });
  });
}
