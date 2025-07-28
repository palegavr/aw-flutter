class InputHoursDto {
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

  InputHoursDto({
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
