import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'backend_exception.dart';

class HttpHeaders {
  static const accountKey = 'AccountKey';
  static const authorizationKey = 'Authorization';
}

const _accountKeyCredential = 'D3JfbERPSWiI+dp06Bh8nQ==';

class BackendQuery {
  static Uri generateApiUri(String endpoint, Map<String, dynamic> parameters) {
    return Uri.https('api.openai.com', endpoint, parameters);
  }

  /// Throws an exception if the response contains error.
  ///
  /// For example 404 not found (offline).
  static void _validateHttpResponse(http.Response response) {
    if (response.statusCode != 200) {
      print('http error ${response.statusCode}');

      throw BackendException(
        type: (response.statusCode == 500)
            ? BackendExceptionType.internalError
            : BackendExceptionType.networkIssue,
        detail: 'http status : ${response.statusCode}',
      );
    }
  }

  /// Decodes the json data payload from response body.
  static Map<String, dynamic> _decodeResponse(String source) {
    final json = jsonDecode(source);
    return json;
  }

  /// Backend query using http get method.
  ///
  /// Returns a json value map of backend response.
  /// Throws [BackendException], if the json contains error status.
  static Future<Map<String, dynamic>> httpGet(
    String endpoint, {
    Map<String, dynamic> parameters = const {},
    Map<String, dynamic>? additionalHeaders,
  }) async {
    try {
      // http://datamall2.mytransport.sg/ltaodataservice/BusStops
      final response = await http.get(
        generateApiUri(endpoint, parameters),
        headers: {
          HttpHeaders.accountKey: _accountKeyCredential,
          ...?additionalHeaders,
        },
      );
      _validateHttpResponse(response);
      return _decodeResponse(response.body);
    } on SocketException catch (e) {
      throw BackendException(
        type: BackendExceptionType.networkIssue,
        detail: '$e',
      );
    }
  }

  /// Backend query using http post method.
  ///
  /// Returns a json value map of backend response.
  /// Throws [BackendException], if the json contains error status.
  static Future<Map<String, dynamic>> httpPost(
    String endpoint, {
    Map<String, dynamic> parameters = const {},
    Map<String, dynamic>? additionalHeaders,
  }) async {
    try {
      // http://datamall2.mytransport.sg/ltaodataservice/BusStops
      final response = await http.post(
        generateApiUri(endpoint, parameters),
        headers: {
          HttpHeaders.authorizationKey:
              'Bearer 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',
          ...?additionalHeaders,
        },
        body: jsonEncode(parameters),
      );
      _validateHttpResponse(response);
      return _decodeResponse(response.body);
    } on SocketException catch (e) {
      throw BackendException(
        type: BackendExceptionType.networkIssue,
        detail: '$e',
      );
    }
  }
}
