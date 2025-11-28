class Constants {
  static const String signedDecimalRegexPattern = r'^((-?\d+\.?\d*)|(-))$';
  static const String unsignedDecimalRegexPattern = r'^\d+\.?\d*$';
  static const String signedIntegerRegexPattern = r'^(-?\d+)|(-)$';
  static const String unsignedIntegerRegexPattern = r'^\d+$';

  static final RegExp signedDecimalRegex = RegExp(signedDecimalRegexPattern);
  static final RegExp unsignedDecimalRegex = RegExp(
    unsignedDecimalRegexPattern,
  );
  static final RegExp signedIntegerRegex = RegExp(signedIntegerRegexPattern);
  static final RegExp unsignedIntegerRegex = RegExp(
    unsignedIntegerRegexPattern,
  );

  static RegExp numericRegex(bool signed, bool decimal) {
    return switch ((signed, decimal)) {
      (true, true) => Constants.signedDecimalRegex, // signed && decimal
      (true, false) => Constants.signedIntegerRegex, // signed && !decimal
      (false, true) => Constants.unsignedDecimalRegex, // !signed && decimal
      (false, false) => Constants.unsignedIntegerRegex, // !signed && !decimal
    };
  }
}
