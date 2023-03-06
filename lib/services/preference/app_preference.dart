import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  factory AppPreference(SharedPreferences sharedPreferences) {
    return AppPreference._(sharedPreferences);
  }

  AppPreference._(this._prefs);

  final SharedPreferences _prefs;

  static const _keyApiKey = 'apiKey';
  String get apiKey => _prefs.getString(_keyApiKey) ?? '';
  set apiKey(String value) => _prefs.setString(_keyApiKey, value);
}
