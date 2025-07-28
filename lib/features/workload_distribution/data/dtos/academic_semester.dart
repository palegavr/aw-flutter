import 'package:aw_flutter/features/workload_distribution/data/dtos/absolute_semester.dart';

enum AcademicSemester {
  first,
  second;

  static AcademicSemester fromAbsoluteSemester(
    AbsoluteSemester absoluteSemester,
  ) {
    return absoluteSemester.semesterNumber % 2 == 1
        ? AcademicSemester.first
        : AcademicSemester.second;
  }
}
