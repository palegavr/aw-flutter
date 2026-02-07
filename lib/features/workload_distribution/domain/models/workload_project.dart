import 'dart:convert';
import 'package:aw_flutter/shared/errors/domain_error.dart';
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


  void createForm3Rate(String employeeId, double rateValue, DateTime dateStart, DateTime dateEnd, int postgraduateCount) {
    final rate = EmployeeRate.create(
      rateValue: rateValue,
      dateStart: dateStart,
      dateEnd: dateEnd,
      postgraduateCount: postgraduateCount,
      workloadItems: [],
    );
    _universityForm3.addRate(employeeId, rate);
    _updatedAt = DateTime.now();
  }

  void removeForm3Rate(String employeeId, EmployeeRate rate) {
    _universityForm3.removeRate(employeeId, rate);
    _updatedAt = DateTime.now();
  }

  void addForm3WorkloadItem(String employeeId, String rateId, UniversityForm3WorkloadItem newItem) {
    for (final field in WorkloadField.values) {
      final val = newItem.getFieldValue(field);
      if (val > 0) {
        _checkWorkloadLimit(newItem.workloadKey, field, val, 0);
      }
    }

    final employee = _universityForm3.employees.firstWhere((e) => e.id == employeeId);
    final rate = employee.rates.firstWhere((r) => r.id == rateId);
    rate.addWorkloadItem(newItem);
    _updatedAt = DateTime.now();
  }

  void updateForm3WorkloadField(String employeeId, String rateId, String itemId, WorkloadField field, double newValue) {
    final employee = _universityForm3.employees.firstWhere((e) => e.id == employeeId);
    final rate = employee.rates.firstWhere((r) => r.id == rateId);
    final itemIndex = rate.workloadItems.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) throw DomainError("Навантаження не знайдено");

    final item = rate.workloadItems[itemIndex];
    final oldValue = item.getFieldValue(field);

    _checkWorkloadLimit(item.workloadKey, field, newValue, oldValue);

    rate.workloadItems[itemIndex] = _setItemFieldValue(item, field, newValue);
    _updatedAt = DateTime.now();
  }

  void updateForm3WorkloadGroups(String employeeId, String rateId, String itemId, List<String> groups) {
    final employee = _universityForm3.employees.firstWhere((e) => e.id == employeeId);
    final rate = employee.rates.firstWhere((r) => r.id == rateId);
    final itemIndex = rate.workloadItems.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      rate.workloadItems[itemIndex] = rate.workloadItems[itemIndex].copyWith(academicGroups: groups);
      _updatedAt = DateTime.now();
    }
  }

  void removeForm3WorkloadItem(String employeeId, String rateId, String itemId) {
    final employee = _universityForm3.employees.firstWhere((e) => e.id == employeeId);
    final rate = employee.rates.firstWhere((r) => r.id == rateId);
    rate.workloadItems.removeWhere((i) => i.id == itemId);
    _updatedAt = DateTime.now();
  }

  void addForm3Employee(Employee employee) {
    _universityForm3.addEmployee(employee);
    _updatedAt = DateTime.now();
  }

  void removeForm3Employee(Employee employee) {
    _universityForm3.removeEmployee(employee);
    _updatedAt = DateTime.now();
  }

  double getTotalWorkload(WorkloadKey key, WorkloadField field) {
    final item = _universityForm1.workloadItems.firstWhere(
      (item) => item.workloadKey == key,
    );
    return item.getFieldValue(field);
  }

  double getUndistributedWorkload(WorkloadKey key, WorkloadField field) {
    final total = getTotalWorkload(key, field);
    double distributed = 0;
    for (final employee in _universityForm3.employees) {
      for (final rate in employee.rates) {
        for (final item in rate.workloadItems) {
          if (item.workloadKey == key) {
            distributed += item.getFieldValue(field);
          }
        }
      }
    }
    return total - distributed;
  }

  void _checkWorkloadLimit(WorkloadKey key, WorkloadField field, double newValue, double oldValue) {
    final undistributed = getUndistributedWorkload(key, field);
    final total = getTotalWorkload(key, field);
    
    if (undistributed + oldValue - newValue < -0.0001) {
      final distributed = total - undistributed;
      final newValueDisplay = newValue == newValue.toInt() ? newValue.toInt().toString() : newValue.toStringAsFixed(2);
      final totalDisplay = total == total.toInt() ? total.toInt().toString() : total.toStringAsFixed(2);
      final distributedDisplay = distributed == distributed.toInt() ? distributed.toInt().toString() : distributed.toStringAsFixed(2);

      throw DomainError("Перевищено ліміт по полю '${field.getDisplayName()}': заплановано $totalDisplay, вже розподілено $distributedDisplay, ви намагаєтесь встановити $newValueDisplay");
    }
  }

  UniversityForm3WorkloadItem _setItemFieldValue(UniversityForm3WorkloadItem item, WorkloadField field, double value) {
    switch (field) {
      case WorkloadField.studentCount: return item.copyWith(studentCount: value.toInt());
      case WorkloadField.lectures: return item.copyWith(lectures: value);
      case WorkloadField.practices: return item.copyWith(practices: value);
      case WorkloadField.labs: return item.copyWith(labs: value);
      case WorkloadField.exams: return item.copyWith(exams: value);
      case WorkloadField.examConsults: return item.copyWith(examConsults: value);
      case WorkloadField.tests: return item.copyWith(tests: value);
      case WorkloadField.qualificationWorks: return item.copyWith(qualificationWorks: value);
      case WorkloadField.certificationExams: return item.copyWith(certificationExams: value);
      case WorkloadField.productionPractices: return item.copyWith(productionPractices: value);
      case WorkloadField.teachingPractices: return item.copyWith(teachingPractices: value);
      case WorkloadField.currentConsults: return item.copyWith(currentConsults: value);
      case WorkloadField.individualWorks: return item.copyWith(individualWorks: value);
      case WorkloadField.courseWorks: return item.copyWith(courseWorks: value);
      case WorkloadField.postgraduateExams: return item.copyWith(postgraduateExams: value);
    }
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

  void addEmployee(Employee newEmployee) {
    employees.add(newEmployee);
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

  void addRate(String employeeId, EmployeeRate rate) {
    final employee = employees.firstWhere((e) => e.id == employeeId);
    employee.addRate(rate);
  }

  void replaceEmployee(Employee oldEmployee, Employee newEmployee) {
    final index = this.employees.indexOf(oldEmployee);
    if (index == -1) return;
    employees[index] = newEmployee;
  }

  void removeEmployee(Employee employee) {
    employees.remove(employee);
  }

  void removeRate(String employeeId, EmployeeRate rate) {
    final employee = employees.firstWhere((e) => e.id == employeeId);
    employee.removeRate(rate);
  }

  void addWorkloadItem(String employeeId, EmployeeRate rate, UniversityForm3WorkloadItem newItem) {
    final employee = employees.firstWhere((e) => e.id == employeeId);
    employee.addWorkloadItem(rate, newItem);
  }

  void replaceWorkloadItem(String employeeId, EmployeeRate rate, UniversityForm3WorkloadItem oldItem, UniversityForm3WorkloadItem newItem) {
    final employee = employees.firstWhere((e) => e.id == employeeId);
    final rateIndex = employee.rates.indexOf(rate);
    if (rateIndex == -1) return;
    employee.rates[rateIndex].replaceWorkloadItem(oldItem, newItem);
  }

  void removeWorkloadItem(String employeeId, EmployeeRate rate, UniversityForm3WorkloadItem item) {
    final employee = employees.firstWhere((e) => e.id == employeeId);
    final rateIndex = employee.rates.indexOf(rate);
    if (rateIndex == -1) return;
    employee.rates[rateIndex].removeWorkloadItem(item);
  }
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

  double getFieldValue(WorkloadField field) {
    switch (field) {
      case WorkloadField.studentCount:
        return studentCount.toDouble();
      case WorkloadField.lectures:
        return lecturesTotal;
      case WorkloadField.practices:
        return practicesTotal;
      case WorkloadField.labs:
        return labsTotal;
      case WorkloadField.exams:
        return exams;
      case WorkloadField.examConsults:
        return examConsults;
      case WorkloadField.tests:
        return tests;
      case WorkloadField.qualificationWorks:
        return qualificationWorks;
      case WorkloadField.certificationExams:
        return certificationExams;
      case WorkloadField.productionPractices:
        return productionPractices;
      case WorkloadField.teachingPractices:
        return teachingPractices;
      case WorkloadField.currentConsults:
        return currentConsults;
      case WorkloadField.individualWorks:
        return individualWorks;
      case WorkloadField.courseWorks:
        return courseWorks;
      case WorkloadField.postgraduateExams:
        return postgraduateExams;
    }
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

@JsonSerializable(explicitToJson: true)
class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String patronymic;
  final EmployeeRank rank;
  final List<EmployeeRate> rates;

  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.rank,
    required this.rates,
  });

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);

  factory Employee.create({
    required String firstName,
    required String lastName,
    required String patronymic,
    required EmployeeRank rank,
    List<EmployeeRate> rates = const [],
  }) {
    return Employee(
      id: const Uuid().v4(),
      firstName: firstName,
      lastName: lastName,
      patronymic: patronymic,
      rank: rank,
      rates: rates,
    );
  }

  String get fullName =>
      '$firstName $lastName${patronymic.isNotEmpty ? ' $patronymic' : ''}';

  void addWorkloadItem(
    EmployeeRate rate,
    UniversityForm3WorkloadItem newItem,
  ) {
    final index = rates.indexOf(rate);
    if (index == -1) return;
    rates[index].addWorkloadItem(newItem);
  }

  void replaceRate(EmployeeRate oldRate, EmployeeRate newRate) {
    final index = rates.indexOf(oldRate);
    if (index == -1) return;
    rates[index] = newRate;
  }

  void removeRate(EmployeeRate rate) {
    rates.remove(rate);
  }

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? patronymic,
    EmployeeRank? rank,
    List<EmployeeRate>? rates,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      patronymic: patronymic ?? this.patronymic,
      rank: rank ?? this.rank,
      rates: rates ?? this.rates,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee && runtimeType == other.runtimeType && id == other.id);

  @override
  int get hashCode => id.hashCode;

  void addRate(EmployeeRate rate) {
    rates.add(rate);
  }
}

@JsonSerializable(explicitToJson: true)
class EmployeeRate {
  final String id;
  final double rateValue;
  final DateTime dateStart;
  final DateTime dateEnd;
  final int postgraduateCount;
  final List<UniversityForm3WorkloadItem> workloadItems;

  const EmployeeRate({
    required this.id,
    required this.rateValue,
    required this.dateStart,
    required this.dateEnd,
    required this.postgraduateCount,
    required this.workloadItems,
  });

  factory EmployeeRate.create({
    required double rateValue,
    required DateTime dateStart,
    required DateTime dateEnd,
    int postgraduateCount = 0,
    List<UniversityForm3WorkloadItem> workloadItems = const [],
  }) {
    if (rateValue <= 0) {
      throw ArgumentError('rateValue must be greater than 0');
    }
    if (postgraduateCount < 0) {
      throw ArgumentError('postgraduateCount must be greater than or equal to 0');
    }

    return EmployeeRate(
      id: const Uuid().v4(),
      rateValue: rateValue,
      dateStart: dateStart,
      dateEnd: dateEnd,
      postgraduateCount: postgraduateCount,
      workloadItems: workloadItems,
    );
  }

  factory EmployeeRate.fromJson(Map<String, dynamic> json) =>
      _$EmployeeRateFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeRateToJson(this);

  void addWorkloadItem(UniversityForm3WorkloadItem newItem) {
    workloadItems.add(newItem);
  }

  void replaceWorkloadItem(
    UniversityForm3WorkloadItem oldItem,
    UniversityForm3WorkloadItem newItem,
  ) {
    final index = workloadItems.indexOf(oldItem);
    if (index == -1) return;
    workloadItems[index] = newItem;
  }

  void removeWorkloadItem(UniversityForm3WorkloadItem item) {
    workloadItems.remove(item);
  }

  EmployeeRate copyWith({
    String? id,
    double? rateValue,
    DateTime? dateStart,
    DateTime? dateEnd,
    int? postgraduateCount,
    List<UniversityForm3WorkloadItem>? workloadItems,
  }) {
    return EmployeeRate(
      id: id ?? this.id,
      rateValue: rateValue ?? this.rateValue,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      postgraduateCount: postgraduateCount ?? this.postgraduateCount,
      workloadItems: workloadItems ?? this.workloadItems,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeeRate &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable(explicitToJson: true)
class UniversityForm3WorkloadItem {
  final String id;
  final WorkloadKey workloadKey;
  final int studentCount;
  final List<String> academicGroups;
  final double lectures;
  final double practices;
  final double labs;
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

  const UniversityForm3WorkloadItem({
    required this.id,
    required this.workloadKey,
    required this.studentCount,
    required this.academicGroups,
    required this.lectures,
    required this.practices,
    required this.labs,
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

  factory UniversityForm3WorkloadItem.create({
    required WorkloadKey workloadKey,
    int studentCount = 0,
    List<String> academicGroups = const [],
    double lectures = 0,
    double practices = 0,
    double labs = 0,
    double exams = 0,
    double examConsults = 0,
    double tests = 0,
    double qualificationWorks = 0,
    double certificationExams = 0,
    double productionPractices = 0,
    double teachingPractices = 0,
    double currentConsults = 0,
    double individualWorks = 0,
    double courseWorks = 0,
    double postgraduateExams = 0,
  }) {
    return UniversityForm3WorkloadItem(
      id: const Uuid().v4(),
      workloadKey: workloadKey,
      studentCount: studentCount,
      academicGroups: academicGroups,
      lectures: lectures,
      practices: practices,
      labs: labs,
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

  factory UniversityForm3WorkloadItem.fromJson(Map<String, dynamic> json) =>
      _$UniversityForm3WorkloadItemFromJson(json);

  Map<String, dynamic> toJson() => _$UniversityForm3WorkloadItemToJson(this);

  UniversityForm3WorkloadItem copyWith({
    String? id,
    WorkloadKey? workloadKey,
    int? studentCount,
    List<String>? academicGroups,
    double? lectures,
    double? practices,
    double? labs,
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
    return UniversityForm3WorkloadItem(
      id: id ?? this.id,
      workloadKey: workloadKey ?? this.workloadKey,
      studentCount: studentCount ?? this.studentCount,
      academicGroups: academicGroups ?? this.academicGroups,
      lectures: lectures ?? this.lectures,
      practices: practices ?? this.practices,
      labs: labs ?? this.labs,
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

  double getFieldValue(WorkloadField field) {
    switch (field) {
      case WorkloadField.studentCount:
        return studentCount.toDouble();
      case WorkloadField.lectures:
        return lectures;
      case WorkloadField.practices:
        return practices;
      case WorkloadField.labs:
        return labs;
      case WorkloadField.exams:
        return exams;
      case WorkloadField.examConsults:
        return examConsults;
      case WorkloadField.tests:
        return tests;
      case WorkloadField.qualificationWorks:
        return qualificationWorks;
      case WorkloadField.certificationExams:
        return certificationExams;
      case WorkloadField.productionPractices:
        return productionPractices;
      case WorkloadField.teachingPractices:
        return teachingPractices;
      case WorkloadField.currentConsults:
        return currentConsults;
      case WorkloadField.individualWorks:
        return individualWorks;
      case WorkloadField.courseWorks:
        return courseWorks;
      case WorkloadField.postgraduateExams:
        return postgraduateExams;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UniversityForm3WorkloadItem &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}

enum WorkloadField {
  studentCount,
  lectures,
  practices,
  labs,
  exams,
  examConsults,
  tests,
  qualificationWorks,
  certificationExams,
  productionPractices,
  teachingPractices,
  currentConsults,
  individualWorks,
  courseWorks,
  postgraduateExams,
  ;

  String getDisplayName() {
    switch (this) {
      case WorkloadField.studentCount:
        return 'Кількість студентів';
      case WorkloadField.lectures:
        return 'Лекції';
      case WorkloadField.practices:
        return 'Практичні';
      case WorkloadField.labs:
        return 'Лабораторні';
      case WorkloadField.exams:
        return 'Екзамени';
      case WorkloadField.examConsults:
        return 'Консультації до екзаменів';
      case WorkloadField.tests:
        return 'Заліки';
      case WorkloadField.qualificationWorks:
        return 'Кваліфікаційні роботи';
      case WorkloadField.certificationExams:
        return 'Атестаційні екзамени';
      case WorkloadField.productionPractices:
        return 'Виробничі практики';
      case WorkloadField.teachingPractices:
        return 'Навчальні практики';
      case WorkloadField.currentConsults:
        return 'Поточні консультації';
      case WorkloadField.individualWorks:
        return 'Індивідуальні роботи';
      case WorkloadField.courseWorks:
        return 'Курсові роботи';
      case WorkloadField.postgraduateExams:
        return 'Кандидатські екзамени';
    }
  }
}
