import 'package:flutter_test/flutter_test.dart';
import 'package:aw_flutter/features/workload_distribution/domain/models/workload_project.dart';

void main() {
  group('EmployeeRate Workload Calculation', () {
    test('1.0 rate for 10 months (min: 580, max: 600)', () {
      final rateFix = EmployeeRate.create(
        rateValue: 1.0,
        dateStart: DateTime(2024, 9, 1),
        dateEnd: DateTime(2024, 9, 1).add(const Duration(days: 300)),
      );

      expect(rateFix.minPossibleHours, 580.0);
      expect(rateFix.maxPossibleHours, 600.0);
    });

    test('0.95 rate for 10 months (min: 551, max: 570)', () {
      final rate = EmployeeRate.create(
        rateValue: 0.95,
        dateStart: DateTime(2024, 9, 1),
        dateEnd: DateTime(2024, 9, 1).add(const Duration(days: 300)),
      );

      expect(rate.minPossibleHours, 551.0);
      expect(rate.maxPossibleHours, 570.0);
    });

    test('1.0 rate for 8.5 months (min: 493, max: 510)', () {
      final rate = EmployeeRate.create(
        rateValue: 1.0,
        dateStart: DateTime(2024, 9, 1),
        dateEnd: DateTime(2024, 9, 1).add(const Duration(days: 255)), // 8.5 * 30 = 255
      );

      expect(rate.minPossibleHours, 493.0);
      expect(rate.maxPossibleHours, 510.0);
    });

    test('0.45 rate for 2 months (min: 52, max: 54)', () {
      final rate = EmployeeRate.create(
        rateValue: 0.45,
        dateStart: DateTime(2024, 9, 1),
        dateEnd: DateTime(2024, 9, 1).add(const Duration(days: 60)), // 2 * 30 = 60
      );

      expect(rate.minPossibleHours, 52.0);
      expect(rate.maxPossibleHours, 54.0);
    });
  });

  group('Employee total calculations', () {
    test('Should sum min/max hours from multiple rates', () {
      final rate1 = EmployeeRate.create(
        rateValue: 0.5,
        dateStart: DateTime(2024, 9, 1),
        dateEnd: DateTime(2024, 9, 1).add(const Duration(days: 150)), // 5 months
      ); // min: 580 * 0.5 * 0.5 = 145, max: 600 * 0.5 * 0.5 = 150

      final rate2 = EmployeeRate.create(
        rateValue: 0.5,
        dateStart: DateTime(2025, 2, 1),
        dateEnd: DateTime(2025, 2, 1).add(const Duration(days: 150)), // 5 months
      ); // min: 145, max: 150

      final employee = Employee.create(
        firstName: 'Test',
        lastName: 'User',
        patronymic: '',
        rank: EmployeeRank.assistant,
        rates: [rate1, rate2],
      );

      expect(employee.totalMinPossibleHours, 290.0);
      expect(employee.totalMaxPossibleHours, 300.0);
    });
  });
}
