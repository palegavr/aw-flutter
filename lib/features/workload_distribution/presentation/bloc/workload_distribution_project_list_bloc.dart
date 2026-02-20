import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/workload_distribution_project_service.dart';
import '../../domain/models/workload_project.dart';

// States
abstract class WorkloadDistributionProjectListState {}

class ProjectListInitial extends WorkloadDistributionProjectListState {}

class ProjectListLoading extends WorkloadDistributionProjectListState {}

class ProjectListReady extends WorkloadDistributionProjectListState {
  final List<WorkloadDistributionProject> projects;
  ProjectListReady(this.projects);
}

class ProjectListLoadError extends WorkloadDistributionProjectListState {
  final String message;
  ProjectListLoadError(this.message);
}

// Events
abstract class WorkloadDistributionProjectListEvent {}

class LoadProjectList extends WorkloadDistributionProjectListEvent {}

class CreateProject extends WorkloadDistributionProjectListEvent {
  final String title;
  final UniversityForm1 form1;
  final UniversityForm3 form3;

  CreateProject({
    required this.title,
    required this.form1,
    required this.form3,
  });
}

class DeleteProject extends WorkloadDistributionProjectListEvent {
  final int projectId;
  DeleteProject(this.projectId);
}

// BLoC
class WorkloadDistributionProjectListBloc
    extends Bloc<WorkloadDistributionProjectListEvent, WorkloadDistributionProjectListState> {
  final WorkloadDistributionProjectService _service;

  WorkloadDistributionProjectListBloc(this._service) : super(ProjectListInitial()) {
    on<LoadProjectList>(_onLoadProjectList);
    on<CreateProject>(_onCreateProject);
    on<DeleteProject>(_onDeleteProject);
  }

  Future<void> _onLoadProjectList(
    LoadProjectList event,
    Emitter<WorkloadDistributionProjectListState> emit,
  ) async {
    emit(ProjectListLoading());
    try {
      final projects = await _service.getAll();
      emit(ProjectListReady(projects));
    } catch (e) {
      emit(ProjectListLoadError(e.toString()));
    }
  }

  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<WorkloadDistributionProjectListState> emit,
  ) async {
    try {
      await _service.create(
        title: event.title,
        universityForm1: event.form1,
        universityForm3: event.form3,
      );
      add(LoadProjectList());
    } catch (e) {
      emit(ProjectListLoadError(e.toString()));
    }
  }

  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<WorkloadDistributionProjectListState> emit,
  ) async {
    try {
      await _service.delete(event.projectId);
      add(LoadProjectList());
    } catch (e) {
      emit(ProjectListLoadError(e.toString()));
    }
  }
}
