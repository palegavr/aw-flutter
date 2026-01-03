import 'dart:convert';

import 'package:aw_flutter/database/app_database.dart';
import 'package:aw_flutter/features/workload_distribution/domain/models/workload_project.dart';
import 'package:drift/drift.dart';

class WorkloadDistributionProjectService {
  final AppDatabase _db = AppDatabase.sharedInstance;

  WorkloadDistributionProjectService._();

  static final WorkloadDistributionProjectService _instance =
      WorkloadDistributionProjectService._();

  factory WorkloadDistributionProjectService() {
    return _instance;
  }

  Future<int> create({
    required String title,
    required UniversityForm1 universityForm1,
    required UniversityForm3 universityForm3,
  }) async {
    final now = DateTime.now();

    return await _db
        .into(_db.workloadDistributionProject)
        .insert(
          WorkloadDistributionProjectCompanion.insert(
            title: title,
            universityForm1Json: jsonEncode(universityForm1.toJson()),
            universityForm3Json: jsonEncode(universityForm3.toJson()),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<List<WorkloadDistributionProject>> getAll() async {
    return (await _db.select(_db.workloadDistributionProject).get())
        .map((e) => WorkloadDistributionProject.fromTableData(e))
        .toList();
  }

  Future<WorkloadDistributionProject?> getById(int id) async {
    var data =
        await (_db.select(_db.workloadDistributionProject)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (data == null) return null;

    return WorkloadDistributionProject.fromTableData(data);
  }

  Future<bool> update(WorkloadDistributionProject aggregate) async {
    final updated = WorkloadDistributionProjectCompanion(
      title: Value(aggregate.title),
      universityForm1Json: Value(
        jsonEncode(aggregate.universityForm1.toJson()),
      ),
      universityForm3Json: Value(
        jsonEncode(aggregate.universityForm3.toJson()),
      ),
      updatedAt: Value(DateTime.now()),
    );

    final count = await (_db.update(_db.workloadDistributionProject)
      ..where((tbl) => tbl.id.equals(aggregate.id))).write(updated);

    return count > 0;
  }

  Future<bool> setTitle(int projectId, String newTitle) async {
    final project = await getById(projectId);
    if (project == null) return false;

    project.changeTitle(newTitle);
    return await update(project);
  }

  Future<bool> delete(int id) async {
    final count =
        await (_db.delete(_db.workloadDistributionProject)
          ..where((tbl) => tbl.id.equals(id))).go();
    return count > 0;
  }
}
