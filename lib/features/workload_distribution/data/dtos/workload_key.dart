import 'package:aw_flutter/features/workload_distribution/data/dtos/learning_form.dart';

class WorkloadKeyDto {
  final LearningForm learningForm;
  final String specialty;
  final String name;
  final int courseNumber;
  final int semesterNumber;

  WorkloadKeyDto({
    required this.learningForm,
    required this.specialty,
    required this.name,
    required this.courseNumber,
    required this.semesterNumber,
  });
}
