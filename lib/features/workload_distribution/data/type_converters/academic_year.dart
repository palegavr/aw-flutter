import 'package:aw_flutter/features/workload_distribution/data/dtos/academic_year.dart';
import 'package:drift/drift.dart';

class AcademicYearTypeConverter extends TypeConverter<AcademicYearDto, int> {
  const AcademicYearTypeConverter();

  @override
  AcademicYearDto fromSql(int fromDb) {
    return AcademicYearDto.fromStartYear(fromDb);
  }

  @override
  int toSql(AcademicYearDto value) {
    return value.startYear;
  }
}
