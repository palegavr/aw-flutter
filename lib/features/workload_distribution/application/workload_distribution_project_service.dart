import 'dart:convert';

import 'package:aw_flutter/database/app_database.dart';
import 'package:aw_flutter/features/workload_distribution/data/dtos/workload_project.dart';
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
    required UniversityForm1Dto universityForm1,
    required UniversityForm3Dto universityForm3,
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

  Future<List<WorkloadDistributionProjectDto>> getAll() async {
    return (await _db.select(_db.workloadDistributionProject).get())
        .map((e) => WorkloadDistributionProjectDto.fromTableData(e))
        .toList();
  }

  Future<WorkloadDistributionProjectDto?> getById(int id) async {
    var data =
        await (_db.select(_db.workloadDistributionProject)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (data == null) return null;

    return WorkloadDistributionProjectDto.fromTableData(data);
  }

  Future<bool> update(WorkloadDistributionProjectDto dto) async {
    final updated = WorkloadDistributionProjectCompanion(
      title: Value(dto.title),
      universityForm1Json: Value(jsonEncode(dto.universityForm1.toJson())),
      universityForm3Json: Value(jsonEncode(dto.universityForm3.toJson())),
      updatedAt: Value(DateTime.now()),
    );

    final count = await (_db.update(_db.workloadDistributionProject)
      ..where((tbl) => tbl.id.equals(dto.id))).write(updated);

    return count > 0;
  }

  Future<bool> setTitle(int projectId, String newTitle) async {
    final project = await getById(projectId);
    if (project == null) return false;
    project.title = newTitle;
    return await update(project);
  }

  Future<bool> delete(int id) async {
    final count =
        await (_db.delete(_db.workloadDistributionProject)
          ..where((tbl) => tbl.id.equals(id))).go();
    return count > 0;
  }
}
