import 'package:flutter/material.dart';

class RateForm extends StatefulWidget {
  final int academicYear;
  final void Function(double rateValue, DateTime dateStart, DateTime dateEnd, int postgraduateCount) onSubmit;

  const RateForm({
    super.key,
    required this.academicYear,
    required this.onSubmit,
  });

  @override
  State<RateForm> createState() => RateFormState();
}

class RateFormState extends State<RateForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _rateValueController = TextEditingController();
  final TextEditingController _postgraduateCountController = TextEditingController();
  DateTime? _dateStart;
  DateTime? _dateEnd;

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
    _rateValueController.dispose();
    _postgraduateCountController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        double.parse(_rateValueController.text),
        _dateStart!,
        _dateEnd!,
        int.parse(_postgraduateCountController.text),
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
