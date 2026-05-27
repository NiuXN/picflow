import 'package:flutter/material.dart';
import '../../../models/frame_model.dart';
import 'frame_card.dart';

class FrameList extends StatelessWidget {
  const FrameList({super.key});

  @override
  Widget build(BuildContext context) {
    final frames = FrameModel.all;

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
