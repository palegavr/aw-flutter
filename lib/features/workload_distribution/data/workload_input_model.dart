import 'package:aw_flutter/features/workload_distribution/data/dtos/input_hours.dart';
import 'package:aw_flutter/features/workload_distribution/data/dtos/learning_form.dart';

enum WlType { common, selective }

enum WlDegree { bachelor, master, doctor }

class WorkloadInputModel {
  final LearningForm learningForm;
  final WlDegree degree;
  final WlType wlType;
  final String name;
  final int semester;
  final List<String> specialities;
  final int? course;
  final int? weeks;
  final int? students;
  final int? groups;
  final int? subgroups;

  final InputHoursDto hours;

  const WorkloadInputModel(
    this.name, {
    required this.hours,
    required this.specialities,
    required this.learningForm,
    required this.degree,
    required this.wlType,
    required this.semester,
    this.course,
    this.weeks,
    this.students,
    this.groups,
    this.subgroups,
  });
}
