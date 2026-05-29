/// 图片模型，存储选中的图片路径和 EXIF 元数据
class ImageModel {
  final String? path;                      // 图片本地文件路径
  final String? name;                      // 图片文件名
  final String? date;                      // 拍摄日期（优先 EXIF，回退当前时间）
  final Map<String, String>? exifData;      // EXIF 元数据键值对
  final bool isLoaded;                     // 图片是否已加载到编辑器

  const ImageModel({
    this.path,
    this.name,
    this.date,
    this.exifData,
    this.isLoaded = false,
  });

  ImageModel copyWith({
    String? path,
    String? name,
    String? date,
    Map<String, String>? exifData,
    bool? isLoaded,
  }) {
    return ImageModel(
      path: path ?? this.path,
      name: name ?? this.name,
      date: date ?? this.date,
      exifData: exifData ?? this.exifData,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

}
