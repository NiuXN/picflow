import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

/// 通用 API 响应封装，对应后端 Result 格式
class ApiResponse<T> {
  final int code;          // 业务状态码：0成功
  final String message;    // 提示信息
  final T? data;           // 响应数据

  const ApiResponse({this.code = 0, this.message = 'success', this.data});
}

/// API 基础服务：封装 Dio 的 GET/POST/PUT/DELETE/Upload，含 JWT 认证拦截器
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _parseResponse(response.data, fromJson);
    } on DioException catch (e) {
      return ApiResponse(code: -1, message: e.message ?? 'Network error');
    }
  }

  Future<ApiResponse<T>> post<T>({
    required String path,
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _parseResponse(response.data, fromJson);
    } on DioException catch (e) {
      return ApiResponse(code: -1, message: e.message ?? 'Network error');
    }
  }

  Future<ApiResponse<T>> put<T>({
    required String path,
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _parseResponse(response.data, fromJson);
    } on DioException catch (e) {
      return ApiResponse(code: -1, message: e.message ?? 'Network error');
    }
  }

  Future<ApiResponse<T>> delete<T>({
    required String path,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.delete(path);
      return _parseResponse(response.data, fromJson);
    } on DioException catch (e) {
      return ApiResponse(code: -1, message: e.message ?? 'Network error');
    }
  }

  Future<ApiResponse<T>> upload<T>({
    required String path,
    required FormData formData,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return _parseResponse(response.data, fromJson);
    } on DioException catch (e) {
      return ApiResponse(code: -1, message: e.message ?? 'Upload failed');
    }
  }

  ApiResponse<T> _parseResponse<T>(
    dynamic responseData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = responseData is String
        ? json.decode(responseData) as Map<String, dynamic>
        : responseData as Map<String, dynamic>;

    return ApiResponse(
      code: data['code'] as int? ?? 0,
      message: data['message'] as String? ?? 'success',
      data: data['data'] != null ? fromJson(data['data'] as Map<String, dynamic>) : null,
    );
  }
}