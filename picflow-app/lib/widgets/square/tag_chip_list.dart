import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/artwork_service.dart';

class TagChipList extends StatefulWidget {
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;
  final ArtworkService? artworkService;

  const TagChipList({
    super.key,
    required this.selectedTag,
    required this.onTagSelected,
    this.artworkService,
  });

  @override
  State<TagChipList> createState() => _TagChipListState();
}

class _TagChipListState extends State<TagChipList> {
  List<String> _tags = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final service = widget.artworkService ?? ArtworkService();
    final tags = await service.getTags();
    if (mounted) {
      setState(() {
        _tags = tags;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _tags.isEmpty) {
      return const SizedBox(height: 36);
    }
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = _tags[index];
          final isSelected = widget.selectedTag == tag;
          return GestureDetector(
            onTap: () => widget.onTagSelected(isSelected ? null : tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.inversePrimary : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.inversePrimary : AppColors.onSurfaceVariant.withValues(alpha: 0.2),
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
        },
      ),
    );
  }
}