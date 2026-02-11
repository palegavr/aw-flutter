import 'package:aw_flutter/features/workload_distribution/domain/models/workload_project.dart';
import 'package:aw_flutter/features/workload_distribution/presentation/view/widgets/employee_rate_form.dart';
import 'package:flutter/material.dart';

class EmployeeForm extends StatefulWidget {
  final void Function(EmployeeFormData data) onSubmit;
  final bool withSubmitButton;
  final int academicYear;
  final EmployeeFormData? initialData;
  final bool showRateForm;

  const EmployeeForm({
    super.key,
    required this.onSubmit,
    required this.academicYear,
    this.withSubmitButton = true,
    this.initialData,
    this.showRateForm = true,
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
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _firstNameController.text = data.firstName;
      _lastNameController.text = data.lastName;
      _patronymicController.text = data.patronymic;
      _selectedRank = data.rank;

      if (data.rateData != null) {
        final rate = data.rateData!;
        _rateValueController.text = rate.rateValue.toString();
        _postgraduateCountController.text = rate.postgraduateCount.toString();
        _dateStart = rate.dateStart;
        _dateEnd = rate.dateEnd;
        _isFullTime =
            (rate.rateValue == 1.0 &&
                rate.dateStart == DateTime(widget.academicYear, 9, 1) &&
                rate.dateEnd == DateTime(widget.academicYear + 1, 6, 30));
      } else {
        _setDefaultRateValues();
      }
    } else {
      _setDefaultRateValues();
      _firstNameController.text = '';
      _lastNameController.text = '';
      _patronymicController.text = '';
    }
  }

  void _setDefaultRateValues() {
    _rateValueController.text = '1.0';
    _postgraduateCountController.text = '0';
    _dateStart = DateTime(widget.academicYear, 9, 1);
    _dateEnd = DateTime(widget.academicYear + 1, 6, 30);
    _isFullTime = true;
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
      EmployeeRateFormData? rateData;

      if (widget.showRateForm) {
        double rateValue;
        DateTime dateStart;
        DateTime dateEnd;

        if (_isFullTime) {
          rateValue = 1.0;
          dateStart = DateTime(widget.academicYear, 9, 1);
          dateEnd = DateTime(widget.academicYear + 1, 6, 30);
        } else {
          if (_dateStart == null || _dateEnd == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Будь ласка, оберіть дати')),
            );
            return;
          }
          rateValue = double.parse(_rateValueController.text);
          dateStart = _dateStart!;
          dateEnd = _dateEnd!;
        }

        rateData = EmployeeRateFormData(
          rateValue: rateValue,
          dateStart: dateStart,
          dateEnd: dateEnd,
          postgraduateCount: int.parse(_postgraduateCountController.text),
        );
      }

      widget.onSubmit(
        EmployeeFormData(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          patronymic: _patronymicController.text,
          rank: _selectedRank!,
          rateData: rateData,
        ),
      );
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
            if (widget.showRateForm) ...[
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
            ],
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

class EmployeeFormData {
  final String firstName;
  final String lastName;
  final String patronymic;
  final EmployeeRank rank;
  final EmployeeRateFormData? rateData;

  EmployeeFormData({
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.rank,
    this.rateData,
  });

  factory EmployeeFormData.fromEmployee(Employee employee) {
    return EmployeeFormData(
      firstName: employee.firstName,
      lastName: employee.lastName,
      patronymic: employee.patronymic,
      rank: employee.rank,
      rateData: employee.rates.isNotEmpty
          ? EmployeeRateFormData(
              rateValue: employee.rates.first.rateValue,
              dateStart: employee.rates.first.dateStart,
              dateEnd: employee.rates.first.dateEnd,
              postgraduateCount: employee.rates.first.postgraduateCount,
            )
          : null,
    );
  }
}
