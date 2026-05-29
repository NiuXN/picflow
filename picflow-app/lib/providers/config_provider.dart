import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/frame_model.dart';
import '../models/filter_model.dart';
import '../services/config_service.dart';

final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

final frameConfigProvider = StateNotifierProvider<FrameConfigNotifier, FrameConfigState>((ref) {
  return FrameConfigNotifier(ref.read(configServiceProvider));
});

final filterConfigProvider = StateNotifierProvider<FilterConfigNotifier, FilterConfigState>((ref) {
  return FilterConfigNotifier(ref.read(configServiceProvider));
});

class FrameConfigState {
  final List<FrameModel> frames;
  final bool isLoading;

  const FrameConfigState({this.frames = const [], this.isLoading = false});

  FrameConfigState copyWith({List<FrameModel>? frames, bool? isLoading}) {
    return FrameConfigState(
      frames: frames ?? this.frames,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FrameConfigNotifier extends StateNotifier<FrameConfigState> {
  final ConfigService _service;

  FrameConfigNotifier(this._service) : super(FrameConfigState(frames: FrameModel.all)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final configs = await _service.getFrames();
      if (configs.isNotEmpty) {
        final frames = configs.map((c) {
          final type = FrameType.values.firstWhere(
            (t) => t.name == c.configKey,
            orElse: () => FrameType.minimal,
          );
          final isPro = c.valueJson['isPro'] as bool? ?? false;
          return FrameModel(
            type: type,
            label: c.label,
            subLabel: c.description ?? '',
            isPro: isPro,
          );
        }).toList();
        state = state.copyWith(frames: frames, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

class FilterConfigState {
  final List<FilterModel> filters;
  final bool isLoading;

  const FilterConfigState({this.filters = const [], this.isLoading = false});

  FilterConfigState copyWith({List<FilterModel>? filters, bool? isLoading}) {
    return FilterConfigState(
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FilterConfigNotifier extends StateNotifier<FilterConfigState> {
  final ConfigService _service;

  FilterConfigNotifier(this._service) : super(FilterConfigState(filters: FilterModel.presets)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final configs = await _service.getFilters();
      if (configs.isNotEmpty) {
        final filters = <FilterModel>[];
        for (final c in configs) {
          final type = FilterType.values.firstWhere(
            (t) => t.name == c.configKey,
            orElse: () => FilterType.none,
          );
          final matrixList = c.valueJson['matrix'] as List?;
          final matrix = matrixList?.map((e) => (e as num).toDouble()).toList() ?? FilterModel.findByType(type).matrix;
          filters.add(FilterModel(
            type: type,
            label: c.label,
            subLabel: c.description ?? '',
            matrix: matrix,
          ));
        }
        state = state.copyWith(filters: filters, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}
