enum WlLearningForm { daytime, evening, correspondence }

enum WlType { common, selective }

enum WlDegree { bachelor, master, doctor }

class WlInputHours {
  final int? lectures;
  final int? practices;
  final int? labs;
  final int? exams;
  final int? examConsults;
  final int? tests;
  final int? qualificationWorks;
  final int? workingPractices;
  final int? examCommittee;
  final int? reviews;
  final int? teachingPractices;
  final int? currentConsults;
  final int? individualWorks;
  final int? courseWorks;

  const WlInputHours({
    this.lectures,
    this.practices,
    this.labs,
    this.exams,
    this.examConsults,
    this.tests,
    this.qualificationWorks,
    this.workingPractices,
    this.examCommittee,
    this.reviews,
    this.teachingPractices,
    this.currentConsults,
    this.individualWorks,
    this.courseWorks,
  });
}

class WorkloadInputModel {
  final WlLearningForm learningForm;
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

  final WlInputHours hours;

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
