import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/artwork_service_provider.dart';
import '../services/upload_service.dart';
import '../utils/snackbar_utils.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PublishScreen extends ConsumerStatefulWidget {
  final String? imagePath;
  final String? frameType;
  final String? aspectRatio;
  final String? bgColor;
  final String? watermarkText;
  final String? filter;

  const PublishScreen({
    super.key,
    this.imagePath,
    this.frameType,
    this.aspectRatio,
    this.bgColor,
    this.watermarkText,
    this.filter,
  });

  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  final _filterLabels = <String, String>{
    'none': '原图', 'cream': '奶油', 'film': '胶片', 'mono': '黑白',
    'warm': '暖阳', 'cool': '冷调', 'retro': '复古',
  };
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedTags = [];
  List<String> _presetTags = [];
  bool _isPublishing = false;
  bool _tagsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final artworkService = ref.read(artworkServiceProvider);
    final tags = await artworkService.getTags();
    if (mounted) {
      setState(() {
        _presetTags = tags;
        _tagsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '发布作品',
          style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _isPublishing ? null : _handlePublish,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.inversePrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isPublishing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: AppColors.surfaceContainerLowest,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        '发布',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.surfaceContainerLowest,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 24),
            _buildTitleInput(),
            const SizedBox(height: 20),
            _buildDescriptionInput(),
            const SizedBox(height: 20),
            _buildTagSelector(),
            const SizedBox(height: 20),
            _buildMetaInfo(),
          ],
        ),
          ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: widget.imagePath != null
              ? Image.file(
                  File(widget.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_rounded, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            '从编辑页导出的作品',
            style: AppTypography.bodyRegular.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '作品标题',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          maxLength: 30,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: '给你的作品起个名字...',
            hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            counterStyle: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '作品描述',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          maxLength: 200,
          style: AppTypography.bodyRegular.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: '分享你的创作灵感和故事...',
            hintStyle: AppTypography.bodyRegular.copyWith(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            counterStyle: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '添加标签',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (_tagsLoading)
          const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(color: AppColors.inversePrimary),
          ))
        else if (_presetTags.isEmpty)
          Text('暂无标签', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant))
        else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    if (_selectedTags.length < 5) {
                      _selectedTags.add(tag);
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.inversePrimary : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.inversePrimary : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? AppColors.surfaceContainerLowest : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMetaInfo() {
    final hasMeta = widget.frameType != null ||
        widget.aspectRatio != null ||
        widget.bgColor != null ||
        widget.filter != null;

    if (!hasMeta) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '创作参数（自动带入）',
            style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.frameType != null) ...[
                _metaBadge('相框：${_frameName(widget.frameType!)}'),
                const SizedBox(width: 8),
              ],
              if (widget.aspectRatio != null) ...[
                _metaBadge(widget.aspectRatio!),
                const SizedBox(width: 8),
              ],
              if (widget.filter != null && widget.filter != 'none') ...[
                _metaBadge('滤镜：${_filterLabel(widget.filter)}'),
                const SizedBox(width: 8),
              ],
              if (widget.bgColor != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse('0xFF${widget.bgColor!.replaceFirst('#', '')}'),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.bgColor!,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.onSurface),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurface),
      ),
    );
  }

  String _filterLabel(String? filter) => _filterLabels[filter] ?? '原图';

  String _frameName(String type) {
    switch (type) {
      case 'exif':
        return 'EXIF参数';
      case 'polaroid':
        return '拍立得';
      case 'proFilm':
        return '专业底片';
      case 'circle':
        return '圆形取景';
      case 'minimal':
      default:
        return '极简留白';
    }
  }

  void _handlePublish() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入作品标题'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      UploadResult? uploadResult;
      if (widget.imagePath != null) {
        final uploadService = ref.read(uploadServiceProvider);
        uploadResult = await uploadService.uploadImage(File(widget.imagePath!));
      }

      if (widget.imagePath != null && uploadResult == null) {
        if (mounted) {
          AppSnackbar.error(context, '图片上传失败，请重试');
        }
        setState(() => _isPublishing = false);
        return;
      }

      final artworkService = ref.read(artworkServiceProvider);
      final success = await artworkService.publishArtwork({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'image_url': uploadResult?.url ?? widget.imagePath,
        'thumbnail_url': uploadResult?.thumbnailUrl,
        'tags': _selectedTags,
        'frame_type': widget.frameType,
        'aspect_ratio': widget.aspectRatio,
        'bg_color': widget.bgColor,
        'watermark_text': widget.watermarkText,
        'filter': widget.filter,
      });

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('发布成功！'),
            backgroundColor: AppColors.inversePrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('发布失败，请重试'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, '发布失败，请检查网络');
    } finally {
      setState(() => _isPublishing = false);
    }
  }
}