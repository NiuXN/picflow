import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/config_provider.dart';
import 'frame_card.dart';

class FrameList extends ConsumerWidget {
  const FrameList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(frameConfigProvider);
    final frames = state.frames;

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: frames.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return FrameCard(frame: frames[index]);
        },
      ),
    );
  }
}
