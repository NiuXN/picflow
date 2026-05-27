import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/artwork_model.dart';
import '../services/artwork_service.dart';
import 'artwork_service_provider.dart';

final myArtworksProvider = StateNotifierProvider<MyArtworksNotifier, MyArtworksState>((ref) {
  return MyArtworksNotifier(ref.read(artworkServiceProvider));
});

class MyArtworksState {
  final List<ArtworkModel> artworks;
  final bool isLoading;

  const MyArtworksState({this.artworks = const [], this.isLoading = false});

  MyArtworksState copyWith({List<ArtworkModel>? artworks, bool? isLoading}) {
    return MyArtworksState(
      artworks: artworks ?? this.artworks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MyArtworksNotifier extends StateNotifier<MyArtworksState> {
  final ArtworkService _service;

  MyArtworksNotifier(this._service) : super(const MyArtworksState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final (artworks, _) = await _service.getArtworks(page: 1);
    state = state.copyWith(artworks: artworks, isLoading: false);
  }
}