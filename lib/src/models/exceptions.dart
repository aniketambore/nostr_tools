class SignatureVerificationException implements Exception {
  final String message;

  SignatureVerificationException(this.message);

  @override
  String toString() => 'SignatureVerificationException: $message';
}
