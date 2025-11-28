import 'package:drift/drift.dart';

class WorkloadDistributionProject extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get universityForm1Json => text()();

  TextColumn get universityForm3Json => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
