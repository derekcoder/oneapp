enum BackendExceptionType {
  // Error on http eg. 404.
  // Socket Exception.
  networkIssue,

  // Error on http 401.
  unauthorized,

  // Error on server internal error http 500.
  internalError,

  // None of the above.
  unknown,
}

class BackendException implements Exception {
  BackendException({
    required this.type,
    required this.detail,
  });

  BackendException.statusCode(
    int statusCode,
    this.detail,
  ) : type = _statusCodeToType[statusCode] ?? BackendExceptionType.networkIssue;

  final BackendExceptionType type;
  final String detail;

  static const _statusCodeToType = <int, BackendExceptionType>{
    401: BackendExceptionType.unauthorized,
    500: BackendExceptionType.internalError,
  };

  @override
  String toString() => '$type : $detail';
}
