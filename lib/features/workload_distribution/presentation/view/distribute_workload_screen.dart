import 'package:aw_flutter/features/workload_distribution/application/workload_distribution_project_service.dart';
import 'package:aw_flutter/shared/errors/domain_error.dart';
import 'package:aw_flutter/features/workload_distribution/domain/models/academic_semester.dart';

import 'package:aw_flutter/features/workload_distribution/domain/models/workload_project.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/add_workload_item_dialog.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/widgets/employee_form.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/widgets/rate_form.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/widgets/group_editor_dialog.dart';
import 'package:aw_flutter/shared/date_time_extension.dart';
import 'package:aw_flutter/src/rust/api/excel_interface.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DistributeWorkloadScreen extends StatefulWidget {
  static const routeName = '/workload_distribution/distribute_workload';

  final int projectId;

  const DistributeWorkloadScreen({super.key, required this.projectId});

  @override
  State<DistributeWorkloadScreen> createState() =>
      _DistributeWorkloadScreenState();
}

class _DistributeWorkloadScreenState extends State<DistributeWorkloadScreen> {
  final ScrollController _horizontalController = ScrollController();
  final _workloadDistributionProjectService =
      WorkloadDistributionProjectService();

  late WorkloadDistributionProject _project;
  bool _projectLoaded = false;
  DisplayMode _displayMode = DisplayMode.form1;

  bool _projectTitleEditing = false;
  final TextEditingController _editProjectTitleFieldTextEditingController =
      TextEditingController();
  final FocusNode _editProjectTitleFieldFocusNode = FocusNode();

  final ValueNotifier<String?> _workloadHintNotifier = ValueNotifier<String?>(
    null,
  );

  _DistributeWorkloadScreenState() {
    _postConstruct();
  }

  @override
  void initState() {
    super.initState();
    _editProjectTitleFieldFocusNode.addListener(_onTitleFocusChange);
  }

  @override
  void dispose() {
    _editProjectTitleFieldFocusNode.removeListener(_onTitleFocusChange);
    _editProjectTitleFieldFocusNode.dispose();
    _editProjectTitleFieldTextEditingController.dispose();
    _workloadHintNotifier.dispose();
    super.dispose();
  }

  void _onTitleFocusChange() {
    if (!_editProjectTitleFieldFocusNode.hasFocus && _projectTitleEditing) {
      _submitEditProjectTitleField(
        _editProjectTitleFieldTextEditingController.text,
      );
    }
  }

  void _postConstruct() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await _refreshProject();
  }

  Future<void> _refreshProject() async {
    final WorkloadDistributionProject project =
        (await _workloadDistributionProjectService.getById(widget.projectId))!;
    setState(() {
      _project = project;
      if (!_projectLoaded) _projectLoaded = true;
    });
  }

  void _setDisplayMode(DisplayMode newDisplayMode) {
    setState(() {
      _displayMode = newDisplayMode;
    });
  }

  void _setProjectTitleEditing(bool newProjectTitleEditing) {
    setState(() {
      if (newProjectTitleEditing) {
        _editProjectTitleFieldTextEditingController.text = _project.title;
        _editProjectTitleFieldFocusNode.requestFocus();
      }
      _projectTitleEditing = newProjectTitleEditing;
    });
  }

  void _toggleProjectTitleEditing() {
    _setProjectTitleEditing(!_projectTitleEditing);
  }


  void _setProjectTitle(String newTitle) async {
    await _workloadDistributionProjectService.setTitle(
      widget.projectId,
      newTitle,
    );
    await _refreshProject();
  }

  void _submitEditProjectTitleField(String value) {
    _setProjectTitle(value);
    _setProjectTitleEditing(false);
  }

  Future<void> _importExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;

      // Show loading indicator while parsing
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final parsedFile = await parseExcelFile(filePath: filePath);
        Navigator.of(context).pop(); // Close loading indicator

        if (!mounted) return;

        // Show sheet selection dialog
        String? selectedSheet = parsedFile.data.keys.firstOrNull;

        await showDialog(
          context: context,
          builder:
              (context) => StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Виберіть лист'),
                    content: DropdownButton<String>(
                      value: selectedSheet,
                      isExpanded: true,
                      items:
                          parsedFile.data.keys.map((String sheet) {
                            return DropdownMenuItem<String>(
                              value: sheet,
                              child: Text(sheet),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSheet = newValue;
                        });
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Скасувати'),
                      ),
                      ElevatedButton(
                        onPressed:
                            selectedSheet == null
                                ? null
                                : () async {
                                  final newForm1 =
                                      UniversityForm1.fromParsedExcelFile(
                                        id: _project.universityForm1.id,
                                        file: parsedFile,
                                        sheetName: selectedSheet!,
                                        academicYear:
                                            _project
                                                .universityForm1
                                                .academicYear,
                                      );

                                  _project.updateForm1(newForm1);
                                  await _workloadDistributionProjectService
                                      .update(_project);
                                  await _refreshProject();

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                        child: const Text('Імпортувати'),
                      ),
                    ],
                  );
                },
              ),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Close loading indicator if error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Помилка при імпорті: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ValueListenableBuilder<String?>(
            valueListenable: _workloadHintNotifier,
            builder: (context, hint, _) {
              if (hint == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      hint,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        title: Row(
          children: [
            Expanded(
              child:
                  _projectTitleEditing
                      ? TextField(
                        controller: _editProjectTitleFieldTextEditingController,
                        focusNode: _editProjectTitleFieldFocusNode,
                        onSubmitted: _submitEditProjectTitleField,
                      )
                      : Text(_projectLoaded ? _project.title : ''),
            ),
            IconButton(
              onPressed:
                  _projectTitleEditing
                      ? () {
                        _submitEditProjectTitleField(
                          _editProjectTitleFieldTextEditingController.text,
                        );
                      }
                      : () {
                        _toggleProjectTitleEditing();
                      },
              icon:
                  _projectTitleEditing
                      ? const Icon(Icons.check)
                      : const Icon(Icons.edit),
            ),
          ],
        ),
      ),
      body:
          (!_projectLoaded)
              ? const Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
              : Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    ToggleButtons(
                      isSelected: [
                        _displayMode == DisplayMode.form1,
                        _displayMode == DisplayMode.form3,
                      ],
                      onPressed: (index) {
                        _setDisplayMode(
                          index == 0 ? DisplayMode.form1 : DisplayMode.form3,
                        );
                      },
                      children: [
                        Text(DisplayMode.form1.name),
                        Text(DisplayMode.form3.name),
                      ],
                    ),
                    Expanded(
                      child:
                          _displayMode == DisplayMode.form1
                              ? _project.universityForm1.workloadItems.isEmpty
                                  ? Center(
                                    child: ElevatedButton.icon(
                                      onPressed: _importExcel,
                                      icon: const Icon(Icons.upload_file),
                                      label: const Text('Імпортувати з Excel'),
                                    ),
                                  )
                                  : _Form1Table(
                                    universityForm1: _project.universityForm1,
                                  )
                              : _displayMode == DisplayMode.form3
                               ? _Form3Editor(
                                 project: _project,
                                 hintNotifier: _workloadHintNotifier,
                                 onUpdateField: (employeeId, rateId, itemId, field, newValue) async {
                                   try {
                                     _project.updateForm3WorkloadField(employeeId, rateId, itemId, field, newValue);
                                     await _workloadDistributionProjectService.update(_project);
                                     await _refreshProject();
                                   } on DomainError catch (e) {
                                     await _refreshProject();
                                     if (mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(
                                           content: Text(e.message),
                                           backgroundColor: Theme.of(context).colorScheme.error,
                                         ),
                                       );
                                     }
                                   } catch (e) {
                                     await _refreshProject();
                                     if (mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(
                                           content: Text('Помилка при оновленні.'),
                                           backgroundColor: Theme.of(context).colorScheme.error,
                                         ),
                                       );
                                     }
                                   }
                                 },
                                 onUpdateGroups: (employeeId, rateId, itemId, groups) async {
                                   _project.updateForm3WorkloadGroups(employeeId, rateId, itemId, groups);
                                   await _workloadDistributionProjectService.update(_project);
                                   await _refreshProject();
                                 },
                                 onDeleteItem: (employeeId, rateId, itemId) async {
                                   _project.removeForm3WorkloadItem(employeeId, rateId, itemId);
                                   await _workloadDistributionProjectService.update(_project);
                                   await _refreshProject();
                                 },
                                 onAddItem: (employeeId, rateId, item) async {
                                   try {
                                     _project.addForm3WorkloadItem(employeeId, rateId, item);
                                     await _workloadDistributionProjectService.update(_project);
                                     await _refreshProject();
                                   } on DomainError catch (e) {
                                     await _refreshProject();
                                     if (mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(
                                           content: Text(e.message),
                                           backgroundColor: Theme.of(context).colorScheme.error,
                                         ),
                                       );
                                     }
                                     rethrow;
                                   } catch (e) {
                                     await _refreshProject();
                                     if (mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(
                                           content: Text('Помилка при додаванні: $e'),
                                           backgroundColor: Theme.of(context).colorScheme.error,
                                         ),
                                       );
                                     }
                                     rethrow;
                                   }
                                 },
                                 onCreateRate: (employeeId, rateValue, dateStart, dateEnd, postgraduateCount) async {
                                   _project.createForm3Rate(employeeId, rateValue, dateStart, dateEnd, postgraduateCount);
                                   await _workloadDistributionProjectService.update(_project);
                                   await _refreshProject();
                                 },
                                 onRemoveRate: (employee, rate) async {
                                   _project.removeForm3Rate(employee.id, rate);
                                   await _workloadDistributionProjectService.update(_project);
                                   await _refreshProject();
                                 },
                                 onAddEmployee: (employee) async {
                                   _project.addForm3Employee(employee);
                                   await _workloadDistributionProjectService.update(_project);
                                   await _refreshProject();
                                 },
                                 onRemoveEmployee: (employee) async {
                                   _project.removeForm3Employee(employee);
                                   await _workloadDistributionProjectService.update(_project);
                                   await _refreshProject();
                                 },
                               )
                              : const Text('Unimplemented :('),
                    ),
                  ],
                ),
              ),
    );
  }
}

enum DisplayMode { form1, form3 }

class _Form1Table extends StatelessWidget {
  final UniversityForm1 universityForm1;

  const _Form1Table({super.key, required this.universityForm1});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Card(
          child: DataTable(
            headingRowHeight: 230,
            columns: const [
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Форма навчання'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Спеціальність'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Назва дисципліни'),
                ),
              ),
              DataColumn(
                label: RotatedBox(quarterTurns: -1, child: Text('Курс')),
              ),
              DataColumn(
                label: RotatedBox(quarterTurns: -1, child: Text('Семестр')),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Кількість тижнів'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Кількість студентів'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Кількість потоків'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Кількість груп'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Кількість підгруп'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Лекції по плану'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Лекції всього'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Практичні (семінарські) по плану'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Практичні (семінарські) всього'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Лабораторні по плану'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Лабораторні всього'),
                ),
              ),
              DataColumn(
                label: RotatedBox(quarterTurns: -1, child: Text('Екзамени')),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Консультації перед екзаменом'),
                ),
              ),
              DataColumn(
                label: RotatedBox(quarterTurns: -1, child: Text('Заліки')),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Кваліфікаційні роботи (проєкти)'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Атестаційні екзамени'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Виробнича практика'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Навчальна практика'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Поточні консультації'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Індивідуальні завдання'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Курсові роботи (проєкти)'),
                ),
              ),
              DataColumn(
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text('Проведення аспірантських екзаменів'),
                ),
              ),
            ],
            rows:
                universityForm1.workloadItems.map((workloadItem) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          workloadItem
                              .workloadKey
                              .learningForm
                              .shortDisplayName,
                        ),
                      ),
                      DataCell(Text(workloadItem.workloadKey.specialty)),
                      DataCell(Text(workloadItem.workloadKey.disciplineName)),
                      DataCell(Text(workloadItem.workloadKey.course)),
                      DataCell(
                        Text(workloadItem.workloadKey.semester.toString()),
                      ),
                      DataCell(Text(workloadItem.weekCount.toString())),
                      DataCell(Text(workloadItem.studentCount.toString())),
                      DataCell(Text(workloadItem.flowCount.toString())),
                      DataCell(Text(workloadItem.groupCount.toString())),
                      DataCell(Text(workloadItem.subgroupCount.toString())),
                      DataCell(Text(workloadItem.lecturesPlanned.toString())),
                      DataCell(Text(workloadItem.lecturesTotal.toString())),
                      DataCell(Text(workloadItem.practicesPlanned.toString())),
                      DataCell(Text(workloadItem.practicesTotal.toString())),
                      DataCell(Text(workloadItem.labsPlanned.toString())),
                      DataCell(Text(workloadItem.labsTotal.toString())),
                      DataCell(Text(workloadItem.exams.toString())),
                      DataCell(Text(workloadItem.examConsults.toString())),
                      DataCell(Text(workloadItem.tests.toString())),
                      DataCell(
                        Text(workloadItem.qualificationWorks.toString()),
                      ),
                      DataCell(
                        Text(workloadItem.certificationExams.toString()),
                      ),
                      DataCell(
                        Text(workloadItem.productionPractices.toString()),
                      ),
                      DataCell(Text(workloadItem.teachingPractices.toString())),
                      DataCell(Text(workloadItem.currentConsults.toString())),
                      DataCell(Text(workloadItem.individualWorks.toString())),
                      DataCell(Text(workloadItem.courseWorks.toString())),
                      DataCell(Text(workloadItem.postgraduateExams.toString())),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class _Form3Editor extends StatelessWidget {
  final WorkloadDistributionProject project;
  final ValueNotifier<String?> hintNotifier;

  final Future<void> Function(String employeeId, String rateId, String itemId, WorkloadField field, double newValue) onUpdateField;
  final void Function(String employeeId, String rateId, String itemId, List<String> groups) onUpdateGroups;
  final void Function(String employeeId, String rateId, String itemId) onDeleteItem;
  final Future<void> Function(String employeeId, String rateId, UniversityForm3WorkloadItem item) onAddItem;
  final void Function(String employeeId, double rateValue, DateTime dateStart, DateTime dateEnd, int postgraduateCount) onCreateRate;
  final void Function(Employee employee, EmployeeRate rate) onRemoveRate;
  final void Function(Employee employee) onAddEmployee;
  final void Function(Employee employee) onRemoveEmployee;

  _Form3Editor({
    super.key,
    required this.project,
    required this.hintNotifier,
    required this.onUpdateField,
    required this.onUpdateGroups,
    required this.onDeleteItem,
    required this.onAddItem,
    required this.onCreateRate,
    required this.onRemoveRate,
    required this.onAddEmployee,
    required this.onRemoveEmployee,
  });

  UniversityForm1 get universityForm1 => project.universityForm1;
  UniversityForm3 get universityForm3 => project.universityForm3;

  @override
  Widget build(BuildContext context) {
    if (universityForm3.employees.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              EmployeeForm(
                academicYear: universityForm1.academicYear,
                onSubmit: (employee) {
                  onAddEmployee(employee);
                },
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final _employeeFormGlobalKey = GlobalKey<EmployeeFormState>();
                return AlertDialog(
                  title: const Text('Додати нового співробітника'),
                  content: EmployeeForm(
                    key: _employeeFormGlobalKey,
                    academicYear: universityForm1.academicYear,
                    withSubmitButton: false,
                    onSubmit: (employee) {
                      onAddEmployee(employee);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Скасувати'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _employeeFormGlobalKey.currentState?.submitForm();
                        if (_employeeFormGlobalKey
                            .currentState!
                            .formKey
                            .currentState!
                            .validate()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Підтвердити'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Додати співробітника'),
        ),
        Expanded(
          child: DefaultTabController(
            length: universityForm3.employees.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs:
                      universityForm3.employees.map((employee) {
                        return Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(employee.lastName),
                              IconButton(
                                iconSize: 18.0,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Підтвердження'),
                                        content: Text(
                                          'Ви впевнені, що хочете видалити співробітника ${employee.fullName}?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Скасувати'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              onRemoveEmployee(employee);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Видалити'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: universityForm3.employees.map((employee) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...employee.rates.map((rate) {
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${employee.lastName} ${employee.firstName} ${employee.patronymic} | Ставка: ${rate.rateValue}',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                              Text(
                                                '${employee.rank.displayName} • ${rate.dateStart.toDefaultString()} - ${rate.dateEnd.toDefaultString()} • Аспірантів: ${rate.postgraduateCount}',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          tooltip: 'Видалити ставку',
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Видалити ставку?'),
                                                content: const Text('Ви впевнені, що хочете видалити цю ставку та все навантаження на ній?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Скасувати'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      onRemoveRate(employee, rate);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Видалити', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildSemesterBlock(
                                    context: context,
                                    title: 'I семестр',
                                    semester: AcademicSemester.first,
                                    rate: rate,
                                    employee: employee,
                                  ),
                                  _buildSemesterBlock(
                                    context: context,
                                    title: 'II семестр',
                                    semester: AcademicSemester.second,
                                    rate: rate,
                                    employee: employee,
                                  ),
                                ],
                              );
                            }).toList(),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      final rateFormKey = GlobalKey<RateFormState>();
                                      return AlertDialog(
                                        title: const Text('Додати ставку'),
                                        content: RateForm(
                                          key: rateFormKey,
                                          academicYear: universityForm1.academicYear,
                                          onSubmit: (rateValue, dateStart, dateEnd, postgraduateCount) {
                                            onCreateRate(employee.id, rateValue, dateStart, dateEnd, postgraduateCount);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Скасувати'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              rateFormKey.currentState?.submitForm();
                                            },
                                            child: const Text('Додати'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Додати ставку'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterBlock({
    required BuildContext context,
    required String title,
    required AcademicSemester semester,
    required EmployeeRate rate,
    required Employee employee,
  }) {
    final semesterItems = rate.workloadItems.where((item) => item.workloadKey.semester == semester).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            if (semesterItems.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Навантаження не розподілено'),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 160,
                  columns: const [
                    DataColumn(label: Text('Назва дисципліни')),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Форма навчання'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Спеціальність'))),
                    DataColumn(label: Text('Групи')),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Курс'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Контингент'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Лекції'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Практичні'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Лабораторні'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Екзамени'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Консультації перед екз.'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Заліки'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Кваліфікаційні роботи'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Атестаційні екзамени'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Виробнича практика'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Навчальна практика'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Поточні консультації'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Індивідуальні завдання'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Курсові роботи'))),
                    DataColumn(label: RotatedBox(quarterTurns: -1, child: Text('Аспірантські екзамени'))),
                    DataColumn(label: Text('Дії')),
                  ],
                  rows: semesterItems.map((workloadItem) {
                    return buildForm3DataRowEdit(
                      context: context,
                      workloadItem: workloadItem,
                      onUpdateField: (field, value) => onUpdateField(employee.id, rate.id, workloadItem.id, field, value),
                      onUpdateGroups: (groups) => onUpdateGroups(employee.id, rate.id, workloadItem.id, groups),
                      onDelete: (itemToDelete) => onDeleteItem(employee.id, rate.id, itemToDelete.id),
                      project: project,
                      hintNotifier: hintNotifier,
                    );
                  }).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddWorkloadItemDialog(
                      universityForm1: universityForm1,
                      universityForm3: universityForm3,
                      onAdd: (newItem) async {
                        await onAddItem(employee.id, rate.id, newItem);
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Додати навантаження'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DataRow buildForm3DataRowView(
  UniversityForm1 universityForm1,
  UniversityForm3WorkloadItem workloadItem,
) {
  return DataRow(
    color:
        workloadItem.workloadKey.semester == AcademicSemester.first
            ? WidgetStateProperty.all(Colors.grey[100])
            : WidgetStateProperty.all(Colors.grey[200]),
    cells: [
      DataCell(Text(workloadItem.workloadKey.disciplineName)),
      DataCell(Text(workloadItem.workloadKey.learningForm.shortDisplayName)),
      DataCell(Text(workloadItem.workloadKey.specialty)),
      DataCell(Text(workloadItem.academicGroups.join(", "))),
      DataCell(Text(workloadItem.workloadKey.course)),
      DataCell(Text(workloadItem.studentCount.toString())),
      DataCell(Text(workloadItem.lectures.toString())),
      DataCell(Text(workloadItem.practices.toString())),
      DataCell(Text(workloadItem.labs.toString())),
      DataCell(Text(workloadItem.exams.toString())),
      DataCell(Text(workloadItem.examConsults.toString())),
      DataCell(Text(workloadItem.tests.toString())),
      DataCell(Text(workloadItem.qualificationWorks.toString())),
      DataCell(Text(workloadItem.certificationExams.toString())),
      DataCell(Text(workloadItem.productionPractices.toString())),
      DataCell(Text(workloadItem.teachingPractices.toString())),
      DataCell(Text(workloadItem.currentConsults.toString())),
      DataCell(Text(workloadItem.individualWorks.toString())),
      DataCell(Text(workloadItem.courseWorks.toString())),
      DataCell(Text(workloadItem.postgraduateExams.toString())),
    ],
  );
}

DataRow buildForm3DataRowEdit({
  required BuildContext context,
  required UniversityForm3WorkloadItem workloadItem,
  required Future<void> Function(WorkloadField, double) onUpdateField,
  required void Function(List<String>) onUpdateGroups,
  required void Function(UniversityForm3WorkloadItem) onDelete,
  required WorkloadDistributionProject project,
  required ValueNotifier<String?> hintNotifier,
}) {
  final academicGroupsController = TextEditingController(
    text: workloadItem.academicGroups.join(", "),
  );
  final studentCountController = TextEditingController(
    text: workloadItem.studentCount.toString(),
  );
  String formatNumber(num value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  final lecturesController = TextEditingController(
    text: formatNumber(workloadItem.lectures),
  );
  final practicesController = TextEditingController(
    text: formatNumber(workloadItem.practices),
  );
  final labsController = TextEditingController(
    text: formatNumber(workloadItem.labs),
  );
  final examsController = TextEditingController(
    text: formatNumber(workloadItem.exams),
  );
  final examConsultsController = TextEditingController(
    text: formatNumber(workloadItem.examConsults),
  );
  final testsController = TextEditingController(
    text: formatNumber(workloadItem.tests),
  );
  final qualificationWorksController = TextEditingController(
    text: formatNumber(workloadItem.qualificationWorks),
  );
  final certificationExamsController = TextEditingController(
    text: formatNumber(workloadItem.certificationExams),
  );
  final productionPracticesController = TextEditingController(
    text: formatNumber(workloadItem.productionPractices),
  );
  final teachingPracticesController = TextEditingController(
    text: formatNumber(workloadItem.teachingPractices),
  );
  final currentConsultsController = TextEditingController(
    text: formatNumber(workloadItem.currentConsults),
  );
  final individualWorksController = TextEditingController(
    text: formatNumber(workloadItem.individualWorks),
  );
  final courseWorksController = TextEditingController(
    text: formatNumber(workloadItem.courseWorks),
  );
  final postgraduateExamsController = TextEditingController(
    text: formatNumber(workloadItem.postgraduateExams),
  );


  double parseNonNegativeDouble(String text, double fallback) {
    final value = double.tryParse(text);
    return (value != null && value >= 0) ? value : fallback;
  }

  void handleGroupsChange(List<String> newGroups) {
    onUpdateGroups(newGroups);
  }

   Future<void> handleFieldChange(WorkloadField field, double newValue) async {
     await onUpdateField(field, newValue);
   }

  DataCell _editableCell({
    required TextEditingController controller,
    bool numeric = false,
    bool isInteger = false,
    bool allowNegative = false,
    VoidCallback? onTap,
    bool readOnly = false,
    String? fieldName,
    WorkloadField? field,
    bool enableHint = false,
  }) {
    return DataCell(
      _EditableWorkloadCell(
        controller: controller,
        numeric: numeric,
        isInteger: isInteger,
        allowNegative: allowNegative,
        onTap: onTap,
        readOnly: readOnly,
        fieldName: fieldName,
        field: field,
        enableHint: enableHint,
        project: project,
        hintNotifier: hintNotifier,
        workloadItem: workloadItem,
        onEditingComplete: () {
          if (field != null) {
            handleFieldChange(
              field,
              numeric
                  ? parseNonNegativeDouble(controller.text, workloadItem.getFieldValue(field))
                  : 0.0,
            );
          }
        },
      ),
    );
  }

  return DataRow(
    color:
        workloadItem.workloadKey.semester == AcademicSemester.first
            ? WidgetStateProperty.all(Colors.grey[100])
            : WidgetStateProperty.all(Colors.grey[200]),
    cells: [
      DataCell(Text(workloadItem.workloadKey.disciplineName)),
      DataCell(Text(workloadItem.workloadKey.learningForm.shortDisplayName)),
      DataCell(Text(workloadItem.workloadKey.specialty)),
      DataCell(
        TextField(
          readOnly: true,
          controller: academicGroupsController,
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => GroupEditorDialog(
                    initialGroups: workloadItem.academicGroups,
                    onSave: (newGroups) {
                      academicGroupsController.text = newGroups.join(", ");
                      handleGroupsChange(newGroups);
                    },
                  ),
            );
          },
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
      DataCell(Text(workloadItem.workloadKey.course)),
      _editableCell(
        controller: studentCountController,
        numeric: true,
        isInteger: true,
        fieldName: 'Студенти',
        field: WorkloadField.studentCount,
      ),
      _editableCell(
        controller: lecturesController,
        numeric: true,
        fieldName: 'Лекції',
        field: WorkloadField.lectures,
      ),
      _editableCell(
        controller: practicesController,
        numeric: true,
        fieldName: 'Практичні',
        field: WorkloadField.practices,
      ),
      _editableCell(
        controller: labsController,
        numeric: true,
        fieldName: 'Лабораторні',
        field: WorkloadField.labs,
        enableHint: true,
      ),
      _editableCell(
        controller: examsController,
        numeric: true,
        fieldName: 'Екзамени',
        field: WorkloadField.exams,
      ),
      _editableCell(
        controller: examConsultsController,
        numeric: true,
        fieldName: 'Конс. перед екз.',
        field: WorkloadField.examConsults,
      ),
      _editableCell(
        controller: testsController,
        numeric: true,
        fieldName: 'Заліки',
        field: WorkloadField.tests,
      ),
      _editableCell(
        controller: qualificationWorksController,
        numeric: true,
        fieldName: 'Квал. роботи',
        field: WorkloadField.qualificationWorks,
      ),
      _editableCell(
        controller: certificationExamsController,
        numeric: true,
        fieldName: 'Атестац. екз.',
        field: WorkloadField.certificationExams,
      ),
      _editableCell(
        controller: productionPracticesController,
        numeric: true,
        fieldName: 'Вироб. практ.',
        field: WorkloadField.productionPractices,
      ),
      _editableCell(
        controller: teachingPracticesController,
        numeric: true,
        fieldName: 'Навч. практ.',
        field: WorkloadField.teachingPractices,
      ),
      _editableCell(
        controller: currentConsultsController,
        numeric: true,
        fieldName: 'Пот. конс.',
        field: WorkloadField.currentConsults,
        enableHint: true,
      ),
      _editableCell(
        controller: individualWorksController,
        numeric: true,
        fieldName: 'Інд. завд.',
        field: WorkloadField.individualWorks,
      ),
      _editableCell(
        controller: courseWorksController,
        numeric: true,
        fieldName: 'Курс. роботи',
        field: WorkloadField.courseWorks,
        enableHint: true,
      ),
      _editableCell(
        controller: postgraduateExamsController,
        numeric: true,
        fieldName: 'Асп. екз.',
        field: WorkloadField.postgraduateExams,
      ),
      DataCell(
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => onDelete(workloadItem),
        ),
      ),
    ],
  );
}

class _EditableWorkloadCell extends StatefulWidget {
  final TextEditingController controller;
  final bool numeric;
  final bool isInteger;
  final bool allowNegative;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? fieldName;
  final WorkloadField? field;
  final bool enableHint;
  final WorkloadDistributionProject project;
  final ValueNotifier<String?> hintNotifier;
  final UniversityForm3WorkloadItem workloadItem;
  final VoidCallback onEditingComplete;

  const _EditableWorkloadCell({
    required this.controller,
    this.numeric = false,
    this.isInteger = false,
    this.allowNegative = false,
    this.onTap,
    this.readOnly = false,
    this.fieldName,
    this.field,
    this.enableHint = false,
    required this.project,
    required this.hintNotifier,
    required this.workloadItem,
    required this.onEditingComplete,
  });

  @override
  State<_EditableWorkloadCell> createState() => _EditableWorkloadCellState();
}

class _EditableWorkloadCellState extends State<_EditableWorkloadCell> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _clearHintIfMine();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _EditableWorkloadCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode.hasFocus) {
      _updateHint();
    } else {
      _clearHintIfMine();
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _updateHint();
    } else {
      _clearHintIfMine();
    }
  }

  void _clearHintIfMine() {
    if (widget.hintNotifier.value?.startsWith("${widget.fieldName}:") ??
        false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Re-check in case another field gained focus in the meantime
        if (widget.hintNotifier.value?.startsWith("${widget.fieldName}:") ??
            false) {
          widget.hintNotifier.value = null;
        }
      });
    }
  }

  String _formatNumber(num value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  void _updateHint() {
    if (!widget.enableHint ||
        widget.fieldName == null ||
        widget.field == null) {
      return;
    }

    final totalHours = widget.project.getTotalWorkload(
      widget.workloadItem.workloadKey,
      widget.field!,
    );
    final undistributed = widget.project.getUndistributedWorkload(
      widget.workloadItem.workloadKey,
      widget.field!,
    );

    final currentValue =
        double.tryParse(widget.controller.text.replaceAll(',', '.')) ?? 0.0;
    final oldValueInForm = widget.workloadItem.getFieldValue(widget.field!);

    final remainingHours = undistributed + oldValueInForm - currentValue;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNode.hasFocus) {
        widget.hintNotifier.value =
            '${widget.fieldName}: ${_formatNumber(remainingHours)} / ${_formatNumber(totalHours)} год. залишилось';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      controller: widget.controller,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onChanged: (_) => _updateHint(),
      keyboardType:
          widget.numeric
              ? TextInputType.numberWithOptions(
                decimal: !widget.isInteger,
                signed: widget.allowNegative,
              )
              : TextInputType.text,
      decoration: const InputDecoration(border: InputBorder.none),
      onEditingComplete: () {
        _focusNode.unfocus();
        widget.onEditingComplete();
      },
      onTapOutside: (_) {
        _focusNode.unfocus();
        widget.onEditingComplete();
      },
    );
  }
}
