import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';

/// 文件上传服务：上传图片到后端，返回 CDN URL
class UploadService {
  final ApiService _api;

  UploadService({ApiService? api}) : _api = api ?? ApiService();

  Future<String?> uploadImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'artwork.jpg',
        ),
      });

      final response = await _api.upload<String>(
        path: '/upload/image',
        formData: formData,
        fromJson: (data) => data['url'] as String,
      );

      return response.data;
    } catch (e) {
      return null;
    }
  }
}