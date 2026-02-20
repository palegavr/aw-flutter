import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/workload_distribution_project_service.dart';
import '../../domain/models/workload_project.dart';

// States
abstract class WorkloadDistributionProjectState {}

class ProjectInitial extends WorkloadDistributionProjectState {}

class ProjectLoading extends WorkloadDistributionProjectState {}

class ProjectReady extends WorkloadDistributionProjectState {
  final WorkloadDistributionProject project;
  final String? errorMessage;
  ProjectReady(this.project, {this.errorMessage});
}

class ProjectLoadError extends WorkloadDistributionProjectState {
  final String message;
  ProjectLoadError(this.message);
}

// Events
abstract class WorkloadDistributionProjectEvent {}

class LoadProject extends WorkloadDistributionProjectEvent {
  final int projectId;
  LoadProject(this.projectId);
}

class ClearProjectError extends WorkloadDistributionProjectEvent {}

class UpdateProjectTitle extends WorkloadDistributionProjectEvent {
  final String newTitle;
  UpdateProjectTitle(this.newTitle);
}

class CreateRate extends WorkloadDistributionProjectEvent {
  final String employeeId;
  final double rateValue;
  final DateTime dateStart;
  final DateTime dateEnd;
  final int postgraduateCount;

  CreateRate({
    required this.employeeId,
    required this.rateValue,
    required this.dateStart,
    required this.dateEnd,
    required this.postgraduateCount,
  });
}

class UpdateRate extends WorkloadDistributionProjectEvent {
  final String employeeId;
  final String rateId;
  final double rateValue;
  final DateTime dateStart;
  final DateTime dateEnd;
  final int postgraduateCount;

  UpdateRate({
    required this.employeeId,
    required this.rateId,
    required this.rateValue,
    required this.dateStart,
    required this.dateEnd,
    required this.postgraduateCount,
  });
}

class RemoveRate extends WorkloadDistributionProjectEvent {
  final String employeeId;
  final EmployeeRate rate;

  RemoveRate({required this.employeeId, required this.rate});
}

class AddWorkloadItem extends WorkloadDistributionProjectEvent {
  final String employeeId;
  final String rateId;
  final UniversityForm3WorkloadItem newItem;

  AddWorkloadItem({
    required this.employeeId,
    required this.rateId,
    required this.newItem,
  });
}

class UpdateWorkloadField extends WorkloadDistributionProjectEvent {
  final String employeeId;
  final String rateId;
  final String itemId;
  final WorkloadField field;
  final double newValue;

  UpdateWorkloadField({
    required this.employeeId,
    required this.rateId,
    required this.itemId,
    required this.field,
    required this.newValue,
  });
}

class UpdateWorkloadGroups extends WorkloadDistributionProjectEvent {
  final String employeeId;
  final String rateId;
  final String itemId;
  final List<String> groups;

  UpdateWorkloadGroups({
    required this.employeeId,
    required this.rateId,
    required this.itemId,
    required this.groups,
  });
}

class RemoveWorkloadItem extends WorkloadDistributionProjectEvent {
  final String employeeId;
  final String rateId;
  final String itemId;

  RemoveWorkloadItem({
    required this.employeeId,
    required this.rateId,
    required this.itemId,
  });
}

class AddEmployee extends WorkloadDistributionProjectEvent {
  final Employee employee;
  AddEmployee(this.employee);
}

class UpdateEmployeeDetails extends WorkloadDistributionProjectEvent {
  final String employeeId;
  final String firstName;
  final String lastName;
  final String patronymic;
  final EmployeeRank rank;

  UpdateEmployeeDetails({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.rank,
  });
}

class RemoveEmployee extends WorkloadDistributionProjectEvent {
  final Employee employee;
  RemoveEmployee(this.employee);
}

class ImportExcel extends WorkloadDistributionProjectEvent {
  final UniversityForm1 form1;
  ImportExcel(this.form1);
}

// BLoC
class WorkloadDistributionProjectBloc
    extends Bloc<WorkloadDistributionProjectEvent, WorkloadDistributionProjectState> {
  final WorkloadDistributionProjectService _service;

  WorkloadDistributionProjectBloc(this._service) : super(ProjectInitial()) {
    on<LoadProject>(_onLoadProject);
    on<ClearProjectError>(_onClearProjectError);
    on<UpdateProjectTitle>(_onUpdateProjectTitle);
    on<CreateRate>(_onCreateRate);
    on<UpdateRate>(_onUpdateRate);
    on<RemoveRate>(_onRemoveRate);
    on<AddWorkloadItem>(_onAddWorkloadItem);
    on<UpdateWorkloadField>(_onUpdateWorkloadField);
    on<UpdateWorkloadGroups>(_onUpdateWorkloadGroups);
    on<RemoveWorkloadItem>(_onRemoveWorkloadItem);
    on<AddEmployee>(_onAddEmployee);
    on<UpdateEmployeeDetails>(_onUpdateEmployeeDetails);
    on<RemoveEmployee>(_onRemoveEmployee);
    on<ImportExcel>(_onImportExcel);
  }

  Future<void> _onLoadProject(LoadProject event, Emitter<WorkloadDistributionProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final project = await _service.getById(event.projectId);
      if (project == null) {
        emit(ProjectLoadError('Проєкт з id=${event.projectId} не знайдено'));
      } else {
        emit(ProjectReady(project));
      }
    } catch (e) {
      emit(ProjectLoadError(e.toString()));
    }
  }

  void _onClearProjectError(ClearProjectError event, Emitter<WorkloadDistributionProjectState> emit) {
    final currentState = state;
    if (currentState is ProjectReady) {
      emit(ProjectReady(currentState.project));
    }
  }

  Future<void> _onUpdateProjectTitle(UpdateProjectTitle event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.changeTitle(event.newTitle);
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onCreateRate(CreateRate event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.createForm3Rate(
          event.employeeId,
          event.rateValue,
          event.dateStart,
          event.dateEnd,
          event.postgraduateCount,
        );
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onUpdateRate(UpdateRate event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.updateForm3Rate(
          event.employeeId,
          event.rateId,
          event.rateValue,
          event.dateStart,
          event.dateEnd,
          event.postgraduateCount,
        );
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onRemoveRate(RemoveRate event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.removeForm3Rate(event.employeeId, event.rate);
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onAddWorkloadItem(AddWorkloadItem event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.addForm3WorkloadItem(
          event.employeeId,
          event.rateId,
          event.newItem,
        );
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onUpdateWorkloadField(UpdateWorkloadField event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.updateForm3WorkloadField(
          event.employeeId,
          event.rateId,
          event.itemId,
          event.field,
          event.newValue,
        );
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onUpdateWorkloadGroups(UpdateWorkloadGroups event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.updateForm3WorkloadGroups(
          event.employeeId,
          event.rateId,
          event.itemId,
          event.groups,
        );
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onRemoveWorkloadItem(RemoveWorkloadItem event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.removeForm3WorkloadItem(
          event.employeeId,
          event.rateId,
          event.itemId,
        );
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onAddEmployee(AddEmployee event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.addForm3Employee(event.employee);
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onUpdateEmployeeDetails(UpdateEmployeeDetails event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.updateEmployeeDetails(
          event.employeeId,
          event.firstName,
          event.lastName,
          event.patronymic,
          event.rank,
        );
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onRemoveEmployee(RemoveEmployee event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.removeForm3Employee(event.employee);
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onImportExcel(ImportExcel event, Emitter<WorkloadDistributionProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectReady) {
      try {
        final updatedProject = currentState.project.updateForm1(event.form1);
        await _service.update(updatedProject);
        emit(ProjectReady(updatedProject));
      } catch (e) {
        emit(ProjectReady(currentState.project, errorMessage: e.toString()));
      }
    }
  }
}
