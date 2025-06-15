import 'package:aw_flutter/features/archive/presentation/view/archive_entries_screen.dart'
    show WorkloadTable;
import 'package:flutter/material.dart';

class WorkloadTableView extends StatelessWidget {
  final WorkloadTable table;

  const WorkloadTableView({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(title: Text("Таблиця: ${table.name}")),
          DataTable(
            columns: const [
              DataColumn(label: Text('Дисципліна')),
              DataColumn(label: Text('Групи')),
              DataColumn(label: Text('Семестр')),
              DataColumn(label: Text('Години')),
            ],
            rows:
                table.entries.map((e) {
                  return DataRow(
                    cells: [
                      DataCell(Text(e.courseName)),
                      DataCell(Text(e.groups.join(', '))),
                      DataCell(Text(e.semester.toString())),
                      DataCell(Text(e.hours.toString())),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
