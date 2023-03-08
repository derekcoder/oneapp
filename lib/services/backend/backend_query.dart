import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'backend_exception.dart';

class HttpHeaders {
  static const authorizationKey = 'Authorization';
  static const acceptKey = 'Accept';
  static const contentTypeKey = 'Content-Type';
  static const acceptLanguageKey = 'Accept-Language';
}

class HttpHeaderValues {
  static const appJson = 'application/json';
}

class BackendQuery {
  static Uri generateApiUri(String endpoint,
      [Map<String, dynamic>? parameters]) {
    return Uri.https('api.openai.com', endpoint, parameters);
  }

  /// Throws an exception if the response contains error.
  ///
  /// For example 404 not found (offline).
  static void _validateHttpResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw BackendException.statusCode(
        response.statusCode,
        'http status : ${response.statusCode}',
      );
    }
  }

  /// Decodes the json data payload from response body.
  static Map<String, dynamic> _decodeResponse(String source) {
    final json = jsonDecode(source);
    return json;
  }

  /// Backend query using http post method.
  ///
  /// Returns a json value map of backend response.
  /// Throws [BackendException], if the json contains error status.
  static Future<Map<String, dynamic>> httpPost(
    String endpoint, {
    required String apiKey,
    Map<String, dynamic> parameters = const {},
    Map<String, dynamic>? additionalHeaders,
  }) async {
    try {
      final response = await http.post(
        generateApiUri(endpoint),
        headers: {
          HttpHeaders.authorizationKey: 'Bearer $apiKey',
          HttpHeaders.acceptKey: HttpHeaderValues.appJson,
          HttpHeaders.contentTypeKey: HttpHeaderValues.appJson,
          HttpHeaders.acceptLanguageKey: 'en-SG,en-GB;q=0.9,en;q=0.8',
          ...?additionalHeaders,
        },
        body: jsonEncode(parameters),
      );
      _validateHttpResponse(response);
      final decodedString = const Utf8Decoder().convert(response.bodyBytes);
      return _decodeResponse(decodedString);
    } on SocketException catch (e) {
      throw BackendException(
        type: BackendExceptionType.networkIssue,
        detail: '$e',
      );
    }
  }
}
