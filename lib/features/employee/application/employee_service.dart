import 'package:aw_flutter/features/employee/data/dtos/employee.dart';

class EmployeeService {
  final List<EmployeeDto> mockEmployees = [
    EmployeeDto(
      id: 'emp-001',
      firstName: 'Ivan',
      patronymic: 'Petrovych',
      lastName: 'Shevchenko',
      rank: EmployeeRank.professor,
      rates: [
        EmployeeRateDto(
          rate: 1.0,
          dateStart: DateTime(2020, 9, 1),
          dateEnd: DateTime(2023, 8, 31),
        ),
      ],
    ),
    EmployeeDto(
      id: 'emp-002',
      firstName: 'Olena',
      patronymic: 'Andriyivna',
      lastName: 'Kovalchuk',
      rank: EmployeeRank.lecturer,
      rates: [
        EmployeeRateDto(
          rate: 0.75,
          dateStart: DateTime(2021, 2, 15),
          dateEnd: DateTime(2022, 12, 31),
        ),
        EmployeeRateDto(
          rate: 1.0,
          dateStart: DateTime(2023, 1, 1),
          dateEnd: DateTime(2024, 12, 31),
        ),
      ],
    ),
    EmployeeDto(
      id: 'emp-003',
      firstName: 'Taras',
      patronymic: 'Mykolayovych',
      lastName: 'Melnyk',
      rank: EmployeeRank.associate,
      rates: [
        EmployeeRateDto(
          rate: 0.5,
          dateStart: DateTime(2019, 5, 1),
          dateEnd: DateTime(2020, 5, 1),
        ),
        EmployeeRateDto(
          rate: 0.75,
          dateStart: DateTime(2020, 5, 2),
          dateEnd: DateTime(2022, 5, 1),
        ),
        EmployeeRateDto(
          rate: 1.0,
          dateStart: DateTime(2022, 5, 2),
          dateEnd: DateTime(2025, 5, 1),
        ),
      ],
    ),
    EmployeeDto(
      id: 'emp-004',
      firstName: 'Nadiia',
      patronymic: 'Volodymyrivna',
      lastName: 'Tkachenko',
      rank: EmployeeRank.assistant,
      rates: [
        EmployeeRateDto(
          rate: 0.5,
          dateStart: DateTime(2022, 1, 10),
          dateEnd: DateTime(2023, 1, 9),
        ),
      ],
    ),
    EmployeeDto(
      id: 'emp-005',
      firstName: 'Yurii',
      patronymic: 'Stepanovych',
      lastName: 'Bondarenko',
      rank: EmployeeRank.head,
      rates: [
        EmployeeRateDto(
          rate: 1.0,
          dateStart: DateTime(2018, 9, 1),
          dateEnd: DateTime(2025, 8, 31),
        ),
      ],
    ),
  ];

  void createEmployee() async {
    // todo
    throw UnimplementedError();
  }

  Future<List<EmployeeDto>> getEmployees() async {
    return mockEmployees;
  }
}
