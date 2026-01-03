import 'package:aw_flutter/features/workload_distribution/domain/models/absolute_semester.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum AcademicSemester {
  @JsonValue(1)
  first,
  @JsonValue(2)
  second;

  int toInt() {
    return this == first ? 1 : 2;
  }

  @override
  String toString() {
    return this == first ? '1' : '2';
  }

  static AcademicSemester fromAbsoluteSemester(
    AbsoluteSemester absoluteSemester,
  ) {
    return absoluteSemester.semesterNumber % 2 == 1
        ? AcademicSemester.first
        : AcademicSemester.second;
  }
}

extension AcademicSemesterComparable on AcademicSemester {
  int compareTo(AcademicSemester other) {
    final order = {AcademicSemester.first: 1, AcademicSemester.second: 2};
    return order[this]!.compareTo(order[other]!);
  }
}
