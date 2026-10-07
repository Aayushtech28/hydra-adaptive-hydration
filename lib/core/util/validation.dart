/// Thrown by repositories/use-cases when user input is invalid. UI maps the
/// [code] to a localized message; the message is for logs only.
class ValidationException implements Exception {
  const ValidationException(this.code, [this.message = '']);
  final ValidationCode code;
  final String message;

  @override
  String toString() => 'ValidationException($code) $message';
}

enum ValidationCode {
  volumeInvalid,
  targetInvalid,
  timeInvalid,
  nameInvalid,
  notFound,
  limitReached,
}
