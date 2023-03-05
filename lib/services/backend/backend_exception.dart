enum BackendExceptionType {
  // Error on http eg. 404, 401.
  // Socket Exception.
  networkIssue,

  // Error on server internal error http 500.
  internalError,

  // None of the above.
  unknown,
}

class BackendException implements Exception {
  BackendException({required this.type, required this.detail, this.response});

  final BackendExceptionType type;
  final String detail;
  final Map<String, dynamic>? response;

  @override
  String toString() => '$type : $detail';
}
