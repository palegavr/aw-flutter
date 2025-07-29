class AcademicYearDto {
  final int startYear; // Рік початку
  final int endYear; // Рік кінця, зазвичай на 1 більше року початку

  const AcademicYearDto._({required this.startYear, required this.endYear});

  /// Створює навчальний рік із року початку (напр., 2024 → 2024–2025)
  factory AcademicYearDto.fromStartYear(int startYear) {
    return AcademicYearDto._(startYear: startYear, endYear: startYear + 1);
  }

  /// Створює навчальний рік із року кінця (напр., 2025 → 2024–2025)
  factory AcademicYearDto.fromEndYear(int endYear) {
    return AcademicYearDto._(startYear: endYear - 1, endYear: endYear);
  }

  @override
  String toString() => '$startYear–$endYear';
}
