import 'dart:io';

import 'package:aw_flutter/features/workload_distribution/data/tables/workload_distribution_project.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    WorkloadDistributionProject,
  ],
)
class AppDatabase extends _$AppDatabase {
  static AppDatabase sharedInstance = AppDatabase._();

  AppDatabase._([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  factory AppDatabase([QueryExecutor? executor]) {
    return AppDatabase._(executor);
  }

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final dbDir = Directory(exeDir);

    return driftDatabase(
      name: 'db',
      native: DriftNativeOptions(databaseDirectory: () async => dbDir),
    );
  }
}
