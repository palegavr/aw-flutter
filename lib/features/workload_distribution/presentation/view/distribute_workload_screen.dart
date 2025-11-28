import 'package:aw_flutter/features/workload_distribution/application/workload_distribution_project_service.dart';
import 'package:aw_flutter/features/workload_distribution/data/dtos/academic_semester.dart';
import 'package:aw_flutter/features/workload_distribution/data/dtos/learning_form.dart';
import 'package:aw_flutter/features/workload_distribution/data/dtos/workload_project.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/add_workload_item_dialog.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/widgets/employee_form.dart';
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

  late WorkloadDistributionProjectDto _project;
  bool _projectLoaded = false;
  DisplayMode _displayMode = DisplayMode.form1;

  bool _projectTitleEditing = false;
  final TextEditingController _editProjectTitleFieldTextEditingController =
      TextEditingController();
  final FocusNode _editProjectTitleFieldFocusNode = FocusNode();

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
    final WorkloadDistributionProjectDto project =
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

  void _setUniversityForm3(UniversityForm3Dto form3) async {
    _project.universityForm3 = form3;
    await _workloadDistributionProjectService.update(_project);
    await _refreshProject();
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
                                      UniversityForm1Dto.fromParsedExcelFile(
                                        file: parsedFile,
                                        sheetName: selectedSheet!,
                                        academicYear:
                                            _project
                                                .universityForm1
                                                .academicYear,
                                      );

                                  _project.universityForm1 = newForm1;
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
                                universityForm1: _project.universityForm1,
                                universityForm3: _project.universityForm3,
                                onChange: (
                                  UniversityForm3Dto newUniversityForm3,
                                ) {
                                  _setUniversityForm3(newUniversityForm3);
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
  final UniversityForm1Dto universityForm1;

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
  final UniversityForm1Dto universityForm1;
  final UniversityForm3Dto universityForm3;

  final void Function(UniversityForm3Dto) onChange;

  _Form3Editor({
    super.key,
    required this.universityForm3,
    required this.onChange,
    required this.universityForm1,
  });

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
                  universityForm3.addEmployee(employee);
                  onChange(universityForm3);
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
                      universityForm3.addEmployee(employee);
                      onChange(universityForm3);
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
                                              universityForm3.employees.remove(
                                                employee,
                                              );
                                              onChange(universityForm3);
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
                    children:
                        universityForm3.employees.map((employee) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children:
                                    employee.rates.map((rate) {
                                      final sortedBySemesterWorkloadItems =
                                          List.of(rate.workloadItems)..sort(
                                            (a, b) => a.workloadKey.semester
                                                .compareTo(
                                                  b.workloadKey.semester,
                                                ),
                                          );
                                      Widget cardForSemester(
                                        AcademicSemester semester,
                                      ) {
                                        return Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 250,
                                                    child: Text(
                                                      '${employee.lastName} | ${rate.rateValue}\n${employee.firstName}\n${employee.patronymic}\n${employee.rank.displayName}\nЗ: ${rate.dateStart.toDefaultString()}\nПо: ${rate.dateEnd.toDefaultString()}\nКількість аспірантів: ${rate.postgraduateCount}',
                                                    ),
                                                  ),
                                                  DataTable(
                                                    headingRowHeight: 230,
                                                    columns: const [
                                                      DataColumn(
                                                        label: Text(
                                                          'Назва дисципліни',
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Форма навчання',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Спеціальність',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text('Групи'),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text('Курс'),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Контингент',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text('Лекції'),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Практичні (семінарські)',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Лабораторні',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Екзамени',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Консультації перед екзаменом',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text('Заліки'),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Кваліфікаційні роботи (проєкти)',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Атестаційні екзамени',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Виробнича практика',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Навчальна практика',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Поточні консультації',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Індивідуальні завдання',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Курсові роботи (проєкти)',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Text(
                                                            'Проведення аспірантських екзаменів',
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text('Дії'),
                                                      ),
                                                    ],
                                                    rows:
                                                        sortedBySemesterWorkloadItems.map((
                                                          workloadItem,
                                                        ) {
                                                          return buildForm3DataRowEdit(
                                                            workloadItem:
                                                                workloadItem,
                                                            onUpdate: () {
                                                              onChange(
                                                                universityForm3,
                                                              );
                                                            },
                                                            onDelete: (
                                                              itemToDelete,
                                                            ) {
                                                              rate.workloadItems
                                                                  .remove(
                                                                    itemToDelete,
                                                                  );
                                                              onChange(
                                                                universityForm3,
                                                              );
                                                            },
                                                            form1:
                                                                universityForm1,
                                                          );
                                                        }).toList(),
                                                  ),
                                                ],
                                              ),
                                              FloatingActionButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AddWorkloadItemDialog(
                                                          universityForm1:
                                                              universityForm1,
                                                          universityForm3:
                                                              universityForm3,
                                                          onAdd: (newItem) {
                                                            universityForm3
                                                                .addWorkloadItem(
                                                                  rate,
                                                                  newItem,
                                                                );
                                                            onChange(
                                                              universityForm3,
                                                            );
                                                          },
                                                        ),
                                                  );
                                                },
                                                child: const Icon(Icons.add),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return cardForSemester(
                                        AcademicSemester.first,
                                      );
                                    }).toList(),
                              ),
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
}

DataRow buildForm3DataRowView(
  UniversityForm1Dto universityForm1,
  UniversityForm3WorkloadItemDto workloadItem,
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
  required UniversityForm3WorkloadItemDto workloadItem,
  required VoidCallback onUpdate,
  required void Function(UniversityForm3WorkloadItemDto) onDelete,
  required UniversityForm1Dto form1,
}) {
  final courseController = TextEditingController(
    text: workloadItem.workloadKey.course,
  );
  final academicGroupsController = TextEditingController(
    text: workloadItem.academicGroups.join(", "),
  );
  final studentCountController = TextEditingController(
    text: workloadItem.studentCount.toString(),
  );
  final lecturesController = TextEditingController(
    text: workloadItem.lectures.toString(),
  );
  final practicesController = TextEditingController(
    text: workloadItem.practices.toString(),
  );
  final labsController = TextEditingController(
    text: workloadItem.labs.toString(),
  );
  final examsController = TextEditingController(
    text: workloadItem.exams.toString(),
  );
  final examConsultsController = TextEditingController(
    text: workloadItem.examConsults.toString(),
  );
  final testsController = TextEditingController(
    text: workloadItem.tests.toString(),
  );
  final qualificationWorksController = TextEditingController(
    text: workloadItem.qualificationWorks.toString(),
  );
  final certificationExamsController = TextEditingController(
    text: workloadItem.certificationExams.toString(),
  );
  final productionPracticesController = TextEditingController(
    text: workloadItem.productionPractices.toString(),
  );
  final teachingPracticesController = TextEditingController(
    text: workloadItem.teachingPractices.toString(),
  );
  final currentConsultsController = TextEditingController(
    text: workloadItem.currentConsults.toString(),
  );
  final individualWorksController = TextEditingController(
    text: workloadItem.individualWorks.toString(),
  );
  final courseWorksController = TextEditingController(
    text: workloadItem.courseWorks.toString(),
  );
  final postgraduateExamsController = TextEditingController(
    text: workloadItem.postgraduateExams.toString(),
  );

  void handleChange() {
    workloadItem.workloadKey.course = courseController.text;
    workloadItem.academicGroups =
        academicGroupsController.text.split(",").map((e) => e.trim()).toList();
    workloadItem.studentCount =
        int.tryParse(studentCountController.text) ?? workloadItem.studentCount;
    workloadItem.lectures =
        double.tryParse(lecturesController.text) ?? workloadItem.lectures;
    workloadItem.practices =
        double.tryParse(practicesController.text) ?? workloadItem.practices;
    workloadItem.labs =
        double.tryParse(labsController.text) ?? workloadItem.labs;
    workloadItem.exams =
        double.tryParse(examsController.text) ?? workloadItem.exams;
    workloadItem.examConsults =
        double.tryParse(examConsultsController.text) ??
        workloadItem.examConsults;
    workloadItem.tests =
        double.tryParse(testsController.text) ?? workloadItem.tests;
    workloadItem.qualificationWorks =
        double.tryParse(qualificationWorksController.text) ??
        workloadItem.qualificationWorks;
    workloadItem.certificationExams =
        double.tryParse(certificationExamsController.text) ??
        workloadItem.certificationExams;
    workloadItem.productionPractices =
        double.tryParse(productionPracticesController.text) ??
        workloadItem.productionPractices;
    workloadItem.teachingPractices =
        double.tryParse(teachingPracticesController.text) ??
        workloadItem.teachingPractices;
    workloadItem.currentConsults =
        double.tryParse(currentConsultsController.text) ??
        workloadItem.currentConsults;
    workloadItem.individualWorks =
        double.tryParse(individualWorksController.text) ??
        workloadItem.individualWorks;
    workloadItem.courseWorks =
        double.tryParse(courseWorksController.text) ?? workloadItem.courseWorks;
    workloadItem.postgraduateExams =
        double.tryParse(postgraduateExamsController.text) ??
        workloadItem.postgraduateExams;

    onUpdate();
  }

  DataCell editableCell(
    TextEditingController controller, {
    bool numeric = false,
  }) {
    return DataCell(
      TextField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (_) => handleChange(),
      ),
    );
  }

  DataCell learningFormCell() {
    var items =
        form1.workloadItems
            .where(
              (e) =>
                  e.workloadKey.disciplineName ==
                  workloadItem.workloadKey.disciplineName,
            )
            .map((e) => e.workloadKey.learningForm)
            .toSet()
            .toList();

    return DataCell(
      DropdownButton<LearningForm>(
        value: workloadItem.workloadKey.learningForm,
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.shortDisplayName),
                  ),
                )
                .toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            workloadItem.workloadKey.learningForm = newValue;
            workloadItem.workloadKey.specialty = '';
            onUpdate();
          }
        },
        underline: const SizedBox(),
      ),
    );
  }

  DataCell disciplineNameCell() {
    var items =
        form1.workloadItems
            .map((e) => e.workloadKey.disciplineName)
            .toSet()
            .toList();
    return DataCell(
      DropdownButton<String>(
        value:
            items.contains(workloadItem.workloadKey.disciplineName)
                ? workloadItem.workloadKey.disciplineName
                : null,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            workloadItem.workloadKey.disciplineName = newValue;
            workloadItem.workloadKey.learningForm = LearningForm.daytime;
            workloadItem.workloadKey.specialty = '';
            onUpdate();
          }
        },
        underline: const SizedBox(),
      ),
    );
  }

  DataCell specialityCell() {
    var items =
        form1.workloadItems
            .where(
              (e) =>
                  e.workloadKey.disciplineName ==
                  workloadItem.workloadKey.disciplineName,
            )
            .where(
              (e) =>
                  e.workloadKey.learningForm ==
                  workloadItem.workloadKey.learningForm,
            )
            .map((e) => e.workloadKey.specialty)
            .toSet()
            .toList();

    return DataCell(
      DropdownButton<String>(
        value:
            items.contains(workloadItem.workloadKey.specialty)
                ? workloadItem.workloadKey.specialty
                : null,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            workloadItem.workloadKey.specialty = newValue;
            onUpdate();
          }
        },
        underline: const SizedBox(),
      ),
    );
  }

  return DataRow(
    color:
        workloadItem.workloadKey.semester == AcademicSemester.first
            ? MaterialStateProperty.all(Colors.grey[100])
            : MaterialStateProperty.all(Colors.grey[200]),
    cells: [
      disciplineNameCell(),
      learningFormCell(),
      specialityCell(),
      editableCell(academicGroupsController),
      editableCell(courseController),
      editableCell(studentCountController, numeric: true),
      editableCell(lecturesController, numeric: true),
      editableCell(practicesController, numeric: true),
      editableCell(labsController, numeric: true),
      editableCell(examsController, numeric: true),
      editableCell(examConsultsController, numeric: true),
      editableCell(testsController, numeric: true),
      editableCell(qualificationWorksController, numeric: true),
      editableCell(certificationExamsController, numeric: true),
      editableCell(productionPracticesController, numeric: true),
      editableCell(teachingPracticesController, numeric: true),
      editableCell(currentConsultsController, numeric: true),
      editableCell(individualWorksController, numeric: true),
      editableCell(courseWorksController, numeric: true),
      editableCell(postgraduateExamsController, numeric: true),
      DataCell(
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => onDelete(workloadItem),
        ),
      ),
    ],
  );
}
