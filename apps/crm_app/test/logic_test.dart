import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

void main() {
  group('CrmTrendPoint', () {
    test('value equality and hashCode', () {
      const a = CrmTrendPoint('Jan', 10, 2, 5);
      const b = CrmTrendPoint('Jan', 10, 2, 5);
      const c = CrmTrendPoint('Feb', 10, 2, 5);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('CrmKpiEntity', () {
    test('equality includes all fields', () {
      const a = CrmKpiEntity(
        label: 'Leads',
        value: '42',
        icon: Icons.people,
        color: Colors.blue,
        bgColor: Colors.blueGrey,
        trend: '+12%',
        trendUp: true,
      );
      const b = CrmKpiEntity(
        label: 'Leads',
        value: '42',
        icon: Icons.people,
        color: Colors.blue,
        bgColor: Colors.blueGrey,
        trend: '+12%',
        trendUp: true,
      );
      const c = CrmKpiEntity(
        label: 'Leads',
        value: '43',
        icon: Icons.people,
        color: Colors.blue,
        bgColor: Colors.blueGrey,
        trend: '+12%',
        trendUp: true,
      );
      expect(a, b);
      expect(a == c, isFalse);
    });
  });

  group('SalespersonPerf', () {
    test('equality by fields', () {
      const a = SalespersonPerf('Ravi', 20, 5);
      const b = SalespersonPerf('Ravi', 20, 5);
      const c = SalespersonPerf('Ravi', 21, 5);
      expect(a, b);
      expect(a == c, isFalse);
    });
  });
}
