import 'package:aw_flutter/features/employee/application/employee_service.dart';
import 'package:aw_flutter/features/employee/data/dtos/employee.dart';
import 'package:bloc/bloc.dart';

// events
sealed class EmployeeEvent {}

class CreateEmployeesEvent extends EmployeeEvent {}

class GetEmployeesEvent extends EmployeeEvent {}

class UpdateEmployeesEvent extends EmployeeEvent {}

class DeleteEmployeesEvent extends EmployeeEvent {}

// states
sealed class EmployeeState {}

class EmployeeInitialState extends EmployeeState {}

class EmployeeLoadingState extends EmployeeState {}

class EmployeeReadyState extends EmployeeState {
  final List<EmployeeDto> employees;

  EmployeeReadyState({required this.employees});
}

// bloc
class EmployeeBlock extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBlock() : super(EmployeeInitialState()) {
    on(_onGetEmployeesEvent);
  }

  Future<void> _onGetEmployeesEvent(
    GetEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoadingState());

    List<EmployeeDto> employees = await EmployeeService().getEmployees();

    emit(EmployeeReadyState(employees: employees));
  }
}
