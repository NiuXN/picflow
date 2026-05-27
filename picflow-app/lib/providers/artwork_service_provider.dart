import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/artwork_service.dart';
import '../services/social_service.dart';
import '../services/upload_service.dart';

/// 作品服务 Provider
final artworkServiceProvider = Provider<ArtworkService>((ref) {
  return ArtworkService();
});

/// 社交互动服务 Provider
final socialServiceProvider = Provider<SocialService>((ref) {
  return SocialService();
});

/// 上传服务 Provider
final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService();
});