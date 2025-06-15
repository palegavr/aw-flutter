import 'package:aw_flutter/features/archive/presentation/view/workload_table_view.dart'
    show WorkloadTableView;
import 'package:aw_flutter/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: ArchiveEntriesScreen()));
}

class ArchiveEntriesScreen extends StatefulWidget {
  static const routeName = '/archive_entries';

  const ArchiveEntriesScreen({super.key});

  @override
  State<ArchiveEntriesScreen> createState() => _ArchiveEntriesScreenState();
}

class _ArchiveEntriesScreenState extends State<ArchiveEntriesScreen> {
  List<int> availableYears = [2021, 2022, 2023];
  int? selectedYear;
  ArchiveData? archiveData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Архів навчального навантаження'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Експортувати у Excel',
            onPressed: archiveData != null ? _exportToExcel : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: defaultSpacing),
        child: Column(
          spacing: defaultSpacing,
          children: [
            _buildYearSelector(),
            const SizedBox(height: 10),
            Expanded(child: _buildArchiveContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Оберіть навчальний рік',
          border: OutlineInputBorder(),
        ),
        value: selectedYear,
        items:
            availableYears.map((year) {
              return DropdownMenuItem(
                value: year,
                child: Text('$year–${year + 1}'),
              );
            }).toList(),
        onChanged: (year) {
          setState(() {
            selectedYear = year;
            archiveData = null;
          });
          _loadArchiveForYear(year!);
        },
      ),
    );
  }

  Widget _buildArchiveContent() {
    if (selectedYear == null) {
      return const Center(child: Text('Оберіть рік для перегляду архіву'));
    }
    if (archiveData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Таблиці НПП'),
              Tab(text: 'Загальна таблиця'),
              Tab(text: 'Діаграми'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildNppTables(),
                const Center(child: Text('TODO: Загальна таблиця')),
                const Center(child: Text('TODO: Діаграма розподілу')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNppTables() {
    if (archiveData!.nppTables.isEmpty) {
      return const Center(child: Text('Немає записів для цього року'));
    }

    return ListView.builder(
      itemCount: archiveData!.nppTables.length,
      itemBuilder: (context, index) {
        final npp = archiveData!.nppTables[index];
        return ExpansionTile(
          title: Text('${npp.name} (${npp.position})'),
          children:
              npp.tables.map((table) {
                return WorkloadTableView(table: table);
              }).toList(),
        );
      },
    );
  }

  void _loadArchiveForYear(int year) async {
    // TODO: Замість цього має бути логіка завантаження архіву
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      archiveData = ArchiveData.mockForYear(year);
    });
  }

  void _exportToExcel() {
    // TODO: Реалізувати експорт до Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Експорт розпочато')),
    );
  }
}

class ArchiveData {
  final List<NppRecord> nppTables;

  ArchiveData({required this.nppTables});

  static ArchiveData mockForYear(int year) {
    return ArchiveData(
      nppTables: [
        NppRecord(
          name: 'Іваненко І.І.',
          position: 'доцент',
          tables: [
            WorkloadTable(
              name: 'Основна таблиця',
              entries: [
                WorkloadEntry(
                  courseName: 'Математика',
                  semester: 1,
                  hours: 90,
                  groups: ['ПІ-21', 'ПІ-22'],
                ),
                WorkloadEntry(
                  courseName: 'Фізика',
                  semester: 2,
                  hours: 60,
                  groups: ['ПІ-21'],
                ),
              ],
            ),
          ],
        ),
        NppRecord(
          name: 'Петренко П.П.',
          position: 'старший викладач',
          tables: [],
        ),
      ],
    );
  }
}

class NppRecord {
  final String name;
  final String position;
  final List<WorkloadTable> tables;

  NppRecord({required this.name, required this.position, required this.tables});
}

class WorkloadTable {
  final String name;
  final List<WorkloadEntry> entries;

  WorkloadTable({required this.name, required this.entries});
}

class WorkloadEntry {
  final String courseName;
  final int semester;
  final int hours;
  final List<String> groups;

  WorkloadEntry({
    required this.courseName,
    required this.semester,
    required this.hours,
    required this.groups,
  });
}
