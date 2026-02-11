import 'package:flutter/material.dart';

class EmployeeRateForm extends StatefulWidget {
  final int academicYear;
  final void Function(EmployeeRateFormData data) onSubmit;
  final EmployeeRateFormData? initialData;

  const EmployeeRateForm({
    super.key,
    required this.academicYear,
    required this.onSubmit,
    this.initialData,
  });

  @override
  State<EmployeeRateForm> createState() => EmployeeRateFormState();
}

class EmployeeRateFormState extends State<EmployeeRateForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _rateValueController = TextEditingController();
  final TextEditingController _postgraduateCountController = TextEditingController();
  DateTime? _dateStart;
  DateTime? _dateEnd;

  @override
  void initState() {
    super.initState();
    _rateValueController.text = (widget.initialData?.rateValue ?? 1.0).toString();
    _postgraduateCountController.text = (widget.initialData?.postgraduateCount ?? 0).toString();
    _dateStart = widget.initialData?.dateStart ?? DateTime(widget.academicYear, 9, 1);
    _dateEnd = widget.initialData?.dateEnd ?? DateTime(widget.academicYear + 1, 6, 30);
  }

  @override
  void dispose() {
    _rateValueController.dispose();
    _postgraduateCountController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        EmployeeRateFormData(
          rateValue: double.parse(_rateValueController.text),
          dateStart: _dateStart!,
          dateEnd: _dateEnd!,
          postgraduateCount: int.parse(_postgraduateCountController.text),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_dateStart ?? DateTime.now()) : (_dateEnd ?? DateTime.now()),
      firstDate: DateTime(widget.academicYear, 8, 1),
      lastDate: DateTime(widget.academicYear + 2, 7, 31),
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
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _rateValueController,
            decoration: const InputDecoration(
              labelText: 'Ставка',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Будь ласка, введіть значення';
              }
              final rate = double.tryParse(value);
              if (rate == null) {
                return 'Будь ласка, введіть числове значення';
              }
              if (rate <= 0) {
                return 'Ставка повинна бути більше 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Початок: ${_dateStart?.toLocal().toString().split(' ')[0] ?? 'Не обрано'}',
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
                  'Кінець: ${_dateEnd?.toLocal().toString().split(' ')[0] ?? 'Не обрано'}',
                ),
              ),
              ElevatedButton(
                onPressed: () => _selectDate(context, false),
                child: const Text('Обрати'),
              ),
            ],
          ),
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
                return 'Будь ласка, введіть значення';
              }
              final count = int.tryParse(value);
              if (count == null) {
                return 'Будь ласка, введіть ціле число';
              }
              if (count < 0) {
                return 'Не може бути від\'ємною';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class EmployeeRateFormData {
  final double rateValue;
  final DateTime dateStart;
  final DateTime dateEnd;
  final int postgraduateCount;

  EmployeeRateFormData({
    required this.rateValue,
    required this.dateStart,
    required this.dateEnd,
    required this.postgraduateCount,
  });
}
