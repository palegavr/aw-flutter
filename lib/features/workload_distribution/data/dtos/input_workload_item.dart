import 'package:aw_flutter/features/workload_distribution/data/dtos/input_hours.dart';
import 'package:aw_flutter/features/workload_distribution/data/dtos/workload_key.dart';

class InputWorkloadItemDto {
  final WorkloadKeyDto key;
  final double weekCount;
  final int studentCount;
  final double flowCount;
  final double groupCount;
  final double subgroupCount;
  final InputHoursDto hours;

  InputWorkloadItemDto({
    required this.key,
    required this.weekCount,
    required this.studentCount,
    required this.flowCount,
    required this.groupCount,
    required this.subgroupCount,
    required this.hours,
  });
}
