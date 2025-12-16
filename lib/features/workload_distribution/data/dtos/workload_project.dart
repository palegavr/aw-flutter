import 'dart:convert';

import 'package:aw_flutter/database/app_database.dart';
import 'package:aw_flutter/features/workload_distribution/data/dtos/academic_semester.dart';
import 'package:aw_flutter/features/workload_distribution/data/dtos/learning_form.dart';
import 'package:aw_flutter/src/rust/excel/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workload_project.freezed.dart';
part 'workload_project.g.dart';

@unfreezed
abstract class WorkloadDistributionProjectDto
    with _$WorkloadDistributionProjectDto {
  factory WorkloadDistributionProjectDto({
    required int id,
    required String title,
    required UniversityForm1Dto universityForm1,
    required UniversityForm3Dto universityForm3,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WorkloadDistributionProjectDto;

  factory WorkloadDistributionProjectDto.fromJson(Map<String, dynamic> json) =>
      _$WorkloadDistributionProjectDtoFromJson(json);

  factory WorkloadDistributionProjectDto.fromTableData(
    WorkloadDistributionProjectData data,
  ) {
    return WorkloadDistributionProjectDto(
      id: data.id,
      title: data.title,
      universityForm1: UniversityForm1Dto.fromJson(
        jsonDecode(data.universityForm1Json),
      ),
      universityForm3: UniversityForm3Dto.fromJson(
        jsonDecode(data.universityForm3Json),
      ),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}

@unfreezed
abstract class UniversityForm1Dto with _$UniversityForm1Dto {
  factory UniversityForm1Dto({
    required int academicYear,
    required List<UniversityForm1WorkloadItemDto> workloadItems,
  }) = _UniversityForm1Dto;

  factory UniversityForm1Dto.fromJson(Map<String, dynamic> json) =>
      _$UniversityForm1DtoFromJson(json);

  factory UniversityForm1Dto.fromParsedExcelFile({
    required ParsedExcelFile file,
    required String sheetName,
    required int academicYear,
  }) {
    final workloadItems = <UniversityForm1WorkloadItemDto>[];

    final sheetData = file.data[sheetName];
    if (sheetData != null) {
      for (final row in sheetData) {
        workloadItems.add(
          UniversityForm1WorkloadItemDto(
            workloadKey: WorkloadKeyDto(
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

    return UniversityForm1Dto(
      academicYear: academicYear,
      workloadItems: workloadItems,
    );
  }

  static double _parseDouble(String value) {
    if (value.isEmpty) return 0.0;

    // Handle fractions like "1/2", "1/1.0"
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

@unfreezed
abstract class UniversityForm3Dto with _$UniversityForm3Dto {
  factory UniversityForm3Dto({
    required int academicYear,
    required List<EmployeeDto> employees,
  }) = _UniversityForm3Dto;

  factory UniversityForm3Dto.fromJson(Map<String, dynamic> json) =>
      _$UniversityForm3DtoFromJson(json);
}

extension UniversityForm3DtoX on UniversityForm3Dto {
  void addEmployee(EmployeeDto newEmployee) {
    employees.add(newEmployee);
  }

  void replaceEmployee(EmployeeDto oldEmployee, EmployeeDto newEmployee) {
    final index = employees.indexOf(oldEmployee);
    if (index != -1) {
      employees[index] = newEmployee;
    }
  }

  void addWorkloadItem(
    EmployeeRateDto rate,
    UniversityForm3WorkloadItemDto newItem,
  ) {
    rate.workloadItems.add(newItem);
  }
}

@unfreezed
abstract class UniversityForm1WorkloadItemDto
    with _$UniversityForm1WorkloadItemDto {
  factory UniversityForm1WorkloadItemDto({
    required WorkloadKeyDto workloadKey,
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
  }) = _UniversityForm1WorkloadItemDto;

  factory UniversityForm1WorkloadItemDto.fromJson(Map<String, dynamic> json) =>
      _$UniversityForm1WorkloadItemDtoFromJson(json);
}

@Freezed(
  equal: true,
  makeCollectionsUnmodifiable: false,
  addImplicitFinal: false,
)
abstract class WorkloadKeyDto with _$WorkloadKeyDto {
  factory WorkloadKeyDto({
    required LearningForm learningForm,
    required String specialty,
    required String disciplineName,
    required String course,
    required AcademicSemester semester,
  }) = _WorkloadKeyDto;

  factory WorkloadKeyDto.fromJson(Map<String, dynamic> json) =>
      _$WorkloadKeyDtoFromJson(json);
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

@unfreezed
abstract class EmployeeDto with _$EmployeeDto {
  factory EmployeeDto({
    required String firstName,
    required String lastName,
    required String patronymic,
    required EmployeeRank rank,
    required List<EmployeeRateDto> rates,
  }) = _EmployeeDto;

  factory EmployeeDto.fromJson(Map<String, dynamic> json) =>
      _$EmployeeDtoFromJson(json);
}

extension EmployeeDtoX on EmployeeDto {
  String get fullName =>
      '${this.firstName} ${this.lastName}${this.patronymic.isNotEmpty ? ' ' + this.patronymic : ''}';
}

@unfreezed
abstract class EmployeeRateDto with _$EmployeeRateDto {
  factory EmployeeRateDto({
    required double rateValue,
    required DateTime dateStart,
    required DateTime dateEnd,
    required int postgraduateCount,
    required List<UniversityForm3WorkloadItemDto> workloadItems,
  }) = _EmployeeRateDto;

  factory EmployeeRateDto.fromJson(Map<String, dynamic> json) =>
      _$EmployeeRateDtoFromJson(json);
}

@unfreezed
abstract class UniversityForm3WorkloadItemDto
    with _$UniversityForm3WorkloadItemDto {
  factory UniversityForm3WorkloadItemDto({
    required WorkloadKeyDto workloadKey,
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
  }) = _UniversityForm3WorkloadItemDto;

  factory UniversityForm3WorkloadItemDto.fromJson(Map<String, dynamic> json) =>
      _$UniversityForm3WorkloadItemDtoFromJson(json);

  factory UniversityForm3WorkloadItemDto.empty() {
    return UniversityForm3WorkloadItemDto(
      workloadKey: WorkloadKeyDto(
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
