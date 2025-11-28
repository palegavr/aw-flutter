enum LearningForm {
  daytime('Д'),
  evening('В'),
  correspondence('З');

  final String shortDisplayName;

  const LearningForm(this.shortDisplayName);

  static LearningForm fromShortDisplayName(String value) {
    return LearningForm.values.firstWhere(
      (element) => element.shortDisplayName == value,
      orElse: () => throw ArgumentError('Unknown LearningForm: $value'),
    );
  }
}
