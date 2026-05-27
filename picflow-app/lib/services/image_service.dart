import 'dart:io';
import 'package:exif/exif.dart';
import 'package:image_picker/image_picker.dart';
import '../models/image_model.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<ImageModel?> pickFromGallery() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return null;

    final exifData = await _readExif(xFile.path);

    return ImageModel(
      path: xFile.path,
      name: xFile.name,
      date: exifData?['DateTimeOriginal'] ?? _formatDate(DateTime.now()),
      isLoaded: true,
      exifData: exifData,
    );
  }

  Future<ImageModel?> pickFromCamera() async {
    final xFile = await _picker.pickImage(source: ImageSource.camera);
    if (xFile == null) return null;

    final exifData = await _readExif(xFile.path);

    return ImageModel(
      path: xFile.path,
      name: xFile.name,
      date: exifData?['DateTimeOriginal'] ?? _formatDate(DateTime.now()),
      isLoaded: true,
      exifData: exifData,
    );
  }

  Future<Map<String, String>?> _readExif(String filePath) async {
    try {
      final tags = await readExifFromFile(File(filePath));
      if (tags.isEmpty) return null;

      final result = <String, String>{};
      for (final entry in tags.entries) {
        result[entry.key] = entry.value.toString();
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}
