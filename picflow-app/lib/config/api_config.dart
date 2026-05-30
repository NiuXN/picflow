import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConfig {
  ApiConfig._();

  static String get _devBaseUrl {
    if (kIsWeb) return 'http://localhost:8080/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/v1';
    return 'http://localhost:8080/v1';
  }
  static const String _prodBaseUrl = 'https://api.picflow.app/v1';

  static String get baseUrl => kReleaseMode ? _prodBaseUrl : _devBaseUrl;

  static const int pageSize = 20;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}