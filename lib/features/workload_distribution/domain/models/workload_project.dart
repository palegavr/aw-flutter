import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:aw_flutter/database/app_database.dart';
import 'package:aw_flutter/features/workload_distribution/domain/models/academic_semester.dart';
import 'package:aw_flutter/features/workload_distribution/domain/models/learning_form.dart';
import 'package:aw_flutter/src/rust/excel/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workload_project.freezed.dart';
part 'workload_project.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkloadDistributionProject {
  final int id;
  String _title;
  UniversityForm1 _universityForm1;
  UniversityForm3 _universityForm3;
  final DateTime createdAt;
  DateTime _updatedAt;

  WorkloadDistributionProject({
    required this.id,
    required String title,
    required UniversityForm1 universityForm1,
    required UniversityForm3 universityForm3,
    required this.createdAt,
    required DateTime updatedAt,
  }) : _title = title,
       _universityForm1 = universityForm1,
       _universityForm3 = universityForm3,
       _updatedAt = updatedAt;

  String get title => _title;
  UniversityForm1 get universityForm1 => _universityForm1;
  UniversityForm3 get universityForm3 => _universityForm3;
  DateTime get updatedAt => _updatedAt;

  factory WorkloadDistributionProject.fromJson(Map<String, dynamic> json) =>
      _$WorkloadDistributionProjectFromJson(json);

  Map<String, dynamic> toJson() => _$WorkloadDistributionProjectToJson(this);

  factory WorkloadDistributionProject.fromTableData(
    WorkloadDistributionProjectData data,
  ) {
    return WorkloadDistributionProject(
      id: data.id,
      title: data.title,
      universityForm1: UniversityForm1.fromJson(
        jsonDecode(data.universityForm1Json) as Map<String, dynamic>,
      ),
      universityForm3: UniversityForm3.fromJson(
        jsonDecode(data.universityForm3Json) as Map<String, dynamic>,
      ),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkloadDistributionProject &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;

  void changeTitle(String newTitle) {
    _title = newTitle;
    _updatedAt = DateTime.now();
  }

  void updateForm1(UniversityForm1 form1) {
    _universityForm1 = form1;
    _updatedAt = DateTime.now();
  }

  void updateForm3(UniversityForm3 form3) {
    _universityForm3 = form3;
    _updatedAt = DateTime.now();
  }
}

@JsonSerializable(explicitToJson: true)
class UniversityForm1 {
  final String id;
  final int academicYear;
  final List<UniversityForm1WorkloadItem> workloadItems;

  const UniversityForm1({
    required this.id,
    required this.academicYear,
    required this.workloadItems,
  });

  factory UniversityForm1.fromJson(Map<String, dynamic> json) =>
      _$UniversityForm1FromJson(json);

  factory UniversityForm1.create({
    required int academicYear,
    List<UniversityForm1WorkloadItem> workloadItems = const [],
  }) {
    return UniversityForm1(
      id: const Uuid().v4(),
      academicYear: academicYear,
      workloadItems: workloadItems,
    );
  }

  Map<String, dynamic> toJson() => _$UniversityForm1ToJson(this);

  static UniversityForm1 fromParsedExcelFile({
    required String id,
    required ParsedExcelFile file,
    required String sheetName,
    required int academicYear,
  }) {
    final workloadItems = <UniversityForm1WorkloadItem>[];

    final sheetData = file.data[sheetName];
    if (sheetData != null) {
      for (final row in sheetData) {
        workloadItems.add(
          UniversityForm1WorkloadItem.create(
            workloadKey: WorkloadKey(
              learningForm: LearningForm.fromShortDisplayName(
                row.learningForm.trim(),
              ),
              specialty: row.speciality,
              disciplineName: row.name,
              course: row.course,
              semester: _parseSemester(row.semester),
            ),
            weekCount: _parseDouble(row.weeksCount),
            studentCount: _parseInt(row.studentsCount),
            flowCount: _parseDouble(row.flowsCount),
            groupCount: _parseDouble(row.groupsCount),
            subgroupCount: _parseDouble(row.subgroupsCount),
            lecturesPlanned: _parseDouble(row.lecturesPlannedCount),
            lecturesTotal: _parseDouble(row.lecturesTotalCount),
            practicesPlanned: _parseDouble(row.practicesPlannedCount),
            practicesTotal: _parseDouble(row.practicesTotalCount),
            labsPlanned: _parseDouble(row.labsPlannedCount),
            labsTotal: _parseDouble(row.labsTotalCount),
            exams: _parseDouble(row.exams),
            examConsults: _parseDouble(row.examConsults),
            tests: _parseDouble(row.tests),
            qualificationWorks: _parseDouble(row.qualWorks),
            certificationExams: _parseDouble(row.certificationExams),
            productionPractices: _parseDouble(row.workingPractice),
            teachingPractices: _parseDouble(row.teachingPractice),
            currentConsults: _parseDouble(row.consults),
            individualWorks: _parseDouble(row.individualWorks),
            courseWorks: _parseDouble(row.courseWorks),
            postgraduateExams: _parseDouble(row.postgraduateExams),
          ),
        );
      }
    }

    return UniversityForm1(
      id: id,
      academicYear: academicYear,
      workloadItems: workloadItems,
    );
  }

  UniversityForm1 copyWith({
    String? id,
    int? academicYear,
    List<UniversityForm1WorkloadItem>? workloadItems,
  }) {
    return UniversityForm1(
      id: id ?? this.id,
      academicYear: academicYear ?? this.academicYear,
      workloadItems: workloadItems ?? this.workloadItems,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UniversityForm1 &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;

  static double _parseDouble(String value) {
    if (value.isEmpty) return 0.0;
    if (value.contains('/')) {
      final parts = value.split('/');
      if (parts.length == 2) {
        final numerator = double.tryParse(parts[0].trim()) ?? 0.0;
        final denominator = double.tryParse(parts[1].trim()) ?? 1.0;
        if (denominator == 0) return 0.0;
        return numerator / denominator;
      }
    }
    return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
  }

  static int _parseInt(String value) {
    if (value.isEmpty) return 0;
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  static AcademicSemester _parseSemester(String value) {
    if (value.trim() == '2') {
      return AcademicSemester.second;
    }
    return AcademicSemester.first;
  }
}

@JsonSerializable(explicitToJson: true)
class UniversityForm3 {
  final String id;
  final int academicYear;
  final List<Employee> employees;

  const UniversityForm3({
    required this.id,
    required this.academicYear,
    required this.employees,
  });

  factory UniversityForm3.fromJson(Map<String, dynamic> json) =>
      _$UniversityForm3FromJson(json);

  Map<String, dynamic> toJson() => _$UniversityForm3ToJson(this);

  factory UniversityForm3.create({
    required int academicYear,
    List<Employee> employees = const [],
  }) {
    return UniversityForm3(
      id: const Uuid().v4(),
      academicYear: academicYear,
      employees: employees,
    );
  }

  UniversityForm3 addEmployee(Employee newEmployee) {
    return copyWith(employees: [...this.employees, newEmployee]);
  }

  UniversityForm3 replaceEmployee(Employee oldEmployee, Employee newEmployee) {
    final index = this.employees.indexOf(oldEmployee);
    if (index == -1) return this;
    final newEmployees = List<Employee>.from(this.employees);
    newEmployees[index] = newEmployee;
    return copyWith(employees: newEmployees);
  }

  UniversityForm3 removeEmployee(Employee employee) {
    return copyWith(
      employees: this.employees.where((e) => e != employee).toList(),
    );
  }

  UniversityForm3 copyWith({
    String? id,
    int? academicYear,
    List<Employee>? employees,
  }) {
    return UniversityForm3(
      id: id ?? this.id,
      academicYear: academicYear ?? this.academicYear,
      employees: employees ?? this.employees,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UniversityForm3 &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable(explicitToJson: true)
class UniversityForm1WorkloadItem {
  final String id;
  final WorkloadKey workloadKey;
  final double weekCount;
  final int studentCount;
  final double flowCount;
  final double groupCount;
  final double subgroupCount;
  final double lecturesPlanned;
  final double lecturesTotal;
  final double practicesPlanned;
  final double practicesTotal;
  final double labsPlanned;
  final double labsTotal;
  final double exams;
  final double examConsults;
  final double tests;
  final double qualificationWorks;
  final double certificationExams;
  final double productionPractices;
  final double teachingPractices;
  final double currentConsults;
  final double individualWorks;
  final double courseWorks;
  final double postgraduateExams;

  const UniversityForm1WorkloadItem({
    required this.id,
    required this.workloadKey,
    required this.weekCount,
    required this.studentCount,
    required this.flowCount,
    required this.groupCount,
    required this.subgroupCount,
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

  factory UniversityForm1WorkloadItem.create({
    required WorkloadKey workloadKey,
    required double weekCount,
    required int studentCount,
    required double flowCount,
    required double groupCount,
    required double subgroupCount,
    required double lecturesPlanned,
    required double lecturesTotal,
    required double practicesPlanned,
    required double practicesTotal,
    required double labsPlanned,
    required double labsTotal,
    required double exams,
    required double examConsults,
    required double tests,
    required double qualificationWorks,
    required double certificationExams,
    required double productionPractices,
    required double teachingPractices,
    required double currentConsults,
    required double individualWorks,
    required double courseWorks,
    required double postgraduateExams,
  }) {
    return UniversityForm1WorkloadItem(
      id: const Uuid().v4(),
      workloadKey: workloadKey,
      weekCount: weekCount,
      studentCount: studentCount,
      flowCount: flowCount,
      groupCount: groupCount,
      subgroupCount: subgroupCount,
      lecturesPlanned: lecturesPlanned,
      lecturesTotal: lecturesTotal,
      practicesPlanned: practicesPlanned,
      practicesTotal: practicesTotal,
      labsPlanned: labsPlanned,
      labsTotal: labsTotal,
      exams: exams,
      examConsults: examConsults,
      tests: tests,
      qualificationWorks: qualificationWorks,
      certificationExams: certificationExams,
      productionPractices: productionPractices,
      teachingPractices: teachingPractices,
      currentConsults: currentConsults,
      individualWorks: individualWorks,
      courseWorks: courseWorks,
      postgraduateExams: postgraduateExams,
    );
  }

  factory UniversityForm1WorkloadItem.fromJson(Map<String, dynamic> json) =>
      _$UniversityForm1WorkloadItemFromJson(json);

  Map<String, dynamic> toJson() => _$UniversityForm1WorkloadItemToJson(this);

  UniversityForm1WorkloadItem copyWith({
    String? id,
    WorkloadKey? workloadKey,
    double? weekCount,
    int? studentCount,
    double? flowCount,
    double? groupCount,
    double? subgroupCount,
    double? lecturesPlanned,
    double? lecturesTotal,
    double? practicesPlanned,
    double? practicesTotal,
    double? labsPlanned,
    double? labsTotal,
    double? exams,
    double? examConsults,
    double? tests,
    double? qualificationWorks,
    double? certificationExams,
    double? productionPractices,
    double? teachingPractices,
    double? currentConsults,
    double? individualWorks,
    double? courseWorks,
    double? postgraduateExams,
  }) {
    return UniversityForm1WorkloadItem(
      id: id ?? this.id,
      workloadKey: workloadKey ?? this.workloadKey,
      weekCount: weekCount ?? this.weekCount,
      studentCount: studentCount ?? this.studentCount,
      flowCount: flowCount ?? this.flowCount,
      groupCount: groupCount ?? this.groupCount,
      subgroupCount: subgroupCount ?? this.subgroupCount,
      lecturesPlanned: lecturesPlanned ?? this.lecturesPlanned,
      lecturesTotal: lecturesTotal ?? this.lecturesTotal,
      practicesPlanned: practicesPlanned ?? this.practicesPlanned,
      practicesTotal: practicesTotal ?? this.practicesTotal,
      labsPlanned: labsPlanned ?? this.labsPlanned,
      labsTotal: labsTotal ?? this.labsTotal,
      exams: exams ?? this.exams,
      examConsults: examConsults ?? this.examConsults,
      tests: tests ?? this.tests,
      qualificationWorks: qualificationWorks ?? this.qualificationWorks,
      certificationExams: certificationExams ?? this.certificationExams,
      productionPractices: productionPractices ?? this.productionPractices,
      teachingPractices: teachingPractices ?? this.teachingPractices,
      currentConsults: currentConsults ?? this.currentConsults,
      individualWorks: individualWorks ?? this.individualWorks,
      courseWorks: courseWorks ?? this.courseWorks,
      postgraduateExams: postgraduateExams ?? this.postgraduateExams,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UniversityForm1WorkloadItem &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}

@freezed
abstract class WorkloadKey with _$WorkloadKey {
  const factory WorkloadKey({
    required LearningForm learningForm,
    required String specialty,
    required String disciplineName,
    required String course,
    required AcademicSemester semester,
  }) = _WorkloadKey;

  factory WorkloadKey.fromJson(Map<String, dynamic> json) =>
      _$WorkloadKeyFromJson(json);
}

enum EmployeeRank {
  head('Завідувач'),
  professor('Професор'),
  associate('Доцент'),
  seniorLecturer('Старший викладач'),
  assistant('Асистент');

  final String displayName;

  const EmployeeRank(this.displayName);
}

@freezed
abstract class Employee with _$Employee {
  const Employee._();

  const factory Employee({
    required String firstName,
    required String lastName,
    required String patronymic,
    required EmployeeRank rank,
    required List<EmployeeRate> rates,
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  String get fullName =>
      '$firstName $lastName${patronymic.isNotEmpty ? ' $patronymic' : ''}';

  Employee addWorkloadItem(
    EmployeeRate rate,
    UniversityForm3WorkloadItem newItem,
  ) {
    final index = rates.indexOf(rate);
    if (index == -1) return this;
    final newRates = List<EmployeeRate>.from(rates);
    newRates[index] = rate.addWorkloadItem(newItem);
    return copyWith(rates: newRates);
  }

  Employee replaceRate(EmployeeRate oldRate, EmployeeRate newRate) {
    final index = rates.indexOf(oldRate);
    if (index == -1) return this;
    final newRates = List<EmployeeRate>.from(rates);
    newRates[index] = newRate;
    return copyWith(rates: newRates);
  }
}

@freezed
abstract class EmployeeRate with _$EmployeeRate {
  const EmployeeRate._();

  const factory EmployeeRate({
    required double rateValue,
    required DateTime dateStart,
    required DateTime dateEnd,
    required int postgraduateCount,
    required List<UniversityForm3WorkloadItem> workloadItems,
  }) = _EmployeeRate;

  factory EmployeeRate.fromJson(Map<String, dynamic> json) =>
      _$EmployeeRateFromJson(json);

  EmployeeRate addWorkloadItem(UniversityForm3WorkloadItem newItem) {
    return copyWith(workloadItems: [...workloadItems, newItem]);
  }

  EmployeeRate replaceWorkloadItem(
    UniversityForm3WorkloadItem oldItem,
    UniversityForm3WorkloadItem newItem,
  ) {
    final index = workloadItems.indexOf(oldItem);
    if (index == -1) return this;
    final newItems = List<UniversityForm3WorkloadItem>.from(workloadItems);
    newItems[index] = newItem;
    return copyWith(workloadItems: newItems);
  }

  EmployeeRate removeWorkloadItem(UniversityForm3WorkloadItem item) {
    return copyWith(
      workloadItems: workloadItems.where((i) => i != item).toList(),
    );
  }
}

@freezed
abstract class UniversityForm3WorkloadItem with _$UniversityForm3WorkloadItem {
  const factory UniversityForm3WorkloadItem({
    required WorkloadKey workloadKey,
    required int studentCount,
    required List<String> academicGroups,
    required double lectures,
    required double practices,
    required double labs,
    required double exams,
    required double examConsults,
    required double tests,
    required double qualificationWorks,
    required double certificationExams,
    required double productionPractices,
    required double teachingPractices,
    required double currentConsults,
    required double individualWorks,
    required double courseWorks,
    required double postgraduateExams,
  }) = _UniversityForm3WorkloadItem;

  factory UniversityForm3WorkloadItem.fromJson(Map<String, dynamic> json) =>
      _$UniversityForm3WorkloadItemFromJson(json);

  factory UniversityForm3WorkloadItem.empty() {
    return UniversityForm3WorkloadItem(
      workloadKey: WorkloadKey(
        learningForm: LearningForm.daytime,
        specialty: '',
        disciplineName: '',
        course: '',
        semester: AcademicSemester.first,
      ),
      studentCount: 0,
      academicGroups: [],
      lectures: 0,
      practices: 0,
      labs: 0,
      exams: 0,
      examConsults: 0,
      tests: 0,
      qualificationWorks: 0,
      certificationExams: 0,
      productionPractices: 0,
      teachingPractices: 0,
      currentConsults: 0,
      individualWorks: 0,
      courseWorks: 0,
      postgraduateExams: 0,
    );
  }
}
