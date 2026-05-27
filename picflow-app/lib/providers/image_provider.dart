import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/image_model.dart';

class ImageNotifier extends StateNotifier<ImageModel> {
  ImageNotifier() : super(const ImageModel());

  void setImage(String path, {String? name, Map<String, String>? exifData}) {
    state = ImageModel(
      path: path,
      name: name ?? '未命名',
      date: _formatDate(DateTime.now()),
      exifData: exifData,
      isLoaded: true,
    );
  }

  void clearImage() {
    state = const ImageModel();
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}

final imageProvider = StateNotifierProvider<ImageNotifier, ImageModel>((ref) {
  return ImageNotifier();
});
