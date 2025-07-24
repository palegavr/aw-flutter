import 'package:aw_flutter/features/workload_distribution/data/group_model.dart';
import 'package:aw_flutter/features/workload_distribution/data/worker_model.dart';
import 'package:aw_flutter/features/workload_distribution/data/workload_input_model.dart';
import 'package:uuid/uuid.dart';

class WlOutputHours {
  final double? lectures;
  final double? practices;
  final double? labs;
  final double? exams;
  final double? examConsults;
  final double? tests;
  final double? qualificationWorks;
  final double? workingPractices;
  final double? teachingPractices;
  final double? currentConsults;
  final double? individualWorks;
  final double? courseWorks;
  final double? postgraduateControl;

  const WlOutputHours({
    this.lectures,
    this.practices,
    this.labs,
    this.exams,
    this.examConsults,
    this.tests,
    this.qualificationWorks,
    this.workingPractices,
    this.teachingPractices,
    this.currentConsults,
    this.individualWorks,
    this.courseWorks,
    this.postgraduateControl,
  });
}

class WorkloadOutputModel {
  final WlLearningForm learningForm;
  final WlDegree degree;
  final String name;
  final List<String> specialities;
  final List<GroupModel> groups;
  final List<int> courses;
  final int students;

  final WlOutputHours hours;

  const WorkloadOutputModel(
    this.name, {
    required this.learningForm,
    required this.degree,
    required this.specialities,
    required this.groups,
    required this.courses,
    required this.students,
    required this.hours,
  });
}

class WorkloadOutputTableModel {
  final List<WorkloadOutputModel> semester1;
  final List<WorkloadOutputModel> semester2;
  final double rate;
  final String rankDescription;
  final String? comment1;
  final String? comment2;
  final String? fromDate;

  const WorkloadOutputTableModel({
    required this.semester1,
    required this.semester2,
    required this.rate,
    required this.rankDescription,
    this.comment1,
    this.comment2,
    this.fromDate,
  });
}

enum WorkerOutputTableType { primary, secondary }

class WorkloadOutputForWorker {
  final String id = const Uuid().v4();
  final WorkerModel worker;
  final WorkloadOutputTableModel primaryTable;
  final WorkloadOutputTableModel? secondaryTable;

  WorkloadOutputForWorker({
    required this.worker,
    required this.primaryTable,
    this.secondaryTable,
  });
}
