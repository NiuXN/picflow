import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';

/// 文件上传服务：上传图片到后端，返回 CDN URL
class UploadResult {
  final String url;
  final String? thumbnailUrl;

  const UploadResult({required this.url, this.thumbnailUrl});
}

class UploadService {
  final ApiService _api;

  UploadService({ApiService? api}) : _api = api ?? ApiService();

  Future<UploadResult?> uploadImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'artwork.jpg',
        ),
      });

      final response = await _api.upload<Map<String, dynamic>>(
        path: '/upload/image',
        formData: formData,
        fromJson: (data) => data,
      );

      if (response.data != null) {
        return UploadResult(
          url: response.data!['url'] as String,
          thumbnailUrl: response.data!['thumbnailUrl'] as String?,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}