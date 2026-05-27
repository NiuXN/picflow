import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/artwork_model.dart';
import '../../theme/app_colors.dart';


class ProfileArtworkGrid extends StatelessWidget {
  final List<ArtworkModel> artworks;

  const ProfileArtworkGrid({super.key, required this.artworks});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: artworks.length,
      itemBuilder: (context, index) {
        final artwork = artworks[index];
        return GestureDetector(
          onTap: () => context.push('/artwork/${artwork.id}'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              artwork.thumbnailUrl ?? artwork.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.background,
                child: const Icon(Icons.image, color: AppColors.onSurfaceVariant),
              ),
            ),
          ),
        );
      },
    );
  }
}