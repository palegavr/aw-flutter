import 'package:aw_flutter/features/workload_distribution/domain/models/workload_project.dart';
import 'package:aw_flutter/features/workload_distribution/domain/models/academic_semester.dart';
import 'package:aw_flutter/features/workload_distribution/domain/models/learning_form.dart';
import 'package:flutter/material.dart';

class AddWorkloadItemDialog extends StatefulWidget {
  final UniversityForm1 universityForm1;
  final UniversityForm3 universityForm3;
  final void Function(UniversityForm3WorkloadItem) onAdd;

  const AddWorkloadItemDialog({
    required this.universityForm1,
    required this.universityForm3,
    required this.onAdd,
  });

  @override
  State<AddWorkloadItemDialog> createState() => _AddWorkloadItemDialogState();
}

class _AddWorkloadItemDialogState extends State<AddWorkloadItemDialog> {
  String? _selectedDiscipline;
  LearningForm? _selectedLearningForm;
  String? _selectedSpecialty;
  String? _selectedCourse;
  AcademicSemester? _selectedSemester;

  List<UniversityForm1WorkloadItem> get _availableItems {
    return widget.universityForm1.workloadItems;
  }

  List<String> get _disciplines {
    return _availableItems
        .map((e) => e.workloadKey.disciplineName)
        .toSet()
        .toList()
      ..sort();
  }

  List<LearningForm> get _learningForms {
    if (_selectedDiscipline == null) return [];
    return _availableItems
        .where((e) => e.workloadKey.disciplineName == _selectedDiscipline)
        .map((e) => e.workloadKey.learningForm)
        .toSet()
        .toList();
  }

  List<String> get _specialties {
    if (_selectedDiscipline == null || _selectedLearningForm == null) return [];
    return _availableItems
        .where(
          (e) =>
              e.workloadKey.disciplineName == _selectedDiscipline &&
              e.workloadKey.learningForm == _selectedLearningForm,
        )
        .map((e) => e.workloadKey.specialty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _courses {
    if (_selectedDiscipline == null ||
        _selectedLearningForm == null ||
        _selectedSpecialty == null)
      return [];
    return _availableItems
        .where(
          (e) =>
              e.workloadKey.disciplineName == _selectedDiscipline &&
              e.workloadKey.learningForm == _selectedLearningForm &&
              e.workloadKey.specialty == _selectedSpecialty,
        )
        .map((e) => e.workloadKey.course)
        .toSet()
        .toList()
      ..sort();
  }

  List<AcademicSemester> get _semesters {
    if (_selectedDiscipline == null ||
        _selectedLearningForm == null ||
        _selectedSpecialty == null ||
        _selectedCourse == null)
      return [];
    return _availableItems
        .where(
          (e) =>
              e.workloadKey.disciplineName == _selectedDiscipline &&
              e.workloadKey.learningForm == _selectedLearningForm &&
              e.workloadKey.specialty == _selectedSpecialty &&
              e.workloadKey.course == _selectedCourse,
        )
        .map((e) => e.workloadKey.semester)
        .toSet()
        .toList();
  }

  bool get _isValid {
    return _selectedDiscipline != null &&
        _selectedLearningForm != null &&
        _selectedSpecialty != null &&
        _selectedCourse != null &&
        _selectedSemester != null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Додати навантаження'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDiscipline,
              decoration: const InputDecoration(labelText: 'Дисципліна'),
              items:
                  _disciplines
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDiscipline = value;
                  _selectedLearningForm = null;
                  _selectedSpecialty = null;
                  _selectedCourse = null;
                  _selectedSemester = null;
                });
              },
            ),
            DropdownButtonFormField<LearningForm>(
              value: _selectedLearningForm,
              decoration: const InputDecoration(labelText: 'Форма навчання'),
              items:
                  _learningForms
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.shortDisplayName),
                        ),
                      )
                      .toList(),
              onChanged:
                  _selectedDiscipline == null
                      ? null
                      : (value) {
                        setState(() {
                          _selectedLearningForm = value;
                          _selectedSpecialty = null;
                          _selectedCourse = null;
                          _selectedSemester = null;
                        });
                      },
            ),
            DropdownButtonFormField<String>(
              value: _selectedSpecialty,
              decoration: const InputDecoration(labelText: 'Спеціальність'),
              items:
                  _specialties
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged:
                  _selectedLearningForm == null
                      ? null
                      : (value) {
                        setState(() {
                          _selectedSpecialty = value;
                          _selectedCourse = null;
                          _selectedSemester = null;
                        });
                      },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCourse,
              decoration: const InputDecoration(labelText: 'Курс'),
              items:
                  _courses
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged:
                  _selectedSpecialty == null
                      ? null
                      : (value) {
                        setState(() {
                          _selectedCourse = value;
                          _selectedSemester = null;
                        });
                      },
            ),
            DropdownButtonFormField<AcademicSemester>(
              value: _selectedSemester,
              decoration: const InputDecoration(labelText: 'Семестр'),
              items:
                  _semesters
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toString()),
                        ),
                      )
                      .toList(),
              onChanged:
                  _selectedCourse == null
                      ? null
                      : (value) {
                        setState(() {
                          _selectedSemester = value;
                        });
                      },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        ElevatedButton(
          onPressed:
              _isValid
                  ? () {
                    final key = WorkloadKey(
                      disciplineName: _selectedDiscipline!,
                      learningForm: _selectedLearningForm!,
                      specialty: _selectedSpecialty!,
                      course: _selectedCourse!,
                      semester: _selectedSemester!,
                    );

                    // Auto-population logic
                    final form1Item = widget.universityForm1.workloadItems
                        .firstWhere((e) => e.workloadKey == key);

                    bool isUsed = false;
                    for (final emp in widget.universityForm3.employees) {
                      for (final rate in emp.rates) {
                        for (final item in rate.workloadItems) {
                          if (item.workloadKey == key) {
                            if (item.lectures > 0 ||
                                item.exams > 0 ||
                                item.tests > 0 ||
                                item.currentConsults > 0 ||
                                item.examConsults > 0) {
                              isUsed = true;
                              break;
                            }
                          }
                        }
                        if (isUsed) break;
                      }
                      if (isUsed) break;
                    }

                    final newItem = UniversityForm3WorkloadItem.empty()
                        .copyWith(
                          workloadKey: key,
                          studentCount: isUsed ? 0 : form1Item.studentCount,
                          lectures: isUsed ? 0 : form1Item.lecturesPlanned,
                          exams: isUsed ? 0 : form1Item.exams,
                          tests: isUsed ? 0 : form1Item.tests,
                          currentConsults:
                              isUsed ? 0 : form1Item.currentConsults,
                          examConsults: isUsed ? 0 : form1Item.examConsults,
                        );

                    widget.onAdd(newItem);
                    Navigator.of(context).pop();
                  }
                  : null,
          child: const Text('Додати'),
        ),
      ],
    );
  }
}
