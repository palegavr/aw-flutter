enum EmployeeRank { head, professor, associate, lecturer, assistant }

class EmployeeDto {
  final String id;
  final String firstName;
  final String lastName;
  final String patronymic;
  final EmployeeRank rank;
  final List<EmployeeRateDto> rates;

  EmployeeDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.rank,
    required this.rates,
  });
}

class EmployeeRateDto {
  final double rate; // Ставка, обычно 1.00

  // Если сотрудник работает по данной ставке С определенной даты
  final DateTime dateStart;

  // Если сотрудник работает по данной ставке ДО определенной даты
  final DateTime dateEnd;

  EmployeeRateDto({
    required this.rate,
    required this.dateStart,
    required this.dateEnd,
  });
}
