import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _devBaseUrl = 'http://localhost:8080/v1';
  static const String _prodBaseUrl = 'https://api.picflow.app/v1';

  static String get baseUrl => kReleaseMode ? _prodBaseUrl : _devBaseUrl;

  static const int pageSize = 20;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}