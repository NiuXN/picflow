import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/artwork_model.dart';
import 'artwork_card.dart';

class ArtworkGrid extends StatelessWidget {
  final List<ArtworkModel> artworks;
  final ScrollController? scrollController;
  final bool hasMore;

  const ArtworkGrid({
    super.key,
    required this.artworks,
    this.scrollController,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (artworks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, size: 64, color: Color(0xFFD9D9D9)),
            const SizedBox(height: 12),
            Text(
              '暂无作品',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return MasonryGridView.count(
      controller: scrollController,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: artworks.length,
      itemBuilder: (context, index) {
        return ArtworkCard(artwork: artworks[index]);
      },
    );
  }
}