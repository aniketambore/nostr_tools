class SignatureVerificationException implements Exception {
  final String message;

  SignatureVerificationException(this.message);

  @override
  String toString() => 'SignatureVerificationException: $message';
}

class ChecksumVerificationException implements Exception {
  final String message;
  ChecksumVerificationException(this.message);

  @override
  String toString() => 'ChecksumVerificationException: $message';
}
