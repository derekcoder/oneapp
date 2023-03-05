import 'backend_exception.dart';
import 'backend_query.dart';

class BaseApi {
  /// Sends http get query with the current user token.
  ///
  /// Returns an empty result if failed.
  Future<Map<String, dynamic>> userHttpGet(
    String endpoint, [
    Map<String, dynamic> parameters = const {},
  ]) async {
    return _callAndRetry(
      () => BackendQuery.httpGet(
        endpoint,
        parameters: parameters,
      ),
    );
  }

  /// Sends http post
  ///
  /// Returns an empty result if failed.
  Future<Map<String, dynamic>> userHttpPost(
    String endpoint, [
    Map<String, dynamic> parameters = const {},
  ]) async {
    return _callAndRetry(
      () => BackendQuery.httpPost(
        endpoint,
        parameters: parameters,
      ),
    );
  }

  /// Retries to make a call 3 times and refreshes the token if needed.
  Future<Map<String, dynamic>> _callAndRetry(
    Function() func, [
    int retries = 3,
  ]) async {
    try {
      return await func();
    } on BackendException catch (_) {
      if (retries > 1) {
        return _callAndRetry(func, retries - 1);
      }
      rethrow;
    }
  }
}
