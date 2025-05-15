import 'package:aw_flutter/features/workload_distribution/domain/group_model.dart';
import 'package:aw_flutter/features/workload_distribution/domain/worker_model.dart';
import 'package:aw_flutter/features/workload_distribution/domain/workload_input_model.dart';

class WlOutputHours {
  final int? lectures;
  final int? practices;
  final int? labs;
  final int? exams;
  final int? examConsults;
  final int? tests;
  final int? qualificationWorks;
  final int? workingPractices;
  final int? teachingPractices;
  final int? currentConsults;
  final int? individualWorks;
  final int? courseWorks;
  final int? postgraduateControl;

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
  final int id;
  final List<WorkloadOutputModel> semester1;
  final List<WorkloadOutputModel> semester2;
  final double rate;
  final String rankDescription;
  final String? comment1;
  final String? comment2;
  final String? fromDate;

  const WorkloadOutputTableModel({
    required this.id,
    required this.semester1,
    required this.semester2,
    required this.rate,
    required this.rankDescription,
    this.comment1,
    this.comment2,
    this.fromDate,
  });
}

class WorkloadOutputForWorker {
  final WorkerModel worker;
  final WorkloadOutputTableModel primaryTable;
  final WorkloadOutputTableModel? secondaryTable;

  const WorkloadOutputForWorker({
    required this.worker,
    required this.primaryTable,
    this.secondaryTable,
  });
}
