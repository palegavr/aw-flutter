class AbsoluteSemester {
  final int semesterNumber;

  AbsoluteSemester({required int semesterNumber})
    : semesterNumber =
          (semesterNumber <= 0)
              ? throw ArgumentError('semesterNumber must be > 0')
              : semesterNumber;
}
