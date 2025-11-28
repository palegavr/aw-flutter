import 'package:aw_flutter/features/workload_distribution/data/dtos/academic_course.dart';
import 'package:drift/drift.dart';

class AcademicCourseTypeConverter
    extends TypeConverter<AcademicCourseDto, String> {
  const AcademicCourseTypeConverter();

  @override
  AcademicCourseDto fromSql(String fromDb) {
    return AcademicCourseDto(courseNumber: int.parse(fromDb));
  }

  @override
  String toSql(AcademicCourseDto value) {
    return value.courseNumber.toString();
  }
}
