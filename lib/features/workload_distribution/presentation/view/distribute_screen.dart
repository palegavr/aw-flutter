import 'package:flutter/material.dart';

import 'package:aw_flutter/widgets.dart';

// class DistributeScreen extends StatelessWidget {
//   static const routeName = '/distribute';

//   const DistributeScreen({super.key});

//   @override
//   Widget build(BuildContext ctx) {
//     const enableExport = true;

//     return Scaffold(
//       appBar: awSimpleAppBar(),
//       body: const Column(children: [Text('Import Screen')]),
//       floatingActionButton: const FloatingActionButton.extended(
//         label: Text('Експорт'),
//         icon: Icon(Icons.file_download_rounded),
//         disabledElevation: enableExport ? null : 0,
//         mouseCursor:
//             enableExport ? SystemMouseCursors.click : SystemMouseCursors.basic,
//         onPressed: null,
//       ),
//     );
//   }
// }

class DistributeScreen extends StatefulWidget {
  static const routeName = '/distribute';

  const DistributeScreen({super.key});

  @override
  State<DistributeScreen> createState() => _DistributeScreenState();
}

class _DistributeScreenState extends State<DistributeScreen> {
  bool isAllLoadDistributed = false; // TODO: Реалізувати логіку перевірки
  String selectedTeacherId = ''; // TODO: Обрати НПП
  List<String> teacherList = []; // TODO: Заповнити список НПП
  String selectedSemester = 'Другий';
  List<String> loadTypes = [
    'Лекції',
    'Практичні заняття',
    'Лабораторні заняття',
  ];
  String selectedLoadType = 'Лекції'; // За замовчуванням

  @override
  void initState() {
    super.initState();
    // TODO: Ініціалізація збереженого стану (наприклад, з локального сховища)
  }

  void _addTeacher() {
    showDialog(
      context: context,
      builder: (context) {
        String fullName = '';
        String position = '';

        return AlertDialog(
          title: const Text('Додати НПП'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'ПІБ'),
                onChanged: (value) => fullName = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Посада'),
                onChanged: (value) => position = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: Додати викладача до списку
                setState(() {
                  teacherList.add(fullName); // Спрощено
                });
                Navigator.of(context).pop();
              },
              child: const Text('Додати'),
            ),
          ],
        );
      },
    );
  }

  void _exportToExcel() {
    // TODO: Відкрити діалог вибору директорії та викликати експорт
    debugPrint('Експортуємо дані до Excel');
  }

  void _undoLastAction() {
    // TODO: Реалізувати CTRL+Z логіку
    debugPrint('Скасовано останню дію');
  }

  void _showDistributionWarning() {
    showDialog(
      context: context,
      builder:
          (_) => const AlertDialog(
            title: Text('Попередження'),
            content: Text('Розподіл навантаження є нерівномірним.'),
          ),
    );
  }

  Widget _buildTeacherTabs() {
    return DropdownButton<String>(
      value: selectedTeacherId.isNotEmpty ? selectedTeacherId : null,
      hint: const Text('Оберіть НПП'),
      items:
          teacherList.map((teacher) {
            return DropdownMenuItem(value: teacher, child: Text(teacher));
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedTeacherId = value;
          });
        }
      },
    );
  }

  Widget _buildTeachingLoadTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: MaterialStateColor.resolveWith(
          (states) => Colors.grey.shade300,
        ),
        columns: const [
          DataColumn(label: Text('НПП')),
          DataColumn(label: Text('Семестр')),
          DataColumn(label: Text('Тип')),
          DataColumn(label: Text('Назва дисципліни')),
          DataColumn(label: Text('Групи')),
          DataColumn(label: Text('Години')),
          DataColumn(label: Text('Дії')),
        ],
        rows: _buildTeachingLoadRows(),
      ),
    );
  }

  List<DataRow> _buildTeachingLoadRows() {
    // TODO: Замінити на фактичні дані з моделі стану
    final dummyData = [
      {
        'npp': 'Іваненко І.І.',
        'semester': '2',
        'type': 'Лекції',
        'subject': 'Програмування',
        'groups': 'ПІ-21, ПІ-22',
        'hours': '30',
      },
      // {
      //   'npp': 'Петренко П.П.',
      //   'semester': '2',
      //   'type': 'Практичні заняття',
      //   'subject': 'Бази даних',
      //   'groups': 'ПІ-21',
      //   'hours': '20',
      // },
    ];

    return dummyData.map((row) {
      return DataRow(
        cells: [
          DataCell(Text(row['npp'] ?? '')),
          DataCell(Text(row['semester'] ?? '')),
          DataCell(Text(row['type'] ?? '')),
          DataCell(Text(row['subject'] ?? '')),
          DataCell(Text(row['groups'] ?? '')),
          DataCell(Text(row['hours'] ?? '')),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    // TODO: Відкрити діалог редагування запису
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    // TODO: Видалити запис з таблиці
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildUnassignedLoadList() {
    final unassignedItems = [
      {
        'type': 'Лекції',
        'semester': '2',
        'subject': 'Алгоритми та структури даних',
        'groups': 'ПІ-21, ПІ-22',
        'hours': 30,
      },
      // {
      //   'type': 'Лабораторні заняття',
      //   'semester': '1',
      //   'subject': 'Компʼютерна графіка',
      //   'groups': 'ПІ-23',
      //   'hours': 15,
      // },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Нерозподілене навантаження:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: unassignedItems.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = unassignedItems[index];
            return ListTile(
              title: Text(item['subject'] as String? ?? ''),
              subtitle: Text(
                '${item['type']} | ${item['semester']} | Групи: ${item['groups']}',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Відкрити діалог додавання цього навантаження до НПП
                },
                child: const Text('Додати до НПП'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTeachingLoadFilter() {
    return Row(
      children: [
        const Text('Семестр: '),
        DropdownButton<String>(
          value: selectedSemester,
          items:
              ['Перший', 'Другий'].map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedSemester = value;
              });
            }
          },
        ),
        const SizedBox(width: 20),
        const Text('Типи навантаження: '),
        DropdownButton<String>(
          value: selectedLoadType,
          items:
              loadTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedLoadType = value;
              });
              // TODO: Застосувати фільтрацію за обраним типом
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Розподіл навчального навантаження'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undoLastAction),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: isAllLoadDistributed ? _exportToExcel : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _addTeacher,
              icon: const Icon(Icons.person_add),
              label: const Text('Додати НПП'),
            ),
            const SizedBox(height: 12),
            _buildTeacherTabs(),
            const SizedBox(height: 12),
            _buildUnassignedLoadList(),
            const SizedBox(height: 12),
            _buildTeachingLoadFilter(),
            const SizedBox(height: 12),
            Expanded(child: _buildTeachingLoadTable()),
            if (!isAllLoadDistributed)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('Навантаження ще не розподілене повністю.'),
                    TextButton(
                      onPressed: _showDistributionWarning,
                      child: const Text('Деталі'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
