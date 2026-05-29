import 'package:flutter/material.dart';
import '../../models/comment_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CommentList extends StatelessWidget {
  final List<CommentModel> comments;

  const CommentList({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            '暂无评论，快来抢沙发吧',
            style: AppTypography.bodyRegular.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return _CommentItem(comment: comments[index]);
      },
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentModel comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.inversePrimary.withValues(alpha: 0.3),
            child: Text(
              (comment.author?.nickname?.isNotEmpty == true ? comment.author!.nickname![0] : (comment.author?.username?.isNotEmpty == true ? comment.author!.username![0] : 'U')).toUpperCase(),
              style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author?.nickname ?? '用户',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment.createdAt),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}