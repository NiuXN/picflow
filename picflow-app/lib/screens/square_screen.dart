import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/square_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/square/artwork_grid.dart';
import '../widgets/square/sort_filter_bar.dart';
import '../widgets/square/tag_chip_list.dart';

class SquareScreen extends ConsumerStatefulWidget {
  final Key? pageKey;

  const SquareScreen({super.key, this.pageKey});

  @override
  ConsumerState<SquareScreen> createState() => _SquareScreenState();
}

class _SquareScreenState extends ConsumerState<SquareScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(squareProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(squareProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '创作广场',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: AppColors.onSurface),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('搜索功能即将上线')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              TagChipList(
                selectedTag: state.selectedTag,
                onTagSelected: (tag) {
                  ref.read(squareProvider.notifier).selectTag(tag);
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SortFilterBar(
            currentSort: state.sort,
            onSortChanged: (sort) {
              ref.read(squareProvider.notifier).changeSort(sort);
            },
          ),
          Expanded(
            child: state.isLoading && state.artworks.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.inversePrimary))
                : RefreshIndicator(
                    onRefresh: () => ref.read(squareProvider.notifier).refresh(),
                    color: AppColors.inversePrimary,
                    child: ArtworkGrid(
                      artworks: state.artworks,
                      scrollController: _scrollController,
                      hasMore: state.hasMore,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}