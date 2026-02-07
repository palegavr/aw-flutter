class DomainError implements Exception {
  final String message;

  DomainError(this.message);

  @override
  String toString() => message;
}
