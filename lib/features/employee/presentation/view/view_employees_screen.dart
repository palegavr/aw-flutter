import 'package:aw_flutter/features/employee/presentation/bloc/employee_bloc.dart';
import 'package:aw_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewEmployeesScreen extends StatefulWidget {
  static const routeName = '/employees';

  const ViewEmployeesScreen({super.key});

  @override
  State<ViewEmployeesScreen> createState() => _ViewEmployeesScreenState();
}

class _ViewEmployeesScreenState extends State<ViewEmployeesScreen> {
  @override
  Widget build(BuildContext context) {
    EmployeeBlock employeeBlock = context.read<EmployeeBlock>();
    employeeBlock.add(GetEmployeesEvent());

    return BlocListener<EmployeeBlock, EmployeeState>(
      listener: (context, state) {},
      child: BlocBuilder<EmployeeBlock, EmployeeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: awSimpleAppBar(),
            body: Align(
              alignment: Alignment.center,
              child:
                  (state is EmployeeReadyState)
                      ? (state.employees.isNotEmpty
                          ? DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('ПІБ')),
                              DataColumn(label: Text('Посада')),
                            ],
                            rows:
                                state.employees.map((e) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(e.id)),
                                      DataCell(Text(e.lastName)),
                                      DataCell(Text(e.rank.displayName)),
                                    ],
                                  );
                                }).toList(),
                          )
                          : const Text('Співробітників поки немає'))
                      : (state is EmployeeLoadingState)
                      ? const CircularProgressIndicator()
                      : (state is EmployeeInitialState)
                      ? const Text('Треба завантижити список співробітників')
                      : const Text('Щось пішло не так...'),
            ),
          );
        },
      ),
    );
  }
}
