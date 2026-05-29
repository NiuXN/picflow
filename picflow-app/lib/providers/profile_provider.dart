import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.read(userServiceProvider));
});

class ProfileState {
  final UserModel? user;
  final UserStats? stats;
  final bool isLoading;
  final String? error;

  const ProfileState({this.user, this.stats, this.isLoading = false, this.error});

  ProfileState copyWith({UserModel? user, UserStats? stats, bool? isLoading, String? error}) {
    return ProfileState(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserService _service;

  ProfileNotifier(this._service) : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _service.getProfile(),
        _service.getUserStats(),
      ]);
      state = state.copyWith(
        user: results[0] as UserModel?,
        stats: results[1] as UserStats?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile({String? nickname, String? bio}) async {
    try {
      final user = await _service.updateProfile(nickname: nickname, bio: bio);
      if (user != null) {
        state = state.copyWith(user: user);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
