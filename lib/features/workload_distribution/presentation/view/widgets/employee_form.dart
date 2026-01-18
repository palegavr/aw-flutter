import 'package:aw_flutter/features/workload_distribution/domain/models/workload_project.dart';
import 'package:flutter/material.dart';

class EmployeeForm extends StatefulWidget {
  final void Function(Employee) onSubmit;
  final bool withSubmitButton;
  final int academicYear;

  const EmployeeForm({
    super.key,
    required this.onSubmit,
    required this.academicYear,
    this.withSubmitButton = true,
  });

  @override
  State<EmployeeForm> createState() => EmployeeFormState();
}

class EmployeeFormState extends State<EmployeeForm> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _patronymicController = TextEditingController();
  EmployeeRank? _selectedRank;
  final TextEditingController _rateValueController = TextEditingController();
  DateTime? _dateStart;
  DateTime? _dateEnd;
  final TextEditingController _postgraduateCountController =
      TextEditingController();
  bool _isFullTime = true;

  @override
  void initState() {
    super.initState();
    _rateValueController.text = '1.0';
    _postgraduateCountController.text = '0';
    _dateStart = DateTime(widget.academicYear, 9, 1);
    _dateEnd = DateTime(widget.academicYear + 1, 6, 30);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _patronymicController.dispose();
    _rateValueController.dispose();
    _postgraduateCountController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (formKey.currentState!.validate()) {
      double rateValue;
      DateTime dateStart;
      DateTime dateEnd;

      if (_isFullTime) {
        rateValue = 1.0;
        dateStart = DateTime(widget.academicYear, 9, 1);
        dateEnd = DateTime(widget.academicYear + 1, 6, 30);
      } else {
        if (_dateStart == null || _dateEnd == null) {
          // This case should ideally be caught by validators, but for safety:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Будь ласка, оберіть дати')),
          );
          return;
        }
        rateValue = double.parse(_rateValueController.text);
        dateStart = _dateStart!;
        dateEnd = _dateEnd!;
      }

      final employee = Employee.create(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        patronymic: _patronymicController.text,
        rank: _selectedRank!,
        rates: [
          EmployeeRate(
            rateValue: rateValue,
            dateStart: dateStart,
            dateEnd: dateEnd,
            postgraduateCount: int.parse(_postgraduateCountController.text),
            workloadItems: [],
          ),
        ],
      );
      widget.onSubmit(employee);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _dateStart = picked;
        } else {
          _dateEnd = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Прізвище',
                hintText: 'Введіть ваше прізвище',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть прізвище';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Ім\'я',
                hintText: 'Введіть ваше ім\'я',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть ім\'я';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _patronymicController,
              decoration: const InputDecoration(
                labelText: 'По батькові',
                hintText: 'Введіть ваше по батькові (необов\'язково)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<EmployeeRank>(
              value: _selectedRank,
              decoration: const InputDecoration(
                labelText: 'Звання',
                border: OutlineInputBorder(),
              ),
              items:
                  EmployeeRank.values
                      .map(
                        (rank) => DropdownMenuItem(
                          value: rank,
                          child: Text(rank.displayName),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRank = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Будь ласка, оберіть звання';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('Повна ставка'),
              value: _isFullTime,
              onChanged: (bool value) {
                setState(() {
                  _isFullTime = value;
                });
              },
            ),
            if (!_isFullTime) ...[
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _rateValueController,
                decoration: const InputDecoration(
                  labelText: 'Ставка',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Будь ласка, введіть числове значення';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Дата початку: ${_dateStart?.toLocal().toString().split(' ')[0] ?? 'Не обрано'}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: const Text('Обрати'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Дата закінчення: ${_dateEnd?.toLocal().toString().split(' ')[0] ?? 'Не обрано'}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: const Text('Обрати'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _postgraduateCountController,
              decoration: const InputDecoration(
                labelText: 'Кількість аспірантів',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть ціле число';
                }
                final intValue = int.tryParse(value);
                if (intValue == null) {
                  return 'Будь ласка, введіть ціле число';
                }
                if (intValue < 0) {
                  return 'Кількість не може бути від\'ємною';
                }
                return null;
              },
            ),
            if (widget.withSubmitButton)
              Column(
                children: [
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        submitForm();
                      },
                      child: const Text('Підтвердити'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
