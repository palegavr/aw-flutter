enum WlLearningForm { daytime, evening, correspondence }

enum WlType { common, selective }

enum WlDegree { bachelor, master, doctor }

class InputHours {
  final double? lecturesPlanned; // Лекції по плану
  final double? lecturesTotal; // Лекції всього
  final double? practicesPlanned; // Практичні по плану
  final double? practicesTotal; // Практичні всього
  final double? labsPlanned; // Лабораторні по плану
  final double? labsTotal; // Лабораторні всього
  final double? exams; // Екзамени
  final double? examConsults; // Консультації перед екзаменом
  final double? tests; // Заліки
  final double? qualificationWorks; // Кваліфікаційні роботи
  final double? certificationExams; // Атестаційний екзамен
  final double? productionPractices; // Виробнича практика
  final double? teachingPractices; // Навчальна практика
  final double? currentConsults; // Поточні консультації
  final double? individualWorks; // Індивідуальні завдання
  final double? courseWorks; // Курсові роботи
  final double? postgraduateExams; // Екзамени для аспірантів

  InputHours({
    required this.lecturesPlanned,
    required this.lecturesTotal,
    required this.practicesPlanned,
    required this.practicesTotal,
    required this.labsPlanned,
    required this.labsTotal,
    required this.exams,
    required this.examConsults,
    required this.tests,
    required this.qualificationWorks,
    required this.certificationExams,
    required this.productionPractices,
    required this.teachingPractices,
    required this.currentConsults,
    required this.individualWorks,
    required this.courseWorks,
    required this.postgraduateExams,
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

  final InputHours hours;

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
